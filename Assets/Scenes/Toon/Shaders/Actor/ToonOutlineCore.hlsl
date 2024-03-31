#ifndef TOON_OUTLINE_INCLUDED
#define TOON_OUTLINE_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"


struct Attributes
{
    float4 positionOS : POSITION;
    float2 uv : TEXCOORD0;
    float4 color : COLOR;
    float3 normalOS : NORMAL;
    float3 tangentOS : TANGENT;
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 uv : TEXCOORD0;
    float4 color : COLOR;
    float3 normalWS : TEXCOORD1;
};


Varyings ToonOutlineVertex(Attributes input)
{
    Varyings output;

    if (_UseSelfOutline == 1)
    {
        // VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
        // float3 normalDir = normalize(input.tangentOS);
        // float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, normalDir);
        // float3 ndcNormal = normalize(TransformWViewToHClip(viewNormal.xyz)) * positionInputs.positionCS.w;
        // float width = input.color.w * _OutlineWidth;
        // positionInputs.positionCS.xy += width * ndcNormal.xy;
        // output.positionCS = positionInputs.positionCS;

        //
        float width = input.color.w * _OutlineWidth * 0.3;
        input.positionOS.xyz += normalize(input.tangentOS.xyz) * width;
        output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
    }
    else
    {
        //---------------miHoYo-----------------
        float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, input.tangentOS.xyz);
        viewNormal.z = -0.1f;
        viewNormal = normalize(viewNormal);

        float3 positionVS = mul(UNITY_MATRIX_MV, float4(input.positionOS.xyz, 1));

        float offset = input.color.z * _OutlineOffset;
        float offsetZ = positionVS.z - offset * 0.01;
        offset = offsetZ / unity_CameraProjection[1].y;
        offset = abs(offset) / _OutlineScale;
        offset = 1 / rsqrt(offset);

        float outlineWidth = _OutlineScale * _OutlineWidth * input.color.w;
        offset = offset * outlineWidth;

        VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
        float3 viewDir = positionInputs.positionWS - GetCurrentViewPosition();
        float dist = length(viewDir);

        dist = smoothstep(_OutlineExtdStart, _OutlineExtdMax, dist);

        dist = min(dist, 0.5);
        dist = dist + 1.0;
        offset = offset * dist;


        viewNormal = viewNormal * offset.xxx + float3(positionVS.xy, offsetZ);
        output.positionCS = TransformWViewToHClip(viewNormal);
    }


    output.uv = input.uv;
    output.color = input.color;
    VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS);
    output.normalWS = normalInputs.normalWS;
    return output;
}

half4 ToonOutlineFragment(Varyings input) : SV_Target
{
    #ifdef _TOON_HAIR
    return half4(_OutlineColor.rgb, 1);
    #endif


    #ifdef _USE_MATERIAL_VALUES_LUT

    float rampLevel = LOAD_TEXTURE2D(_LightMap, input.uv).w;
    rampLevel = floor(rampLevel * 8);
    float3 outlineColor = LOAD_TEXTURE2D(_MaterialValuesPackLUT, float2(rampLevel, 2));
    #else
    float3 outlineColor = _OutlineColor.rgb;
    #endif


    Light light = GetMainLight();
    float3 normalWS = normalize(input.normalWS);
    float NdotL = dot(normalWS, light.direction);
    float lambert = smoothstep(0, 1, NdotL * 6.6);

    float darkenVal = lerp(1, lambert, _ES_OutLineDarkenVal);
    // darkenValInv = lerp(1-lambert, 1, _ES_OutLineDarkenVal);

    outlineColor = outlineColor * darkenVal + lambert * _ES_OutLineLightedVal;
    return half4(outlineColor, 1);
}
#endif
