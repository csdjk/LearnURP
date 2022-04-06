using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

/// <summary>
/// 自定义RendererFeature(后期处理)
/// </summary>
public class RainFeature : ScriptableRendererFeature
{

    /// <summary>
    /// 设置面板（PipelineAsset Inspector面板会显示这些属性）
    /// </summary>
    [System.Serializable]
    public class Settings
    {
        public RenderPassEvent renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
        public Material blitMaterial = null;
        public RenderTexture renderTexture = null;
        public Color color = new Color(1, 1, 1, 0);
    }

    public Settings settings = new Settings();
    private CustomPass blitPass;

    /// <summary>
    /// 初始化此特性的资源。每次序列化发生时都会调用此函数。
    /// </summary>
    public override void Create()
    {
        if (!settings.renderTexture)
            settings.renderTexture = RenderTexture.GetTemporary(1280, 720, 0);
        blitPass = new CustomPass(name, settings);

        blitPass.renderPassEvent = settings.renderPassEvent;
    }

    // Here you can inject one or multiple render passes in the renderer.
    // 当为每个摄像机设置渲染器时，会调用此方法。
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (settings.blitMaterial == null)
        {
            Debug.LogWarning("blit材质丢失");
            return;
        }
        // blitPass.Setup(renderer.cameraDepth);
        blitPass.Setup(renderer.cameraColorTarget);
        renderer.EnqueuePass(blitPass);
    }



    /// <summary>
    /// 可用于扩展URP渲染器。
    /// </summary>
    public class CustomPass : ScriptableRenderPass
    {

        private Settings settings;
        string m_ProfilerTag;
        RenderTargetIdentifier source;
        private RenderTextureDescriptor m_OpaqueDesc;
        private RenderTargetHandle m_ColorHandle;
        static readonly int MainTexId = Shader.PropertyToID("_MainTex");
        static readonly int TempTargetId = Shader.PropertyToID("_TempTargetZoomBlur");

        public CustomPass(string tag, Settings settings)
        {
            m_ProfilerTag = tag;
            this.settings = settings;
        }

        public void Setup(RenderTargetIdentifier src)
        {
            source = src;
        }
        // public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        // {
        //     cameraTextureDescriptor.msaaSamples = 1;
        //     m_OpaqueDesc = cameraTextureDescriptor;
        //     cmd.GetTemporaryRT(m_ColorHandle.id, cameraTextureDescriptor, FilterMode.Bilinear);
        // }
        public RenderTargetIdentifier tempRenderTexture = new RenderTargetIdentifier();

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            ref var cameraData = ref renderingData.cameraData;

            CommandBuffer command = CommandBufferPool.Get(m_ProfilerTag);
            settings.blitMaterial.SetColor("_Color", settings.color);

            // Configure(command,cameraData.cameraTargetDescriptor);
            // int destination = Shader.PropertyToID("_BlitTex");
            // var w = cameraData.camera.scaledPixelWidth;
            // var h = cameraData.camera.scaledPixelHeight;

            // command.GetTemporaryRT(destination, w, h, 0, FilterMode.Point, RenderTextureFormat.Default);
            // command.Blit(source, destination);

            command.SetGlobalTexture("_BlitTex", source);
            command.SetRenderTarget(tempRenderTexture);
            command.DrawMesh(RenderingUtils.fullscreenMesh, Matrix4x4.identity, settings.blitMaterial);

            // command.Blit(null, source);
            context.ExecuteCommandBuffer(command);
            CommandBufferPool.Release(command);
        }
    }
}