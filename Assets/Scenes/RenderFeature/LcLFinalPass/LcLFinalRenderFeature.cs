using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

/// <summary>
/// 自定义FinalPass
/// 需要手动在URP中注释掉自带的FinalPass,
/// 在UniversalRenderer.cs中注释掉"EnqueuePass(m_FinalBlitPass);"
/// </summary>
public class LcLFinalRenderFeature : ScriptableRendererFeature
{
    LcLFinalBlitPass m_ScriptablePass;
    Material m_Material;

    public override void Create()
    {
        m_Material = CoreUtils.CreateEngineMaterial("Hidden/Universal Render Pipeline/Blit");
        m_ScriptablePass = new LcLFinalBlitPass(RenderPassEvent.AfterRendering, m_Material);
    }
    protected override void Dispose(bool disposing)
    {
        CoreUtils.Destroy(m_Material);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (renderingData.cameraData.camera.cameraType == CameraType.Preview)
        {
            return;
        }
        renderer.EnqueuePass(m_ScriptablePass);
    }

    class LcLFinalBlitPass : ScriptableRenderPass
    {
        RenderTargetIdentifier m_Source;

        private Material m_Material;
        static ProfilingSampler m_ProfilingSampler = new ProfilingSampler("LcLRenderPass");
        public static readonly int sourceTex = Shader.PropertyToID("_SourceTex");

        public LcLFinalBlitPass(RenderPassEvent evt, Material material)
        {
            m_Material = material;
            renderPassEvent = evt;
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            Camera camera = renderingData.cameraData.camera;
            ref CameraData cameraData = ref renderingData.cameraData;
            ScriptableRenderer renderer = cameraData.renderer;
            RenderTargetHandle cameraTargetHandle = RenderTargetHandle.CameraTarget;
            RenderTargetIdentifier cameraTarget = (cameraData.targetTexture != null) ? new RenderTargetIdentifier(cameraData.targetTexture) : cameraTargetHandle.Identifier();

            bool isSceneViewCamera = cameraData.isSceneViewCamera;
            CommandBuffer cmd = CommandBufferPool.Get();


            using (new ProfilingScope(cmd, m_ProfilingSampler))
            {
                cmd.SetGlobalTexture(sourceTex, cameraData.renderer.GetCameraColorBackBuffer(cmd));

                if (isSceneViewCamera || cameraData.isDefaultViewport)
                {
                    m_Source = cameraData.renderer.GetCameraColorBackBuffer(cmd);
                    if (m_Source == cameraData.renderer.GetCameraColorFrontBuffer(cmd))
                    {
                        m_Source = renderingData.cameraData.renderer.cameraColorTarget;
                    }
                    cmd.SetRenderTarget(BuiltinRenderTextureType.CameraTarget,
                        RenderBufferLoadAction.DontCare, RenderBufferStoreAction.Store, // color
                        RenderBufferLoadAction.DontCare, RenderBufferStoreAction.DontCare); // depth
                    cmd.Blit(m_Source, cameraTarget, m_Material);
                    cameraData.renderer.ConfigureCameraTarget(cameraTarget, cameraTarget);
                }
                else
                {
                    CoreUtils.SetRenderTarget(
                        cmd,
                        cameraTarget,
                        RenderBufferLoadAction.DontCare,
                        RenderBufferStoreAction.Store,
                        ClearFlag.None,
                        Color.black);

                    cmd.SetViewProjectionMatrices(Matrix4x4.identity, Matrix4x4.identity);
                    cmd.SetViewport(camera.pixelRect);
                    cmd.DrawMesh(RenderingUtils.fullscreenMesh, Matrix4x4.identity, m_Material);
                    cmd.SetViewProjectionMatrices(camera.worldToCameraMatrix, camera.projectionMatrix);
                    cameraData.renderer.ConfigureCameraTarget(cameraTarget, cameraTarget);
                }
            }

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {
        }
    }


}


