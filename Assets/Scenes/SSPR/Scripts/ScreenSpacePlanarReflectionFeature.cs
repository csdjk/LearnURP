using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace LcLGame
{
    [Serializable]
    public class SSPRSettings
    {
        [Range(128, 1080)]
        public int textureResolution = 512;
        public float horizontalReflectionPlaneHeightWS = 0;
        [Range(0.01f, 1)]
        public float fadeOutScreenBorderHorizontal = 0.01f;
        [Range(0.01f, 1)]
        public float fadeOutScreenBorderVerticle = 0.01f;

        //左右丢失像素uv拉伸阈值
        [Range(-1f, 1f)]
        public float screenLRStretchThreshold = 0.9f;
        //左右丢失像素uv拉伸强度
        [Range(0, 8f)]
        public float screenLRStretchIntensity = 4;
        public bool applyFillHoleFix = true;
        public bool applyBlur = false;
        [Range(2, 5)]
        public int iterations = 2;
        [Range(0.0f, 10f)]
        public float blurRadius = 1;
        [Range(0, 5)]
        public int downSample = 1;
    }


    [ExecuteAlways]
    public class ScreenSpacePlanarReflectionFeature : RendererFeatureBase
    {
        public ComputeShader computeShader;
        public SSPRSettings settings = new SSPRSettings();


        ScreenSpacePlanarReflectionPass m_ReflectionsPass;

        //必须和ComputeShader的[numthread(x,y)] 相同
        const int SHADER_NUMTHREAD_X = 8;
        const int SHADER_NUMTHREAD_Y = 8;

        protected override void Create()
        {
            m_ReflectionsPass = new ScreenSpacePlanarReflectionPass(settings)
            {
                renderPassEvent = RenderPassEvent.BeforeRenderingTransparents
            };
        }

        protected override void Dispose()
        {
            m_ReflectionsPass?.Dispose();
            m_ReflectionsPass = null;
        }

        protected override void AddRenderPasses(ScriptableRenderer renderer)
        {
            if (computeShader)
            {
                m_ReflectionsPass.Setup(computeShader);
                renderer.EnqueuePass(m_ReflectionsPass);
            }
        }


        class ScreenSpacePlanarReflectionPass : ScriptableRenderPass
        {
            SSPRSettings m_Settings;

            readonly int m_TintColorPID = Shader.PropertyToID("_TintColor");
            readonly int m_RtSizePID = Shader.PropertyToID("_RTSize");
            readonly int m_HorizontalPlaneHeightPID = Shader.PropertyToID("_HorizontalPlaneHeightWS");
            readonly int m_FadeOutScreenBorderPID = Shader.PropertyToID("_FadeOutScreenBorder");
            readonly int m_CameraDirectionPID = Shader.PropertyToID("_CameraDirection");
            readonly int m_ScreenStretchDataPID = Shader.PropertyToID("_ScreenLRStretchData");
            readonly int m_NoiseIntensityPID = Shader.PropertyToID("_NoiseIntensity");

            readonly int m_SSPRTexturePID = Shader.PropertyToID("_ScreenSpaceReflectionTexture");
            ShaderTagId m_LightModeID = new ShaderTagId("SSPR");

            RenderTargetIdentifier m_CameraColorTarget;
            RenderTargetIdentifier m_CameraDepthTarget;

            RenderTargetHandle m_DepthTexture;
            RenderTargetHandle m_OpaqueTexture;

            RenderTargetHandle m_ColorTexHandle;

            // RTHandle
            RenderTargetHandle m_PosWSyHandle;
            RenderTargetHandle m_BlurTexHandle;
            ComputeShader m_ComputeShader;
            int m_KernelMain;
            int m_KernelFillHoles;
            int m_KernelNoiseReduction;

            Vector2Int m_RtSize;

            // BlurEffect.BlurRenderPass blurPass;
            RenderTextureDescriptor m_BlurRTD;

            FilteringSettings m_FilteringSettings;
            ProfilingSampler m_ProfilingSampler;

            public ScreenSpacePlanarReflectionPass(SSPRSettings settings)
            {
                m_Settings = settings ?? new SSPRSettings();
                m_FilteringSettings = new FilteringSettings(RenderQueueRange.all);
                m_ProfilingSampler = new ProfilingSampler("SSPR");

                m_DepthTexture.Init("_CameraDepthTexture");
                m_OpaqueTexture.Init("_CameraOpaqueTexture");

                m_ColorTexHandle.Init("ColorRT");
                m_PosWSyHandle.Init("PosWSyRT");
                m_BlurTexHandle.Init("BlurRT");

                // blurPass = new BlurEffect.BlurRenderPass("Blur", new BlurSettings()
                // {
                //     iterations = 2,
                //     blurRadius = 0.1f,
                //     downSample = 0,
                // })
                // {
                //     renderPassEvent = RenderPassEvent.AfterRenderingTransparents
                // };
            }

            public void Setup(ComputeShader cs)
            {
                m_KernelMain = cs.FindKernel("SSPRMain");
                m_KernelFillHoles = cs.FindKernel("FillHoles");
                this.m_ComputeShader = cs;
            }

            Vector2Int GetRTSize(int textureResolution, float aspect)
            {
                int height = Mathf.Max(textureResolution, 512);
                int width = Mathf.CeilToInt(height * aspect);
                return new Vector2Int(width, height);
            }


            public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
            {
                // var settings = ScreenSpacePlanarReflection.SettingParams;
                // if (settings == null) return;
                m_RtSize = GetRTSize(m_Settings.textureResolution,
                    (float)cameraTextureDescriptor.width / cameraTextureDescriptor.height);
                var colorFormat = RenderTextureFormat.ARGBHalf;
                RenderTextureDescriptor rtd = new RenderTextureDescriptor(m_RtSize.x, m_RtSize.y, colorFormat, 0, 0)
                {
                    enableRandomWrite = true
                };
                m_BlurRTD = rtd;
                cmd.GetTemporaryRT(m_ColorTexHandle.id, rtd);
                if (m_Settings.applyBlur)
                {
                    cmd.GetTemporaryRT(m_BlurTexHandle.id, rtd);
                }

                rtd.colorFormat = RenderTextureFormat.RFloat;
                cmd.GetTemporaryRT(m_PosWSyHandle.id, rtd);
            }

            public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
            {
                var settings = m_Settings;
                if (settings == null)
                {
                    Debug.LogWarning("ScreenSpacePlanarReflectionPass settings is null");
                    return;
                }

                if (m_ComputeShader == null)
                {
                    Debug.LogWarning("ScreenSpacePlanarReflectionPass ComputeShader is null");
                    return;
                }

                CommandBuffer cmd = CommandBufferPool.Get();
                var camera = renderingData.cameraData.camera;
                ref CameraData cameraData = ref renderingData.cameraData;
                var cameraColorTarget = cameraData.renderer.cameraColorTarget;
                var cameraDepthTarget = cameraData.renderer.cameraDepthTarget;

                using (new ProfilingScope(cmd, m_ProfilingSampler))
                {
                    context.ExecuteCommandBuffer(cmd);
                    cmd.Clear();

                    // cmd.SetRenderTarget(cameraColorTarget, RenderBufferLoadAction.DontCare,
                    //     RenderBufferStoreAction.DontCare,
                    //     RenderBufferLoadAction.DontCare, RenderBufferStoreAction.DontCare);

                    // 为了使 uv 和 SV_DispatchThreadID 对齐
                    // 即: [0,1] => [0,RTSize-1]
                    var dispatchThreadGroupXCount = m_RtSize.x / SHADER_NUMTHREAD_X;
                    var dispatchThreadGroupYCount = m_RtSize.y / SHADER_NUMTHREAD_Y;
                    var dispatchThreadGroupZCount = 1;

                    // cmd.SetComputeVectorParam(cs, tintColorPID, tintColor);
                    cmd.SetComputeVectorParam(m_ComputeShader, m_RtSizePID, new Vector2(m_RtSize.x, m_RtSize.y));
                    cmd.SetComputeVectorParam(m_ComputeShader, m_FadeOutScreenBorderPID,
                        new Vector2(settings.fadeOutScreenBorderHorizontal, settings.fadeOutScreenBorderVerticle));
                    cmd.SetComputeVectorParam(m_ComputeShader, m_ScreenStretchDataPID,
                        new Vector2(settings.screenLRStretchThreshold, settings.screenLRStretchIntensity));
                    cmd.SetComputeVectorParam(m_ComputeShader, m_CameraDirectionPID, camera.transform.forward);
                    cmd.SetComputeFloatParam(m_ComputeShader, m_HorizontalPlaneHeightPID, settings.horizontalReflectionPlaneHeightWS);

                    // cmd.SetComputeTextureParam(cs, kernelMain, "_CameraOpaqueTexture", new RenderTargetIdentifier("_CameraOpaqueTexture"));
                    cmd.SetComputeTextureParam(m_ComputeShader, m_KernelMain, m_DepthTexture.id, m_DepthTexture.Identifier());
                    cmd.SetComputeTextureParam(m_ComputeShader, m_KernelMain, m_OpaqueTexture.id, m_OpaqueTexture.Identifier());
                    cmd.SetComputeTextureParam(m_ComputeShader, m_KernelMain, m_ColorTexHandle.id, m_ColorTexHandle.Identifier());
                    cmd.SetComputeTextureParam(m_ComputeShader, m_KernelMain, m_PosWSyHandle.id, m_PosWSyHandle.Identifier());

                    // VP 逆矩阵
                    Matrix4x4 projMatrix = GL.GetGPUProjectionMatrix(camera.projectionMatrix, true);
                    Matrix4x4 viewMatrix = camera.worldToCameraMatrix;
                    Matrix4x4 viewProjMatrix = projMatrix * viewMatrix;
                    cmd.SetComputeMatrixParam(m_ComputeShader, "_VPMatrix", viewProjMatrix);
                    Matrix4x4 invViewProjMatrix = Matrix4x4.Inverse(viewProjMatrix);
                    cmd.SetComputeMatrixParam(m_ComputeShader, "_InverseVPMatrix", invViewProjMatrix);

                    cmd.DispatchCompute(m_ComputeShader, m_KernelMain, dispatchThreadGroupXCount, dispatchThreadGroupYCount,
                        dispatchThreadGroupZCount);

                    // 修复镂空
                    if (settings.applyFillHoleFix)
                    {
                        cmd.SetComputeTextureParam(m_ComputeShader, m_KernelFillHoles, m_ColorTexHandle.id,
                            m_ColorTexHandle.Identifier());
                        cmd.DispatchCompute(m_ComputeShader, m_KernelFillHoles, Mathf.CeilToInt(dispatchThreadGroupXCount / 2f),
                            Mathf.CeilToInt(dispatchThreadGroupYCount / 2f), dispatchThreadGroupZCount);
                    }


                    var finalHandle = m_ColorTexHandle;
                    // if (settings.applyBlur)
                    // {
                    //     blurPass.Setup(m_ColorTexHandle.Identifier(), blurRTD);
                    //     blurPass.SetIterations(settings.iterations);
                    //     blurPass.SetBlurRadius(settings.blurRadius);
                    //     blurPass.SetDownSample(settings.downSample);
                    //     blurPass.SetOutputTextureID(m_BlurTexHandle.id);
                    //     blurPass.Execute(context, ref renderingData, cmd);
                    //     finalHandle = m_BlurTexHandle;
                    // }

                    cmd.SetGlobalTexture(m_SSPRTexturePID, finalHandle.id);

                    // cmd.SetRenderTarget(cameraColorTarget, RenderBufferLoadAction.Load, RenderBufferStoreAction.Store,
                    //     cameraDepthTarget, RenderBufferLoadAction.Load, RenderBufferStoreAction.Store);

                    context.ExecuteCommandBuffer(cmd);
                    cmd.Clear();

                    DrawingSettings drawingSettings =
                        CreateDrawingSettings(m_LightModeID, ref renderingData, SortingCriteria.CommonOpaque);
                    context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref m_FilteringSettings);
                }

                context.ExecuteCommandBuffer(cmd);
                CommandBufferPool.Release(cmd);
            }

            public override void FrameCleanup(CommandBuffer cmd)
            {
                cmd.ReleaseTemporaryRT(m_ColorTexHandle.id);
                cmd.ReleaseTemporaryRT(m_PosWSyHandle.id);
                cmd.ReleaseTemporaryRT(m_BlurTexHandle.id);
                // blurPass?.FrameCleanup(cmd);
            }

            public void Dispose()
            {
                CommandBuffer cmd = CommandBufferPool.Get();
                FrameCleanup(cmd);
            }
        }
    }
}
