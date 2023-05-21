using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

/// <summary>
/// 自定义RendererFeature(后期处理)
/// </summary>
public class SimplePostProcess : ScriptableRendererFeature
{

    /// <summary>
    /// 设置面板（PipelineAsset Inspector面板会显示这些属性）
    /// </summary>
    [System.Serializable]
    public class Settings
    {
        public RenderPassEvent renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
        public Color color = new Color(1, 1, 1, 0);
    }

    public Settings settings = new Settings();
    private CustomPass blitPass;

    /// <summary>
    /// 初始化此特性的资源。每次序列化发生时都会调用此函数。
    /// </summary>
    public override void Create()
    {
        blitPass = new CustomPass(name, settings);
        blitPass.renderPassEvent = settings.renderPassEvent;
    }

    // Here you can inject one or multiple render passes in the renderer.
    // 当为每个摄像机设置渲染器时，会调用此方法。
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(blitPass);
    }



    /// <summary>
    /// 可用于扩展URP渲染器。
    /// </summary>
    public class CustomPass : ScriptableRenderPass
    {
        readonly string m_ShaderName = "LcL/PostProcess/SimplePostProcess";
        private Settings m_Setting;
        string m_ProfilerTag;
        Material m_Material;

        public CustomPass(string tag, Settings settings)
        {
            m_ProfilerTag = tag;
            m_Setting = settings;
            m_Material = CoreUtils.CreateEngineMaterial(m_ShaderName);
        }



        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer command = CommandBufferPool.Get(m_ProfilerTag);
            m_Material.SetColor("_Color", m_Setting.color);

            var source = renderingData.cameraData.renderer.cameraColorTarget;

            Blit(command, ref renderingData, m_Material, 0);
            context.ExecuteCommandBuffer(command);
            CommandBufferPool.Release(command);
        }

    }
}
