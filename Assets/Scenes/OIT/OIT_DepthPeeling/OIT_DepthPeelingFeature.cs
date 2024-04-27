using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace LcLGame
{
    public class OIT_DepthPeelingFeature : ScriptableRendererFeature
    {
        [System.Serializable]
        public class Settings
        {
            [Range(1, 16)] public int DepthPeelingPass = 4;
        }

        public Settings settings = new Settings();
        DepthPeelingRenderPass m_ScriptablePass;

        public override void Create()
        {
            m_ScriptablePass = new DepthPeelingRenderPass(settings)
            {
                renderPassEvent = RenderPassEvent.BeforeRenderingTransparents
            };
        }

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            renderer.EnqueuePass(m_ScriptablePass);
        }

        class DepthPeelingRenderPass : ScriptableRenderPass
        {
            ProfilingSampler m_ProfilingSampler = new ProfilingSampler("OIT DepthPeeling");
            FilteringSettings m_FilteringSettings;

            static readonly ShaderTagId depthPeelingFirstID = new ShaderTagId("DepthPeelingTransparentFirst");
            static readonly ShaderTagId depthPeelingID = new ShaderTagId("DepthPeelingTransparent");

            Settings m_Settings;
            Material m_Material;
            int[] colorRTs;
            int[] depthRTs;


            public DepthPeelingRenderPass(Settings settings)
            {
                m_Settings = settings;
                m_Material = CoreUtils.CreateEngineMaterial("LcL/OIT/DepthPeelingTransparent");
                m_FilteringSettings = new FilteringSettings(RenderQueueRange.transparent);
                colorRTs = new int[m_Settings.DepthPeelingPass];
                depthRTs = new int[m_Settings.DepthPeelingPass];
            }


            public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
            {
                // Create RT
                // cmd.GetTemporaryRT(m_TempTextureHandle.id, cameraTextureDescriptor);
                var depthDesc = cameraTextureDescriptor;
                depthDesc.colorFormat = RenderTextureFormat.RFloat;
                depthDesc.depthBufferBits = 32;

                var colorDesc = cameraTextureDescriptor;
                colorDesc.colorFormat = RenderTextureFormat.ARGB32;
                colorDesc.depthBufferBits = 0;


                for (int i = 0; i < m_Settings.DepthPeelingPass; i++)
                {
                    colorRTs[i] = Shader.PropertyToID($"_DepthPeelingColor{i}");
                    depthRTs[i] = Shader.PropertyToID($"_DepthPeelingDepth{i}");
                    cmd.GetTemporaryRT(colorRTs[i], colorDesc);
                    cmd.GetTemporaryRT(depthRTs[i], depthDesc);
                }
            }

            public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
            {
            }

            public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
            {
                ref CameraData cameraData = ref renderingData.cameraData;
                var renderer = cameraData.renderer;
                var camera = cameraData.camera;
                var source = renderer.cameraColorTarget;
                var sourceDepth = renderer.cameraDepthTarget;
                var drawingSettings =
                    CreateDrawingSettings(depthPeelingFirstID, ref renderingData, SortingCriteria.CommonTransparent);
                var cmd = CommandBufferPool.Get();

                using (new ProfilingScope(cmd, m_ProfilingSampler))
                {
                    context.ExecuteCommandBuffer(cmd);
                    cmd.Clear();

                    // Depth peeling
                    for (int i = 0; i < m_Settings.DepthPeelingPass; i++)
                    {
                        if (i == 0)
                        {
                            drawingSettings.SetShaderPassName(0, depthPeelingFirstID);
                        }
                        else
                        {
                            cmd.SetGlobalTexture("_PrevCameraDepthTexture", depthRTs[i - 1]);
                            drawingSettings.SetShaderPassName(0, depthPeelingID);
                        }

                        cmd.SetRenderTarget(new RenderTargetIdentifier[] { colorRTs[i], depthRTs[i] }, depthRTs[i]);
                        cmd.ClearRenderTarget(true, true, Color.clear);
                        context.ExecuteCommandBuffer(cmd);
                        cmd.Clear();

                        context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref m_FilteringSettings);
                    }

                    // Combine all the color textures
                    cmd.SetRenderTarget(source, sourceDepth);
                    for (var i = m_Settings.DepthPeelingPass - 1; i >= 0; i--)
                    {
                        cmd.SetGlobalTexture("_DepthTexture", i == 0 ? depthRTs[0] : Texture2D.blackTexture);
                        cmd.Blit(colorRTs[i], source, m_Material, 2);
                    }
                }

                context.ExecuteCommandBuffer(cmd);
                CommandBufferPool.Release(cmd);
            }

            public override void OnCameraCleanup(CommandBuffer cmd)
            {
                for (int i = 0; i < m_Settings.DepthPeelingPass; i++)
                {
                    cmd.ReleaseTemporaryRT(colorRTs[i]);
                    cmd.ReleaseTemporaryRT(depthRTs[i]);
                }
            }
        }
    }
}
