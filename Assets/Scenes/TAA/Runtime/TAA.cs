using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace GameOldBoy.Rendering
{
    public enum RenderingMode
    {
        Forward,
        Deferred
    }

    public class TAA : ScriptableRendererFeature
    {
        public bool PreviewInSceneView = true;
        public bool UseMotionVector;
        public RenderingMode RenderingMode = RenderingMode.Forward;
        public bool WorkOnPrepass = false;
        public bool IgonreTransparentObject = false;

        public bool Use32Bit = false;
        [HideInInspector]
        public Shader Shader;
        Material material;

        TAACameraPass m_TAACameraPrepass;
        TAACameraPass m_TAACameraPass;
        TAAPass m_TAAPass;

        Dictionary<int, HaltonSequence> haltonSequences = new Dictionary<int, HaltonSequence>();

        public override void Create()
        {
#if UNITY_EDITOR
            foreach (var guid in AssetDatabase.FindAssets("TAA t:Shader"))
            {
                var path = AssetDatabase.GUIDToAssetPath(guid);
                if (path.Contains("URP TAA/Shaders/TAA.shader"))
                {
                    Shader = AssetDatabase.LoadAssetAtPath<Shader>(path);
                    break;
                }
            }
#endif
            m_TAACameraPrepass = new TAACameraPass(name);
#if UNITY_2021_1_OR_NEWER
            m_TAACameraPrepass.renderPassEvent = RenderPassEvent.BeforeRenderingPrePasses;
#else
            m_TAACameraPrepass.renderPassEvent = RenderPassEvent.BeforeRenderingPrepasses;
#endif
            m_TAACameraPass = new TAACameraPass(name);
#if UNITY_2021_2_OR_NEWER
            switch (RenderingMode)
            {
                case RenderingMode.Forward:
                    m_TAACameraPass.renderPassEvent = RenderPassEvent.BeforeRenderingOpaques;
                    break;
                case RenderingMode.Deferred:
                    m_TAACameraPass.renderPassEvent = RenderPassEvent.BeforeRenderingGbuffer;
                    break;
            }
#else
            m_TAACameraPass.renderPassEvent = RenderPassEvent.BeforeRenderingOpaques;
#endif
            m_TAAPass = new TAAPass(name);
            if (IgonreTransparentObject)
            {
                m_TAAPass.renderPassEvent = RenderPassEvent.BeforeRenderingTransparents;
            }
            else
            {
                m_TAAPass.renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
            }
        }

        bool getMaterial()
        {
            if (material == null)
            {
                material = CoreUtils.CreateEngineMaterial(Shader);
                if (material == null)
                {
                    return false;
                }
                else
                {
                    return true;
                }
            }
            else
            {
                return true;
            }
        }

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            var camera = renderingData.cameraData.camera;
            var isSceneViewCamera = renderingData.cameraData.isSceneViewCamera;
            TAAComponent taa;
            if (isSceneViewCamera && Camera.main != null)
            {
                taa = Camera.main.GetComponent<TAAComponent>();
            }
            else
            {
                taa = camera.GetComponent<TAAComponent>();
            }
            if (taa != null)
            {
                if (getMaterial() && (isSceneViewCamera ? PreviewInSceneView : true) && taa.Enabled)
                {
                    var hash = camera.GetHashCode();
                    var proj = camera.projectionMatrix;
                    var view = camera.worldToCameraMatrix;
                    var viewProj = proj * view;
                    HaltonSequence haltonSequence;

                    if (haltonSequences.ContainsKey(hash))
                    {
                        haltonSequence = haltonSequences[hash];
                    }
                    else
                    {
                        haltonSequence = new HaltonSequence(1024);
                    }

                    if (haltonSequence.prevViewProj == Matrix4x4.zero)
                    {
                        haltonSequence.prevViewProj = viewProj;
                    }

                    haltonSequence.Get(out var offsetX, out var offsetY);

                    var matrix = camera.projectionMatrix;
                    var descriptor = renderingData.cameraData.cameraTargetDescriptor;
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

                    var offset = new Vector2(
                        (offsetX - 0.5f) / descriptor.width,
                        (offsetY - 0.5f) / descriptor.height);

                    if (WorkOnPrepass)
                    {
                        m_TAACameraPrepass.Setup(matrix);
                        renderer.EnqueuePass(m_TAACameraPrepass);
                    }
                    m_TAACameraPass.Setup(matrix);
                    renderer.EnqueuePass(m_TAACameraPass);

                    m_TAAPass.Setup(
                        renderer,
                        Use32Bit,
                        material,
                        haltonSequence.prevViewProj,
                        offset,
                        taa,
                        UseMotionVector,
                        RenderingMode);
                    renderer.EnqueuePass(m_TAAPass);

                    haltonSequence.prevViewProj = viewProj;
                    haltonSequence.frameCount = Time.frameCount;
                    haltonSequences[hash] = haltonSequence;
                }
            }

            if (haltonSequences.Count > 0)
            {
                //Span<int> rmArr = stackalloc int[8];
                int[] rmArr = new int[8];
                int index = 0;
                foreach (var item in haltonSequences)
                {
                    var haltonSequence = item.Value;
                    if (Time.frameCount - haltonSequence.frameCount > 10)
                    {
                        rmArr[index] = item.Key;
                        if (++index == 8) break;
                    }
                }
                if (index > 0)
                {
                    for (int i = 0; i < index; i++)
                    {
                        haltonSequences.Remove(rmArr[i]);
                        m_TAAPass.CleanUp(rmArr[i]);
                    }
                    if (haltonSequences.Count == 0)
                    {
                        CoreUtils.Destroy(material);
                        material = null;
                    }
                }
            }
        }

        //void cleanup()
        //{
        //    int[] rmArr = new int[haltonSequences.Count];
        //    int index = 0;
        //    foreach (var item in haltonSequences)
        //    {
        //        var haltonSequence = item.Value;
        //        rmArr[index++] = item.Key;
        //    }
        //    if (index > 0)
        //    {
        //        for (int i = 0; i < rmArr.Length; i++)
        //        {
        //            haltonSequences.Remove(rmArr[i]);
        //            m_TAAPass.CleanUp(rmArr[i]);
        //        }
        //    }

        //    CoreUtils.Destroy(material);
        //    material = null;
        //}

        //void OnDisable()
        //{
        //    cleanup();
        //}

        //protected override void Dispose(bool disposing)
        //{
        //    cleanup();

        //    base.Dispose(disposing);
        //}

        class TAACameraPass : ScriptableRenderPass
        {
#if UNITY_2019_4_OR_NEWER
            ProfilingSampler m_ProfilingSampler;
#else
            string m_ProfilingSampler;
#endif

            Matrix4x4 matrix;

            public TAACameraPass(string profilerTag)
            {
#if UNITY_2019_4_OR_NEWER
                m_ProfilingSampler = new ProfilingSampler(profilerTag);
#else
                m_ProfilingSampler = profilerTag;
#endif
            }

            public void Setup(Matrix4x4 matrix)
            {
                this.matrix = matrix;
            }

            public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
            {
#if UNITY_2020_1_OR_NEWER
                var cmd = CommandBufferPool.Get();
#else
#if UNITY_2019_4_OR_NEWER
                var cmd = CommandBufferPool.Get(m_ProfilingSampler.name);
#else
                var cmd = CommandBufferPool.Get(m_ProfilingSampler);
#endif
#endif

#if UNITY_2019_4_OR_NEWER
                using (new ProfilingScope(cmd, m_ProfilingSampler))
#else
                using (new ProfilingSample(cmd, m_ProfilingSampler))
#endif
                {
                    var camera = renderingData.cameraData.camera;
                    cmd.SetViewProjectionMatrices(camera.worldToCameraMatrix, matrix);
                }

                context.ExecuteCommandBuffer(cmd);
                CommandBufferPool.Release(cmd);
            }
        }

        class TAAPass : ScriptableRenderPass
        {
#if UNITY_2019_4_OR_NEWER
            ProfilingSampler m_ProfilingSampler;
#else
            string m_ProfilingSampler;
#endif

            ScriptableRenderer renderer;
            bool use32Bit;
            Material material;
            Matrix4x4 prevViewProj;
            Vector2 offset;
            float blend;
            bool antiGhosting;
            bool useSharpenFilter;
            bool useBicubicFilter;
            bool useClipAABB;
            bool useDilation;
            bool useTonemap;
            bool useVarianceClipping;
            bool useYCoCgSpace;
            float gamma;
            float sharp;
            float prevSharp;
            bool useMotionVector;
            bool use4Tap;

            class TAATextureSwap
            {
                public RenderTexture TAATextureA { get; }
                public RenderTexture TAATextureB { get; }
                public RenderTextureDescriptor Descriptor { get; }
                bool swap;
                public TAATextureSwap(RenderTexture taaTextureA, RenderTexture taaTextureB, RenderTextureDescriptor descriptor)
                {
                    TAATextureA = taaTextureA;
                    TAATextureB = taaTextureB;
                    Descriptor = descriptor;
                    swap = true;
                }
                public bool Swap()
                {
                    swap = !swap;
                    return swap;
                }
                public bool CheckTextureNull()
                {
                    return TAATextureA == null || TAATextureB == null;
                }
                public void Release()
                {
                    if (TAATextureA != null)
                    {
                        TAATextureA.Release();
                    }
                    if(TAATextureB != null)
                    {
                        TAATextureB.Release();
                    }
                }
            }
            Dictionary<int, TAATextureSwap> taaTextures = new Dictionary<int, TAATextureSwap>();

            int taaPrevViewProj = Shader.PropertyToID("_TAA_PrevViewProj");
            int taaOffset = Shader.PropertyToID("_TAA_Offset");
            int taaParams0 = Shader.PropertyToID("_TAA_Params0");
            int taaSourceTex = Shader.PropertyToID("_SourceTex");
            int taaTexture = Shader.PropertyToID("_TAA_Texture");

            public TAAPass(string profilerTag)
            {
#if UNITY_2019_4_OR_NEWER
                m_ProfilingSampler = new ProfilingSampler(profilerTag);
#else
                m_ProfilingSampler = profilerTag;
#endif
            }

            public void Setup(
                ScriptableRenderer renderer,
                bool use32Bit,
                Material material,
                Matrix4x4 prevViewProj,
                Vector2 offset,
                TAAComponent taa,
                bool useMotionVector,
                RenderingMode renderingMode)
            {
                this.renderer = renderer;
                this.use32Bit = use32Bit;
                this.material = material;
                this.prevViewProj = prevViewProj;
                this.offset = offset;
                blend = taa.Blend;
                antiGhosting = taa.AntiGhosting;
                useSharpenFilter = taa.UseBlurSharpenFilter;
                useBicubicFilter = taa.UseBicubicFilter;
                useClipAABB = taa.UseClipAABB;
                useDilation = taa.UseDilation;
                useTonemap = taa.UseTonemap;
                useVarianceClipping = taa.UseVarianceClipping;
                useYCoCgSpace = taa.UseYCoCgSpace;
                gamma = taa.Stability;
                sharp = taa.SharpenStrength;
                prevSharp = taa.HistorySharpening;
                this.useMotionVector = useMotionVector;
                use4Tap = taa.Use4Tap;

#if UNITY_2021_2_OR_NEWER
                switch (renderingMode)
                {
                    case RenderingMode.Forward:
                        if (useMotionVector)
                        {
                            ConfigureInput(ScriptableRenderPassInput.Depth | ScriptableRenderPassInput.Motion);
                        }
                        else
                        {
                            ConfigureInput(ScriptableRenderPassInput.Depth);
                        }
                        break;
                    case RenderingMode.Deferred:
                        if (useMotionVector)
                        {
                            ConfigureInput(ScriptableRenderPassInput.Motion);
                        }
                        break;
                }
#else
#if UNITY_2020_1_OR_NEWER
                ConfigureInput(ScriptableRenderPassInput.Depth);
#endif
#endif
            }

            void allocRT(out RenderTexture rt_a, out RenderTexture rt_b, RenderTextureDescriptor descriptor)
            {
                rt_a = new RenderTexture(descriptor);
                rt_a.filterMode = FilterMode.Bilinear;
                rt_b = new RenderTexture(descriptor);
                rt_b.filterMode = FilterMode.Bilinear;
            }

            void allocRT(out RenderTexture rt_a, out RenderTexture rt_b, CommandBuffer cmd, ScriptableRenderContext context, RenderTargetIdentifier rtid, RenderTextureDescriptor descriptor)
            {
                allocRT(out rt_a, out rt_b, descriptor);
                cmd.SetGlobalTexture(taaSourceTex, rtid);
                cmd.SetRenderTarget(rt_a);
                cmd.DrawMesh(RenderingUtils.fullscreenMesh, Matrix4x4.identity, material, 0, 1);
                cmd.SetRenderTarget(rt_b);
                cmd.DrawMesh(RenderingUtils.fullscreenMesh, Matrix4x4.identity, material, 0, 1);
                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();
            }

            void genRT(CommandBuffer cmd, ScriptableRenderContext context, RenderTargetIdentifier rtid, RenderTextureDescriptor descriptor, int hash)
            {
                descriptor.useMipMap = false;
                descriptor.autoGenerateMips = false;
                descriptor.depthBufferBits = 0;
                descriptor.msaaSamples = 1;
                if (use32Bit) descriptor.colorFormat = RenderTextureFormat.ARGBFloat;

                if (taaTextures.ContainsKey(hash))
                {
                    if (taaTextures[hash].CheckTextureNull())
                    {
                        allocRT(out var taaTextureA, out var taaTextureB, cmd, context, rtid, descriptor);
                        taaTextures[hash] = new TAATextureSwap(taaTextureA, taaTextureB, descriptor);
                        return;
                    }
                }
                else
                {
                    allocRT(out var taaTextureA, out var taaTextureB, cmd, context, rtid, descriptor);
                    taaTextures[hash] = new TAATextureSwap(taaTextureA, taaTextureB, descriptor);
                    return;
                }

                var desc = taaTextures[hash].Descriptor;
                if (desc.width != descriptor.width ||
                    desc.height != descriptor.height ||
                    desc.colorFormat != descriptor.colorFormat)
                {
                    taaTextures[hash].Release();
                    allocRT(out var taaTextureA, out var taaTextureB, cmd, context, rtid, descriptor);
                    taaTextures[hash] = new TAATextureSwap(taaTextureA, taaTextureB, descriptor);
                }
            }

            public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
            {
#if UNITY_2020_1_OR_NEWER
                var cmd = CommandBufferPool.Get();
#else
#if UNITY_2019_4_OR_NEWER
                var cmd = CommandBufferPool.Get(m_ProfilingSampler.name);
#else
                var cmd = CommandBufferPool.Get(m_ProfilingSampler);
#endif
#endif

#if UNITY_2019_4_OR_NEWER
                using (new ProfilingScope(cmd, m_ProfilingSampler))
#else
                using (new ProfilingSample(cmd, m_ProfilingSampler))
#endif
                {
                    var camera = renderingData.cameraData.camera;
                    var cameraColorTarget = renderer.cameraColorTarget;
                    var descriptor = renderingData.cameraData.cameraTargetDescriptor;
                    var hash = renderingData.cameraData.camera.GetHashCode();
                    cmd.SetViewProjectionMatrices(Matrix4x4.identity, Matrix4x4.identity);
                    genRT(cmd, context, cameraColorTarget, descriptor, hash);
                    material.SetMatrix(taaPrevViewProj, prevViewProj);
                    cmd.SetGlobalVector(taaOffset, offset);
                    material.SetVector(taaParams0, new Vector4(blend, gamma, sharp, prevSharp));
                    CoreUtils.SetKeyword(material, "_TAA_AntiGhosting", antiGhosting);
#if UNITY_2021_2_OR_NEWER
                    CoreUtils.SetKeyword(material, "_TAA_UseMotionVector", renderingData.cameraData.isSceneViewCamera ? false : useMotionVector);
#else
                    CoreUtils.SetKeyword(material, "_TAA_UseMotionVector", false);
#endif
                    CoreUtils.SetKeyword(material, "_TAA_UseBlurSharpenFilter", useSharpenFilter);
                    CoreUtils.SetKeyword(material, "_TAA_UseBicubicFilter", useBicubicFilter);
                    CoreUtils.SetKeyword(material, "_TAA_UseClipAABB", useClipAABB);
                    CoreUtils.SetKeyword(material, "_TAA_UseDilation", useDilation);
                    CoreUtils.SetKeyword(material, "_TAA_UseTonemap", useTonemap);
                    CoreUtils.SetKeyword(material, "_TAA_UseVarianceClipping", useVarianceClipping);
                    CoreUtils.SetKeyword(material, "_TAA_UseYCoCgSpace", useYCoCgSpace);
                    CoreUtils.SetKeyword(material, "_TAA_Use4Tap", use4Tap);
                    var taaTextureSwap = taaTextures[hash];
                    if (taaTextureSwap.Swap())
                    {
                        cmd.SetGlobalTexture(taaSourceTex, cameraColorTarget);
                        material.SetTexture(taaTexture, taaTextureSwap.TAATextureB);
                        cmd.SetRenderTarget(taaTextureSwap.TAATextureA);
                        cmd.DrawMesh(RenderingUtils.fullscreenMesh, Matrix4x4.identity, material, 0, 0);
                        cmd.SetGlobalTexture(taaSourceTex, taaTextureSwap.TAATextureA);
                        cmd.SetRenderTarget(cameraColorTarget);
                        cmd.DrawMesh(RenderingUtils.fullscreenMesh, Matrix4x4.identity, material, 0, 1);
                    }
                    else
                    {
                        cmd.SetGlobalTexture(taaSourceTex, cameraColorTarget);
                        material.SetTexture(taaTexture, taaTextureSwap.TAATextureA);
                        cmd.SetRenderTarget(taaTextureSwap.TAATextureB);
                        cmd.DrawMesh(RenderingUtils.fullscreenMesh, Matrix4x4.identity, material, 0, 0);
                        cmd.SetGlobalTexture(taaSourceTex, taaTextureSwap.TAATextureB);
                        cmd.SetRenderTarget(cameraColorTarget);
                        cmd.DrawMesh(RenderingUtils.fullscreenMesh, Matrix4x4.identity, material, 0, 1);
                    }
                    cmd.SetViewProjectionMatrices(camera.worldToCameraMatrix, camera.projectionMatrix);
                }

                context.ExecuteCommandBuffer(cmd);
                CommandBufferPool.Release(cmd);
            }

            public void CleanUp(int hash)
            {
                if (taaTextures.ContainsKey(hash))
                {
                    taaTextures[hash].Release();
                    taaTextures.Remove(hash);
                }
            }
        }

        struct HaltonSequence
        {
            int count;
            int index;
            float[] arrX;
            float[] arrY;

            public Matrix4x4 prevViewProj;
            public int frameCount;

            public HaltonSequence(int count)
            {
                this.count = count;
                index = 0;
                arrX = new float[count];
                arrY = new float[count];
                prevViewProj = Matrix4x4.zero;
                frameCount = 0;
                for (int i = 0; i < arrX.Length; i++)
                {
                    arrX[i] = get(i, 2);
                }

                for (int i = 0; i < arrY.Length; i++)
                {
                    arrY[i] = get(i, 3);
                }
            }

            float get(int index, int @base)
            {
                float fraction = 1;
                float result = 0;

                while (index > 0)
                {
                    fraction /= @base;
                    result += fraction * (index % @base);
                    index /= @base;
                }

                return result;
            }

            public void Get(out float x, out float y)
            {
                if (++index == count) index = 1;
                x = arrX[index];
                y = arrY[index];
            }
        }
    }
}
