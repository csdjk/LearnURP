using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace LcLGame.PRTGI
{
    [ExecuteAlways]
    public class PrtGiRelightFeature : ScriptableRendererFeature
    {
        RelightRenderPass m_ScriptablePass;
        public RenderPassEvent renderPassEvent = RenderPassEvent.BeforeRenderingOpaques;

        public override void Create()
        {
            m_ScriptablePass = new RelightRenderPass();
            m_ScriptablePass.renderPassEvent = renderPassEvent;
        }

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            if (ProbeVolume.Instance == null || ProbeVolume.Instance.ProbeCount == 0 ||
                ProbeVolume.Instance.computeShader == null) return;

            renderer.EnqueuePass(m_ScriptablePass);
        }

        class RelightRenderPass : ScriptableRenderPass
        {
            ProfilingSampler m_ProfilingSampler = new ProfilingSampler("Relight RenderPass");

            public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
            {
                var probeVolume = ProbeVolume.Instance;
                if (probeVolume == null) return;

                CommandBuffer cmd = CommandBufferPool.Get();
                using (new ProfilingScope(cmd, m_ProfilingSampler))
                {
                    context.ExecuteCommandBuffer(cmd);
                    cmd.Clear();

                    probeVolume.ClearCoefficientVoxel(cmd);

                    var probeGridSize = new Vector4(probeVolume.probeGridSize.x, probeVolume.probeGridSize.y,
                        probeVolume.probeGridSize.z, 0);
                    cmd.SetGlobalVector(PbrtShaderPropertyID.ProbeGridSize, probeGridSize);
                    // xyz: _VoxelCorner , w: _ProbeSpacing
                    cmd.SetGlobalVector(PbrtShaderPropertyID.VoxelCorner, probeVolume.VoxelCorner);

                    // cmd.SetGlobalBuffer("_lastFrameCoefficientVoxel", volume.lastFrameCoefficientVoxel);
                    cmd.SetGlobalBuffer(PbrtShaderPropertyID.CoefficientVoxel, probeVolume.CoefficientVoxel);

                    cmd.SetGlobalFloat(PbrtShaderPropertyID.SkyLightIntensity, probeVolume.skyLightIntensity);
                    cmd.SetGlobalFloat(PbrtShaderPropertyID.GIIntensity, probeVolume.giIntensity);

                    foreach (var probe in ProbeVolume.Instance.Probes)
                    {
                        if (probe == null) continue;
                        probe.ReLight(cmd);
                        // context.ExecuteCommandBuffer(cmd);
                        // cmd.Clear();
                    }
                }

                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();
                CommandBufferPool.Release(cmd);
            }
        }
    }
}
