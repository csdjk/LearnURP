using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public enum RenderTextureResolution
{
    _64 = 64,
    _128 = 128,
    _256 = 256,
    _512 = 512,
    _1024 = 1024,
    _2048 = 2048,
}

public class LcLRenderingUtils
{
    static MaterialPropertyBlock s_PropertyBlock = new MaterialPropertyBlock();

    static Mesh s_FullscreenMesh = null;
    public static Mesh fullscreenMesh
    {
        get
        {
            if (s_FullscreenMesh != null)
                return s_FullscreenMesh;

            float topV = 1.0f;
            float bottomV = 0.0f;

            s_FullscreenMesh = new Mesh { name = "Fullscreen Quad" };
            s_FullscreenMesh.SetVertices(new List<Vector3>
                {
                    new Vector3(-1.0f, -1.0f, 0.0f),
                    new Vector3(-1.0f,  1.0f, 0.0f),
                    new Vector3(1.0f, -1.0f, 0.0f),
                    new Vector3(1.0f,  1.0f, 0.0f)
                });

            s_FullscreenMesh.SetUVs(0, new List<Vector2>
                {
                    new Vector2(0.0f, bottomV),
                    new Vector2(0.0f, topV),
                    new Vector2(1.0f, bottomV),
                    new Vector2(1.0f, topV)
                });

            s_FullscreenMesh.SetIndices(new[] { 0, 1, 2, 2, 1, 3 }, MeshTopology.Triangles, 0, false);
            s_FullscreenMesh.UploadMeshData(true);
            return s_FullscreenMesh;
        }
    }

    static Mesh s_PlaneMesh = null;
    public static Mesh planeMesh
    {
        get
        {
            if (s_PlaneMesh != null)
                return s_PlaneMesh;

            float topV = 1.0f;
            float bottomV = 0.0f;

            s_PlaneMesh = new Mesh { name = "Plane Mesh" };
            s_PlaneMesh.SetVertices(new List<Vector3>
            {
                new Vector3(-1.0f, 0.0f, -1.0f),
                new Vector3(-1.0f, 0.0f, 1.0f),
                new Vector3(1.0f, 0.0f, -1.0f),
                new Vector3(1.0f, 0.0f, 1.0f)
            });

            s_PlaneMesh.SetUVs(0, new List<Vector2>
            {
                new Vector2(0.0f, bottomV),
                new Vector2(0.0f, topV),
                new Vector2(1.0f, bottomV),
                new Vector2(1.0f, topV)
            });

            s_PlaneMesh.SetIndices(new[] { 0, 1, 2, 2, 1, 3 }, MeshTopology.Triangles, 0, false);
            s_PlaneMesh.UploadMeshData(true);
            return s_PlaneMesh;
        }
    }

    static Mesh m_QuadMesh;
    // getter 
    public static Mesh quadMesh
    {
        get
        {
            if (m_QuadMesh == null)
            {
                float nearClipZ = -1;
                if (SystemInfo.usesReversedZBuffer)
                    nearClipZ = 1;

                m_QuadMesh = new Mesh();
                // m_QuadMesh.vertices = GetQuadVertexPosition(nearClipZ);
                m_QuadMesh.SetVertices(GetQuadVertexPosition(nearClipZ));
                // m_QuadMesh.uv = GetQuadTexCoord();
                m_QuadMesh.SetUVs(0, GetQuadTexCoord());
                // m_QuadMesh.triangles = new int[6] { 0, 1, 2, 0, 2, 3 };
                m_QuadMesh.SetTriangles(new int[6] { 0, 1, 2, 0, 2, 3 }, 0);
            }
            return m_QuadMesh;
        }
    }
    static Vector3[] GetQuadVertexPosition(float z /*= UNITY_NEAR_CLIP_VALUE*/)
    {
        var r = new Vector3[4];
        for (uint i = 0; i < 4; i++)
        {
            uint topBit = i >> 1;
            uint botBit = (i & 1);
            float x = topBit;
            float y = 1 - (topBit + botBit) & 1; // produces 1 for indices 0,3 and 0 for 1,2
            r[i] = new Vector3(x, y, z);
        }
        return r;
    }
    // Should match Common.hlsl
    static Vector2[] GetQuadTexCoord()
    {
        var r = new Vector2[4];
        for (uint i = 0; i < 4; i++)
        {
            uint topBit = i >> 1;
            uint botBit = (i & 1);
            float u = topBit;
            float v = (topBit + botBit) & 1; // produces 0 for indices 0,3 and 1 for 1,2
            if (SystemInfo.graphicsUVStartsAtTop)
                v = 1.0f - v;

            r[i] = new Vector2(u, v);
        }
        return r;
    }


    static class ShaderConstants
    {
        public static readonly int _SourceSize = Shader.PropertyToID("_SourceSize");
        public static readonly int _SourceTex = Shader.PropertyToID("_SourceTex");
    }


    public static void SetSourceSize(CommandBuffer cmd, RenderTextureDescriptor desc)
    {
        float width = desc.width;
        float height = desc.height;
        if (desc.useDynamicScale)
        {
            width *= ScalableBufferManager.widthScaleFactor;
            height *= ScalableBufferManager.heightScaleFactor;
        }
        cmd.SetGlobalVector(ShaderConstants._SourceSize, new Vector4(width, height, 1.0f / width, 1.0f / height));
    }

    public static void SetSourceTexture(CommandBuffer cmd, RenderTargetIdentifier source)
    {
        cmd.SetGlobalTexture(ShaderConstants._SourceTex, source);
    }

    public static BuiltinRenderTextureType BlitDstDiscardContent(CommandBuffer cmd, RenderTargetIdentifier rt)
    {
        cmd.SetRenderTarget(new RenderTargetIdentifier(rt, 0, CubemapFace.Unknown, -1),
            RenderBufferLoadAction.DontCare, RenderBufferStoreAction.Store,
            RenderBufferLoadAction.DontCare, RenderBufferStoreAction.DontCare);
        return BuiltinRenderTextureType.CurrentActive;
    }

    public static RenderTextureDescriptor GetCompatibleDescriptor(RenderTextureDescriptor descriptor, int width, int height, GraphicsFormat format, int depthBufferBits = 0)
    {
        var desc = descriptor;
        desc.depthBufferBits = depthBufferBits;
        desc.msaaSamples = 1;
        desc.width = width;
        desc.height = height;
        desc.graphicsFormat = format;
        return desc;
    }
 
    public static void Blit(CommandBuffer cmd, RenderingData data, Material material, int passIndex = 0)
    {
        var renderer = data.cameraData.renderer;
        var destination = renderer.GetCameraColorFrontBuffer(cmd);
        destination = BlitDstDiscardContent(cmd, destination);
        cmd.Blit(renderer.cameraColorTarget, destination, material, passIndex);
        renderer.SwapColorBuffer(cmd);
    }
   

    static internal void DrawQuad(CommandBuffer cmd, Material material, int shaderPass)
    {
        if (SystemInfo.graphicsShaderLevel < 30)
            cmd.DrawMesh(quadMesh, Matrix4x4.identity, material, 0, shaderPass, s_PropertyBlock);
        else
            cmd.DrawProcedural(Matrix4x4.identity, material, shaderPass, MeshTopology.Quads, 4, 1, s_PropertyBlock);
    }
}