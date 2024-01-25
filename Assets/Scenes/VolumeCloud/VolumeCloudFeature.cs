using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Serialization;

namespace LcLGame
{
    public class VolumeCloudFeature : RendererFeatureBase
    {
        public Shader shader;

        [System.Serializable]
        public class CloudSettings
        {
            public Texture3D cloudTexture;
            public Vector3 noiseTiling = new Vector3(1, 1, 1);
            public Vector3 noiseOffset = new Vector3(0, 0, 0);
            public Texture2D blurNoise;
            public Vector2 blurTiling = new Vector2(1, 1);
            [Range(0, 0.1f)] public float blurIntensity = 0.01f;

            public Color color = Color.white;
            public Color shadowColor = Color.black;
            [Range(0, 5)] public int downSample = 1;
            [Range(0, 300)] public int maxStep = 100;
            [Range(0.001f, 0.3f)] public float sdfThreshold = 0.007f;
            [Range(0, 2)] public float stepScale = 1f;
            [Range(0, 10f)] public float densityScale = 1;
            [Range(0, 10f)] public float densityPower = 1;


            [Range(0, 1)] public float lightAbsorptionThroughCloud = 0.8f;

            [Range(0, 1)] public float darknessThreshold = 0.1f;
            [Range(0, 1)] public float scatterForward = 0.1f;
            [Range(0, 1)] public float scatterBackward = 0.1f;
            [Range(0, 1)] public float scatterWeight = 0.1f;
        }

        public Vector3 BoundMax => transform.position + transform.localScale * 0.5f;
        public Vector3 BoundMin => transform.position - transform.localScale * 0.5f;

        public CloudSettings cloudSettings = new CloudSettings();

        public Vector3 Resolution => new Vector3(cloudSettings.cloudTexture.width, cloudSettings.cloudTexture.height,
            cloudSettings.cloudTexture.depth);

        Vector3 m_InvScale;
        Vector3 m_VoxelSize;
        float m_InverseResolution;
        float m_BoundSize;


        static Vector3 VoxelSize(Vector3 textureResolution, out float inverseResolution)
        {
            inverseResolution = 1.0f / Mathf.Max(textureResolution.x, textureResolution.y, textureResolution.z);
            return new Vector3(textureResolution.x * inverseResolution, textureResolution.y * inverseResolution,
                textureResolution.z * inverseResolution);
        }

        VolumeCloudPass m_RenderPass;

#if UNITY_EDITOR
        void Update()
        {
            UpdateCloudData();
        }
#endif

        void UpdateCloudData()
        {
            if (!cloudSettings.cloudTexture)
                return;

            m_VoxelSize = VoxelSize(Resolution, out m_InverseResolution);
            m_InvScale = new Vector3(1.0f / m_VoxelSize.x, 1.0f / m_VoxelSize.y, 1.0f / m_VoxelSize.z);
            m_BoundSize = Mathf.Max(transform.localScale.x, transform.localScale.y, transform.localScale.z) / 2;
        }


        public override void Create()
        {
            UpdateCloudData();
            m_RenderPass = new VolumeCloudPass(shader, cloudSettings)
            {
                renderPassEvent = RenderPassEvent.BeforeRenderingTransparents
            };
        }

        public override void AddRenderPasses(ScriptableRenderer renderer)
        {
            if (!cloudSettings.cloudTexture)
                return;

            m_RenderPass.Setup(BoundMax, BoundMin, m_BoundSize);
            renderer.EnqueuePass(m_RenderPass);
        }

        class VolumeCloudPass : ScriptableRenderPass
        {
            static readonly int m_FrustumCornersRayID = Shader.PropertyToID("_FrustumCornersRay");
            static readonly int m_BoundsMinID = Shader.PropertyToID("_BoundsMin");
            static readonly int m_BoundsMaxID = Shader.PropertyToID("_BoundsMax");
            static readonly int m_CloudTextureID = Shader.PropertyToID("_CloudTexture");
            static readonly int m_NoiseTilingID = Shader.PropertyToID("_NoiseTiling");
            static readonly int m_NoiseOffsetID = Shader.PropertyToID("_NoiseOffset");
            static readonly int m_BlueNoiseTexID = Shader.PropertyToID("_BlueNoiseTex");
            static readonly int m_BlurTilingAndIntensityID = Shader.PropertyToID("_BlurTilingAndIntensity");
            static readonly int m_ColorID = Shader.PropertyToID("_Color");
            static readonly int m_ShadowColorID = Shader.PropertyToID("_ShadowColor");
            static readonly int m_MaxStepID = Shader.PropertyToID("_MaxStep");
            static readonly int m_CloudDataID = Shader.PropertyToID("_CloudData");
            static readonly int m_ScatterDataID = Shader.PropertyToID("_ScatterData");

            Material m_Material = null;
            RenderTargetHandle m_MainTexID;
            RenderTextureDescriptor m_Descriptor;
            ProfilingSampler m_ProfilingSampler;
            CloudSettings m_CloudSettings;
            Vector3 m_BoundMax;
            Vector3 m_BoundMin;
            float m_BoundSize;

            public void Setup(Vector3 boundMax, Vector3 boundMin, float boundSize)
            {
                m_BoundMax = boundMax;
                m_BoundMin = boundMin;
                m_BoundSize = boundSize;
            }

