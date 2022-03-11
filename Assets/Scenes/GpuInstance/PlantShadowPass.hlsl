// ----------植被阴影pass----------

#define USE_SHADOW_BIAS

#ifdef USE_SHADOW_BIAS
    float3 _LightDirection;
#endif

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 uv : TEXCOORD0;
    #ifdef _ALPHATEST_ON
        float3 positionWS : TEXCOORD1;
    #endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

Varyings ShadowPassVertex(Attributes input, uint instanceID : SV_InstanceID)
{
    Varyings output;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    output.uv.xy = TRANSFORM_TEX(input.uv, _BaseMap);

    float posOffset = ObjectPosRand01();

    //Compose parameter structs
    WindSettings wind = InitializeWindSettings(_WindAmbientStrength, _WindSpeed, _WindDirection, _WindSwinging, input.color.r, _WindGustStrength, _WindGustFreq);

    VertexInputs vertexInputs = GetVertexInputs(input);
    VertexOutput vertexData = GetVertexOutput(vertexInputs, posOffset, wind);

    #ifdef USE_SHADOW_BIAS
        float4 positionCS = TransformWorldToHClip(ApplyShadowBias(vertexData.positionWS, vertexData.normalWS, _LightDirection));
    #else
        //Skip depth bias, to keep shadows touching base of mesh (results in some acne)
        float4 positionCS = TransformWorldToHClip(vertexData.positionWS);
    #endif

    output.positionCS = positionCS;

    #if UNITY_REVERSED_Z
        output.positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
    #else
        output.positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
    #endif

    output.positionWS = vertexData.positionWS;

    return output;
}

half4 ShadowPassFragment(Varyings input) : SV_TARGET
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    #ifdef _ALPHATEST_ON
        float alpha = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv).a;
        // AlphaClip(alpha, _Cutoff, input.positionCS.xyz, input.positionWS.xyz, _FadeParams);
        clip(alpha - _Cutoff);
    #endif
    return 0;
}