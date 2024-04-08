using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace LcLGame
{
    public enum BilateralFilterType
    {
        BaseColor,
        BaseNormal,
        BaseDepth,
        NormalDepth
    }
    [System.Serializable]
    public class BilateralFilterBlurSettings
    {
        public BilateralFilterType bilateralFilterType = BilateralFilterType.BaseColor;

        [Range(0.0f, 1.0f)]
        public float bilateralFilterFactor = 0.8f;
        [Range(0.2f, 10.0f)]
        public float blurRadius = 1.0f;

        [Range(0, 4)]
        public int downSample = 0;
        [Range(1, 4)]
        public int iteration = 1;
    }

    /// <summary>
    /// 双边滤波
    /// </summary>
    public class BilateralFilterRendererPass : ScriptableRenderPass, IBlurPass
    {
        ProfilingSampler m_ProfilingSampler = new ProfilingSampler("Bilateral Filter Blur");
        string m_ShaderName = "Hidden/LcLPostProcess/BilateralFilterBlur";
        Material m_Material;
        BilateralFilterBlurSettings m_Settings;

        RenderTextureDescriptor m_Descriptor;
        RenderTargetHandle m_TempTextureHandle1;
        RenderTargetHandle m_TempTextureHandle2;

        RenderTargetIdentifier m_RenderTarget;

        static readonly int m_OffsetID = Shader.PropertyToID("_Offset");
        static readonly int m_BilateralFilterFactorID = Shader.PropertyToID("_BilateralFilterFactor");
        int m_ShaderPass = 0;

        public BilateralFilterRendererPass(BilateralFilterBlurSettings settings)
        {
            m_Settings = settings;
            m_Material = CoreUtils.CreateEngineMaterial(m_ShaderName);
            m_TempTextureHandle1.Init("TempTexture");
            m_TempTextureHandle2.Init("TempTexture2");
        }


        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            m_Descriptor = cameraTextureDescriptor;
            m_Descriptor.msaaSamples = 1;
            m_Descriptor.width = m_Descriptor.width >> m_Settings.downSample;
            m_Descriptor.height = m_Descriptor.height >> m_Settings.downSample;

            // Create RT
            cmd.GetTemporaryRT(m_TempTextureHandle1.id, m_Descriptor);
            cmd.GetTemporaryRT(m_TempTextureHandle2.id, m_Descriptor);

            if (m_Settings.bilateralFilterType == BilateralFilterType.BaseColor)
            {
                m_ShaderPass = 0;
            }
            else if (m_Settings.bilateralFilterType == BilateralFilterType.BaseNormal)
            {
                m_ShaderPass = 1;
                ConfigureInput(ScriptableRenderPassInput.Normal);
            }
            else if (m_Settings.bilateralFilterType == BilateralFilterType.BaseDepth)
            {
                m_ShaderPass = 2;
                ConfigureInput(ScriptableRenderPassInput.Depth);
            }
            else if (m_Settings.bilateralFilterType == BilateralFilterType.NormalDepth)
            {
                m_ShaderPass = 3;
                ConfigureInput(ScriptableRenderPassInput.Normal | ScriptableRenderPassInput.Depth);
            }
        }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
        }

        public void SetRenderTarget(RenderTargetIdentifier renderTarget)
        {
            m_RenderTarget = renderTarget;
        }

        CommandBuffer m_CommandBuffer;
        public void Execute(ScriptableRenderContext context, ref RenderingData renderingData, CommandBuffer cmd)
        {
            m_CommandBuffer = cmd;
            Execute(context, ref renderingData);
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (m_Material == null)
                return;

            ref CameraData cameraData = ref renderingData.cameraData;
            var renderer = cameraData.renderer;
            var camera = cameraData.camera;

            var cmd = m_CommandBuffer ?? CommandBufferPool.Get();
            var source = m_CommandBuffer == null ? renderer.cameraColorTarget : m_RenderTarget;


            var rt1 = m_TempTextureHandle1.id;
            var rt2 = m_TempTextureHandle2.id;
            var rt = source;



            using (new ProfilingScope(cmd, m_ProfilingSampler))
            {
                if (m_CommandBuffer == null)
                {
                    context.ExecuteCommandBuffer(cmd);
                    cmd.Clear();
                }

                int iteration = m_Settings.iteration;
                for (int i = 0; i < iteration; i++)
                {
                    cmd.SetGlobalFloat(m_BilateralFilterFactorID, m_Settings.bilateralFilterFactor);
                    cmd.SetGlobalVector(m_OffsetID, new Vector4(0, m_Settings.blurRadius, 0, 0));

                    Blit(cmd, rt, rt2, m_Material, m_ShaderPass);

                    cmd.SetGlobalVector(m_OffsetID, new Vector4(m_Settings.blurRadius, 0, 0, 0));
                    if (i == iteration - 1)
                    {
                        Blit(cmd, rt2, source, m_Material, m_ShaderPass);
                    }
                    else
                    {

                        Blit(cmd, rt2, rt1, m_Material, m_ShaderPass);
                    }
                    rt = rt1;
                }
            }
            if (m_CommandBuffer == null)
            {
                context.ExecuteCommandBuffer(cmd);
                CommandBufferPool.Release(cmd);
            }
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            cmd.ReleaseTemporaryRT(m_TempTextureHandle1.id);
            cmd.ReleaseTemporaryRT(m_TempTextureHandle2.id);
        }



    }
}
