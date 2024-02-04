// Create by lichanglong
// 2022.4.5
// 天气系统
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Assets\Shaders\Libraries\Node.hlsl"
#include "Assets\Shaders\Libraries\Noise.hlsl"

TEXTURE2D(_RippleMap);
SAMPLER(sampler_RippleMap);

TEXTURE2D(_HeightMap);
SAMPLER(sampler_HeightMap);

#if defined(_WATER_RIPPLE_ADVANCED)
TEXTURE2D(_RippleMapAdvanced);
SAMPLER(sampler_RippleMapAdvanced);
#endif

struct WetlandData
{
    half3 albedo;
    half3 normalTS;
    half smoothness;
    half metallic;
    half colorPower;
};

struct WaterData
{
    half3 color;
    half colorPower;
    half smoothnessAdd;
    half metallic;
    half height;
    half maskBlend;
};

WetlandData InitWetlandData(half3 albedo, half3 normalTS, half smoothness, half metallic, half colorPower
)
{
    WetlandData data;
    data.albedo = albedo;
    data.normalTS = normalTS;
    data.smoothness = smoothness;
    data.metallic = metallic;
    data.colorPower = colorPower;
    return data;
}

WaterData InitWaterData(half3 color, half colorPower, half smoothnessAdd, half metallic, half height,
half blend)
{
    WaterData data;
    data.color = color;
    data.colorPower = colorPower;
    data.smoothnessAdd = smoothnessAdd;
    data.metallic = metallic;
    data.height = height;
    data.maskBlend = blend;
    return data;
}

float3 UnpackNormalWithScale(float2 packednormal, float scale)
{
    float3 normal;
    normal.xy = (packednormal.xy * 2 - 1) * scale;
    normal.z = sqrt(1 - saturate(dot(normal.xy, normal.xy)));
    return normal;
}

half3 CalculateRippleXY(float2 ripple_uv, half speed, half intensity, half2 size)
{
    float tile = round(_Time.y * speed);
    float2 flip_uv = Flipbook(frac(ripple_uv), size.x, size.y, tile, float2(0, 1));
    float4 normal = SAMPLE_TEXTURE2D(_RippleMap, sampler_RippleMap, flip_uv);
    half3 rippleNormal = UnpackNormalWithScale(normal.xy, intensity);
    return rippleNormal;
}
half3 CalculateRippleZW(float2 ripple_uv, half speed, half intensity, half2 size)
{
    float tile = round(_Time.y * speed);
    float2 flip_uv = Flipbook(frac(ripple_uv), size.x, size.y, tile, float2(0, 1));
    float4 normal = SAMPLE_TEXTURE2D(_RippleMap, sampler_RippleMap, flip_uv);
    half3 rippleNormal = UnpackNormalWithScale(normal.zw, intensity);
    return rippleNormal;
}


#if defined(_WATER_RIPPLE_ADVANCED)

    // https://seblagarde.wordpress.com/2013/01/03/water-drop-2b-dynamic-rain-and-its-effects/
    float3 CalculateRippleAdvanced(float2 uv, float currentTime, float weight, float2 intensity, float frequency = 9, int frequencyMax = 3)
    {
        // R：存储到距圆中心距离的反向。类似sdf
        // G/B：存储圆中心的方向(法线)，
        // A：采用随机灰度值为圆的常数。
        float4 ripple = SAMPLE_TEXTURE2D(_RippleMapAdvanced, sampler_RippleMapAdvanced, uv);
        //gb [0,1]-> [-1,1]
        ripple.yz = ripple.yz * 2.0 - 1.0;

        //随机值加上时间偏移
        float dropFrac = frac(ripple.w + currentTime);
        //timeFrac限制在[-1,1],dropFrac - 1.0,可以确保圆圈的外面(ripple.x=0),timeFrac<=0.
        //从而波纹外面的法线是垂直的。也就是水平的。
        float timeFrac = dropFrac - 1.0 + ripple.x;
        // 波纹随着时间扩大(dropFrac 变大)，dropFator越小，波纹慢慢变平
        float dropFator = saturate(0.2 + weight * 0.8 - dropFrac);
        //从波纹出现开始，时间越大(dropFrac 变大)，dropFator 越小，final 越小，波纹越平。
        //sin(clamp(timeFrac * 9.0,0.0,3.0)PI)：0-3PI之间，sin就是一个波峰-波谷-波峰的函数图像，
        //在0-3*PI之外sin函数皆为0.9.0是一个把timeFrac参数放大的因子。
        //波纹圈内的值，比如波纹中心值，经过sin函数的计算，变成0.也就是说波纹中心点也是平的。这个平的区域，
        // 随着时间变大，慢慢扩大，（时间越大，只有红色通道部分越小的地方(红色通道ripple.x渐变到0)，
        //sin函数才不为0.所有波纹就会有慢慢变大的效果
        float final = dropFator * ripple.x * sin(clamp(timeFrac * frequency, 0.0, frequencyMax) * PI);
        return float3(ripple.yz * final * 0.35 * intensity, 1.0);
    }

