using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class BakeTextureFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class Settings
    {
        public RenderPassEvent renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
        public Mesh drawMesh = null;
        public Color color = Color.white;
    }

    public Settings settings = new Settings();
    private CommandExamplePass m_BlitPass;

    public override void Create()
    {
        m_BlitPass = new CommandExamplePass(name, settings)
        {
            renderPassEvent = settings.renderPassEvent
        };
    }


    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (settings.drawMesh == null)
        {
            return;
        }
        m_BlitPass.SetTarget(renderer.cameraColorTarget);
        renderer.EnqueuePass(m_BlitPass);
    }

    public class CommandExamplePass : ScriptableRenderPass
    {
        static readonly int m_RenderTexture = Shader.PropertyToID("_RenderTexture");
        static readonly string m_Shader = "lcl/CommandBuffer/BakeTexture";
        private Material m_Material;
        private Settings m_Settings;
        private RenderTargetIdentifier m_Source;
        private ProfilingSampler m_ProfilingSampler;

        public CommandExamplePass(string tag, Settings settings)
        {
            m_ProfilingSampler = new ProfilingSampler(tag);
            m_Material = CoreUtils.CreateEngineMaterial(m_Shader);
            this.m_Settings = settings;
        }

        public void SetTarget(RenderTargetIdentifier cameraColorTarget)
        {
            m_Source = cameraColorTarget;
        }

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
            using (new ProfilingScope(command, m_ProfilingSampler))
            {
                m_Material.SetColor("_Color", m_Settings.color);
                command.DrawMesh(m_Settings.drawMesh, Matrix4x4.identity, m_Material, 0, 0);
                command.Blit(m_RenderTexture, m_Source);
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
