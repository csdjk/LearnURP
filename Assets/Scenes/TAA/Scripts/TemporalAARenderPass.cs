using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace LcLGame
{
    public class TemporalAARenderPass : ScriptableRenderPass
    {
        private const string SHADER_NAME = "Hidden/LcL/TemporalAA";
        private readonly ProfilingSampler m_ProfilingSampler = new ProfilingSampler("TAA Render Pass");

        private readonly string m_AnitGhostingKeyword = "_TAA_Anti_Ghosting";
        private readonly string m_MotionVectorKeyword = "_TAA_MotionVector";
        private readonly string m_ClipAABBKeyword = "_TAA_ClipAABB";
        private readonly string m_YcocgKeyword = "_TAA_YCOCG";
        private readonly string m_NudgeKeyword = "_TAA_Nudge";
        private readonly string m_TonemapKeyword = "_TAA_Tonemap";
        private readonly string m_FindClosestKeyword = "_TAA_FindClosest";

        private readonly int m_ParamsID = Shader.PropertyToID("_Params");
        private readonly int m_PrevViewProjID = Shader.PropertyToID("_PrevViewProj");

        private readonly Material m_Material;
        private readonly TaaSettings m_Settings;
        private readonly RenderTargetHandle m_HistoryTextureHandle;
        private RenderTexture m_HistoryTexture;


        private Matrix4x4 m_PrevViewProj;
        private Vector2 m_Offset;

        private readonly Dictionary<int, RenderTexture> m_TaaTextures = new Dictionary<int, RenderTexture>();

        public TemporalAARenderPass(TaaSettings settings)
        {
            m_Settings = settings;
            m_Material = CoreUtils.CreateEngineMaterial(SHADER_NAME);
            m_HistoryTextureHandle.Init("_HistoryTexture");

        }

        public void Setup(Matrix4x4 prevViewProj, Vector2 offset)
        {
            m_PrevViewProj = prevViewProj;
            m_Offset = offset;
        }

        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            if (m_Settings.useMotionVector)
            {
                ConfigureInput(ScriptableRenderPassInput.Depth | ScriptableRenderPassInput.Motion);
            }
        }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            if(m_Material == null)
                return;
            CoreUtils.SetKeyword(m_Material, m_AnitGhostingKeyword, m_Settings.anitGhosting);
            CoreUtils.SetKeyword(m_Material, m_MotionVectorKeyword, !renderingData.cameraData.isSceneViewCamera && m_Settings.useMotionVector);
            // CoreUtils.SetKeyword(m_Material, m_NudgeKeyword, m_Settings.useNudge);
            CoreUtils.SetKeyword(m_Material, m_ClipAABBKeyword, m_Settings.useClipAABB);
            CoreUtils.SetKeyword(m_Material, m_YcocgKeyword, m_Settings.useYCOCG);
            CoreUtils.SetKeyword(m_Material, m_TonemapKeyword, m_Settings.useTonemap);
            CoreUtils.SetKeyword(m_Material, m_FindClosestKeyword, m_Settings.useFindClosest);
        }

        public void AllocateRenderTexture(CommandBuffer cmd, int hash, RenderTargetIdentifier source,
            RenderTextureDescriptor descriptor)
        {
            if (!m_TaaTextures.ContainsKey(hash) || m_TaaTextures[hash] == null ||
                m_TaaTextures[hash].height != descriptor.height || m_TaaTextures[hash].width != descriptor.width)
            {
                if (m_TaaTextures.ContainsKey(hash))
                    m_TaaTextures[hash]?.Release();

                m_TaaTextures[hash] = new RenderTexture(descriptor);
                m_TaaTextures[hash].filterMode = FilterMode.Bilinear;
                m_TaaTextures[hash].Create();
                cmd.Blit(source, m_TaaTextures[hash]);
            }

            m_HistoryTexture = m_TaaTextures[hash];
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (m_Material == null)
                return;


            ref CameraData cameraData = ref renderingData.cameraData;
            var renderer = cameraData.renderer;
            var camera = cameraData.camera;
            var source = renderer.cameraColorTarget;
            var targetDescriptor = cameraData.cameraTargetDescriptor;
            var hash = camera.GetHashCode();

            var cmd = CommandBufferPool.Get();

            using (new ProfilingScope(cmd, m_ProfilingSampler))
            {
                AllocateRenderTexture(cmd, hash, source, targetDescriptor);
                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();

                if (!m_Settings.useMotionVector)
                {
                    var viewPortRay = LcLRenderingUtils.CalculateFrustumCornersRay(camera);
                    cmd.SetGlobalMatrix(LcLRenderingUtils.FrustumCornersRayID, viewPortRay);
                    m_Offset = Vector2.zero;
                }

                cmd.SetGlobalMatrix(m_PrevViewProjID, m_PrevViewProj);
                cmd.SetGlobalVector(m_ParamsID, new Vector4(m_Offset.x, m_Offset.y, m_Settings.blend, 0));
                cmd.SetGlobalTexture(m_HistoryTextureHandle.id, m_HistoryTexture);

                var destination = LcLRenderingUtils.Blit(cmd, renderingData, m_Material, 0);
                cmd.Blit(destination, m_HistoryTexture);
            }

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {

        }

        public void Dispose()
        {
            if (m_Material != null)
            {
                CoreUtils.Destroy(m_Material);
            }

            foreach (var taaTexture in m_TaaTextures)
            {
                if (taaTexture.Value != null)
                {
                    taaTexture.Value.Release();
                }
            }

            m_TaaTextures.Clear();
        }
    }
}
