using System;
using UnityEngine;
using UnityEngine.Rendering;
using Random = UnityEngine.Random;

namespace LcLGame.PRTGI
{
    [Serializable]
    public struct Surfel
    {
        public Vector3 position;
        public Vector3 normal;
        public Vector3 albedo;
        public float skyMask;
    }

    public enum ProbeDebugMode
    {
        None = 0,
        SphereDistribution = 1,
        SampleDirection = 2,
        Surfel = 3,
        SurfelRadiance = 4
    }

    public enum ProbeDebugPos
    {
        None = 0,
        Index = 1,
        GridIndex = 2,
        WorldPos = 3
    }

    public class Probe
    {
        const int CUBEMAP_SIZE = 128;

        public Vector3 position;
        public int index;
        public Vector3Int gridIndex;

        ComputeShader m_ComputeShader;
        RenderTexture m_AlbedoRT;
        RenderTexture m_NormalRT;
        RenderTexture m_WorldPosRT;

        public ComputeBuffer surfels;

        Surfel[] m_SurfelBuffer;
        public Surfel[] SurfelBuffer => m_SurfelBuffer;

        // static int[] m_CoefficientClearValue;

        static Vector3[] m_CoefficientClearValue;

        //-------------Debug Data-----------------
        public ComputeBuffer surfelRadianceDebug;

        Vector3[] m_RadianceDebugBuffer;

        // public ComputeBuffer coefficientSH9;

        public Color debugColor = new(0.0f, 0.8f, 0.0f, 0.80f);
        public Color debugSkyColor = new(0.302f, 0.478f, 1.000f, 0.80f);

        public float debugScale = 0.03f;

        static Probe()
        {
            // m_CoefficientClearValue = new int[CoefficientSize];
            m_CoefficientClearValue = new Vector3[9];
        }

        public Probe(Vector3 position, int index,Vector3Int gridIndex, ComputeShader computeShader)
        {
            this.position = position;
            this.index = index;
            this.gridIndex = gridIndex;
            m_ComputeShader = computeShader;

            var size = System.Runtime.InteropServices.Marshal.SizeOf(typeof(Surfel));
            surfels = new ComputeBuffer(ProbeVolume.SampleCount, size);
            m_SurfelBuffer = new Surfel[ProbeVolume.SampleCount];
            m_RadianceDebugBuffer = new Vector3[ProbeVolume.SampleCount];
            // coefficientSH9 = new ComputeBuffer(9, sizeof(float) * 3);

            surfelRadianceDebug = new ComputeBuffer(ProbeVolume.SampleCount, sizeof(float) * 3);
        }

        public void Destroy()
        {
            surfels?.Release();
        }


        public void Bake(Camera bakeCamera, ProbeBakeFeature bakeFeature)
        {
            m_AlbedoRT = RenderTexture.GetTemporary(CUBEMAP_SIZE, CUBEMAP_SIZE, 0, RenderTextureFormat.ARGBFloat);
            m_AlbedoRT.filterMode = FilterMode.Point;
            m_AlbedoRT.dimension = TextureDimension.Cube;
            m_NormalRT = RenderTexture.GetTemporary(CUBEMAP_SIZE, CUBEMAP_SIZE, 0, RenderTextureFormat.ARGBFloat);
            m_NormalRT.filterMode = FilterMode.Point;
            m_NormalRT.dimension = TextureDimension.Cube;
            m_WorldPosRT = RenderTexture.GetTemporary(CUBEMAP_SIZE, CUBEMAP_SIZE, 0, RenderTextureFormat.ARGBFloat);
            m_WorldPosRT.filterMode = FilterMode.Point;
            m_WorldPosRT.dimension = TextureDimension.Cube;

            bakeCamera.transform.position = position;
            bakeFeature.SetBakeMode(ProbeLightMode.BakeAlbedo);
            bakeCamera.RenderToCubemap(m_AlbedoRT);

            bakeFeature.SetBakeMode(ProbeLightMode.BakeNormal);
            bakeCamera.RenderToCubemap(m_NormalRT);

            bakeFeature.SetBakeMode(ProbeLightMode.BakeWorldPos);
            bakeCamera.RenderToCubemap(m_WorldPosRT);


            SampleSurfels();

            RenderTexture.ReleaseTemporary(m_AlbedoRT);
            RenderTexture.ReleaseTemporary(m_NormalRT);
            RenderTexture.ReleaseTemporary(m_WorldPosRT);
        }

