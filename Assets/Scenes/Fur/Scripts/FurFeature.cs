using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace LcLGame
{
    public class FurFeature : RendererFeatureBase
    {
        [Serializable]
        public class FurSettings
        {
            [Range(5, 30)] public int passNumber = 20;
        }

        public FurSettings settings = new FurSettings();

        private FurRenderPass m_ReflectionPass;
        public override bool RenderPreview()
        {
            return true;
        }
        public override void Create()
        {
            m_ReflectionPass = new FurRenderPass(settings);
            m_ReflectionPass.renderPassEvent = RenderPassEvent.AfterRenderingTransparents;
        }

        public override void AddRenderPasses(ScriptableRenderer renderer)
        {
            renderer.EnqueuePass(m_ReflectionPass);
        }

        public class FurRenderPass : ScriptableRenderPass
        {
            string m_ProfilerTag = "FurRenderPass";
            FurSettings m_Settings;
            FilteringSettings m_FilteringSettings;
            public static readonly int furOffsetID = Shader.PropertyToID("_FurOffset");
            public static readonly ShaderTagId shaderTagID = new ShaderTagId("UniversalFur");

            public FurRenderPass(FurSettings settings)
            {
                m_Settings = settings;
                m_FilteringSettings = new FilteringSettings(RenderQueueRange.transparent);
            }

            public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
            {
                var cmd = CommandBufferPool.Get();

                using (new ProfilingScope(cmd, new ProfilingSampler(m_ProfilerTag)))
                {
                    DrawingSettings drawingSettings = CreateDrawingSettings(shaderTagID, ref renderingData,
                        SortingCriteria.CommonTransparent);
                    var passNumber = m_Settings.passNumber;
                    for (int i = 0; i < passNumber; i++)
                    {
                        cmd.Clear();
                        cmd.SetGlobalFloat(furOffsetID, (float)i / (float)passNumber);
                        context.ExecuteCommandBuffer(cmd);
                        context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref m_FilteringSettings);
                    }
                }

                CommandBufferPool.Release(cmd);
            }
        }
    }
}
