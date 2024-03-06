using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace LcLGame
{
    [Serializable]
    public class RainLayerData
    {
        public Vector2 tilling = new Vector2(10f, 10f);
        public Vector2 speed = new Vector2(0f, 50f);
        [Range(0, 30)]
        public float depthBase = 0f;
        [Range(0, 50)]
        public float depthRange = 1f;

        [Range(0, 1)]
        public float threshold = 0.5f;
        [Range(0, 1)]
        public float smoothness = 0.5f;

        [Range(0, 10)]
        public float intensity = 1.5f;
    }

    [Serializable]
    public class RainSettings
    {
        public Mesh rainMesh;
        public float meshScale = 1f;
        public Texture2D rainTexture = null;
        public Texture sceneHeightRT;

        public Color rainColor = Color.gray;
        public RainLayerData layerNear = new RainLayerData { depthBase = 2f, depthRange = 3 };
        public RainLayerData layerFar = new RainLayerData { tilling = new Vector2(20, 20), depthBase = 7, depthRange = 40 };

        public Vector3 windDir = Vector3.zero;
    }

    public class RainFeature : RendererFeatureBase
    {
        public RainSettings settings = new RainSettings();

        RainPass m_RainPass;

        public override void Create()
        {
            m_RainPass = new RainPass(settings);
            m_RainPass.renderPassEvent = RenderPassEvent.AfterRenderingTransparents;
        }

        public override void AddRenderPasses(ScriptableRenderer renderer)
        {
            if (!settings.rainTexture || !settings.rainMesh || !settings.sceneHeightRT)
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
            RainSettings m_RainSettings;

            public RainPass(RainSettings rainSettings)
            {
                m_Material = CoreUtils.CreateEngineMaterial("LcL/Rain");
                m_RainSettings = rainSettings;
            }

            public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
            {
                var camera = renderingData.cameraData.camera;
                CommandBuffer cmd = CommandBufferPool.Get();

                using (new ProfilingScope(cmd, m_ProfilingSampler))
                {
                    context.ExecuteCommandBuffer(cmd);
                    cmd.Clear();

                    var layerFar = m_RainSettings.layerFar;
                    var layerNear = m_RainSettings.layerNear;
                    cmd.SetGlobalMatrix(m_DepthCameraMatrixVPID, HeightMapRender.SceneHeightMatrixVP);
                    cmd.SetGlobalTexture(m_SceneHeightTexID, m_RainSettings.sceneHeightRT);
                    cmd.SetGlobalTexture(m_RainTextureID, m_RainSettings.rainTexture);
                    cmd.SetGlobalColor(m_RainColorID, m_RainSettings.rainColor);
                    cmd.SetGlobalVector(m_RainIntensityID, new Vector4(layerNear.intensity, layerFar.intensity, 0, 0));

                    cmd.SetGlobalVector(m_NearTillingSpeedID,
                        new Vector4(layerNear.tilling.x, layerNear.tilling.y, layerNear.speed.x, layerNear.speed.y));
                    cmd.SetGlobalVector(m_FarTillingSpeedID,
                        new Vector4(layerFar.tilling.x, layerFar.tilling.y, layerFar.speed.x, layerFar.speed.y));

                    cmd.SetGlobalVector(m_NearDepthSmoothID,
                        new Vector4(layerNear.depthBase, layerNear.depthRange, layerNear.threshold,
                            layerNear.smoothness));
                    cmd.SetGlobalVector(m_FarDepthSmoothID,
                        new Vector4(layerFar.depthBase, layerFar.depthRange, layerFar.threshold, layerFar.smoothness));

                    var xform = Matrix4x4.TRS(camera.transform.position, Quaternion.Euler(m_RainSettings.windDir),
                        Vector3.one * m_RainSettings.meshScale);

                    cmd.DrawMesh(m_RainSettings.rainMesh, xform, m_Material);
                }

                context.ExecuteCommandBuffer(cmd);
                CommandBufferPool.Release(cmd);
            }
        }
    }
}
