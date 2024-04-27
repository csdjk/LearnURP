using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace LcLGame
{
    public class OIT_WeightedBlendFeature : ScriptableRendererFeature
    {
        [System.Serializable]
        public class Settings
        {
        }

        public Settings settings = new Settings();
        WeightedBlendRenderPass m_ScriptablePass;

        public override void Create()
        {
            m_ScriptablePass = new WeightedBlendRenderPass(settings)
            {
                renderPassEvent = RenderPassEvent.BeforeRenderingTransparents
            };
        }

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            renderer.EnqueuePass(m_ScriptablePass);
        }

        class WeightedBlendRenderPass : ScriptableRenderPass
        {
            ProfilingSampler m_ProfilingSampler = new ProfilingSampler("OIT Weighted Blend");
            FilteringSettings m_FilteringSettings;

            static readonly ShaderTagId weightedBlendID = new ShaderTagId("WeightedBlendTransparent");
            static readonly ShaderTagId depthPeelingID = new ShaderTagId("DepthPeelingTransparent");

            static readonly int m_AccumTextureID = Shader.PropertyToID("_AccumTexture");
            static readonly int m_RevealageTextureID = Shader.PropertyToID("_RevealageTexture");

            Settings m_Settings;
            Material m_Material;
            RenderTargetHandle m_AccumTextureHandle;
            RenderTargetHandle m_RevealageTextureHandle;

            private RenderTargetIdentifier[] m_Buffers = new RenderTargetIdentifier[2];

            public WeightedBlendRenderPass(Settings settings)
            {
                m_Settings = settings;
                m_Material = CoreUtils.CreateEngineMaterial("Hidden/OIT/WeightedBlend");
                m_FilteringSettings = new FilteringSettings(RenderQueueRange.transparent);
                m_AccumTextureHandle.Init("_AccumTexture");
                m_RevealageTextureHandle.Init("_RevealageTexture");

                m_Buffers[0] = m_AccumTextureHandle.Identifier();
                m_Buffers[1] = m_RevealageTextureHandle.Identifier();
            }


            public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
            {
                var accumTexDesc = cameraTextureDescriptor;
                // accumTexDesc.colorFormat = RenderTextureFormat.ARGB64;
                accumTexDesc.graphicsFormat = GraphicsFormat.R16G16B16A16_SFloat;
                accumTexDesc.depthBufferBits = 0;
                accumTexDesc.msaaSamples = 1;
                // accumTexDesc.sRGB = false;
                cmd.GetTemporaryRT(m_AccumTextureHandle.id, accumTexDesc, FilterMode.Bilinear);

                var revealageTexDesc = cameraTextureDescriptor;
                // revealageTexDesc.colorFormat = RenderTextureFormat.R16;
                revealageTexDesc.graphicsFormat = GraphicsFormat.R16_SFloat;
                revealageTexDesc.depthBufferBits = 0;
                revealageTexDesc.msaaSamples = 1;
                // revealageTexDesc.sRGB = false;

                cmd.GetTemporaryRT(m_RevealageTextureHandle.id, revealageTexDesc, FilterMode.Bilinear);
            }

            public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
            {
                cmd.SetRenderTarget(m_AccumTextureHandle.Identifier());
                cmd.ClearRenderTarget(false, true, Color.clear);

                cmd.SetRenderTarget(m_RevealageTextureHandle.Identifier());
                cmd.ClearRenderTarget(false, true, Color.white);

                this.ConfigureTarget(m_Buffers, renderingData.cameraData.renderer.cameraDepthTarget);
            }



            public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
            {
                ref CameraData cameraData = ref renderingData.cameraData;
                var renderer = cameraData.renderer;
                var camera = cameraData.camera;
                var source = renderer.cameraColorTarget;
                var sourceDepth = renderer.cameraDepthTarget;
                var drawingSettings =
                    CreateDrawingSettings(weightedBlendID, ref renderingData, SortingCriteria.CommonTransparent);
                var cmd = CommandBufferPool.Get();

                using (new ProfilingScope(cmd, m_ProfilingSampler))
                {
                    context.ExecuteCommandBuffer(cmd);
                    cmd.Clear();

                    //Accumulate
                    // cmd.SetRenderTarget(m_Buffers, sourceDepth);
                    // cmd.ClearRenderTarget(true, true, Color.clear);
                    // context.ExecuteCommandBuffer(cmd);
                    // cmd.Clear();
                    context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref m_FilteringSettings);


                    //Blend
                    cmd.SetGlobalTexture(m_AccumTextureID, m_AccumTextureHandle.Identifier());
                    cmd.SetGlobalTexture(m_RevealageTextureID, m_RevealageTextureHandle.Identifier());
                    Blit(cmd, ref renderingData, m_Material);
                    // Blit(cmd, m_AccumTextureHandle.id, source, m_Material, 0);
                }

                context.ExecuteCommandBuffer(cmd);
                CommandBufferPool.Release(cmd);
            }

            public override void OnCameraCleanup(CommandBuffer cmd)
            {
                cmd.ReleaseTemporaryRT(m_AccumTextureHandle.id);
                cmd.ReleaseTemporaryRT(m_RevealageTextureHandle.id);
            }
        }
    }
}
