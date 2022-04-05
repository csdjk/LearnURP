using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

/// <summary>
/// Command Buffer
/// </summary>
public class CommandBufferExample : ScriptableRendererFeature
{
    /// <summary>
    /// 设置面板（PipelineAsset Inspector面板会显示这些属性）
    /// </summary>
    [System.Serializable]
    public class Settings
    {
        public RenderPassEvent renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
        public Mesh drawMesh = null;
        public RenderTexture renderTexture = null;
        public Material drawMaterial = null;
        public Color color = Color.white;
    }

    public Settings settings = new Settings();
    private CommandExamplePass blitPass;

    /// <summary>
    /// 初始化此特性的资源。每次序列化发生时都会调用此函数。
    /// </summary>
    public override void Create()
    {
        if (!settings.renderTexture)
            settings.renderTexture = RenderTexture.GetTemporary(1024, 1024, 0);

        blitPass = new CommandExamplePass(name, settings);
        blitPass.renderPassEvent = settings.renderPassEvent;
    }

    // Here you can inject one or multiple render passes in the renderer.
    // 当为每个摄像机设置渲染器时，会调用此方法。
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (settings.drawMaterial == null)
        {
            Debug.LogWarning("blit材质丢失");
            return;
        }
        blitPass.SetTarget(renderer.cameraColorTarget);
        renderer.EnqueuePass(blitPass);

    }


    /// <summary>
    /// 可用于扩展URP渲染器。
    /// </summary>
    public class CommandExamplePass : ScriptableRenderPass
    {
        private Settings settings;
        private RenderTargetIdentifier source;
        private ProfilingSampler m_ProfilingSampler;

        public CommandExamplePass(string tag, Settings settings)
        {
            m_ProfilingSampler = new ProfilingSampler(tag);
            this.settings = settings;
        }

        public void SetTarget(RenderTargetIdentifier cameraColorTarget)
        {
            source = cameraColorTarget;
        }
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer command = CommandBufferPool.Get();
            using (new ProfilingScope(command, m_ProfilingSampler))
            {
                settings.drawMaterial.SetColor("_Color", settings.color);
                command.SetRenderTarget(settings.renderTexture);
                command.DrawMesh(settings.drawMesh, Matrix4x4.identity, settings.drawMaterial, 0, 0);
                command.Blit(settings.renderTexture, source);
            }
            context.ExecuteCommandBuffer(command);
            CommandBufferPool.Release(command);
        }


    }
}
