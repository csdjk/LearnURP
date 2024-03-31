Shader "LcL/UnlitShaderExample"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _MaskTex ("Mask Texture", 2D) = "white" { }
        _MainColor ("Main Color", Color) = (1, 1, 1, 1)
        _MainSpeed ("Main Speed", Vector) = (0, 0, 10, 1)
        _MainChannel ("Main Channel", Color) = (1, 0, 0, 1)
        _MainChannelRGB ("Main Channel RGB", Color) = (1, 0, 0, 0)
        _MaskChannel ("Mask Channel", Color) = (1, 0, 0, 0)
        _MaskSpeed ("Mask Speed", Vector) = (0.1, 0, 0, 1)
        _MaskUVoffset ("Mask UV offset", Vector) = (2, 2, 0, 1)
        _OneMinusOpacityDitherScale ("One Minus Opacity Dither Scale", Range(0, 1)) = 0
        _Opacity ("Opacity", Range(0, 1)) = 1
        _CoverBackground ("Cover Background", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent" }

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        // float4 _MainColor                1.00, 1.00, 1.00, 0.10 16
        // float4 _MainSpeed                0.00, 0.00, 10.00, 1.00 32
        // float4 _MainChannel              1.00, 0.00, 0.00, 1.00 48
        // float4 _MainChannelRGB           1.00, 0.00, 0.00, 0.00 64
        // float4 _MaskChannel              1.00, 0.00, 0.00, 0.00 80
        // float4 _MaskTex_ST               1.00, 1.00, 0.00, 0.00 144
        // float4 _MaskSpeed                0.10, 0.00, 0.00, 1.00 160
        // float4 _MaskUVoffset             2.00, 2.00, 0.00, 1.00 176
        // float _OneMinusOpacityDitherScale 0.00                  208
        // float _Opacity                  1.00                  212
        // float _CoverBackground          0.00                  216

        CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _MaskTex_ST;
            float4 _MainColor;
            float4 _MainSpeed;
            float4 _MainChannel;
            float4 _MainChannelRGB;
            float4 _MaskChannel;
            float4 _MaskSpeed;
            float4 _MaskUVoffset;
            float _OneMinusOpacityDitherScale;
            float _Opacity;
            float _CoverBackground;
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
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                return _MainColor;
            }
            ENDHLSL
        }
    }
}
