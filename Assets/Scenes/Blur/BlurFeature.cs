using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace LcLGame
{
    public class BlurFeature : RendererFeatureBase
    {

        public GaussianBlurSettings settings = new GaussianBlurSettings();
        GaussianBlurRendererPass m_BlurPass;
        public override void Create()
        {
            m_BlurPass = new GaussianBlurRendererPass(settings)
            {
                renderPassEvent = RenderPassEvent.AfterRenderingTransparents
            };
        }

        public override void AddRenderPasses(ScriptableRenderer renderer)
        {
            m_BlurPass.SetRenderTarget(renderer.cameraColorTarget);
            renderer.EnqueuePass(m_BlurPass);
        }

    }
}
