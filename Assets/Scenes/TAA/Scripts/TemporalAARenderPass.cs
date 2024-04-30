using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace LcLGame
{
    public class TemporalAARenderPass : ScriptableRenderPass
    {
        const string SHADER_NAME = "Hidden/LcL/TemporalAA";
        ProfilingSampler m_ProfilingSampler = new ProfilingSampler("TAA Render Pass");

        string m_MotionVectorKeyword = "_TAA_MotionVector";
        string m_ClipAABBKeyword = "_TAA_ClipAABB";
        string m_YCOCGKeyword = "_TAA_YCOCG";
        string m_NudgeKeyword = "_TAA_Nudge";
        string m_TonemapKeyword = "_TAA_Tonemap";
        string m_FindClosestKeyword = "_TAA_FindClosest";


        int m_ParamsID = Shader.PropertyToID("_Params");
        int m_PrevViewProjID = Shader.PropertyToID("_PrevViewProj");
        // int m_OffsetID = Shader.PropertyToID("_Offset");

        Material m_Material;
        TaaSettings m_Settings;

        RenderTargetHandle m_TempTextureHandle;
        RenderTargetHandle m_HistoryTextureHandle;
        RenderTexture m_HistoryTexture;


        Matrix4x4 m_PrevViewProj;
        Vector2 m_Offset;

        Dictionary<int, RenderTexture> taaTextures = new Dictionary<int, RenderTexture>();

        public TemporalAARenderPass(TaaSettings settings)
        {
            m_Settings = settings;
            m_Material = CoreUtils.CreateEngineMaterial(SHADER_NAME);
            m_HistoryTextureHandle.Init("_HistoryTexture");
            m_TempTextureHandle.Init("_TempTexture");
        }

        public void Setup(Matrix4x4 prevViewProj, Vector2 offset)
        {
            m_PrevViewProj = prevViewProj;
            m_Offset = offset;
        }

        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            cmd.GetTemporaryRT(m_TempTextureHandle.id, cameraTextureDescriptor);
            if (m_Settings.useMotionVector)
            {
                ConfigureInput(ScriptableRenderPassInput.Depth | ScriptableRenderPassInput.Motion);
            }
        }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            CoreUtils.SetKeyword(m_Material, m_MotionVectorKeyword,
                renderingData.cameraData.isSceneViewCamera ? false : m_Settings.useMotionVector);
            CoreUtils.SetKeyword(m_Material, m_NudgeKeyword, m_Settings.useNudge);
            CoreUtils.SetKeyword(m_Material, m_ClipAABBKeyword, m_Settings.useClipAABB);
            CoreUtils.SetKeyword(m_Material, m_YCOCGKeyword, m_Settings.useYCOCG);
            CoreUtils.SetKeyword(m_Material, m_TonemapKeyword, m_Settings.useTonemap);
            CoreUtils.SetKeyword(m_Material, m_FindClosestKeyword, m_Settings.useFindClosest);
        }

        public void AllocateRenderTexture(CommandBuffer cmd, int hash, RenderTargetIdentifier source,
            RenderTextureDescriptor descriptor)
        {
            if (!taaTextures.ContainsKey(hash) || taaTextures[hash] == null ||
                taaTextures[hash].height != descriptor.height || taaTextures[hash].width != descriptor.width)
            {
                if (taaTextures.ContainsKey(hash))
                    taaTextures[hash]?.Release();

                taaTextures[hash] = new RenderTexture(descriptor);
                taaTextures[hash].filterMode = FilterMode.Bilinear;
                taaTextures[hash].Create();
                cmd.Blit(source, taaTextures[hash]);
            }

            m_HistoryTexture = taaTextures[hash];
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
                }

                cmd.SetGlobalMatrix(m_PrevViewProjID, m_PrevViewProj);
                cmd.SetGlobalVector(m_ParamsID, new Vector4(m_Offset.x, m_Offset.y, m_Settings.blend, 0));

                cmd.SetGlobalTexture(m_HistoryTextureHandle.id, m_HistoryTexture);
                LcLRenderingUtils.SetSourceTexture(cmd, source);
                LcLRenderingUtils.Blit(cmd, source, m_TempTextureHandle.id, m_Material, 0);

                Blit(cmd, m_TempTextureHandle.id, source);

                cmd.Blit(m_TempTextureHandle.id, source);
                cmd.Blit(source, m_HistoryTexture);
            }

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            cmd.ReleaseTemporaryRT(m_TempTextureHandle.id);
        }
    }
}
