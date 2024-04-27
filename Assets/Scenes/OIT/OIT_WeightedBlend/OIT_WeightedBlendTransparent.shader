Shader "LcL/OIT/WeightedBlendTransparent"
{
    Properties
    {
        [MainTexture] _BaseMap("Base Map (RGB) Smoothness / Alpha (A)", 2D) = "white" {}
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)

        _Cutoff("Alpha Clipping", Range(0.0, 1.0)) = 0.5

        _Smoothness("Smoothness", Range(0.0, 1.0)) = 0.5
        _SpecColor("Specular Color", Color) = (0.5, 0.5, 0.5, 0.5)
        _SpecGlossMap("Specular Map", 2D) = "white" {}
        _SmoothnessSource("Smoothness Source", Float) = 0.0
        _SpecularHighlights("Specular Highlights", Float) = 1.0

        [HideInInspector] _BumpScale("Scale", Float) = 1.0
        [NoScaleOffset] _BumpMap("Normal Map", 2D) = "bump" {}

        [HDR] _EmissionColor("Emission Color", Color) = (0,0,0)
        [NoScaleOffset]_EmissionMap("Emission Map", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent" "RenderPipeline"="UniversalPipeline" "Queue" = "Transparent"
        }

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitForwardPass.hlsl"

        #define  EQ7

        struct DepthPeelingOutput
        {
            float4 color : SV_TARGET0;
            float alpha : SV_TARGET1;
        };

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

            // float3 viewDirWS = normalize(input.viewDirWS);
            // float3 normalWS = normalize(input.normalWS);
            // float fresnel = 1 - dot(viewDirWS, normalWS);
            // fresnel = pow(fresnel, 5);
            // baseMap.a = ( fresnel) * _BaseColor.a;
        }

        // float Weight(float z, float a)
        // {
        //     // return clamp(pow(min(1.0, a * 10.0) + 0.01, 3.0) * 1e8 * pow(1.0 - z * 0.9, 3.0), 1e-2, 3e3);
        //     return a * max(1e-2, min(3 * 1e3, 0.03 / (1e-5 + pow(z / 200, 4))));
        // }
        inline float d(float z)
        {
            float zNear = 0.1;
            float zFar = 500;
            return ((zNear * zFar) / z - zFar) / (zNear - zFar);
        }

        inline float Weight(float z, float alpha)
        {
            // https://jcgt.org/published/0002/02/09/
            #ifdef EQ7
            // (eq.7)
            return alpha * max(1e-2, min(3 * 1e3, 10.0 / (1e-5 + pow(z / 5, 2) + pow(z / 200, 6))));
            #elif EQ8
            // (eq.8)
            return alpha * max(1e-2, min(3 * 1e3, 10.0 / (1e-5 + pow(z / 10, 3) + pow(z / 200, 6))));
            #elif EQ9
            // (eq.9)
            return alpha * max(1e-2, min(3 * 1e3, 0.03 / (1e-5 + pow(z / 200, 4))));
            #else
            // eq.10
            return alpha * max(1e-2, 3 * 1e3 * (1 - pow(d(z), 3)));
            #endif
        }
        #pragma enable_d3d11_debug_symbols

        DepthPeelingOutput WeightedBlendFrag(Varyings input) : SV_Target
        {
            float4 color = RenderFragment(input);
            const float weight = Weight(input.positionCS.z, color.a);

            color.rgb = color.rgb * color.a;
            DepthPeelingOutput output;
            output.color = color * weight;
            output.alpha = 0;
            // output.alpha = color.a;
            return output;
        }

        // void WeightedBlendFrag(Varyings input, out float4 color : SV_Target0, out float4 alpha : SV_Target1)
        // {
        //     color = RenderFragment(input);
        //     const float weight = Weight(input.positionCS.z, color.a);
        //
        //     color.rgb = color.rgb * color.a;
        //     color = color * weight;
        //     alpha = 0;
        //     // alpha = color.a;
        // }
        ENDHLSL

        Pass
        {
            Name "WeightedBlendTransparent"
            Tags
            {
                "LightMode"="WeightedBlendTransparent"
            }
            // 对RenderTarget指定混合
            Blend 0 One One
            Blend 1 Zero OneMinusSrcAlpha

            //  ZTest Off
            ZWrite Off
            Cull Off

            HLSLPROGRAM
            #pragma vertex LitPassVertexSimple
            #pragma fragment WeightedBlendFrag
            ENDHLSL
        }
    }
}