        void SampleSurfels()
        {
            int kernel = m_ComputeShader.FindKernel("SampleSurfel");

            m_ComputeShader.SetVector(PbrtShaderPropertyID.ProbePos, position);
            // m_ComputeShader.SetFloat(PbrtShaderPropertyID.RandSeed, Random.Range(0.0f, 1.0f));
            m_ComputeShader.SetTexture(kernel, PbrtShaderPropertyID.AlbedoCubemap, m_AlbedoRT);
            m_ComputeShader.SetTexture(kernel, PbrtShaderPropertyID.NormalCubemap, m_NormalRT);
            m_ComputeShader.SetTexture(kernel, PbrtShaderPropertyID.WorldPosCubemap, m_WorldPosRT);
            m_ComputeShader.SetBuffer(kernel, PbrtShaderPropertyID.Surfels, surfels);

            m_ComputeShader.Dispatch(kernel, 1, 1, 1);

            surfels.GetData(m_SurfelBuffer);
        }

        public void ReLight(CommandBuffer cmd)
        {
            int kernel = m_ComputeShader.FindKernel("Relight");
            cmd.SetComputeVectorParam(m_ComputeShader, PbrtShaderPropertyID.ProbePos,
                new Vector4(position.x, position.y, position.z, 1.0f));
            cmd.SetComputeBufferParam(m_ComputeShader, kernel, PbrtShaderPropertyID.Surfels, surfels);
            // cmd.SetComputeBufferParam(m_ComputeShader, kernel, "_coefficientSH9", coefficientSH9);
            cmd.SetComputeBufferParam(m_ComputeShader, kernel, PbrtShaderPropertyID.SurfelRadianceDebug,
                surfelRadianceDebug);
            cmd.SetComputeBufferParam(m_ComputeShader, kernel, PbrtShaderPropertyID.CoefficientVoxel,
                ProbeVolume.Instance.CoefficientVoxel);
            cmd.SetComputeIntParam(m_ComputeShader, PbrtShaderPropertyID.IndexInProbeVolume, index);

            // 清空 coefficientSH9 Buffer
            // cmd.SetBufferData(coefficientSH9, m_CoefficientClearValue);

            cmd.DispatchCompute(m_ComputeShader, kernel, 9, 1, 1);
        }

        public void DrawGizmos(ProbeDebugMode debugMode)
        {
            // if (debugMode == ProbeDebugMode.None)
            //     return;
            if (m_SurfelBuffer == null)
                return;

            surfels.GetData(m_SurfelBuffer);

            surfelRadianceDebug.GetData(m_RadianceDebugBuffer);

            for (int i = 0; i < ProbeVolume.SampleCount; i++)
            {
                Surfel surfel = m_SurfelBuffer[i];
                Vector3 radiance = m_RadianceDebugBuffer[i];
                var pos = surfel.position;
                var normal = surfel.normal;
                var albedo = surfel.albedo;

                var dir = Vector3.Normalize(pos - position);
                bool isSky = surfel.skyMask >= 0.995;

                Gizmos.color = debugColor;

                switch (debugMode)
                {
                    case ProbeDebugMode.SphereDistribution:
                        Gizmos.color = isSky ? debugSkyColor : debugColor;
                        Gizmos.DrawSphere(dir + position, debugScale);
                        break;

                    case ProbeDebugMode.SampleDirection:
                        if (isSky)
                        {
                            Gizmos.color = debugSkyColor;
                            Gizmos.DrawLine(position, position + dir * 25.0f);
                        }
                        else
                        {
                            Gizmos.DrawLine(position, pos);
                            Gizmos.DrawSphere(pos, debugScale);
                        }

                        break;

                    case ProbeDebugMode.Surfel:
                        if (isSky) continue;
                        Gizmos.color = new Color(albedo.x, albedo.y, albedo.z);
                        Gizmos.DrawSphere(pos, debugScale);
                        Gizmos.DrawLine(pos, pos + normal * 0.25f);
                        break;

                    case ProbeDebugMode.SurfelRadiance:
                        if (isSky) continue;
                        Gizmos.color = new Color(radiance.x, radiance.y, radiance.z);
                        Gizmos.DrawSphere(pos, debugScale);
                        break;
                }
            }
        }
    }
}
