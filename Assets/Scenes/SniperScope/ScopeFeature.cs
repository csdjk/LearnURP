using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class ScopeFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class RainLayerData
    {
        public Vector2 tilling = new Vector2(10f, 10f);
        public Vector2 speed = new Vector2(0f, 50f);
        [Range(0, 30)]
        public float depthStart = 0f;
    }

    [System.Serializable]
    public class RainSettings
    {
        public RenderPassEvent renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;

        public Shader shader;
        public Mesh scopeMesh;
        // public Texture2D tempTexture = null;
        public Material material = null;
    }

    public RainSettings settings = new RainSettings();
    private ScopePass blitPass;

    public override void Create()
    {
        if (!isActive)
        {
            DestroyImmediate(settings.material);
            return;
        }
        if (!settings.material)
        {
            if (!settings.shader)
            {
                // settings.rainShader = Shader.Find("LcL/Scope");
                return;
            }
            settings.material = new Material(settings.shader);
            settings.material.hideFlags = HideFlags.DontSave;
        }
        blitPass = new ScopePass(name, settings);
        blitPass.renderPassEvent = settings.renderPassEvent;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (settings.shader == null || settings.scopeMesh == null)
        {
            Debug.LogWarning("rainShader or rainMesh 丢失!");
            return;
        }
        blitPass.Setup(renderer.cameraColorTarget);
        renderer.EnqueuePass(blitPass);
    }



    public class ScopePass : ScriptableRenderPass
    {
        private RainSettings settings;
        string m_ProfilerTag;
        RenderTargetIdentifier source;
        RenderTargetIdentifier tempRenderTexture = new RenderTargetIdentifier();
        RenderTargetIdentifier tempRenderTexture2 = new RenderTargetIdentifier();
        public ScopePass(string tag, RainSettings settings)
        {
            m_ProfilerTag = tag;
            this.settings = settings;
        }

        public void Setup(RenderTargetIdentifier src)
        {
            source = src;
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            var camera = renderingData.cameraData.camera;
            CommandBuffer command = CommandBufferPool.Get(m_ProfilerTag);
            var fov = camera.fieldOfView;
            camera.fieldOfView = 60;

            var dest = RenderTargetHandle.CameraTarget;
            Render(camera, command);
            context.ExecuteCommandBuffer(command);
            CommandBufferPool.Release(command);

            camera.fieldOfView = fov;
        }

        public void Render(Camera cam, CommandBuffer command)
        {

            var pos = cam.transform.position;
            pos.z = pos.z + 2;
            // pos = Vector3.zero;
            var xform = Matrix4x4.TRS(pos, Quaternion.Euler(0, 0, 0), new Vector3(1f, 1f, 1f));
            command.SetRenderTarget(tempRenderTexture);
            command.DrawMesh(settings.scopeMesh, xform, settings.material);

        }
    }
}
