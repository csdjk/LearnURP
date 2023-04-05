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
        public Color color = Color.white;
    }

    public Settings settings = new Settings();
    private CommandExamplePass blitPass;

    /// <summary>
    /// 初始化此特性的资源。每次序列化发生时都会调用此函数。
    /// </summary>
    public override void Create()
    {
        blitPass = new CommandExamplePass(name, settings);
        blitPass.renderPassEvent = settings.renderPassEvent;
    }

    // Here you can inject one or multiple render passes in the renderer.
    // 当为每个摄像机设置渲染器时，会调用此方法。
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (settings.drawMesh == null)
        {
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
        static readonly int m_RenderTexture = Shader.PropertyToID("_RenderTexture");
        static readonly string m_Shader = "lcl/CommandBuffer/BakeTexture";
        //create material
        private Material m_Material;
        private Settings settings;
        private RenderTargetIdentifier source;
        private ProfilingSampler m_ProfilingSampler;

        public CommandExamplePass(string tag, Settings settings)
        {
            m_ProfilingSampler = new ProfilingSampler(tag);
            m_Material = CoreUtils.CreateEngineMaterial(m_Shader);
            this.settings = settings;
        }

        public void SetTarget(RenderTargetIdentifier cameraColorTarget)
        {
            source = cameraColorTarget;
        }

        // 配置此渲染通道的输入和输出目标。
        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            cmd.GetTemporaryRT(m_RenderTexture, cameraTextureDescriptor);
            ConfigureTarget(m_RenderTexture);
            ConfigureClear(ClearFlag.All, Color.clear);
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {

            CommandBuffer command = CommandBufferPool.Get();
            var camera = renderingData.cameraData.camera;
            // renderingData.cameraData.isSceneViewCamera
            using (new ProfilingScope(command, m_ProfilingSampler))
            {
                m_Material.SetColor("_Color", settings.color);
                command.DrawMesh(settings.drawMesh, Matrix4x4.identity, m_Material, 0, 0);
                command.Blit(m_RenderTexture, source);
            }
            context.ExecuteCommandBuffer(command);
            CommandBufferPool.Release(command);
        }

        public override void FrameCleanup(CommandBuffer cmd)
        {
            cmd.ReleaseTemporaryRT(m_RenderTexture);
        }

        void Dispose(bool disposing)
        {
            if (m_Material != null)
            {
                CoreUtils.Destroy(m_Material);
            }
        }
    }
}
