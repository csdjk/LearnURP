using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace LcLGame
{
    [System.Serializable]
    public class TaaSettings
    {
        [Range(0, 0.999f)] public float blend = 0.8f;
        public bool anitGhosting = true;
        public bool useMotionVector = false;
        public bool useFindClosest = true;
        public bool useClipAABB = true;
        public bool useYCOCG = false;
        public bool useTonemap = false;
        // public bool useNudge = true;
    }

    public class TemporalAAFeature : ScriptableRendererFeature
    {
        public TaaSettings settings = new TaaSettings();
        TemporalAARenderPass m_TaaRenderPass;
        TemporalAACameraPass m_TaaCameraPass;
        Dictionary<int, HaltonSequence> m_HaltonSequences = new Dictionary<int, HaltonSequence>();

        public override void Create()
        {
            m_TaaRenderPass?.Dispose();
            m_TaaRenderPass = new TemporalAARenderPass(settings)
            {
                renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing
            };
            m_TaaCameraPass = new TemporalAACameraPass()
            {
                renderPassEvent = RenderPassEvent.BeforeRenderingOpaques
            };
        }

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            if (renderingData.cameraData.isSceneViewCamera || renderingData.cameraData.isPreviewCamera)
                return;

            var (matrix, prevViewProj, offset) = CalculateJitter(ref renderingData.cameraData);
            m_TaaCameraPass.Setup(matrix);
            m_TaaRenderPass.Setup(prevViewProj, offset);
            renderer.EnqueuePass(m_TaaCameraPass);
            renderer.EnqueuePass(m_TaaRenderPass);
        }

        //Dispose
        protected override void Dispose(bool disposing)
        {
            m_TaaRenderPass.Dispose();
            m_HaltonSequences.Clear();
        }

        public HaltonSequence GetHaltonSequence(int hash, Matrix4x4 viewProj)
        {
            HaltonSequence haltonSequence;
            if (m_HaltonSequences.ContainsKey(hash))
            {
                haltonSequence = m_HaltonSequences[hash];
            }
            else
            {
                haltonSequence = new HaltonSequence(1024);
            }

            if (haltonSequence.prevViewProj == Matrix4x4.zero)
            {
                haltonSequence.prevViewProj = viewProj;
            }

            return haltonSequence;
        }

        public (Matrix4x4,Matrix4x4,Vector2) CalculateJitter(ref CameraData cameraData)
        {
            var camera = cameraData.camera;
            var hash = camera.GetHashCode();
            var proj = camera.projectionMatrix;
            var view = camera.worldToCameraMatrix;
            var viewProj = proj * view;

            var haltonSequence = GetHaltonSequence(hash, viewProj);
            (var offsetX, var offsetY) = haltonSequence.Get();

            var matrix = camera.projectionMatrix;
            var descriptor = cameraData.cameraTargetDescriptor;
            if (camera.orthographic)
            {
                matrix[0, 3] -= (offsetX * 2 - 1) / descriptor.width;
                matrix[1, 3] -= (offsetY * 2 - 1) / descriptor.height;
            }
            else
            {
                matrix[0, 2] += (offsetX * 2 - 1) / descriptor.width;
                matrix[1, 2] += (offsetY * 2 - 1) / descriptor.height;
            }

            var offset = new Vector2((offsetX - 0.5f) / descriptor.width, (offsetY - 0.5f) / descriptor.height);

            var prevViewProj = haltonSequence.prevViewProj;

            // haltonSequence.prevViewProj = matrix * view;
            haltonSequence.prevViewProj = viewProj;
            haltonSequence.frameCount = Time.frameCount;
            m_HaltonSequences[hash] = haltonSequence;
            return (matrix, prevViewProj, offset);
        }
    }
}
