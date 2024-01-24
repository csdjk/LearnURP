#ifndef DOD_VOLUME_CLOUD_CORE_INCLUDED
#define DOD_VOLUME_CLOUD_CORE_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

TEXTURE3D(_CloudTexture); SAMPLER(sampler_CloudTexture);


// dstToBox：射线原点到包围盒的距离，如果射线原点在包围盒内部，这个距离就是0
// dstInsideBox: 射线穿过包围盒的距离，
// 如果射线原点在包围盒外部，这个长度就是射线进入和离开包围盒的点之间的距离；
// 如果射线原点在包围盒内部，这个长度就是射线原点到离开包围盒的点的距离。
float2 rayBoxDst(float3 boundsMin, float3 boundsMax, float3 rayOrigin, float3 rayDir)
{
    float3 t0 = (boundsMin - rayOrigin) / rayDir;
    float3 t1 = (boundsMax - rayOrigin) / rayDir;
    float3 tmin = min(t0, t1);
    float3 tmax = max(t0, t1);

    //射线到box两个相交点的距离, dstA最近距离， dstB最远距离
    float dstA = max(max(tmin.x, tmin.y), tmin.z);
    float dstB = min(tmax.x, min(tmax.y, tmax.z));

    float dstToBox = max(0, dstA);
    float dstInsideBox = max(0, dstB - dstToBox);
    return float2(dstToBox, dstInsideBox);
}

//Beer衰减
float Beer(float density, float absorptivity = 1)
{
    return exp(-density * absorptivity);
}

//粉糖效应，模拟云的内散射影响
float BeerPowder(float density, float absorptivity = 1)
{
    return 2.0 * exp(-density * absorptivity) * (1.0 - exp(-2.0 * density));
}

//Henyey-Greenstein相位函数
float HenyeyGreenstein(float angle, float g)
{
    float g2 = g * g;
    return (1.0 - g2) / (4.0 * PI * pow(1.0 + g2 - 2.0 * g * angle, 1.5));
}

//两层Henyey-Greenstein散射，使用Max混合。同时兼顾向前 向后散射
float HGScatterMax(float angle, float g_1, float intensity_1, float g_2, float intensity_2)
{
    return max(intensity_1 * HenyeyGreenstein(angle, g_1), intensity_2 * HenyeyGreenstein(angle, g_2));
}

//两层Henyey-Greenstein散射，使用Lerp混合。同时兼顾向前 向后散射
float HGScatterLerp(float angle, float g_1, float g_2, float weight)
{
    return lerp(HenyeyGreenstein(angle, g_1), HenyeyGreenstein(angle, g_2), weight);
}


float SampleDensity(float3 uvw,float densityScale,float power = 1.0)
{
    float noise = SAMPLE_TEXTURE3D_LOD(_CloudTexture, sampler_CloudTexture, uvw, 0).x;
    half density = pow(noise, power) * densityScale;
    return density;
}

float3 SampleDensity(float3 uvw)
{
    float3 noise = SAMPLE_TEXTURE3D_LOD(_CloudTexture, sampler_CloudTexture, uvw, 0).rgb;
    return noise;
}
#endif
