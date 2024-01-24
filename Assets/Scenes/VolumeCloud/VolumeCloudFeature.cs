
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
public class VolumeCloudFeature : ScriptableRendererFeature
{

    [System.Serializable]
    public class Settings
    {
        public Transform box;
        [Range(0, 0.5f)]
        public float StepSize = 0.02f;
        [Range(0, 0.5f)]
        public float Density = 0.02f;
        [Range(0, 300)]
        public int MaxStep = 100;
        [Range(0, 1)]
        public float NoiseIntensity = 0.1f;
    }

    VolumeCloudPass renderPass;
    public Shader shader;
    public override void Create()
    {
        renderPass = new VolumeCloudPass(shader)
        {
            renderPassEvent = RenderPassEvent.BeforeRenderingTransparents
        };
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (VolumeCloud.Instance == null || VolumeCloud.Instance.cloudTexture == null) return;

        renderPass.Setup(renderer.cameraColorTarget);
        renderer.EnqueuePass(renderPass);
    }

    class VolumeCloudPass : ScriptableRenderPass
    {
        static readonly int m_FrustumCornersRayID = Shader.PropertyToID("_FrustumCornersRay");
        string shaderName = "Hidden/VolumeCloudBake";
        Material m_Material = null;
        RenderTargetHandle m_MainTexID;
        RenderTextureDescriptor m_Descriptor;
        ProfilingSampler m_ProfilingSampler;

        public void Setup(RenderTargetIdentifier source)
        {
        }

        public VolumeCloudPass(Shader shader)
        {
            m_Material = CoreUtils.CreateEngineMaterial(shader);
            m_MainTexID.Init("_VolumeCloud");
            m_ProfilingSampler = new ProfilingSampler("VolumeCloud");

        }


        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            var cloudSetting = VolumeCloud.Instance;
            if (cloudSetting == null) return;
            m_Descriptor = cameraTextureDescriptor;
            // 降采样
            m_Descriptor.width = m_Descriptor.width >> cloudSetting.downSample;
            m_Descriptor.height = m_Descriptor.height >> cloudSetting.downSample;
            m_Descriptor.colorFormat = RenderTextureFormat.ARGBHalf;
            cmd.GetTemporaryRT(m_MainTexID.id, m_Descriptor, FilterMode.Bilinear);
            ConfigureTarget(m_MainTexID.Identifier());
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
            if (VolumeCloud.Instance == null) return;

            var cloudSetting = VolumeCloud.Instance;
            CommandBuffer cmd = CommandBufferPool.Get();
            using (new ProfilingScope(cmd, m_ProfilingSampler))
            {
                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();
                var camera = renderingData.cameraData.camera;
                var viewPortRay = CalculateFrustumCornersRay(camera);

                cmd.SetGlobalMatrix(m_FrustumCornersRayID, viewPortRay);
                cmd.SetGlobalVector("_BoundsMin", cloudSetting.BoundMin);
                cmd.SetGlobalVector("_BoundsMax", cloudSetting.BoundMax);

                cmd.SetGlobalTexture("_CloudTexture", cloudSetting.cloudTexture);
                cmd.SetGlobalVector("_NoiseTiling", new Vector4(cloudSetting.noiseTiling.x, cloudSetting.noiseTiling.y, cloudSetting.noiseTiling.z, cloudSetting.densityPower));
                cmd.SetGlobalVector("_NoiseOffset", cloudSetting.noiseOffset);

                cmd.SetGlobalTexture("_BlueNoiseTex", cloudSetting.blurNoise);
                cmd.SetGlobalVector("_BlurTilingAndIntensity", new Vector4(cloudSetting.blurTiling.x, cloudSetting.blurTiling.y, cloudSetting.blurIntensity, 0));

                cmd.SetGlobalColor("_Color", cloudSetting.color);
                cmd.SetGlobalColor("_ShadowColor", cloudSetting.shadowColor);


                cmd.SetGlobalInt("_MaxStep", cloudSetting.maxStep);
                cmd.SetGlobalVector("_CloudData", new Vector4(cloudSetting.sdfThreshold, cloudSetting.stepScale * cloudSetting.boundSize, cloudSetting.densityScale, cloudSetting.lightAbsorptionThroughCloud));
                cmd.SetGlobalVector("_ScatterData", new Vector4(cloudSetting.scatterForward, cloudSetting.scatterBackward, cloudSetting.scatterWeight, cloudSetting.darknessThreshold));

                cmd.Blit(null, m_MainTexID.Identifier(), m_Material, 0);
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


}







