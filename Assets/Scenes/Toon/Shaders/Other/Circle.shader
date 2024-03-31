Shader "LcL/Circle"
{
    Properties
    {
        _MainColor ("Main Color", Color) = (0.59904, 0.65922, 1.00, 1.00)
        _MainTex ("Main Texture", 2D) = "white" { }
        _MaskTex ("Mask Texture", 2D) = "white" { }
        _MainTexScale ("Main Tex Scale", Float) = 3.75
        _MaskOffset ("Mask Offset", Float) = -2.84
        _MaskScale ("Mask Scale", Float) = 2.33
        _MaskSpeed ("Mask Speed", Vector) = (0, 0, 0, 0)
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent+2" }

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"


        CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _MaskTex_ST;
            float4 _MainColor;
            float _MainTexScale;
            float _MaskOffset;
            float _MaskScale;
            float2 _MaskSpeed;
        CBUFFER_END
        ENDHLSL

        Pass
        {
            Tags { "LightMode" = "UniversalForward" }
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

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

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            TEXTURE2D(_MaskTex);
            SAMPLER(sampler_MaskTex);

            Varyings vert(Attributes input)
            {
                Varyings output;

                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = positionInputs.positionCS;
                output.color = input.color;
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                float2 maskUV = TRANSFORM_TEX(input.uv, _MaskTex) + _Time.yy * _MaskSpeed.xy;

                float2 maskUV1 = float2(maskUV.x, _Time.y * 0.02 + maskUV.y);
                float mask = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, maskUV1).r;

                float2 maskUV2 = float2(maskUV.x, _Time.y * 0.02 + maskUV.y);
                float mask2 = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, maskUV2).r;


                float4 mainTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MaskTex, input.uv);
                mainTex = mainTex * _MainColor * _MainTexScale;

                mainTex.a = saturate((mask + mask2) * _MaskScale + _MaskOffset);
                return mainTex;
            }
            ENDHLSL
        }
    }
}
