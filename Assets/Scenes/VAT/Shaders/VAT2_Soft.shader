Shader "LcL/VAT/VAT2_Soft"
{
    //VAT 2.0
    Properties
    {
        _BaseMap ("BaseMap", 2D) = "white" { }
        _BaseColor ("Color", Color) = (1, 1, 1, 1)
        _Cutoff ("Alpha Cutoff", Float) = 0.5

        [Foldout()] _VAT_SOFT ("VAT-2.0 Soft", int) = 0
        [SingleLine]_PosTex ("Pos Texture", 2D) = "black" { }
        [SingleLine]_NormalTex ("Normal Texture", 2D) = "black" { }
        _PosRange ("Pos Range", Vector) = (0, 0, 0, 0)
        _TotalFrame ("Total Frame", float) = 128

        _CurrentFrame ("Current Frame", Range(0, 200)) = 0
        [FoldoutEnd]_Speed ("Animation Speed", float) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque" "Queue" = "Geometry" "RenderPipeline" = "UniversalPipeline"
        }

        HLSLINCLUDE
        #pragma target 3.5

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Assets/Shaders/Libraries/VAT2_Helper.hlsl"


        CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            float4 _BaseColor;
            float _Cutoff;
            float _CurrentFrame;
            float _TotalFrame;
            float _Speed;
            float4 _PosRange;
        CBUFFER_END

        TEXTURE2D(_PosTex);
        TEXTURE2D(_NormalTex);
        SAMPLER(sampler_PosTex);

        struct Attributes
        {
            float4 positionOS : POSITION;
            float2 uv : TEXCOORD0;
            float4 color : COLOR;
            float4 normalOS : NORMAL;
            float2 uv1 : TEXCOORD1; // uv1.x = vertex id
        };
        ENDHLSL

        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
                float3 normalWS : NORMAL;
                float3 positionWS : TEXCOORD2;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            Varyings vert(Attributes input)
            {
                Varyings output;

                float3 positionOS = input.positionOS.xyz;
                float3 normalOS = input.normalOS.xyz;

                float3 outPosition;
                SoftVAT(positionOS, input.uv1, _PosTex, _NormalTex, _PosRange.xy, _TotalFrame, _CurrentFrame, outPosition, normalOS);
                positionOS = outPosition;

                VertexPositionInputs positionInputs = GetVertexPositionInputs(positionOS);
                output.positionCS = positionInputs.positionCS;

                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                output.color = input.color;

                output.positionWS = positionInputs.positionWS;

                VertexNormalInputs normalInputs = GetVertexNormalInputs(normalOS);
                output.normalWS = normalInputs.normalWS;

                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
                half4 color = baseMap * _BaseColor * input.color;

                float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS.xyz);
                Light light = GetMainLight(shadowCoord);
                half3 shading = LightingLambert(light.color, light.direction, input.normalWS);

                return half4(color.rgb, color.a);
            }
            ENDHLSL
        }
    }
    CustomEditor "LcLShaderEditor.LcLShaderGUI"
}
