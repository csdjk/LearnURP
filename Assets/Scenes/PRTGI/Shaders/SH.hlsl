#ifndef PRTGI_SH_INCLUDED
#define PRTGI_SH_INCLUDED

uint3 _ProbeGridSize;
float4 _VoxelCorner;
#define _ProbeSpacing _VoxelCorner.w
// StructuredBuffer<float3> _CoefficientVoxel;


// ref: https://www.shadertoy.com/view/lsfXWH
float SH(uint index, float3 s)
{
    #define k01 0.2820947918    // sqrt(  1/PI)/2
    #define k02 0.4886025119    // sqrt(  3/PI)/2
    #define k03 1.0925484306    // sqrt( 15/PI)/2
    #define k04 0.3153915652    // sqrt(  5/PI)/4
    #define k05 0.5462742153    // sqrt( 15/PI)/4

    float x = s.x;
    float y = s.z;
    float z = s.y;

    if (index == 0) return k01; // l=0, m=0

    else if (index == 1) return k02 * y; // l=1, m=-1
    else if (index == 2) return k02 * z; // l=1, m=0
    else if (index == 3) return k02 * x; // l=1, m=1

    else if (index == 4) return k03 * x * y; // l=2, m=-2
    else if (index == 5) return k03 * y * z; // l=2, m=-1
    else if (index == 6) return k04 * (2.0 * z * z - x * x - y * y); // l=2, m=0
    else if (index == 7) return k03 * x * z; // l=2, m=1
    else if (index == 8) return k05 * (x * x - y * y); // l=2, m=2

    else return 0.0;
}

// decode irradiance
float3 IrradianceSH9(in float3 c[9], in float3 dir)
{
    #define A0 3.1415
    #define A1 2.0943
    #define A2 0.7853

    float3 irradiance = float3(0, 0, 0);
    irradiance += SH(0, dir) * c[0] * A0;
    irradiance += SH(1, dir) * c[1] * A1;
    irradiance += SH(2, dir) * c[2] * A1;
    irradiance += SH(3, dir) * c[3] * A1;
    irradiance += SH(4, dir) * c[4] * A2;
    irradiance += SH(5, dir) * c[5] * A2;
    irradiance += SH(6, dir) * c[6] * A2;
    irradiance += SH(7, dir) * c[7] * A2;
    irradiance += SH(8, dir) * c[8] * A2;
    irradiance = max(float3(0, 0, 0), irradiance);

    return irradiance;
}


float3 Index3DToWorldPos(uint3 probeIndex3)
{
    return probeIndex3 * _ProbeSpacing + _VoxelCorner.xyz;
}

//网格坐标转换为一维索引
uint Index3DToIndex1D(uint3 index3)
{
    return index3.x + index3.y * _ProbeGridSize.x + index3.z * _ProbeGridSize.x * _ProbeGridSize.y;
}

bool IsIndex3DInsideVoxel(uint3 probeIndex3)
{
    bool isInsideVoxelX = probeIndex3.x < _ProbeGridSize.x;
    bool isInsideVoxelY = probeIndex3.y < _ProbeGridSize.y;
    bool isInsideVoxelZ = probeIndex3.z < _ProbeGridSize.z;
    bool isInsideVoxel = isInsideVoxelX && isInsideVoxelY && isInsideVoxelZ;
    return isInsideVoxel;
}

//世界坐标转换为Grid坐标xyz
uint3 WorldPosToIndex3D(float3 worldPos, float3 probeSpacing, uint3 probeGridSize, float3 voxelCorner)
{
    // 将世界坐标转换为局部坐标
    float3 localPos = worldPos - voxelCorner;
    // 将局部坐标转换为网格坐标
    localPos = localPos / probeSpacing;
    uint3 index3D = floor(localPos);
    // 限制在网格范围内
    return clamp(index3D, uint3(0, 0, 0), probeGridSize - uint3(1, 1, 1));
}

uint GetProbeIndex(float3 worldPos, float3 probeSpacing, uint3 probeGridSize, float3 voxelCorner)
{
    uint3 index3D = WorldPosToIndex3D(worldPos, probeSpacing, probeGridSize, voxelCorner);
    uint index = Index3DToIndex1D(index3D);
    return index;
}


void DecodeSHCoefficientFromVoxel(inout float3 c[9], in StructuredBuffer<float3> _coefficientVoxel, int probeIndex)
{
    UNITY_UNROLL
    for (int i = 0; i < 9; i++)
    {
        c[i] = _coefficientVoxel[probeIndex * 9 + i];
    }
}


float3 TrilinearInterpolationFloat3(in float3 value[8], float3 rate)
{
    float3 a = lerp(value[0], value[4], rate.x); // 000, 100
    float3 b = lerp(value[2], value[6], rate.x); // 010, 110
    float3 c = lerp(value[1], value[5], rate.x); // 001, 101
    float3 d = lerp(value[3], value[7], rate.x); // 011, 111
    float3 e = lerp(a, b, rate.y);
    float3 f = lerp(c, d, rate.y);
    float3 g = lerp(e, f, rate.z);
    return g;
}

float3 SampleSHVoxel(in float3 worldPos, in float3 normal, in StructuredBuffer<float3> _coefficientVoxel)
{
    // uint probeIndex = GetProbeIndex(worldPos, _ProbeSpacing, _ProbeGridSize, _VoxelCorner.xyz);
    // float3 c[9];
    // DecodeSHCoefficientFromVoxel(c, _coefficientVoxel, probeIndex);
    // float3 irradiance = IrradianceSH9(c, normal) * INV_PI;
    // return irradiance;

    // probe grid index for current fragment
    uint3 probeIndex3 = WorldPosToIndex3D(worldPos, _ProbeSpacing, _ProbeGridSize, _VoxelCorner);
    int3 offset[8] = {
        int3(0, 0, 0), int3(0, 0, 1), int3(0, 1, 0), int3(0, 1, 1),
        int3(1, 0, 0), int3(1, 0, 1), int3(1, 1, 0), int3(1, 1, 1),
    };

    float3 c[9];
    float3 Lo[8] = {
        float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0), float3(0, 0, 0),
        float3(0, 0, 0), float3(0, 0, 0),
    };
    float weight = 0.0005;

    // near 8 probes
    for (int i = 0; i < 8; i++)
    {
        uint3 idx3 = probeIndex3 + offset[i];
        bool isInsideVoxel = IsIndex3DInsideVoxel(idx3);
        if (!isInsideVoxel)
        {
            Lo[i] = float3(0, 0, 0);
            continue;
        }

        // normal weight blend
        float3 probePos = Index3DToWorldPos(idx3);
        float3 dir = normalize(probePos - worldPos);
        float normalWeight = saturate(dot(dir, normal));
        weight += normalWeight;

        // decode SH9
        int probeIndex = Index3DToIndex1D(idx3);
        DecodeSHCoefficientFromVoxel(c, _coefficientVoxel, probeIndex);
        // Lo[i] = IrradianceSH9(c, normal) * INV_PI * normalWeight;
        Lo[i] = IrradianceSH9(c, normal) * INV_PI;
    }

    // trilinear interpolation
    float3 minCorner = Index3DToWorldPos(probeIndex3);
    float3 rate = (worldPos - minCorner) / _ProbeSpacing;
    // float3 color = TrilinearInterpolationFloat3(Lo, rate) / weight;
    float3 color = TrilinearInterpolationFloat3(Lo, rate);


    return color;
}
#endif
