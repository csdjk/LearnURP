using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class ReconstructWorldPosition2 : ScriptableRendererFeature
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
        readonly string m_ShaderName = "LcL/Depth/ReconstructWorldPosition2";
        string m_ProfilerTag;
        ReconstructPositionSettings m_Setting;
        Material m_Material;
        static readonly int m_CameraForwardID = Shader.PropertyToID("_CameraForward");
        static readonly int m_FrustumCornersRayID = Shader.PropertyToID("_ViewPortRay");
        public ReconstructRenderPass(string tag, ReconstructPositionSettings settings)
        {
            m_ProfilerTag = tag;
            m_Setting = settings;
            m_Material = CoreUtils.CreateEngineMaterial(m_ShaderName);

        }
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {

        }
        /// <summary>
        /// 计算相机在远裁剪面处的四个角的方向向量(正交相机)
        /// </summary>
        /// <param name="camera"></param>
        /// <param name="commandBuffer"></param>
        private void CalculateFrustumCornersRayOrtho(Camera camera, CommandBuffer commandBuffer)
        {
            var aspect = camera.aspect;
            var far = camera.farClipPlane;
            var orthoSize = camera.orthographicSize;
            var right = camera.transform.right;
            var up = camera.transform.up;
            var forward = camera.transform.forward;

            //计算相机在远裁剪面处的xyz三方向向量
            var rightVec = right * orthoSize * aspect;
            var upVec = up * orthoSize;

            //构建四个角的方向向量
            var topLeft = -rightVec + upVec;
            var topRight = rightVec + upVec;
            var bottomLeft = -rightVec - upVec;
            var bottomRight = rightVec - upVec;

            var viewPortRay = Matrix4x4.identity;

            //计算近裁剪平面四个角对应向量，并存储在一个矩阵类型的变量中
            viewPortRay.SetRow(0, bottomLeft);
            viewPortRay.SetRow(1, topLeft);
            viewPortRay.SetRow(2, topRight);
            viewPortRay.SetRow(3, bottomRight);
            commandBuffer.SetGlobalMatrix(m_FrustumCornersRayID, viewPortRay);
            commandBuffer.SetGlobalVector(m_CameraForwardID, forward * far);
        }

        /// <summary>
        /// 计算相机在远裁剪面处的四个角的方向向量(透视相机)
        /// </summary>
        /// <param name="camera"></param>
        /// <param name="commandBuffer"></param>
        private void CalculateFrustumCornersRay(Camera camera, CommandBuffer commandBuffer)
        {
            var aspect = camera.aspect;
            var far = camera.farClipPlane;
            var right = camera.transform.right;
            var up = camera.transform.up;
            var forward = camera.transform.forward;
            var halfFovTan = Mathf.Tan(camera.fieldOfView * 0.5f * Mathf.Deg2Rad);

            //计算相机在远裁剪面处的xyz三方向向量
            var rightVec = right * far * halfFovTan * aspect;
            var upVec = up * far * halfFovTan;
            var forwardVec = forward * far;

            //构建四个角的方向向量
            var topLeft = (forwardVec - rightVec + upVec);
            var topRight = (forwardVec + rightVec + upVec);
            var bottomLeft = (forwardVec - rightVec - upVec);
            var bottomRight = (forwardVec + rightVec - upVec);

            var viewPortRay = Matrix4x4.identity;

            //计算近裁剪平面四个角对应向量，并存储在一个矩阵类型的变量中
            viewPortRay.SetRow(0, bottomLeft);
            viewPortRay.SetRow(1, topLeft);
            viewPortRay.SetRow(2, topRight);
            viewPortRay.SetRow(3, bottomRight);
            commandBuffer.SetGlobalMatrix(m_FrustumCornersRayID, viewPortRay);
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer command = CommandBufferPool.Get(m_ProfilerTag);
            var camera = renderingData.cameraData.camera;

            command.Clear();

            if (m_Setting.useVertexID)
            {
                command.EnableShaderKeyword("_USE_VERTEX_ID");
            }
            else
            {
                command.DisableShaderKeyword("_USE_VERTEX_ID");
            }
            if (camera.orthographic)
            {
                CalculateFrustumCornersRayOrtho(camera, cmd);
            }
            else
            {
                CalculateFrustumCornersRay(camera, cmd);
            }
            Blit(command, ref renderingData, m_Material, 0);

            context.ExecuteCommandBuffer(command);
            CommandBufferPool.Release(command);
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {

        }
    }
}


