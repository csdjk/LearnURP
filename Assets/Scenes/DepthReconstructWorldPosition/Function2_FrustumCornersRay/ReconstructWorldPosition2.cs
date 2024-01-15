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
        static readonly int m_FrustumCornersRayID = Shader.PropertyToID("_FrustumCornersRay");
        readonly string m_ShaderName = "LcL/Depth/ReconstructWorldPosition2";
        string m_ProfilerTag;
        ReconstructPositionSettings m_Setting;
        Material m_Material;
        static readonly int m_CameraForwardID = Shader.PropertyToID("_CameraForward");
        public ReconstructRenderPass(string tag, ReconstructPositionSettings settings)
        {
            m_ProfilerTag = tag;
            m_Setting = settings;
            m_Material = CoreUtils.CreateEngineMaterial(m_ShaderName);
        }

        /// <summary>
        /// 计算相机在远裁剪面处的四个角的方向向量
        /// </summary>
        /// <param name="camera"></param>
        /// <param name="commandBuffer"></param>
        private Matrix4x4 CalculateFrustumCornersRay(Camera camera)
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
            CommandBuffer command = CommandBufferPool.Get(m_ProfilerTag);
            var camera = renderingData.cameraData.camera;

            context.ExecuteCommandBuffer(command);
            command.Clear();

            if (m_Setting.useVertexID)
            {
                command.EnableShaderKeyword("_USE_VERTEX_ID");
            }
            else
            {
                command.DisableShaderKeyword("_USE_VERTEX_ID");
            }

            var viewPortRay = CalculateFrustumCornersRay(camera);
            command.SetGlobalMatrix(m_FrustumCornersRayID, viewPortRay);

            Blit(command, ref renderingData, m_Material, 0);

            context.ExecuteCommandBuffer(command);
            CommandBufferPool.Release(command);
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {

        }
    }
}