#endif


WetlandData BlendWater(WetlandData data, WaterData waterData, float2 uv, float4 ripple_uv, float2 rippleSpeed,
float2 rippleIntensity, float2 rippleGrid, half weight = 5,half rippleFrequency = 9,half rippleFrequencyMax = 3)
{
    half2 mask_uv = uv;

    half height = SAMPLE_TEXTURE2D(_HeightMap, sampler_HeightMap, mask_uv).r;

    half wetness = 1.0 - SmoothValue(waterData.height, waterData.maskBlend, height);
    // 根据湿度插值
    half3 waterColor = pow(data.albedo, waterData.colorPower) * _WaterColor.rgb;
    half3 wetlandColor = pow(data.albedo, data.colorPower);


    float3 waterNormal = float3(0, 0, 1);
    // 水滴波纹
    #if defined(_WATER_RIPPLE)
        #if defined(_WATER_RIPPLE_ADVANCED)
            waterNormal = CalculateRippleAdvanced(ripple_uv.xy, _Time.x * rippleSpeed, weight, rippleIntensity, rippleFrequency, rippleFrequencyMax);
        #else
            waterNormal = CalculateRippleXY(ripple_uv.xy, rippleSpeed.x, rippleIntensity.x, rippleGrid);
        #endif
    #endif
    //积水法线
    #if defined(_WATER_FLOW)
        waterNormal = BlendNormal(CalculateRippleZW(ripple_uv.zw, rippleSpeed.y, rippleIntensity.y, rippleGrid), waterNormal);
    #endif

    data.albedo = lerp(wetlandColor, waterColor, wetness);
    data.smoothness = lerp(saturate(data.smoothness + waterData.smoothnessAdd), _WaterColor.a, wetness);
    data.normalTS = lerp(data.normalTS, waterNormal, wetness);
    data.metallic = lerp(data.metallic, waterData.metallic, wetness);
    return data;
}




//
// // 混合地面和水
// WetlandData BlendWater(
//     WetlandData data,
//     float2 uv, float3 waterColor,
//     float waterHeight, float noiseSpped,
//     float rippleStrength, float rippleTilling
// )
// {
//     // half old_smoothness = data.smoothness;
//     // 根据高度图混合
//     half height = SAMPLE_TEXTURE2D(_HeightMap, sampler_HeightMap, uv).r;
//     float4 layer1 = float4(0, 0, 0, height);
//     float4 layer2 = float4(1, 1, 1, waterHeight);
//     float wetness = BlendTexture(layer1, uv.x, layer2, uv.x);
//
//     wetness = saturate(wetness);
//     // 根据湿度插值
//     half3 wetColor = data.albedo * data.albedo * waterColor;
//     data.albedo = lerp(data.albedo, wetColor, wetness);
//     data.smoothness *= wetness;
//     //  noise
//     float scale = _Time.x * noiseSpped;
//     float strength = random(uv * scale);
//     // data.albedo = strength;
//
//     strength *= rippleStrength * step(waterHeight, wetness + 0.001);
//     // 水滴波纹，两层
//     float2 ripple_uv = uv * rippleTilling;
//     float2 ripple_uv2 = uv * rippleTilling * 0.5 + 0.3;
//     half3 rippleNormal = BlendNormal(
//         CalculateRipple(ripple_uv, strength),
//         CalculateRipple(ripple_uv2, strength)
//     );
//     // 混合水、波纹法线
//     rippleNormal = BlendNormal(rippleNormal, half3(0, 0, 1));
//     // data.normalTS = BlendNormal(rippleNormal, data.normalTS) ;
//     data.normalTS = lerp(data.normalTS, rippleNormal, wetness);
//
//     data.metallic = lerp(data.metallic, 0, wetness);
//     return data;
// }
