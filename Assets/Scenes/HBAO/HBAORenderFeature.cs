using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using LcLGame;
using UnityEngine.Serialization;

public class HBAORenderFeature : RendererFeatureBase
{
    public enum NoiseType
    {
        Dither,
        InterleavedGradientNoise,
    }
    public enum PerPixelNormals
    {
        Reconstruct2Samples,
        Reconstruct4Samples,
        Camera
    }
    [System.Serializable]
    public class Settings
    {

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

        public NoiseType noiseType = NoiseType.Dither;
        public Texture2D noiseTexture;
        public PerPixelNormals perPixelNormals = PerPixelNormals.Reconstruct4Samples;
        public bool useBlur = true;

    }

    public Settings settings = new Settings();

    HBAOPass m_HBAOPass;

    public override void Create()
    {
        m_HBAOPass = new HBAOPass(settings)
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
        static readonly int m_NoiseTextureID = Shader.PropertyToID("_NoiseTex");
        static readonly int m_ParamsID = Shader.PropertyToID("_Params");
        static readonly int m_Params2ID = Shader.PropertyToID("_Params2");
        static readonly int m_BlurOffsetID = Shader.PropertyToID("_BlurOffset");

        static readonly string m_InterleavedGradientNoiseKeyword = "INTERLEAVED_GRADIENT_NOISE";
        static readonly string m_NormalsReconstruct4Keyword = "NORMALS_RECONSTRUCT4";
        static readonly string m_NormalsReconstruct2Keyword = "NORMALS_RECONSTRUCT2";
        static readonly string m_NormalsCameraKeyword = "NORMALS_CAMERA";


        Material m_Material;
        Settings m_Settings;

        RenderTextureDescriptor m_Descriptor;

        RenderTargetHandle m_HBAOTextureHandle;
        RenderTargetHandle m_TempTextureHandle1;
        private string[] m_ShaderKeywords;

        public HBAOPass(Settings settings)
        {
            m_Settings = settings;
            m_Material = CoreUtils.CreateEngineMaterial("Hidden/LcLPostProcess/HBAO");
            m_HBAOTextureHandle.Init("_HBAOTexture");
            m_TempTextureHandle1.Init("_TempTexture");
        }


        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            //这个normal没啥用, 内置Shader把normalWS压缩到texture没有映射到[0,1],导致解压出来的normal不对
            // ConfigureInput(ScriptableRenderPassInput.Depth | ScriptableRenderPassInput.Normal);

            m_Descriptor = cameraTextureDescriptor;
            m_Descriptor.msaaSamples = 1;
            m_Descriptor.width = m_Descriptor.width >> m_Settings.downSample;
            m_Descriptor.height = m_Descriptor.height >> m_Settings.downSample;
            m_Descriptor.colorFormat = RenderTextureFormat.ARGB32;

            cmd.GetTemporaryRT(m_HBAOTextureHandle.id, m_Descriptor);
            cmd.GetTemporaryRT(m_TempTextureHandle1.id, m_Descriptor);

            UpdateShaderKeywords();
        }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
        }


        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (m_Material == null)
                return;

            ref CameraData cameraData = ref renderingData.cameraData;
            var renderer = cameraData.renderer;
            var camera = cameraData.camera;


            CommandBuffer cmd = CommandBufferPool.Get();

            using (new ProfilingScope(cmd, m_ProfilingSampler))
            {
                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();
                RenderTargetIdentifier source = renderer.cameraColorTarget;

                RenderAO(cmd, camera, source);

                if (m_Settings.useBlur)
                    Blur(cmd);

                //Composite
                LcLRenderingUtils.SetSourceTexture(cmd, source);
                LcLRenderingUtils.SetSourceSize(cmd, m_Descriptor);
                cmd.SetGlobalTexture(m_HBAOTextureHandle.id, m_HBAOTextureHandle.Identifier());
                Blit(cmd, m_HBAOTextureHandle.Identifier(), source, m_Material, 2);
            }

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public static string GetPerPixelNormalsKeyword(PerPixelNormals perPixelNormals)
        {
            switch (perPixelNormals)
            {
                case PerPixelNormals.Reconstruct4Samples:
                    return m_NormalsReconstruct4Keyword;
                case PerPixelNormals.Reconstruct2Samples:
                    return m_NormalsReconstruct2Keyword;
                case PerPixelNormals.Camera:
                    return m_NormalsCameraKeyword;
                default:
                    return "__";
            }
        }
        public static string GetNoiseKeyword(NoiseType noiseType)
        {
            switch (noiseType)
            {
                case NoiseType.InterleavedGradientNoise:
                    return m_InterleavedGradientNoiseKeyword;
                case NoiseType.Dither:
                default:
                    return "__";
            }
        }
        private void UpdateShaderKeywords()
        {
            if (m_ShaderKeywords == null) m_ShaderKeywords = new string[2];

            m_ShaderKeywords[0] = GetNoiseKeyword(m_Settings.noiseType);
            m_ShaderKeywords[1] = GetPerPixelNormalsKeyword(m_Settings.perPixelNormals);

            m_Material.shaderKeywords = m_ShaderKeywords;

        }
        public void RenderAO(CommandBuffer cmd, Camera camera, RenderTargetIdentifier source)
        {
            var sourceWidth = m_Descriptor.width;
            var sourceHeight = m_Descriptor.height;

            float tanHalfFovY = Mathf.Tan(0.5f * camera.fieldOfView * Mathf.Deg2Rad);
            float maxRadInPixels = Mathf.Max(16, m_Settings.maxRadiusPixels * Mathf.Sqrt(sourceWidth * sourceHeight / (1080.0f * 1920.0f)));

            float radius = m_Settings.radius * 0.5f * (sourceHeight / (tanHalfFovY * 2.0f));

            cmd.SetGlobalVector(m_ParamsID, new Vector4(
                radius,
                m_Settings.angleBias,
                m_Settings.intensity,
                maxRadInPixels
            ));

            // _MaxDistance,_DistanceFalloff, _NegInvRadius2,_AoMultiplier
            cmd.SetGlobalVector(m_Params2ID, new Vector4(
                m_Settings.maxDistance,
                m_Settings.distanceFalloff,
                -1.0f / (m_Settings.radius * m_Settings.radius),
                1.0f / (1.0f - m_Settings.angleBias)
                ));

            if (m_Settings.noiseType == NoiseType.Dither)
            {
                cmd.SetGlobalTexture(m_NoiseTextureID, m_Settings.noiseTexture);
            }


            LcLRenderingUtils.SetSourceTexture(cmd, source);
            LcLRenderingUtils.SetSourceSize(cmd, m_Descriptor);
            Blit(cmd, source, m_HBAOTextureHandle.Identifier(), m_Material, 0);

        }

        public void Blur(CommandBuffer cmd)
        {
            LcLRenderingUtils.SetSourceSize(cmd, m_Descriptor);

            LcLRenderingUtils.SetSourceTexture(cmd, m_HBAOTextureHandle.id);
            cmd.SetGlobalVector(m_BlurOffsetID, new Vector4(0, 1, 0, 0));
            Blit(cmd, m_HBAOTextureHandle.id, m_TempTextureHandle1.id, m_Material, 1);

            LcLRenderingUtils.SetSourceTexture(cmd, m_TempTextureHandle1.id);
            cmd.SetGlobalVector(m_BlurOffsetID, new Vector4(1, 0, 0, 0));
            Blit(cmd, m_TempTextureHandle1.id, m_HBAOTextureHandle.id, m_Material, 1);
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            cmd.ReleaseTemporaryRT(m_HBAOTextureHandle.id);
            cmd.ReleaseTemporaryRT(m_TempTextureHandle1.id);
        }
    }
}
