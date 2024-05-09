Shader "LcL/OIT/DepthPeelingObject"
{
    Properties
    {
        [MainTexture] _BaseMap ("Base Map (RGB) Smoothness / Alpha (A)", 2D) = "white" { }
        [MainColor] _BaseColor ("Base Color", Color) = (1, 1, 1, 1)

        _Cutoff ("Alpha Clipping", Range(0.0, 1.0)) = 0.5

        _Smoothness ("Smoothness", Range(0.0, 1.0)) = 0.5
        _SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 0.5)
        _SpecGlossMap ("Specular Map", 2D) = "white" { }
        _SmoothnessSource ("Smoothness Source", Float) = 0.0
        _SpecularHighlights ("Specular Highlights", Float) = 1.0

        [HideInInspector] _BumpScale ("Scale", Float) = 1.0
        [NoScaleOffset] _BumpMap ("Normal Map", 2D) = "bump" { }

        [HDR] _EmissionColor ("Emission Color", Color) = (0, 0, 0)
        [NoScaleOffset]_EmissionMap ("Emission Map", 2D) = "white" { }

        [HideInInspector]_MainTex ("MainTex", 2D) = "white" { }
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry" "RenderType" = "Opaque"
        }

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitForwardPass.hlsl"

        struct DepthPeelingOutput
        {
            float4 color : SV_TARGET0;
            float depth : SV_TARGET1;
        };

        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        float4 _MainTex_ST;

        TEXTURE2D(_DepthTexture);

        TEXTURE2D(_PrevCameraDepthTexture);
        SAMPLER(sampler_PrevCameraDepthTexture);
        SamplerState sampler_PointClamp;

        inline float4 RenderFragment(Varyings input)
        {
            UNITY_SETUP_INSTANCE_ID(input);
            UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

            SurfaceData surfaceData;
            InitializeSimpleLitSurfaceData(input.uv, surfaceData);

            InputData inputData;
            InitializeInputData(input, surfaceData.normalTS, inputData);
            SETUP_DEBUG_TEXTURE_DATA(inputData, input.uv, _BaseMap);

            half4 color = UniversalFragmentBlinnPhong(inputData, surfaceData);
            color.rgb = MixFog(color.rgb, inputData.fogCoord);
            color.a = OutputAlpha(color.a, 1);

            return color;
        }

        DepthPeelingOutput DepthPeelingFirstFrag(Varyings input) : SV_Target
        {
            DepthPeelingOutput output;
            output.color = RenderFragment(input);
            output.depth = input.positionCS.z;
            return output;
        }

        DepthPeelingOutput DepthPeelingFrag(Varyings input) : SV_Target
        {
            float2 screenUV = input.positionCS.xy / _ScaledScreenParams.xy;
            float prevDepth = SAMPLE_DEPTH_TEXTURE(_PrevCameraDepthTexture, sampler_PointClamp, screenUV).r;
            float selfDepth = input.positionCS.z;

            if (selfDepth >= prevDepth)
            {
                discard;
            }

            DepthPeelingOutput output;
            output.color = RenderFragment(input);
            output.depth = input.positionCS.z;
            return output;
        }
        ENDHLSL

        Pass
        {
            Name "DepthPeelingFirstPass"
            Tags
            {
                "LightMode" = "DepthPeelingFirst"
            }
            Cull Off

            HLSLPROGRAM
            #pragma vertex LitPassVertexSimple
            #pragma fragment DepthPeelingFirstFrag
            ENDHLSL
        }

        Pass
        {
            Name "DepthPeelingPass"
            Tags
            {
                "LightMode" = "DepthPeeling"
            }
            Cull Off

            HLSLPROGRAM
            #pragma vertex LitPassVertexSimple
            #pragma fragment DepthPeelingFrag
            ENDHLSL
        }
    }
}
