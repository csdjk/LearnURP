// Create by lichanglong
// 2022.4.5
// 天气系统
#include "Assets\Shaders\Libraries\Node.hlsl"
#include "Assets\Shaders\Libraries\Noise.hlsl"

struct WetlandData
{
    half3 albedo;
    half3 normalTS;
    half smoothness;
    half metallic;
};

WetlandData InitWetlandData(half3 albedo, half3 normalTS, half smoothness, half metallic)
{
    WetlandData o;
    o.albedo = albedo;
    o.normalTS = normalTS;
    o.smoothness = smoothness;
    o.metallic = metallic;
    return o;
}

// 计算波纹
half3 CalculateRipple(float2 ripple_uv, float strength, TEXTURE2D_PARAM(_RippleMap, sampler_RippleMap))
{
    float tile = round(_Time.x * _RippleSpeed);
    float2 flip_uv = Flipbook(frac(ripple_uv), 4, 4, tile, float2(0, 1));
    half3 rippleNormal = SampleNormal(flip_uv, TEXTURE2D_ARGS(_RippleMap, sampler_RippleMap), strength);
    return rippleNormal;
}

// 混合地面和水
WetlandData BlendWater(
    WetlandData data,
    float2 uv, float3 waterColor,
    float waterHeight, float noiseSpped,
    float rippleStrength, float rippleTilling,
    TEXTURE2D_PARAM(_HeightMap, sampler_HeightMap),
    TEXTURE2D_PARAM(_RippleMap, sampler_RippleMap))
{
    // half old_smoothness = data.smoothness;
    // 根据高度图混合
    half height = SAMPLE_TEXTURE2D(_HeightMap, sampler_HeightMap, uv).r;
    float4 layer1 = float4(0, 0, 0, height);
    float4 layer2 = float4(1, 1, 1, waterHeight);
    float wetness = BlendTexture(layer1, uv.x, layer2, uv.x);

    wetness = saturate(wetness);
    // 根据湿度插值
    half3 wetColor = data.albedo * data.albedo * waterColor;
    data.albedo = lerp(data.albedo, wetColor, wetness);
    data.smoothness *= wetness;
    //  noise
    float scale = _Time.x * noiseSpped ;
    float strength = random(uv * scale);
// data.albedo = strength;

    strength *= rippleStrength * step(waterHeight, wetness + 0.001);
    // 水滴波纹，两层
    float2 ripple_uv = uv * rippleTilling;
    float2 ripple_uv2 = uv * rippleTilling * 0.5 + 0.3;
    half3 rippleNormal = BlendNormal(
        CalculateRipple(ripple_uv, strength, TEXTURE2D_ARGS(_RippleMap, sampler_RippleMap)),
        CalculateRipple(ripple_uv2, strength, TEXTURE2D_ARGS(_RippleMap, sampler_RippleMap))
    );
    // 混合水、波纹法线
    rippleNormal = BlendNormal(rippleNormal, half3(0, 0, 1));
    // data.normalTS = BlendNormal(rippleNormal, data.normalTS) ;
    data.normalTS = lerp(data.normalTS, rippleNormal, wetness);

    data.metallic = lerp(data.metallic, 0, wetness);
    return data;
}