using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Experimental.Rendering;
using System.Collections.Generic;

namespace LcLGame
{
    public class VolumetricLightFeature : RendererFeatureBase
    {

        [System.Serializable]
        public class VolumetricLightSetting
        {
            public RenderTextureResolution size = RenderTextureResolution._256;
            [Range(0.0f, 2.0f)]
            public float exposure = 1f;
            public Color color = Color.white;

            [Range(0.0f, 1.0f)]
            public float lightingRadius = 1.0f;

            [Range(0.0f, 1.0f)]
            public float blurWidth = 0.25f;

            [Range(0.5f, 1.0f)]
            public float decay = 0.95f;
            [Range(1.0f, 3.0f)]
            public int iterations = 1;
        }

        public VolumetricLightSetting settings = new VolumetricLightSetting();
        private VolumetricLightRenderPass m_RenderPass;

        public override void Create()
        {
            m_RenderPass = new VolumetricLightRenderPass(name, settings)
            {
                renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing
            };
        }

        public override void AddRenderPasses(ScriptableRenderer renderer)
        {
            renderer.EnqueuePass(m_RenderPass);
        }

        public override void Dispose()
        {
            m_RenderPass?.Dispose();
        }


        public class VolumetricLightRenderPass : ScriptableRenderPass
        {
            readonly GraphicsFormat m_DefaultHDRFormat;

            int m_TempRT1 = Shader.PropertyToID("_TempRT1");
            int m_TempRT2 = Shader.PropertyToID("_TempRT2");
            readonly int m_VolumetricLightTextureID = Shader.PropertyToID("_VolumetricLightingTex");
            readonly int m_VolumetricLightParamsID = Shader.PropertyToID("_VolumetricLightParams");
            readonly int m_LightingColorID = Shader.PropertyToID("_LightingColor");
            readonly int m_ScreenLightPosID = Shader.PropertyToID("_ScreenLightPos");


            VolumetricLightSetting m_Settings;
            string m_ProfilerTag;
            RenderTextureDescriptor m_Descriptor;
            Material m_Material;

            Material Material
            {
                get
                {
                    if (m_Material == null)
                    {
                        m_Material = CoreUtils.CreateEngineMaterial("LcL/PostProcess/VolumetricLight");
                    }
                    return m_Material;
                }
            }
            public VolumetricLightRenderPass(string tag, VolumetricLightSetting settings)
            {
                m_ProfilerTag = tag;
                m_Settings = settings;
                m_DefaultHDRFormat = QualitySettings.activeColorSpace == ColorSpace.Linear ? GraphicsFormat.R8G8B8A8_SRGB : GraphicsFormat.R8G8B8A8_UNorm;
            }
            public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
            {
                RenderTextureDescriptor cameraTextureDescriptor = renderingData.cameraData.cameraTargetDescriptor;
                m_Descriptor = cameraTextureDescriptor;
            }

            public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
            {
                if (Material == null)
                {
                    return;
                }
                var cameraData = renderingData.cameraData;
                var camera = cameraData.camera;
                CommandBuffer cmd = CommandBufferPool.Get(m_ProfilerTag);
                var source = renderingData.cameraData.renderer.cameraColorTarget;
                // var width = m_Descriptor.width >> settings.downSample;
                // var height = m_Descriptor.height >> settings.downSample;

                var size = (int)m_Settings.size;

                using (new ProfilingScope(cmd, new ProfilingSampler("VolumetricLight")))
                {
                    var data = VolumetricLightData.Instance.Data;
                    foreach (var item in data)
                    {
                        if (item.TryGetViewPosition(camera, out var pos))
                        {
                            var desc = LcLRenderingUtils.GetCompatibleDescriptor(m_Descriptor, size, size, m_DefaultHDRFormat);

                            cmd.GetTemporaryRT(m_TempRT1, desc, FilterMode.Bilinear);
                            cmd.GetTemporaryRT(m_TempRT2, desc, FilterMode.Bilinear);

                            cmd.SetGlobalVector(m_ScreenLightPosID, new Vector4(pos.x, pos.y, 0, 0));
                            cmd.SetGlobalVector(m_LightingColorID, m_Settings.color * item.lightingColor);
                            cmd.SetGlobalVector(m_VolumetricLightParamsID, new Vector4(m_Settings.exposure, m_Settings.lightingRadius, m_Settings.blurWidth, m_Settings.decay));

                            Blit(cmd, source, m_TempRT1, Material, 0);

                            for (int i = 0; i < m_Settings.iterations; i++)
                            {
                                Blit(cmd, m_TempRT1, m_TempRT2, Material, 1);
                                var temp = m_TempRT1;
                                m_TempRT1 = m_TempRT2;
                                m_TempRT2 = temp;
                            }

                            cmd.SetGlobalTexture(m_VolumetricLightTextureID, m_TempRT1);

                            Blit(cmd, ref renderingData, Material, 2);
                        }
                    }
                }

                context.ExecuteCommandBuffer(cmd);
                CommandBufferPool.Release(cmd);
            }

            public override void FrameCleanup(CommandBuffer cmd)
            {
                cmd.ReleaseTemporaryRT(m_TempRT1);
                cmd.ReleaseTemporaryRT(m_TempRT2);
                cmd.ReleaseTemporaryRT(m_VolumetricLightTextureID);
            }

            public void Dispose()
            {
                CoreUtils.Destroy(Material);
            }
        }
    }
}

