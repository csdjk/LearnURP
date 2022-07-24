using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

/// <summary>
/// Rain RendererFeature
/// </summary>
public class RainFeature : ScriptableRendererFeature
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

        public Shader rainShader;
        public Mesh rainMesh;
        public Texture2D rainTexture = null;
        public Color rainColor = Color.gray;
        [Range(0f, 1f)]
        public float rainAlpha = 1f;

        public RainLayerData layerFar;
        public RainLayerData layerNear;

        public Vector3 windDir = Vector3.zero;

        [HideInInspector]
        public Material rainMaterial = null;

    }

    public RainSettings settings = new RainSettings();
    private RainPass blitPass;

    public override void Create()
    {
        if (!isActive)
        {
            DestroyImmediate(settings.rainMaterial);
            return;
        }
        if (!settings.rainMaterial)
        {
            if (!settings.rainShader)
            {
                settings.rainShader = Shader.Find("LcL/Rain");
                return;
            }
            settings.rainMaterial = new Material(settings.rainShader);
            settings.rainMaterial.hideFlags = HideFlags.DontSave;
        }
        blitPass = new RainPass(name, settings);
        blitPass.renderPassEvent = settings.renderPassEvent;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (settings.rainShader == null || settings.rainMesh == null)
        {
            Debug.LogWarning("rainShader or rainMesh 丢失!");
            return;
        }
        // blitPass.Setup(renderer.cameraDepth);
        blitPass.Setup(renderer.cameraColorTarget);
        renderer.EnqueuePass(blitPass);
    }



    public class RainPass : ScriptableRenderPass
    {
        private RainSettings settings;
        string m_ProfilerTag;
        RenderTargetIdentifier source;
        RenderTargetIdentifier tempRenderTexture = new RenderTargetIdentifier();
        RenderTargetIdentifier tempRenderTexture2 = new RenderTargetIdentifier();
        public RainPass(string tag, RainSettings settings)
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


            var dest = RenderTargetHandle.CameraTarget;
            // Configure(command, renderingData.cameraData.cameraTargetDescriptor);
            // command.GetTemporaryRT(settings.tempRenderTexture, camera.pixelWidth, camera.pixelHeight, 0);

            // command.SetGlobalTexture("_SourceTex", source);
            // command.Blit(source, settings.tempRenderTexture);
            // command.Blit(settings.tempRenderTexture, source, settings.rainMaterial);
            Render(camera, command);

            context.ExecuteCommandBuffer(command);
            CommandBufferPool.Release(command);
        }

        public void Render(Camera cam, CommandBuffer command)
        {
            var mat = settings.rainMaterial;
            command.SetGlobalTexture("_SourceTex", source);
            command.SetGlobalTexture("_RainTexture", settings.rainTexture);
            command.SetGlobalVector("_RainColor", settings.rainColor);
            command.SetGlobalFloat("_RainAlpha", settings.rainAlpha);

            var layerFar = settings.layerFar;
            var layerNear = settings.layerNear;

            if (RainRay.Instance)
            {
                layerFar.depthStart = RainRay.Instance.boundSize + 2;
                layerNear.depthStart = RainRay.Instance.boundSize;
                Debug.Log(layerNear.depthStart);

                settings.windDir.y = RainRay.Instance.transform.rotation.y;
            }

            // far layer
            command.SetGlobalVector("_FarTillingSpeed", new Vector4(layerFar.tilling.x, layerFar.tilling.y, layerFar.speed.x, layerFar.speed.y));
            command.SetGlobalFloat("_FarDepthStart", layerFar.depthStart);

            // near layer
            command.SetGlobalVector("_NearTillingSpeed", new Vector4(layerNear.tilling.x, layerNear.tilling.y, layerNear.speed.x, layerNear.speed.y));
            command.SetGlobalFloat("_NearDepthStart", layerNear.depthStart);



            var pos = cam.transform.position;
            // pos = Vector3.zero;
            var xform = Matrix4x4.TRS(pos, Quaternion.Euler(settings.windDir), new Vector3(1f, 1f, 1f));
            command.SetRenderTarget(tempRenderTexture);
            command.DrawMesh(settings.rainMesh, xform, settings.rainMaterial);

        }
    }
}
