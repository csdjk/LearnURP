Shader "LcL/PostProcess/VolumetricLight"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
    }

    HLSLINCLUDE
    #pragma target 3.5
    // #pragma exclude_renderers gles
    #pragma only_renderers gles gles3 glcore metal vulkan d3d11
    #pragma multi_compile _ _USE_DRAW_PROCEDURAL

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

    TEXTURE2D(_MainTex);
    TEXTURE2D(_VolumetricLightingTex);

    float4 _VolumetricLightParams;
    float4 _ScreenLightPos;
    half4 _LightingColor;

    #define _Exposure _VolumetricLightParams.x
    #define _LightingRadius _VolumetricLightParams.y
    #define _Density _VolumetricLightParams.z
    #define _Decay _VolumetricLightParams.w

    #define _DepthThreshold 0.99
    #define NUM_SAMPLES 50

    struct BlurVaryings
    {
        float4 positionCS : SV_POSITION;
        float2 uv : TEXCOORD0;
        float4 uv01 : TEXCOORD1;
        float4 uv23 : TEXCOORD2;
        float4 uv45 : TEXCOORD3;
        UNITY_VERTEX_OUTPUT_STEREO
    };


    half4 PrefilterFrag(Varyings input) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        half4 ori = SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, input.uv);
        half luminance = Luminance(ori);

        float depth = Linear01Depth(SampleSceneDepth(input.uv), _ZBufferParams);
        half lum = depth > _DepthThreshold ? luminance : 0;


        float2 distance = _ScreenLightPos.xy - input.uv;
        distance.y *= _ScreenParams.y / _ScreenParams.x;
        float distanceDecay = saturate(_LightingRadius - length(distance));

        depth *= distanceDecay;

        return half4(depth, depth, depth, lum);
    }

    half4 RadialBlurFrag(Varyings input) : SV_Target
    {
        half4 color = half4(0.0f, 0.0f, 0.0f, 1.0f);

        half2 ray = input.uv - _ScreenLightPos.xy;
        half illuminationDecay = 1.0f;

        UNITY_UNROLL
        for (int i = 0; i < NUM_SAMPLES; i++)
        {
            half scale = 1.0f - _Density * (half(i) / half(NUM_SAMPLES - 1));
            half4 sample = SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, (ray * scale) + _ScreenLightPos.xy);
            sample.rgb *= illuminationDecay * sample.a;
            color.xyz += sample.rgb;
            illuminationDecay *= _Decay;
        }
        color.xyz = color.xyz / half(NUM_SAMPLES);
        return color;
    }

    // https://developer.nvidia.com/gpugems/gpugems3/part-ii-light-and-shadows/chapter-13-volumetric-light-scattering-post-process
    half4 RadialBlurFrag2(Varyings input) : SV_Target
    {
        float2 uv = input.uv;

        half2 deltaTexCoord = uv - _ScreenLightPos.xy;
        deltaTexCoord *= 1.0f / half(NUM_SAMPLES) * _Density;

        half3 color = SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, uv);
        // 衰减因子
        half illuminationDecay = 1.0f;

        UNITY_UNROLL
        for (int i = 0; i < NUM_SAMPLES; i++)
        {
            uv -= deltaTexCoord;

            half4 sample = SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, uv);
            sample.rgb *= illuminationDecay * sample.a;
            color += sample.rgb;
            illuminationDecay *= _Decay;
        }
        color = color / half(NUM_SAMPLES);

        return half4(color, 1.0f);
    }


    half4 CompositeFrag(Varyings input) : SV_Target
    {
        half3 mainColor = SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, input.uv).rgb;

        half3 volumetricColor = SAMPLE_TEXTURE2D(_VolumetricLightingTex, sampler_LinearClamp, input.uv).rgb;
        volumetricColor = volumetricColor * _LightingColor.rgb * _Exposure;

        #ifdef UNITY_COLORSPACE_GAMMA
            mainColor = Gamma20ToLinear(mainColor);
            volumetricColor = Gamma20ToLinear(volumetricColor);
        #endif

        half3 finalColor = mainColor + volumetricColor;

        #ifdef UNITY_COLORSPACE_GAMMA
            finalColor = LinearToGamma20(finalColor);
        #endif

        return half4(finalColor, 1);
    }
    ENDHLSL

    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" }
        LOD 100
        ZTest Always ZWrite Off Cull Off
        Pass
        {
            Name "Volumetric Light Prefilter"
            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"

            #pragma vertex FullscreenVert
            #pragma fragment PrefilterFrag
            ENDHLSL
        }

        Pass
        {
            Name "Volumetric Light Blur"
            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"

            #pragma vertex FullscreenVert
            #pragma fragment RadialBlurFrag
            // #pragma fragment RadialBlurFrag2
            ENDHLSL
        }


        Pass
        {
            Name "Volumetric Light Composite"
            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"

            #pragma vertex FullscreenVert
            #pragma fragment CompositeFrag
            ENDHLSL
        }
    }
}
