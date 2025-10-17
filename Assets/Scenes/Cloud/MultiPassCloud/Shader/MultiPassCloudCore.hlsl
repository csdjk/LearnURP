#ifndef LCL_MULT_PASS_CLOUD_INCLUDED
#define LCL_MULT_PASS_CLOUD_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
#include "Assets/Shaders/Libraries/Node.hlsl"

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

TEXTURE2D(_CloudNoiseTex);
SAMPLER(sampler_CloudNoiseTex);

TEXTURE3D(_CloudNoiseTex3D);
SAMPLER(sampler_CloudNoiseTex3D);

uint _PassNumber;
float _LayerOffset;

// 注意内存对齐(4D向量为一组)
CBUFFER_START(UnityPerMaterial)
    float4 _MainTex_ST;
    half4 _DiffuseColor;
    half4 _OcclusionColor;

    float _OffsetIntensity;
    float _EdgeFade;
    half _FresnelLV;
    half _LightFilter;
    half _AlphaBase;

    half _NoiseScale;
    float3 _NoiseSpeed;

    // Translucency
    half _NormalDist;
    half _Scattering;
    half _Direct;
    half3 _Ambient;
    half _Translucency;
CBUFFER_END

VertexOutput LitPassVertex(Attributes input, uint instanceID : SV_InstanceID)
{
    VertexOutput output;
    ZERO_INITIALIZE(VertexOutput, output);

    #ifdef FUR_INSTANCING_ENABLED
        float layerOffset = (float)instanceID / _PassNumber;
    #else
        float layerOffset = _LayerOffset;
    #endif


    // Offset
    half3 direction = input.normalOS.xyz;
    input.positionOS.xyz += direction * _OffsetIntensity * layerOffset;


    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    output.positionCS = vertexInput.positionCS;
    output.positionWS = vertexInput.positionWS;
    VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS.xyz);
    output.normalWS = normalInputs.normalWS;
    output.viewDirWS = GetWorldSpaceNormalizeViewDir(vertexInput.positionWS);
    output.uv.xy = TRANSFORM_TEX(input.uv, _MainTex);
    output.uv.zw = input.uv * _NoiseScale + _Time.x * _NoiseSpeed.xy;


    // Shadow
    float4 shadowCoord = float4(0.0, 0.0, 0.0, 0.0);
    #if defined(_SHADOW_ON)
        shadowCoord = GetShadowCoord(vertexInput);
    #endif

    output.shadowCoord = shadowCoord;

    Light mainLight = GetMainLight(shadowCoord, vertexInput.positionWS, 1);
    float3 L = mainLight.direction;
    half3 lightColor = mainLight.color;

    // -----------------------------Lighting----------------------------
    float3 N = normalize(normalInputs.normalWS);
    float3 V = SafeNormalize(output.viewDirWS);
    half NdotL = dot(N, L);
    half NdotV = max(0, dot(N, V));

    half3 SH = SampleSH(output.normalWS);

    half Occlusion = layerOffset * layerOffset;
    half3 SHL = lerp(_OcclusionColor.rgb * SH, SH, Occlusion);

    half Fresnel = 1 - NdotV;
    half3 RimLight = Fresnel * Occlusion; //AO的深度剔除

    RimLight *= RimLight;
    RimLight *= _FresnelLV * SH;
    SHL += RimLight;

    half dirLight = saturate(NdotL + _LightFilter + layerOffset);

    float3 transLighting = Translucency(V, L, N, _NormalDist,_Scattering,1,_Direct,_Ambient,layerOffset,_Translucency);

    output.directLight = dirLight * lightColor + transLighting;
    output.indirectLight = SHL;

    // output.directLight = transLighting;
    // output.indirectLight = 0;
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
        #if defined(MAIN_LIGHT_CALCULATE_SHADOWS)
            shadowCoord = TransformWorldToShadowCoord(positionWS);
        #endif
    #endif
    Light mainLight = GetMainLight(shadowCoord, positionWS, 1);
    float atten = mainLight.shadowAttenuation;

    half NdotV = saturate(dot(N, V));

    half3 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv).rgb;
    albedo = albedo * _DiffuseColor.rgb;


    //-----------------------------Noise----------------------------
    float noise = 1;
    #if defined(_USE_3D_NOISE)
        half3 flowUV = input.positionWS.xyz * _NoiseScale + _Time.x * _NoiseSpeed.xyz;
        noise = SAMPLE_TEXTURE3D(_CloudNoiseTex3D, sampler_CloudNoiseTex3D, flowUV).r;
    #else
        // noise_uv = TriplanarFlowUV(positionWS, N, _NoiseScale, _NoiseSpeed);
        noise = SAMPLE_TEXTURE2D(_CloudNoiseTex, sampler_CloudNoiseTex, noise_uv).r;
    #endif

    // -----------------------------Alpha----------------------------
    noise = smoothstep(_LayerOffset, 1, noise) + _AlphaBase;

    half alpha = 1 - _LayerOffset * _LayerOffset;
    alpha += NdotV - _EdgeFade;
    alpha = max(0, alpha);
    alpha *= noise;

    // return alpha;
    // -----------------------------Dither Alpha---------------------------
    float ditherMask = pow(1-NdotV,4);
    half2 screenPos = ComputeScreenPosUV(input.positionCS);
    float dither = Dither4x4Bayer(screenPos);
    alpha = alpha * lerp(1,dither,ditherMask);
    // alpha += dither / 255;
    // alpha *= dither;
    // return dither;


    half3 finalColor = albedo * (input.directLight * atten + input.indirectLight);
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
