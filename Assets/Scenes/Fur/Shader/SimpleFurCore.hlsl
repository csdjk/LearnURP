#ifndef LCL_FUR_INCLUDED
#define LCL_FUR_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float2 uv : TEXCOORD0;
    float4 color : COLOR;
    float4 normalOS : NORMAL;
    UNITY_VERTEX_INPUT_INSTANCE_ID

};

struct VertexOutput
{
    float4 positionCS : SV_POSITION;
    float4 uv : TEXCOORD0;
    float3 normalWS : NORMAL;
    float4 shadowCoord : TEXCOORD1;
    float3 viewDirWS : TEXCOORD2;
    float3 positionWS : TEXCOORD3;
    half3 lightColor : COLOR;
    half3 directLight : COLOR1;
    half3 indirectLight : COLOR2;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);
TEXTURE2D(_FurNoiseTex);
SAMPLER(sampler_FurNoiseTex);

float _FurOffset;

// 注意内存对齐(4D向量为一组)
CBUFFER_START(UnityPerMaterial)
    float4 _MainTex_ST;
    half4 _DiffuseColor;
    half4 _OcclusionColor;
    float4 _FurNoiseTex_ST;

    float3 _Gravity;
    float _FurLength;

    float _EdgeFade;
    float _GravityStrength;
    half _FresnelLV;
    half _LightFilter;

    half _CutoffStart;
    half _CutoffEnd;
    half _AlphaBase;
CBUFFER_END

VertexOutput LitPassVertex(Attributes input)
{
    VertexOutput output;
    ZERO_INITIALIZE(VertexOutput, output);
    // FUR
    //  外力影响
    half3 direction = lerp(input.normalOS.xyz, _Gravity.xyz, _GravityStrength);
    // 对发尖影响最大
    direction = lerp(input.normalOS.xyz, direction, _FurOffset);
    input.positionOS.xyz += direction * _FurLength * _FurOffset;


    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    output.positionCS = vertexInput.positionCS;
    output.positionWS = vertexInput.positionWS;
    VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS.xyz);
    output.normalWS = normalInputs.normalWS;
    output.viewDirWS = GetWorldSpaceNormalizeViewDir(vertexInput.positionWS);
    output.uv.xy = TRANSFORM_TEX(input.uv, _MainTex);
    output.uv.zw = TRANSFORM_TEX(input.uv, _FurNoiseTex);


    // Shadow
    float4 shadowCoord = float4(0.0, 0.0, 0.0, 0.0);
    #if defined(_SHADOW_ON)
        #if defined(_ACTOR_SHADOW)
            shadowCoord = GetActorShadowCoord(vertexInput.positionWS);
        #else
            shadowCoord = GetShadowCoord(vertexInput);
        #endif
    #endif
    output.shadowCoord = shadowCoord;

    Light mainLight = GetMainLight(shadowCoord, vertexInput.positionWS,1);
    // float atten = mainLight.shadowAttenuation;
    float3 L = mainLight.direction;
    half3 lightColor = mainLight.color;

    // Shadeing
    float3 N = normalize(normalInputs.normalWS);
    float3 V = SafeNormalize(output.viewDirWS);
    half NdotL = dot(N, L);
    half NdotV = max(0, dot(N, V));

    half3 finalColor = half3(0, 0, 0);
    // SH = half3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
    half3 SH = SampleSH(output.normalWS);
    SH = Gamma20ToLinear(SH);

    half Occlusion = _FurOffset * _FurOffset;
    // Occlusion += 0.04;
    half3 SHL = lerp(_OcclusionColor.rgb * SH, SH, Occlusion);

    half Fresnel = 1 - NdotV;
    half3 RimLight = Fresnel * Occlusion; //AO的深度剔除

    RimLight *= RimLight;
    RimLight *= _FresnelLV * SH;
    SHL += RimLight;

    half DirLight = saturate(NdotL + _LightFilter + _FurOffset);

    // output.directLight = RimLight;
    output.directLight = DirLight * lightColor;
    output.indirectLight = SHL;
    return output;
}


half4 LitPassFragment(VertexOutput input) : SV_Target
{
    half2 uv = input.uv.xy;
    half2 noise_uv = input.uv.zw;
    float3 N = normalize(input.normalWS);
    float3 V = SafeNormalize(input.viewDirWS);
    float3 positionWS = input.positionWS;

    float4 shadowCoord = float4(0, 0, 0, 0);
    #if defined(_SHADOW_ON)
        shadowCoord = input.shadowCoord;
        #if defined(MAIN_LIGHT_CALCULATE_SHADOWS) && !defined(_ACTOR_SHADOW)
            shadowCoord = TransformWorldToShadowCoord(positionWS);
        #endif
    #endif
    Light mainLight = GetMainLight(shadowCoord, positionWS,1);
    float atten = mainLight.shadowAttenuation;

    half NdotV = saturate(dot(N, V));

    half3 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv).rgb;
    albedo = albedo * _DiffuseColor.rgb;
    albedo = Gamma20ToLinear(albedo);

    // -----------------------------Fur Alpha----------------------------
    float noise = SAMPLE_TEXTURE2D(_FurNoiseTex, sampler_FurNoiseTex, noise_uv).r;
    #if defined(_SOFT)
        noise = smoothstep(_FurOffset, 1, noise) + _AlphaBase;
    #else
        noise = step(lerp(_CutoffStart, _CutoffEnd, _FurOffset), noise);
    #endif

    half alpha = 1 - _FurOffset * _FurOffset;
    alpha += NdotV - _EdgeFade;
    alpha = max(0, alpha);
    alpha *= noise;


    half3 finalColor = albedo * (input.directLight * atten + input.indirectLight);
    finalColor = LinearToGamma20(finalColor);
    return half4(finalColor, saturate(alpha));
}




// ------------------------------Shadow Pass------------------------------
float3 _LightDirection;
float3 _LightPosition;

float4 GetShadowPositionHClip(Attributes input)
{
    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
    float3 normalWS = TransformObjectToWorldNormal(input.normalOS);

    #if _CASTING_PUNCTUAL_LIGHT_SHADOW
        float3 lightDirectionWS = normalize(_LightPosition - positionWS);
    #else
        float3 lightDirectionWS = _LightDirection;
    #endif

    #if defined(_ACTOR_SHADOW)
        float4 positionCS = TransformWorldToHClip(ApplyActorShadowBias(positionWS, normalWS, lightDirectionWS));
    #else
        float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));
    #endif


    #if UNITY_REVERSED_Z
        positionCS.z = min(positionCS.z, UNITY_NEAR_CLIP_VALUE);
    #else
        positionCS.z = max(positionCS.z, UNITY_NEAR_CLIP_VALUE);
    #endif

    return positionCS;
}

VertexOutput ShadowPassVertex(Attributes input)
{
    VertexOutput output;
    output.uv = TRANSFORM_TEX(input.uv, _MainTex).xyxy;
    output.positionCS = GetShadowPositionHClip(input);
    return output;
}

half4 ShadowPassFragment(VertexOutput input) : SV_TARGET
{
    Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_MainTex, sampler_MainTex)).a, _DiffuseColor, 0.5);
    return 0;
}

#endif
