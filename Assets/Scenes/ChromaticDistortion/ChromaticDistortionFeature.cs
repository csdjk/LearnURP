using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace LcLGame
{
    // ===================================================================
    //  色散扭曲后处理效果设置
    //  Chromatic Aberration + Wave Distortion Post Process
    //  用途：中毒、迷幻、头晕等状态表现
    // ===================================================================
    [System.Serializable]
    public class ChromaticDistortionSettings
    {
        [Header("色散 Chromatic Aberration")]
        [Range(0f, 5f)]
        [Tooltip("色散强度，RGB三通道向外偏移，产生彩虹边缘效果")]
        public float aberrationStrength = 1.5f;

        [Header("扭曲 Wave Distortion")]
        [Range(0f, 5f)]
        [Tooltip("扭曲幅度，控制画面波浪形扭曲程度")]
        public float distortionStrength = 1.0f;

        [Range(1f, 50f)]
        [Tooltip("扭曲频率（波纹密度）")]
        public float distortionFrequency = 10f;

        [Range(0f, 5f)]
        [Tooltip("扭曲动画速度")]
        public float distortionSpeed = 1.0f;

        [Header("视觉增强")]
        [Range(0f, 2f)]
        [Tooltip("暗角强度，边缘变暗加强压迫感")]
        public float vignetteStrength = 0.5f;

        [Range(0f, 1f)]
        [Tooltip("中毒色调（偏红/压蓝），模拟中毒/迷幻色调")]
        public float poisonTint = 0.5f;
    }

    // ===================================================================
    //  挂载到相机 GameObject 上的 RendererFeature 组件
    //  用法：将此脚本挂到场景中任意 GameObject，启用即生效
    // ===================================================================
    public class ChromaticDistortionFeature : RendererFeatureBase
    {
        [Header("效果参数")]
        public ChromaticDistortionSettings settings = new ChromaticDistortionSettings();

        [Header("渲染时机")]
        public RenderPassEvent renderPassEvent = RenderPassEvent.AfterRenderingTransparents;

        ChromaticDistortionPass m_Pass;

        public override void Create()
        {
            m_Pass = new ChromaticDistortionPass(settings)
            {
                renderPassEvent = renderPassEvent
            };
        }

        public override void AddRenderPasses(ScriptableRenderer renderer)
        {
            if (settings.aberrationStrength <= 0f &&
                settings.distortionStrength <= 0f)
                return;

            renderer.EnqueuePass(m_Pass);
        }

        public override void Dispose()
        {
            m_Pass?.Dispose();
        }
    }
}
