using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace LcLGame
{
    class TemporalAACameraPass : ScriptableRenderPass
    {
        ProfilingSampler m_ProfilingSampler = new ProfilingSampler("Temporal Anti-Aliasing Camera Pass");
        Matrix4x4 m_Matrix;

        public void Setup(Matrix4x4 matrix)
        {
            m_Matrix = matrix;
        }
        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
        }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            ref CameraData cameraData = ref renderingData.cameraData;
            var renderer = cameraData.renderer;
            var camera = cameraData.camera;

            CommandBuffer cmd = CommandBufferPool.Get();
            using (new ProfilingScope(cmd, m_ProfilingSampler))
            {
                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();

                cmd.SetViewProjectionMatrices(camera.worldToCameraMatrix, m_Matrix);
            }

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {
        }
    }
}
