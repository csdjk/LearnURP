using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using LcLGame;
using UnityEngine.Serialization;

public class DepthReconstructPositionVS : RendererFeatureBase
{
    [System.Serializable]
    public class Settings
    {
        public bool show = true;
    }

    public Settings settings = new Settings();
    RenderPass m_ScriptablePass;

    public override void Create()
    {
        m_ScriptablePass = new RenderPass(settings)
        {
            renderPassEvent = RenderPassEvent.AfterRenderingTransparents
        };
    }

    public override void AddRenderPasses(ScriptableRenderer renderer)
    {

        renderer.EnqueuePass(m_ScriptablePass);
    }



    class RenderPass : ScriptableRenderPass
    {
        ProfilingSampler m_ProfilingSampler = new ProfilingSampler("Depth Reconstruct PositionVS");
        string m_ShaderName = "Hidden/LcL/Depth/DepthReconstructPositionVS";
        Material m_Material;
        Settings m_Settings;

        public RenderPass(Settings settings)
        {
            m_Settings = settings;
            m_Material = CoreUtils.CreateEngineMaterial(m_ShaderName);
        }


        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
        }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (m_Material == null)
                return;

            ref CameraData cameraData = ref renderingData.cameraData;
            var renderer = cameraData.renderer;
            var camera = cameraData.camera;
            RenderTargetIdentifier source = renderer.cameraColorTarget;

            CommandBuffer cmd = CommandBufferPool.Get();

            using (new ProfilingScope(cmd, m_ProfilingSampler))
            {
                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();

                cmd.SetGlobalFloat("_ShowViewPos" , m_Settings.show ? 1 : 0);
                LcLRenderingUtils.SetSourceTexture(cmd, source);
                LcLRenderingUtils.Blit(cmd, renderingData, m_Material, 0);
            }

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {
        }
    }
}



