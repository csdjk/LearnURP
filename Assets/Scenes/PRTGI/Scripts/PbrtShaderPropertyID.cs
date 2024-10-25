using UnityEngine;

namespace LcLGame.PRTGI
{
    internal static class PbrtShaderPropertyID
    {
        public static readonly int AlbedoCubemap = Shader.PropertyToID("_AlbedoCubemap");
        public static readonly int NormalCubemap = Shader.PropertyToID("_NormalCubemap");
        public static readonly int WorldPosCubemap = Shader.PropertyToID("_WorldPosCubemap");
        public static readonly int Surfels = Shader.PropertyToID("_Surfels");
        public static readonly int ProbePos = Shader.PropertyToID("_ProbePos");

        public static readonly int SurfelRadianceDebug = Shader.PropertyToID("_SurfelRadianceDebug");
        public static readonly int CoefficientVoxel = Shader.PropertyToID("_CoefficientVoxel");
        public static readonly int IndexInProbeVolume = Shader.PropertyToID("_IndexInProbeVolume");
        public static readonly int ProbeGridSize = Shader.PropertyToID("_ProbeGridSize");
        public static readonly int VoxelCorner = Shader.PropertyToID("_VoxelCorner");
        public static readonly int LastFrameCoefficientVoxel = Shader.PropertyToID("_LastFrameCoefficientVoxel");
        public static readonly int SkyLightIntensity = Shader.PropertyToID("_SkyLightIntensity");
        public static readonly int GIIntensity = Shader.PropertyToID("_GIIntensity");

        // public static readonly int CoefficientSH9 = Shader.PropertyToID("_coefficientSH9");
        // public static readonly int s_RandSeed = Shader.PropertyToID("_RandSeed");
    }


}
