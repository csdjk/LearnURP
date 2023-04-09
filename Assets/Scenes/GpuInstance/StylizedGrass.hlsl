#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"

#include "Assets/Shaders/Libraries/Wind.hlsl"
#include "Assets/Shaders/Libraries/Node.hlsl"
#include "Assets/Shaders/Libraries/Color.hlsl"


#define SHADOW_BIAS_OFFSET 0.01
// #define MASK_MAP SAMPLE_TEXTURE2D_LOD(_MaskMap, sampler_MaskMap, input.uv, 0)
// #define AO_MASK MASK_MAP.r


#if !defined(SHADERPASS_SHADOWCASTER) || !defined(SHADERPASS_DEPTHONLY)
    #define LIGHTING_PASS
#else
    #undef _NORMALMAP
#endif

// -----------------------------Properties--------------------------------
// TEXTURE2D(_MaskMap);
SAMPLER(sampler_MaskMap);

CBUFFER_START(UnityPerMaterial)
    float4 _BaseColor;
    float4 _BaseMap_ST;
    float4 _BumpMap_ST;
    half _BumpScale;
    float4 _HueVariation;
    float4 _FadeParams;
    half4 _WindDirection;
    
    half _Cutoff;
    half _Smoothness;
    half _OcclusionStrength;
    half _ShadowStrength;
    half _IndirectStrength;

    // SSS
    half _Translucency;
    half _Distortion;
    half _ScaterPower;
    half _ScaterScale;

    //Wind
    half _WindAmbientStrength;
    half _WindSpeed;
    half _WindSwinging;
    half _WindGustStrength;
    half _WindGustFreq;
    half _WindGustTint;

    float4 _BaseColor2;


    // 交互对象坐标和范围（w）
    float4 _PlayerPos;
    // 下压强度
    float _PushStrength;
CBUFFER_END

// -----------------------------Properties End--------------------------------



struct Attributes
{
    float4 positionOS : POSITION;
    float4 color : COLOR0;
    #ifdef LIGHTING_PASS
        float3 normalOS : NORMAL;
    #endif
    #if defined(_NORMALMAP) || defined(CURVEDWORLD_NORMAL_TRANSFORMATION_ON)
        float4 tangentOS : TANGENT;
        float4 uv : TEXCOORD0;
    #else
        float2 uv : TEXCOORD0;
    #endif

    UNITY_VERTEX_INPUT_INSTANCE_ID
};


struct VertexInputs
{
    float4 positionOS;
    float3 normalOS;
    #if defined(_NORMALMAP) || defined(CURVEDWORLD_NORMAL_TRANSFORMATION_ON)
        float4 tangentOS;
    #endif
};

VertexInputs GetVertexInputs(Attributes v)
{
    VertexInputs i = (VertexInputs)0;
    i.positionOS = v.positionOS;
    i.normalOS = v.normalOS;
    #if defined(_NORMALMAP) || defined(CURVEDWORLD_NORMAL_TRANSFORMATION_ON)
        i.tangentOS = v.tangentOS;
    #endif

    return i;
}

struct VertexOutput
{
    float3 positionWS;
    float4 positionCS;
    float4 positionNDC;
    float3 viewDir;

    #if defined(_NORMALMAP) || defined(CURVEDWORLD_NORMAL_TRANSFORMATION_ON)
        real3 tangentWS;
        real3 bitangentWS;
    #endif
    float3 normalWS;
};


