using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class ReconstructWorldPosition1 : ScriptableRendererFeature
{
    public RenderPassEvent m_RenderPassEvent = RenderPassEvent.AfterRenderingTransparents;
    ReconstructRenderPass m_RenderPass;
    public override void Create()
    {
        m_RenderPass = new ReconstructRenderPass(name);

        m_RenderPass.renderPassEvent = m_RenderPassEvent;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_RenderPass);
    }

    class ReconstructRenderPass : ScriptableRenderPass
    {
        readonly string m_ShaderName = "LcL/Depth/ReconstructWorldPosition1";
        string m_ProfilerTag;
        Material m_Material;

        public ReconstructRenderPass(string tag)
        {
            m_ProfilerTag = tag;
            m_Material = CoreUtils.CreateEngineMaterial(m_ShaderName);

        }
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {

        }


        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer command = CommandBufferPool.Get(m_ProfilerTag);
            var camera = renderingData.cameraData.camera;

            Matrix4x4 ProjectionMatrix = GL.GetGPUProjectionMatrix(camera.projectionMatrix, true);
            var vpMatrix = camera.projectionMatrix * camera.worldToCameraMatrix;
            command.SetGlobalMatrix("_InverseVPMatrix", vpMatrix.inverse);

            Blit(command, ref renderingData, m_Material, 0);

            context.ExecuteCommandBuffer(command);
            CommandBufferPool.Release(command);
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {

        }
    }
}


