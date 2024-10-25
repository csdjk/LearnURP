using System;
using System.Collections.Generic;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering;
using UnityEngine;
using UnityEngine.Experimental.Rendering.Universal;
using static UnityEngine.Experimental.Rendering.Universal.RenderObjects;

public enum ProbeLightMode
{
    BakeAlbedo,
    BakeNormal,
    BakeWorldPos
}


public class ProbeBakeFeature : ScriptableRendererFeature
{
    [SerializeField] ProbeLightMode shaderTagId = ProbeLightMode.BakeAlbedo;
    CustomCameraSettings m_CameraSettings;
    private LayerMask m_LayerMask = -1;
    RenderObjectsPass m_BakeOpaqueForwardPass;
    RenderObjectsPass m_BakeTransparentForwardPass;

    public void SetBakeMode(ProbeLightMode mode)
    {
        shaderTagId = mode;
        var shaderTagIds = new[] { mode.ToString() };
        m_CameraSettings = new CustomCameraSettings();
        m_BakeOpaqueForwardPass = new RenderObjectsPass("Probe Bake Opaque", RenderPassEvent.AfterRenderingOpaques,
            shaderTagIds, RenderQueueType.Opaque, m_LayerMask, m_CameraSettings);
        m_BakeTransparentForwardPass = new RenderObjectsPass("Probe Bake Transparent",
            RenderPassEvent.AfterRenderingTransparents, shaderTagIds, RenderQueueType.Transparent, m_LayerMask,
            m_CameraSettings);
    }

    public override void Create()
    {
        SetBakeMode(shaderTagId);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_BakeOpaqueForwardPass);
        renderer.EnqueuePass(m_BakeTransparentForwardPass);
    }
}
