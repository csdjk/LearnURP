using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

/// <summary>
/// Rain RendererFeature
/// </summary>
public class RainFeature : ScriptableRendererFeature
{
    RainPass m_RainPass;

    public override void Create()
    {
        m_RainPass = new RainPass();
        m_RainPass.renderPassEvent = RenderPassEvent.AfterRenderingTransparents;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (!Rain.Instance || !Rain.Instance.rainTexture || !Rain.Instance.sceneHeightRT || !Rain.Instance.rainMesh)
        {
            return;
        }
        renderer.EnqueuePass(m_RainPass);
    }


    public class RainPass : ScriptableRenderPass
    {
        ProfilingSampler m_ProfilingSampler = new ProfilingSampler("RainRender");

        static readonly int m_DepthCameraMatrixVPID = Shader.PropertyToID("_DepthCameraMatrixVP");
        static readonly int m_SceneHeightTexID = Shader.PropertyToID("_SceneHeightTex");
        static readonly int m_RainTextureID = Shader.PropertyToID("_RainTexture");
        static readonly int m_RainColorID = Shader.PropertyToID("_RainColor");
        static readonly int m_RainIntensityID = Shader.PropertyToID("_RainIntensity");
        static readonly int m_NearTillingSpeedID = Shader.PropertyToID("_NearTillingSpeed");
        static readonly int m_FarTillingSpeedID = Shader.PropertyToID("_FarTillingSpeed");
        static readonly int m_NearDepthSmoothID = Shader.PropertyToID("_NearDepthSmooth");
        static readonly int m_FarDepthSmoothID = Shader.PropertyToID("_FarDepthSmooth");

        Material m_Material;
        public RainPass()
        {
            m_Material = CoreUtils.CreateEngineMaterial("LcL/Rain");
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            var rainData = Rain.Instance;
            if (!rainData)
            {
                return;
            }

            var camera = renderingData.cameraData.camera;
            CommandBuffer cmd = CommandBufferPool.Get();
            var renderer = renderingData.cameraData.renderer;
            var source = renderer.cameraColorTarget;
            var dest = RenderTargetHandle.CameraTarget;

            using (new ProfilingScope(cmd, m_ProfilingSampler))
            {
                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();

                var layerFar = rainData.layerFar;
                var layerNear = rainData.layerNear;
                cmd.SetGlobalMatrix(m_DepthCameraMatrixVPID, HeightMapRender.SceneHeightMatrixVP);
                // cmd.SetGlobalTexture("_SceneHeightTex", sceneHeightRT);
                cmd.SetGlobalTexture(m_SceneHeightTexID, rainData.sceneHeightRT);
                cmd.SetGlobalTexture(m_RainTextureID, rainData.rainTexture);
                cmd.SetGlobalColor(m_RainColorID, rainData.rainColor);
                cmd.SetGlobalVector(m_RainIntensityID, new Vector4(layerNear.intensity, layerFar.intensity, 0, 0));

                cmd.SetGlobalVector(m_NearTillingSpeedID,
                    new Vector4(layerNear.tilling.x, layerNear.tilling.y, layerNear.speed.x, layerNear.speed.y));
                cmd.SetGlobalVector(m_FarTillingSpeedID,
                    new Vector4(layerFar.tilling.x, layerFar.tilling.y, layerFar.speed.x, layerFar.speed.y));

                cmd.SetGlobalVector(m_NearDepthSmoothID,
                    new Vector4(layerNear.depthBase, layerNear.depthRange, layerNear.threshold, layerNear.smoothness));
                cmd.SetGlobalVector(m_FarDepthSmoothID,
                    new Vector4(layerFar.depthBase, layerFar.depthRange, layerFar.threshold, layerFar.smoothness));

                var xform = Matrix4x4.TRS(camera.transform.position, Quaternion.Euler(rainData.windDir),
                    Vector3.one * rainData.meshScale);

                cmd.DrawMesh(rainData.rainMesh, xform, m_Material);
            }

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }
    }
}