struct Varyings
{
    float4 positionCS : SV_POSITION;
    #ifdef _NORMALMAP
        float4 uv : TEXCOORD0;
    #else
        float2 uv : TEXCOORD0;
    #endif
    float4 color : COLOR0;  // r:风力影响强度, g:散射半透影响强度, b: AO
    float3 mask : COLOR1;
    float4 positionWS : TEXCOORD2;
    half3 normalWS : TEXCOORD3;
    #ifdef _NORMALMAP
        half3 tangentWS : TEXCOORD4;
        half3 bitangentWS : TEXCOORD5;
    #endif

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        float4 shadowCoord : TEXCOORD6; // compute shadow coord per-vertex for the main light
    #endif

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        float3 vertexLight : TEXCOORD7;
    #endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

float4 ApplyWind(float4 positionOS)
{
    float2 windSize = positionOS.xz / 12;
    float2 noiseUV = (_Time.y) / 30;
    half noiseValue = SAMPLE_TEXTURE2D_LOD(_WindMap, sampler_WindMap, noiseUV, 0).r;
    positionOS.xz += sin(_Time.zz * _WindSpeed + windSize) * (positionOS.y / 10) * _WindDirection.xz * noiseValue;

    return positionOS;
}


VertexOutput GetVertexOutput(VertexInputs input, float rand, WindSettings s)
{
    VertexOutput data = (VertexOutput)0;

    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
    //草的顶点越接近下面的风力越小
    float4 windVec = GetWindOffset(input.positionOS.xyz, positionWS, rand, s);
    float3 offsets = windVec.xyz;

    // Player 交互
    float3 offsetDir = normalize(positionWS.xyz - _PlayerPos.xyz);
    float dis = distance(positionWS.xyz, _PlayerPos.xyz);
    float radius = _PlayerPos.w;
    
    float isPushRange = smoothstep(dis, dis + 0.2, radius) * s.mask;
    offsets.xz = lerp(offsets.xz, offsets + offsetDir.xz * _PushStrength, isPushRange);
    // offsets.y = lerp(offsets.y, offsets.y + _PushStrength*0.1, isPushRange);


    //Apply Wind offset
    positionWS.xz += offsets.xz;
    positionWS.y -= offsets.y;

    data.positionWS = positionWS;
    data.positionCS = TransformWorldToHClip(data.positionWS);
    
    float4 ndc = data.positionCS * 0.5f;
    data.positionNDC.xy = float2(ndc.x, ndc.y * _ProjectionParams.x) + ndc.w;
    data.positionNDC.zw = data.positionCS.zw;
    return data;

    #ifdef LIGHTING_PASS

        #if defined(_ADVANCED_LIGHTING) && defined(RECALC_NORMALS)
            float3 oPos = TransformWorldToObject(positionWS);
            float3 bentNormals = lerp(input.normalOS, normalize(oPos - input.positionOS.xyz), abs(offsets.x + offsets.z) * 0.5);
        #else
            float3 bentNormals = input.normalOS;
        #endif

        // data.normalWS = TransformObjectToWorldNormal(bentNormals);
        data.normalWS = SafeNormalize(mul(unity_ObjectToWorld, float4(bentNormals, 0)).xyz);
        

        #ifdef _NORMALMAP
            real sign = input.tangentOS.w * GetOddNegativeScale();

            data.tangentWS = TransformObjectToWorldDir(input.tangentOS.xyz);
            // data.tangentWS = SafeNormalize(mul(localToWorld, float4(input.tangentOS.xyz, 0.0)));
            data.bitangentWS = cross(data.normalWS, data.tangentWS) * sign;
        #endif
    #endif

    return data;
}


Varyings LitPassVertex(Attributes input, uint instanceID : SV_InstanceID)
{
    Varyings output;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    //r:风力影响强度, g:散射半透影响强度, b:AO
    output.mask = input.color;

    
    float posOffset = ObjectPosRand01();

    WindSettings wind = InitializeWindSettings(_WindAmbientStrength, _WindSpeed, _WindDirection, _WindSwinging, output.mask.r, _WindGustStrength, _WindGustFreq);
    VertexInputs vertexInputs = GetVertexInputs(input);
    VertexOutput vertexData = GetVertexOutput(vertexInputs, posOffset, wind);

    //Vertex color
    output.color = ApplyVertexColor(_BaseColor.rgb, output.mask.b, _OcclusionStrength, _HueVariation);
    //Apply per-vertex light if enabled in pipeline
    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        //Pass to fragment shader to apply in Lighting function
        output.vertexLight.rgb = VertexLighting(vertexData.positionWS, vertexData.normalWS);
    #endif

    output.uv.xy = TRANSFORM_TEX(input.uv, _BaseMap);
    // output.positionWS = float4(vertexData.positionWS.xyz, ComputeFogFactor(vertexData.positionCS.z));
    output.positionWS = float4(vertexData.positionWS.xyz, 1);
    output.normalWS = vertexData.normalWS;
    #ifdef _NORMALMAP
        output.uv.zw = TRANSFORM_TEX(input.uv, _BumpMap);
        output.tangentWS = vertexData.tangentWS;
        output.bitangentWS = vertexData.bitangentWS;
    #endif

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) //Previously _MAIN_LIGHT_SHADOWS
        //Only when when shadow cascades are per-pixel
        #if defined(_SHADOWBIAS_CORRECTION)
            //Move the shadowed position slightly away from the camera to avoid banding artifacts
            float3 shadowPos = vertexData.positionWS + (vertexData.viewDir * SHADOW_BIAS_OFFSET);
        #else
            float3 shadowPos = vertexData.positionWS;
        #endif

