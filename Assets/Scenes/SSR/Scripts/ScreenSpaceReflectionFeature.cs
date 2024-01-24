using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace LcLGame
{
    public class ScreenSpaceReflectionFeature : ScriptableRendererFeature
    {
        [System.Serializable]
        public class ReflectionSettings
        {
            [Range(0, 3)] public int downSample = 1;

            [Range(0, 0.5f)] public float stepSize = 0.02f;

            [Range(0, 300)] public int maxStep = 50;

            // [Range(0, 100)]
            // public float MaxDistance = 100;
            [Range(0, 0.2f)] public float thickness = 0.01f;
            [Range(0, 0.3f)] public float noiseIntensity = 0f;
        }

        public ReflectionSettings settings = new ReflectionSettings();
        ReflectionPass m_ReflectionPass;

        public override void Create()
        {
            m_ReflectionPass = new ReflectionPass(settings)
            {
                renderPassEvent = RenderPassEvent.BeforeRenderingTransparents
            };
        }

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            renderer.EnqueuePass(m_ReflectionPass);
        }

        class ReflectionPass : ScriptableRenderPass
        {
            const string SHADER_NAME = "Hidden/ScreenSpaceReflection";
            Material m_Material = null;
            RenderTargetHandle m_MainTexID;
            RenderTextureDescriptor m_Descriptor;
            public ReflectionSettings settings;

            public void Setup()
            {
            }

            public ReflectionPass(ReflectionSettings settings)
            {
                this.settings = settings;
                m_Material = CoreUtils.CreateEngineMaterial(SHADER_NAME);
                m_MainTexID.Init("_ScreenSpaceReflectionTexture");
            }


            public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
            {
                m_Descriptor = cameraTextureDescriptor;
                m_Descriptor.msaaSamples = 1;
                m_Descriptor.width = m_Descriptor.width >> settings.downSample;
                m_Descriptor.height = m_Descriptor.height >> settings.downSample;
                cmd.GetTemporaryRT(m_MainTexID.id, m_Descriptor, FilterMode.Bilinear);
                ConfigureTarget(m_MainTexID.Identifier());
                // ConfigureClear(ClearFlag.All, Color.black);
            }

            public static readonly ShaderTagId litShaderTagID = new ShaderTagId("SSRLit");

            public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
            {
                CommandBuffer cmd = CommandBufferPool.Get();
                var renderer = renderingData.cameraData.renderer;
                var source = renderer.cameraColorTarget;

                using (new ProfilingScope(cmd, new ProfilingSampler("SSR")))
                {
                    context.ExecuteCommandBuffer(cmd);
                    cmd.Clear();

                    m_Material.SetInteger("_MaxStep", settings.maxStep);
                    m_Material.SetFloat("_StepSize", settings.stepSize);
                    // m_Material.SetFloat("_MaxDistance", settings.MaxDistance);
                    m_Material.SetFloat("_Thickness", settings.thickness);
                    m_Material.SetFloat("_NoiseIntensity", settings.noiseIntensity);

                    cmd.Blit(source, m_MainTexID.Identifier(), m_Material, 0);
                    cmd.SetGlobalTexture(m_MainTexID.id, m_MainTexID.Identifier());
                }

                context.ExecuteCommandBuffer(cmd);
                CommandBufferPool.Release(cmd);
            }

            public override void FrameCleanup(CommandBuffer cmd)
            {
                cmd.ReleaseTemporaryRT(m_MainTexID.id);
            }
        }
    }
}
