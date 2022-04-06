using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

/// <summary>
/// Rain RendererFeature
/// </summary>
public class RainFeature : ScriptableRendererFeature
{

    [System.Serializable]
    public class RainSettings
    {
        public RenderPassEvent renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;

        public Shader rainShader;
        public Mesh rainMesh;
        public Texture2D rainTexture = null;
        public Color rainColor = Color.gray;


        // Far Rain
        public Vector2 tillingFar = new Vector2(20f, 5f);
        public Vector2 speedFar = new Vector2(0f, 10f);
        // Near Rain
        public Vector2 tillingNear = new Vector2(10f, 8f);
        public Vector2 speedNear = new Vector2(0f, 30f);


        public Vector4 rainDepthRange = Vector4.one;
        public Vector4 rainDepthStart = Vector4.zero;

        public Vector3 windDir = Vector3.zero;



        [Range(0.25f, 4f)]
        public float lightExponent = 1f;
        [Range(0.25f, 4f)]
        public float lightIntensity1 = 1f;
        [Range(0.25f, 4f)]
        public float lightIntensity2 = 1f;

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
            var shader = settings.rainShader ?? Shader.Find("Hidden/DodRain1");
            if (!shader)
                return;
            settings.rainMaterial = new Material(shader);
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
            command.SetGlobalVector("_FarRainData", new Vector4(settings.tillingFar.x, settings.tillingFar.y, settings.speedFar.x, settings.speedFar.y));
            command.SetGlobalVector("_NearRainData", new Vector4(settings.tillingNear.x, settings.tillingNear.y, settings.speedNear.x, settings.speedNear.y));

            command.SetGlobalVector("_RainColor", settings.rainColor);

            command.SetGlobalVector("_RainDepthRange", settings.rainDepthRange);


            if (RainRay.Instance)
            {
                // x:far , y: near
                settings.rainDepthStart.x = RainRay.Instance.boundSize + 5;
                settings.rainDepthStart.y = RainRay.Instance.boundSize;
                Debug.Log(settings.rainDepthStart);

                settings.windDir.y = RainRay.Instance.transform.rotation.y;
            }
            command.SetGlobalVector("_RainDepthStart", settings.rainDepthStart);
            command.SetGlobalFloat("_LightExponent", settings.lightExponent);
            command.SetGlobalFloat("_LightIntensity1", settings.lightIntensity1);
            command.SetGlobalFloat("_LightIntensity2", settings.lightIntensity2);

            var pos = cam.transform.position;
            // pos = Vector3.zero;
            var xform = Matrix4x4.TRS(pos, Quaternion.Euler(settings.windDir), new Vector3(1f, 1f, 1f));
            command.SetRenderTarget(tempRenderTexture);
            command.DrawMesh(settings.rainMesh, xform, settings.rainMaterial);

        }
    }
}
