Shader "LcL/UnitySH"
{
    Properties
    {
        _CustomCubemap ("Custom Cubemap", CUBE) = "" { }
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
            float _Cutoff;
        CBUFFER_END

        real4 _CustomCubemap_HDR;
        TEXTURECUBE(_CustomCubemap);
        SAMPLER(sampler_CustomCubemap);
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
            #pragma enable_d3d11_debug_symbols
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
                float4 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 sh : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
            };

            Varyings vert(Attributes input)
            {
                Varyings output;
                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = positionInputs.positionCS;
                VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS.xyz);
                output.sh = SampleSH(normalInputs.normalWS);
                output.normalWS = normalInputs.normalWS;
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                float4 skyColor = SAMPLE_TEXTURECUBE_LOD(_CustomCubemap, sampler_CustomCubemap, input.normalWS, 0);
                #if !defined(UNITY_USE_NATIVE_HDR)
                    skyColor.rgb = DecodeHDREnvironment(skyColor, _CustomCubemap_HDR);
                #endif


                // return float4(skyColor.rgb, 1);
                return float4(input.sh, 1);
            }
            ENDHLSL
        }

    }
}
