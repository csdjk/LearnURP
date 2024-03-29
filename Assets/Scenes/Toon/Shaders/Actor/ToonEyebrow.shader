Shader "LcL/ToonEyebrow"
{
    Properties
    {
        _Color ("Colour", Color) = (0.41602, 0.45344, 0.60703, 0.76471)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry+1" }

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        CBUFFER_START(UnityPerMaterial)
            float4 _Color;
        CBUFFER_END
        ENDHLSL

        Pass
        {
            Blend DstColor Zero, DstAlpha Zero
            ColorMask RGB
            // ZWrite Off
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma target 4.5
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
                float factor : TEXCOORD0;
                float4 color : COLOR;
            };

            Varyings vert(Attributes input)
            {
                Varyings output;

                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = positionInputs.positionCS;
                output.color = input.color;

                float3 viewWS = GetWorldSpaceViewDir(positionInputs.positionWS);
                float3 viewOS = mul(UNITY_MATRIX_I_M, float4(viewWS, 0)).xyz;
                viewOS = normalize(viewOS);
                output.factor = dot(viewOS.xy, float2(0.276, 0.961));
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                float4 color = _Color;
                color.a = saturate(input.factor + 0.25) * input.color.a;

                return _Color;
            }
            ENDHLSL
        }
    }
}
