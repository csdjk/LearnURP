using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace LcLGame
{
    public class MultiPassFeature : RendererFeatureBase
    {
        [Serializable]
        public class MultiPassSettings
        {
            [Range(5, 30)] public int passNumber = 20;
        }

        public MultiPassSettings settings = new();

        private MultiPassRenderPass m_RenderPass;

        public override bool RenderPreview()
        {
            return true;
        }

        public override void Create()
        {
            m_RenderPass = new MultiPassRenderPass(settings);
            m_RenderPass.renderPassEvent = RenderPassEvent.AfterRenderingTransparents;
        }

        public override void AddRenderPasses(ScriptableRenderer renderer)
        {
            renderer.EnqueuePass(m_RenderPass);
        }

        public class MultiPassRenderPass : ScriptableRenderPass
        {
            private string m_ProfilerTag = "CloudRenderPass";
            private MultiPassSettings m_Settings;
            private FilteringSettings m_FilteringSettings;
            static readonly int layerOffsetID = Shader.PropertyToID("_LayerOffset");
            static readonly ShaderTagId shaderTagID = new("UniversalCloud");

            public MultiPassRenderPass(MultiPassSettings settings)
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
                        cmd.SetGlobalFloat(layerOffsetID, (float)i / (float)passNumber);
                        context.ExecuteCommandBuffer(cmd);
                        context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref m_FilteringSettings);
                    }
                }

                CommandBufferPool.Release(cmd);
            }
        }
    }
}