        output.shadowCoord = TransformWorldToShadowCoord(shadowPos); //vertexData.positionWS
    #endif
    output.positionCS = vertexData.positionCS;

    return output;
}


SurfaceData InitializeSurfaceData(Varyings input, float3 positionWS, WindSettings wind, Light mainLight)
{
    SurfaceData surfaceData;

    float4 mainTex = SampleAlbedoAlpha(input.uv.xy, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    float3 albedo = mainTex.rgb;
    albedo.rgb *= input.color.rgb;

    //Tint by wind gust
    wind.gustStrength = 1;
    float gust = SampleGustMap(positionWS.xyz, wind);
    albedo += gust * _WindGustTint * 10 * (mainLight.shadowAttenuation) * input.mask.r;

    surfaceData.albedo = albedo;
    surfaceData.specular = float3(0, 0, 0);
    surfaceData.metallic = 0;
    surfaceData.smoothness = _Smoothness;
    #ifdef _NORMALMAP
        surfaceData.normalTS = SampleNormal(input.uv.zw, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
    #else
        surfaceData.normalTS = float3(0.5, 0.5, 1);
    #endif
    surfaceData.emission = 0;
    surfaceData.occlusion = 1;
    surfaceData.alpha = mainTex.a;
    return surfaceData;
}


float3 ApplyShadowAtten(in Light light, in float amount)
{
    float atten = light.distanceAttenuation * light.shadowAttenuation;
    return lerp(1, atten, amount);
}

void ApplySubsurfaceScattering(inout float3 color, float3 viewDirWS, float3 normalWS, Light light, float amount)
{
    float sss = SubsurfaceScattering(viewDirWS, light.direction, normalWS, _Distortion, _ScaterPower, _ScaterScale);

    float atten = ApplyShadowAtten(light, _ShadowStrength);
    sss *= atten;

    // 根据太阳和地平线夹角衰减
    half sunAngle = dot(float3(0, 1, 0), light.direction);
    half angleMask = saturate(sunAngle * 6.666); /* 1.0/0.15 = 6.666 */
    sss *= angleMask;
    

    float3 tColor = color + BlendOverlay((light.color), color);
    color = lerp(color, tColor, sss * (amount * 4.0));
}

// Tree
half3 SimpleLighting(Light light, half3 normalWS, half3 bakedGI, half3 albedo, half3 emission)
{
    float atten = ApplyShadowAtten(light, _ShadowStrength);
    light.color *= atten;

    float NdotL = saturate(dot(normalWS, light.direction));

    // float3 diffuseColor = lerp(_BaseColor2, _BaseColor, NdotL);
    // half3 color = bakedGI * albedo * diffuseColor * light.color;

    float3 diffuseColor = bakedGI + (NdotL * light.color);
    half3 color = (albedo * diffuseColor) + emission;

    return color;
}

// Grass
half3 SimpleLightingGrass(Light light, half3 normalWS, half3 bakedGI, half3 albedo, half3 emission)
{
    float atten = ApplyShadowAtten(light, _ShadowStrength);
    light.color *= atten;

    float NdotL = saturate(dot(normalWS, light.direction));
    float3 diffuse = lerp(_BaseColor2, _BaseColor, NdotL);

    half3 color = albedo * (bakedGI + diffuse * light.color) + emission;
    // half3 color = albedo * (bakedGI + diffuse * light.color) * (NdotL * 0.5 + 0.5) + emission;

    return color;
}


// General function to apply lighting based on the configured mode
half3 ApplyLighting(SurfaceData surfaceData, Light mainLight, half3 vertexLight, half3 normalWS, half3 positionWS, half translucency)
{
    half3 bakedGI = SampleSH(normalWS) * _IndirectStrength;

    half3 viewDirectionWS = SafeNormalize(GetCameraPositionWS() - positionWS);
    
    #if defined(_ADVANCED_LIGHTING)
        // BRDF
        BRDFData brdfData;
        InitializeBRDFData(surfaceData.albedo, 0, 0, surfaceData.smoothness, surfaceData.alpha, brdfData);
        half3 color = GlobalIllumination(brdfData, bakedGI, surfaceData.occlusion, normalWS, viewDirectionWS);
        color += LightingPhysicallyBased(brdfData, mainLight, normalWS, viewDirectionWS);
    #else
        // 简单着色
        MixRealtimeAndBakedGI(mainLight, normalWS, bakedGI, half4(0, 0, 0, 0));
        half3 color = SimpleLightingGrass(mainLight, normalWS, bakedGI, surfaceData.albedo.rgb, surfaceData.emission);
    #endif

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        color += vertexLight;
    #endif
    // 次表面散射
    ApplySubsurfaceScattering(color, viewDirectionWS, normalWS, mainLight, translucency);
    color += surfaceData.emission;

    return color;
}


half4 ForwardPassFragment(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
    // return half4(input.color.rgb, 1);
    
    float3 positionWS = input.positionWS.xyz;

    //Only when when shadow cascades are per-pixel
    #if defined(_SHADOWBIAS_CORRECTION) && defined(MAIN_LIGHT_CALCULATE_SHADOWS)
        //Move the shadowed position slightly away from the camera to avoid banding artifacts
        half3 viewDirectionWS = SafeNormalize(GetCameraPositionWS() - positionWS);
        float3 shadowPos = positionWS + (viewDirectionWS * SHADOW_BIAS_OFFSET);
    #else
        float3 shadowPos = positionWS;
    #endif

    float4 shadowCoord = float4(0, 0, 0, 0);
    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        shadowCoord = input.shadowCoord;
    #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
        shadowCoord = TransformWorldToShadowCoord(shadowPos);
    #endif

    Light mainLight = GetMainLight(shadowCoord);
    WindSettings wind = InitializeWindSettings(_WindAmbientStrength, _WindSpeed, _WindDirection, _WindSwinging, input.mask.r, _WindGustStrength, _WindGustFreq);
    SurfaceData surfaceData = InitializeSurfaceData(input, positionWS, wind, mainLight);

    clip(surfaceData.alpha - _Cutoff);


    #ifdef _NORMALMAP
        half3 normalWS = TransformTangentToWorld(surfaceData.normalTS, half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz));
    #else
        half3 normalWS = input.normalWS;
    #endif

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        half3 vertexLight = input.vertexLight;
    #else
        half3 vertexLight = 0;
    #endif

    float translucencyMask = input.mask.g * _Translucency;

    float3 finalColor = ApplyLighting(surfaceData, mainLight, vertexLight, normalWS, positionWS, translucencyMask);

    // float fogFactor = input.positionWS.w;
    // finalColor = MixFog(finalColor, fogFactor);
    // finalColor = input.mask.g;

    return half4(finalColor, surfaceData.alpha);
}