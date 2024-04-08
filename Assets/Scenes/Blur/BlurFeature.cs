using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace LcLGame
{
    public enum BlurType
    {
        GaussianBlur,
        BilateralFilter
    }


    public class BlurFeature : RendererFeatureBase
    {
        public BlurType blurType = BlurType.GaussianBlur;

        public GaussianBlurSettings gaussianSettings = new GaussianBlurSettings();
        public BilateralFilterBlurSettings bilateralFilterSettings = new BilateralFilterBlurSettings();


        IBlurPass m_BlurPass;
        public override void Create()
        {
            switch (blurType)
            {

                case BlurType.GaussianBlur:
                    m_BlurPass = new GaussianBlurRendererPass(gaussianSettings)
                    {
                        renderPassEvent = RenderPassEvent.AfterRenderingTransparents
                    };
                    break;
                case BlurType.BilateralFilter:
                    m_BlurPass = new BilateralFilterRendererPass(bilateralFilterSettings)
                    {
                        renderPassEvent = RenderPassEvent.AfterRenderingTransparents
                    };
                    break;
            }

        }

        public override void AddRenderPasses(ScriptableRenderer renderer)
        {
            renderer.EnqueuePass(m_BlurPass as ScriptableRenderPass);

        }

    }
}
