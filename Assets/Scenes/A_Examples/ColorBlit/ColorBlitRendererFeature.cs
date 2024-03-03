using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

internal class ColorBlitRendererFeature : ScriptableRendererFeature
{
    [Range(0, 5)]
    public float m_Intensity = 1;

    Material m_Material;

    ColorBlitPass m_RenderPass = null;

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (renderingData.cameraData.cameraType == CameraType.Preview)
            return;

        renderer.EnqueuePass(m_RenderPass);
    }

    public override void Create()
    {
        m_Material = CoreUtils.CreateEngineMaterial("Hidden/ColorBlit");
        m_RenderPass = new ColorBlitPass(m_Material);
        m_RenderPass.intensity = m_Intensity;
    }

    protected override void Dispose(bool disposing)
    {
        CoreUtils.Destroy(m_Material);
    }
}


internal class ColorBlitPass : ScriptableRenderPass
{
    ProfilingSampler m_ProfilingSampler = new ProfilingSampler("ColorBlit");
    Material m_Material;
    public float intensity;

    public ColorBlitPass(Material material)
    {
        m_Material = material;
        renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
    }


    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        if (m_Material == null)
            return;

        ref CameraData cameraData = ref renderingData.cameraData;
        var renderer = cameraData.renderer;
        var camera = cameraData.camera;

        CommandBuffer cmd = CommandBufferPool.Get();
        using (new ProfilingScope(cmd, m_ProfilingSampler))
        {
            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();
            // LcLRenderingUtils.SetSourceSize(cmd, m_Descriptor);

            RenderTargetIdentifier source = renderer.cameraColorTarget;
            // RenderTargetIdentifier destination = renderer.GetCameraColorFrontBuffer(cmd);


            m_Material.SetFloat("_Intensity", intensity);

            // 这里设置了RenderBufferLoadAction.DontCare，节省带宽
            LcLRenderingUtils.Blit(cmd, renderingData, m_Material, 0);

        }
        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
    }
}

