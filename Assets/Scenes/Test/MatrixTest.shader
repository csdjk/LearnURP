Shader "LcL/UnlitShaderExample"
{
    Properties
    {
        _BaseMap ("Texture", 2D) = "white" { }
        _BaseColor ("Colour", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            float4 _BaseColor;
        CBUFFER_END
        ENDHLSL

        Pass
        {
            Tags { "LightMode" = "UniversalForward" }

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
                float3 positionWS : TEXCOORD1;
                float4 color : COLOR;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            Varyings vert(Attributes input)
            {
                Varyings output;

                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = positionInputs.positionCS;
                output.positionWS = positionInputs.positionWS;
                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                output.color = input.color;
                return output;
            }
            #pragma enable_d3d11_debug_symbols
            half4 frag(Varyings input) : SV_Target
            {
                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
                float3x3 mat1 = float3x3(
                    0, 1, 2,
                    3, 4, 5,
                    6, 7, 8
                );
                float3x3 mat2 = float3x3(float3(0, 1, 2), float3(3, 4, 5), float3(6, 7, 8));
                float3 pos = mul(mat1, float3(0, 0, 1));
                float3x3 matT = transpose(mat1);

                float3 pos2 = mul(mat2, input.positionWS);
                float3 pos3 = mul(matT, input.positionWS);
                baseMap.rbg = baseMap.rgb * pos * pos2*pos3;
                return baseMap * _BaseColor * input.color;
            }
            ENDHLSL
        }
    }
}
