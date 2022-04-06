Shader "lcl/Rain"
{
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        
        CBUFFER_START(UnityPerMaterial)
            float4 _BlitTex_ST;
            float4 _Color;
        CBUFFER_END
        ENDHLSL

        Pass
        {
            Name "Example"
            Tags { "LightMode" = "UniversalForward" }
            
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT

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
                float2 uv : TEXCOORD0;
                float4 color : COLOR;

                float3 normalWS : NORMAL;
                float3 positionWS : TEXCOORD2;
            };
            
            TEXTURE2D(_BlitTex);
            SAMPLER(sampler_BlitTex);
            
            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS.xyz);
                OUT.positionCS = positionInputs.positionCS;

                OUT.uv = TRANSFORM_TEX(IN.uv, _BlitTex);
                OUT.color = IN.color;

                OUT.positionWS = positionInputs.positionWS;

                return OUT;
            }
            
            half4 frag(Varyings IN) : SV_Target
            {
                half4 color = SAMPLE_TEXTURE2D(_BlitTex, sampler_BlitTex, IN.uv);
                return half4(color.rgb * _Color, 1);
            }
            ENDHLSL

        }
    }
}