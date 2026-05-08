using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace LcLGame
{
    public class ChromaticDistortionPass : ScriptableRenderPass
    {
        static readonly ProfilingSampler k_ProfilingSampler  = new ProfilingSampler("Chromatic Distortion");
        const string k_ShaderName = "Hidden/LcLPostProcess/ChromaticDistortion";

        static readonly int k_MainTexID             = Shader.PropertyToID("_MainTex");
        static readonly int k_AberrationStrengthID  = Shader.PropertyToID("_AberrationStrength");
        static readonly int k_DistortionStrengthID  = Shader.PropertyToID("_DistortionStrength");
        static readonly int k_DistortionFrequencyID = Shader.PropertyToID("_DistortionFrequency");
        static readonly int k_DistortionSpeedID     = Shader.PropertyToID("_DistortionSpeed");
        static readonly int k_VignetteStrengthID    = Shader.PropertyToID("_VignetteStrength");
        static readonly int k_PoisonTintID          = Shader.PropertyToID("_PoisonTint");

        Material m_Material;
        ChromaticDistortionSettings m_Settings;

        RenderTargetHandle m_TempRT;

        public ChromaticDistortionPass(ChromaticDistortionSettings settings)
        {
            m_Settings = settings;
            m_Material = CoreUtils.CreateEngineMaterial(k_ShaderName);
            m_TempRT.Init("_ChromaticDistortionTemp");
        }

        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            var desc = cameraTextureDescriptor;
            desc.msaaSamples = 1;
            cmd.GetTemporaryRT(m_TempRT.id, desc);
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (m_Material == null || m_Settings == null) return;

            var camera = renderingData.cameraData.camera;

            // 跳过预览相机
            if (camera.cameraType == CameraType.Preview)
                return;

            // 渲染到 RenderTexture 的相机（如平面反射相机）跳过，只对渲染到屏幕的相机生效
            if (camera.targetTexture != null)
                return;

            var renderer = renderingData.cameraData.renderer;
            var source   = renderer.cameraColorTarget;

            var cmd = CommandBufferPool.Get();
            using (new ProfilingScope(cmd, k_ProfilingSampler))
            {
                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();

                // 手动把 source 绑到 _MainTex（与 GaussianBlur 保持一致）
                cmd.SetGlobalTexture(k_MainTexID, source);

                // 设置效果参数
                cmd.SetGlobalFloat(k_AberrationStrengthID,  m_Settings.aberrationStrength);
                cmd.SetGlobalFloat(k_DistortionStrengthID,  m_Settings.distortionStrength);
                cmd.SetGlobalFloat(k_DistortionFrequencyID, m_Settings.distortionFrequency);
                cmd.SetGlobalFloat(k_DistortionSpeedID,     m_Settings.distortionSpeed);
                cmd.SetGlobalFloat(k_VignetteStrengthID,    m_Settings.vignetteStrength);
                cmd.SetGlobalFloat(k_PoisonTintID,          m_Settings.poisonTint);

                // source -> temp (应用效果) -> source
                Blit(cmd, source, m_TempRT.Identifier(), m_Material, 0);
                Blit(cmd, m_TempRT.Identifier(), source);
            }

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            cmd.ReleaseTemporaryRT(m_TempRT.id);
        }

        public void Dispose()
        {
            CoreUtils.Destroy(m_Material);
        }
    }
}
