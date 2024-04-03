using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using LcLGame;
using UnityEngine.Serialization;

public class HBAORenderFeature : RendererFeatureBase
{
    [System.Serializable]
    public class Settings
    {
        public Texture2D noiseTexture;
        [Range(0, 3)]
        public int downSample = 1;
        [Range(0, 5f)]
        public float radius = 0.5f;
        [Range(16, 256)]
        public float maxRadiusPixels = 128;
        [Range(0, 0.5f)]
        public float angleBias = 0.1f;
        [Range(0, 3)]
        public float intensity = 1;
        public float maxDistance = 150f;
        public float distanceFalloff = 50f;
    }

    public Settings settings = new Settings();
    HBAOPass m_HBAOPass;


    public GaussianBlurSettings gaussianSettings = new GaussianBlurSettings();

    GaussianBlurRendererPass m_BlurPass;

    public override void Create()
    {

        m_BlurPass = new GaussianBlurRendererPass(gaussianSettings)
        {
            renderPassEvent = RenderPassEvent.AfterRenderingTransparents
        };

        m_HBAOPass = new HBAOPass(settings, m_BlurPass)
        {
            renderPassEvent = RenderPassEvent.AfterRenderingSkybox
        };
    }

    public override void AddRenderPasses(ScriptableRenderer renderer)
    {
        renderer.EnqueuePass(m_HBAOPass);
    }


    class HBAOPass : ScriptableRenderPass
    {
        ProfilingSampler m_ProfilingSampler = new ProfilingSampler("HBAO");
        static readonly int m_FrustumCornersRayID = Shader.PropertyToID("_FrustumCornersRay");
        static readonly int m_NoiseTextureID = Shader.PropertyToID("_NoiseTex");
        static readonly int m_ParamsID = Shader.PropertyToID("_Params");
        static readonly int m_Params2ID = Shader.PropertyToID("_Params2");

        Material m_Material;
        Settings m_Settings;

        RenderTextureDescriptor m_Descriptor;

        RenderTargetHandle m_HBAOTextureHandle;

        GaussianBlurRendererPass m_BlurPass;

        public HBAOPass(Settings settings, GaussianBlurRendererPass blurPass)
        {
            m_Settings = settings;
            m_BlurPass = blurPass;
            m_Material = CoreUtils.CreateEngineMaterial("Hidden/LcLPostProcess/HBAO");
            m_HBAOTextureHandle.Init("_HBAOTexture");
        }


        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            ConfigureInput(ScriptableRenderPassInput.Depth | ScriptableRenderPassInput.Normal);


            m_Descriptor = cameraTextureDescriptor;
            m_Descriptor.msaaSamples = 1;
            m_Descriptor.width = m_Descriptor.width >> m_Settings.downSample;
            m_Descriptor.height = m_Descriptor.height >> m_Settings.downSample;

            cmd.GetTemporaryRT(m_HBAOTextureHandle.id, cameraTextureDescriptor);

            m_BlurPass.Configure(cmd, m_Descriptor);
        }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            m_BlurPass.OnCameraSetup(cmd, ref renderingData);
        }

        /// <summary>
        /// 计算相机在远裁剪面处的四个角的方向向量
        /// </summary>
        /// <param name="camera"></param>
        /// <param name="commandBuffer"></param>
        private Matrix4x4 CalculateFrustumCornersRay(Camera camera, Matrix4x4 projInv)
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

            topLeft = projInv.MultiplyVector(topLeft);
            topRight = projInv.MultiplyVector(topRight);
            bottomLeft = projInv.MultiplyVector(bottomLeft);
            bottomRight = projInv.MultiplyVector(bottomRight);


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
            if (m_Material == null)
                return;

            ref CameraData cameraData = ref renderingData.cameraData;
            var renderer = cameraData.renderer;
            var camera = cameraData.camera;
            Matrix4x4 proj = renderingData.cameraData.GetProjectionMatrix();
            // 计算proj逆矩阵，即从裁剪空间变换到世界空间
            Matrix4x4 projInv = proj.inverse;

            var sourceWidth = cameraData.cameraTargetDescriptor.width;
            var sourceHeight = cameraData.cameraTargetDescriptor.height;


            CommandBuffer cmd = CommandBufferPool.Get();

            using (new ProfilingScope(cmd, m_ProfilingSampler))
            {
                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();
                RenderTargetIdentifier source = renderer.cameraColorTarget;


                float tanHalfFovY = Mathf.Tan(0.5f * camera.fieldOfView * Mathf.Deg2Rad);

                float invFocalLenX = 1.0f / (1.0f / tanHalfFovY * (sourceHeight / (float)sourceWidth));
                float invFocalLenY = 1.0f / (1.0f / tanHalfFovY);
                float maxRadInPixels = Mathf.Max(16, m_Settings.maxRadiusPixels * Mathf.Sqrt(sourceWidth * sourceHeight / (1080.0f * 1920.0f)));

                float radius = m_Settings.radius * 0.5f * (sourceHeight / (tanHalfFovY * 2.0f));

                m_Material.SetVector(m_ParamsID, new Vector4(
                    radius,
                    m_Settings.angleBias,
                    m_Settings.intensity,
                    maxRadInPixels
                ));

                // _MaxDistance,_DistanceFalloff, _NegInvRadius2,_AoMultiplier
                m_Material.SetVector(m_Params2ID, new Vector4(
                    m_Settings.maxDistance,
                    m_Settings.distanceFalloff,
                    -1.0f / (m_Settings.radius * m_Settings.radius),
                    1.0f / (1.0f - m_Settings.angleBias)
                    ));

                m_Material.SetTexture(m_NoiseTextureID, m_Settings.noiseTexture);

                var viewPortRay = CalculateFrustumCornersRay(camera, projInv);
                cmd.SetGlobalMatrix(m_FrustumCornersRayID, viewPortRay);


                LcLRenderingUtils.SetSourceTexture(cmd, source);
                LcLRenderingUtils.SetSourceSize(cmd, m_Descriptor);
                // LcLRenderingUtils.Blit(cmd, renderingData, m_Material, 0);
                Blit(cmd, source, m_HBAOTextureHandle.Identifier(), m_Material, 0);



                m_BlurPass.SetRenderTarget(m_HBAOTextureHandle.Identifier());
                m_BlurPass.Execute(context, ref renderingData, cmd);
            }

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            cmd.ReleaseTemporaryRT(m_HBAOTextureHandle.id);
            m_BlurPass.OnCameraCleanup(cmd);
        }
    }
}