            public VolumeCloudPass(Shader shader, CloudSettings cloudSettings)
            {
                m_CloudSettings = cloudSettings;
                m_Material = CoreUtils.CreateEngineMaterial(shader);
                m_MainTexID.Init("_VolumeCloud");
                m_ProfilingSampler = new ProfilingSampler("VolumeCloud");
            }


            public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
            {
                if (m_CloudSettings == null) return;
                m_Descriptor = cameraTextureDescriptor;
                // 降采样
                m_Descriptor.width = m_Descriptor.width >> m_CloudSettings.downSample;
                m_Descriptor.height = m_Descriptor.height >> m_CloudSettings.downSample;
                m_Descriptor.colorFormat = RenderTextureFormat.ARGBHalf;
                cmd.GetTemporaryRT(m_MainTexID.id, m_Descriptor, FilterMode.Bilinear);
                // ConfigureTarget(m_MainTexID.Identifier());
                // ConfigureClear(ClearFlag.All, Color.black);
            }

            private Matrix4x4 CalculateFrustumCornersRay(Camera camera)
            {
                var aspect = camera.aspect;
                var far = camera.farClipPlane;
                var right = camera.transform.right;
                var up = camera.transform.up;
                var forward = camera.transform.forward;

                var forwardVec = Vector3.zero;
                Vector3 rightVec, upVec;

                if (camera.orthographic)
                {
                    var orthoSize = camera.orthographicSize;
                    rightVec = right * orthoSize * aspect;
                    upVec = up * orthoSize;
                }
                else
                {
                    forwardVec = forward * far;
                    var halfFovTan = Mathf.Tan(camera.fieldOfView * 0.5f * Mathf.Deg2Rad);
                    rightVec = right * far * halfFovTan * aspect;
                    upVec = up * far * halfFovTan;
                }

                //构建四个角的方向向量
                var topLeft = forwardVec - rightVec + upVec;
                var topRight = forwardVec + rightVec + upVec;
                var bottomLeft = forwardVec - rightVec - upVec;
                var bottomRight = forwardVec + rightVec - upVec;

                var viewPortRay = Matrix4x4.identity;

                //计算近裁剪平面四个角对应向量
                viewPortRay.SetRow(0, bottomLeft);
                viewPortRay.SetRow(1, bottomRight);
                viewPortRay.SetRow(2, topLeft);
                viewPortRay.SetRow(3, topRight);
                return viewPortRay;
            }

            public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
            {
                if (m_CloudSettings == null) return;

                CommandBuffer cmd = CommandBufferPool.Get();
                using (new ProfilingScope(cmd, m_ProfilingSampler))
                {
                    context.ExecuteCommandBuffer(cmd);
                    cmd.Clear();
                    var camera = renderingData.cameraData.camera;
                    var viewPortRay = CalculateFrustumCornersRay(camera);

                    cmd.SetGlobalMatrix(m_FrustumCornersRayID, viewPortRay);
                    cmd.SetGlobalVector(m_BoundsMinID, m_BoundMin);
                    cmd.SetGlobalVector(m_BoundsMaxID, m_BoundMax);

                    cmd.SetGlobalTexture(m_CloudTextureID, m_CloudSettings.cloudTexture);
                    cmd.SetGlobalVector(m_NoiseTilingID,
                        new Vector4(m_CloudSettings.noiseTiling.x, m_CloudSettings.noiseTiling.y,
                            m_CloudSettings.noiseTiling.z,
                            m_CloudSettings.densityPower));
                    cmd.SetGlobalVector(m_NoiseOffsetID, m_CloudSettings.noiseOffset);

                    cmd.SetGlobalTexture(m_BlueNoiseTexID, m_CloudSettings.blurNoise);
                    cmd.SetGlobalVector(m_BlurTilingAndIntensityID,
                        new Vector4(m_CloudSettings.blurTiling.x, m_CloudSettings.blurTiling.y,
                            m_CloudSettings.blurIntensity,
                            0));

                    cmd.SetGlobalColor(m_ColorID, m_CloudSettings.color);
                    cmd.SetGlobalColor(m_ShadowColorID, m_CloudSettings.shadowColor);


                    cmd.SetGlobalInt(m_MaxStepID, m_CloudSettings.maxStep);
                    cmd.SetGlobalVector(m_CloudDataID,
                        new Vector4(m_CloudSettings.sdfThreshold, m_CloudSettings.stepScale * m_BoundSize,
                            m_CloudSettings.densityScale, m_CloudSettings.lightAbsorptionThroughCloud));
                    cmd.SetGlobalVector(m_ScatterDataID,
                        new Vector4(m_CloudSettings.scatterForward, m_CloudSettings.scatterBackward,
                            m_CloudSettings.scatterWeight, m_CloudSettings.darknessThreshold));

                    cmd.Blit(null, m_MainTexID.Identifier(), m_Material, 0);
                    cmd.SetGlobalTexture(m_MainTexID.id, m_MainTexID.Identifier());
                    // cmd.Blit(null, m_MainTexID.Identifier(), m_Material, 1);
                    Blit(cmd, ref renderingData, m_Material, 1);
                }

                context.ExecuteCommandBuffer(cmd);
                CommandBufferPool.Release(cmd);
            }

            public override void FrameCleanup(CommandBuffer cmd)
            {
                cmd.ReleaseTemporaryRT(m_MainTexID.id);
            }
        }

#if UNITY_EDITOR
        void OnDrawGizmos()
        {
            Gizmos.color = Color.green;
            Gizmos.DrawWireCube(transform.position, transform.localScale);
        }
#endif
    }
}
