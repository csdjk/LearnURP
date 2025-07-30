Shader "LcL/PolarCoordinates"
{
    Properties
    {
        _BaseMap ("Texture", 2D) = "white" {}
        _BaseColor ("Colour", Color) = (1, 1, 1, 1)
        _Cutoff ("Alpha Cutoff", Float) = 0.5
        _Tilling ("Tiling", Vector) = (1, 1, 0, 0)
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline"
        }

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            float4 _BaseColor;
            float _Cutoff;
            float2 _Tilling;
        CBUFFER_END
        ENDHLSL

        Pass
        {
            Tags
            {
                "LightMode"="UniversalForward"
            }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            Varyings vert(Attributes input)
            {
                Varyings output;

                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = positionInputs.positionCS;
                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                output.color = input.color;
                return output;
            }

            float2 UVToPolar(float2 uv, float2 center, float2 tilling)
            {
                uv = uv - center;
                float2 polar;
                polar.x = length(uv) * 2;
                polar.y = atan2(uv.x, uv.y) / TWO_PI;
                return polar * tilling;
            }

            half4 frag(Varyings input) : SV_Target
            {
                float2 uv = input.uv;
                float2 polar = UVToPolar(uv, float2(0.5, 0.5), float2(1, 1));

                //解决接缝问题
                float mask = smoothstep(0.9,1,abs( polar.y *2));

                float2 polar2 = UVToPolar(float2(uv.x, 1 - uv.y), float2(0.5, 0.5), float2(1, 1));
                polar2.y = 1 - (polar2.y + 0.5) - 0.5;

                polar = polar * _Tilling.xy;
                polar2 = polar2 * _Tilling.xy;

                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, polar);
                half4 baseMap2 = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, polar2);

                baseMap = lerp(baseMap, baseMap2, mask);

                return baseMap;
            }
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            ZWrite On
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment
            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
            ENDHLSL
        }
    }
    CustomEditor "LcLShaderEditor.LcLShaderGUI"
}
