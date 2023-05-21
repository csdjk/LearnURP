using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class ReconstructWorldPosition3 : ScriptableRendererFeature
{
    [System.Serializable]
    public class ReconstructPositionSettings
    {
        public RenderPassEvent renderPassEvent = RenderPassEvent.AfterRenderingTransparents;
        public bool useVertexID = true;
    }

    public ReconstructPositionSettings settings = new ReconstructPositionSettings();

    ReconstructRenderPass m_RenderPass;
    public override void Create()
    {
        m_RenderPass = new ReconstructRenderPass(name, settings);

        m_RenderPass.renderPassEvent = settings.renderPassEvent;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_RenderPass);
    }

    class ReconstructRenderPass : ScriptableRenderPass
    {
        readonly string m_ShaderName = "LcL/Depth/ReconstructWorldPosition4";
        string m_ProfilerTag;
        ReconstructPositionSettings m_Setting;
        Material m_Material;

        public ReconstructRenderPass(string tag, ReconstructPositionSettings settings)
        {
            m_ProfilerTag = tag;
            m_Setting = settings;
            m_Material = CoreUtils.CreateEngineMaterial(m_ShaderName);

        }
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {

        }


        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer command = CommandBufferPool.Get(m_ProfilerTag);
            var camera = renderingData.cameraData.camera;


            Blit(command, ref renderingData, m_Material, 0);

            context.ExecuteCommandBuffer(command);
            CommandBufferPool.Release(command);
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {

        }
    }
}


