Shader "LcL/OIT/WeightedBlendTransparent"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _BaseColor ("Colour", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent" "RenderPipeline"="UniversalPipeline" "Queue" = "Transparent"
        }

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _BaseColor;
        CBUFFER_END

        struct Attributes
        {
            float4 positionOS : POSITION;
            float2 uv : TEXCOORD0;
            float4 color : COLOR;
            float3 normalOS : NORMAL;
        };

        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float2 uv : TEXCOORD0;
            float4 color : COLOR;
            float3 normalWS : TEXCOORD1;
            float3 viewDirWS : TEXCOORD2;
        };

        struct DepthPeelingOutput
        {
            float4 color : SV_TARGET0;
            float alpha : SV_TARGET1;
        };

        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);

        Varyings DefaultVert(Attributes input)
        {
            Varyings output;

            VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
            output.positionCS = positionInputs.positionCS;
            output.uv = TRANSFORM_TEX(input.uv, _MainTex);
            output.color = input.color;

            VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS);
            output.normalWS = normalInputs.normalWS;
            output.viewDirWS = GetWorldSpaceViewDir(positionInputs.positionWS);
            return output;
        }

        inline float4 RenderFragment(Varyings input)
        {
            half4 baseMap = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv) * _BaseColor;
            // float3 viewDirWS = normalize(input.viewDirWS);
            // float3 normalWS = normalize(input.normalWS);
            // float fresnel = 1 - dot(viewDirWS, normalWS);
            // fresnel = pow(fresnel, 5);
            // baseMap.a = ( fresnel) * _BaseColor.a;
            return baseMap;
        }

        float Weight(float z, float a)
        {
            // return clamp(pow(min(1.0, a * 10.0) + 0.01, 3.0) * 1e8 * pow(1.0 - z * 0.9, 3.0), 1e-2, 3e3);
            return a * max(1e-2, min(3 * 1e3, 0.03 / (1e-5 + pow(z / 200, 4))));
        }

        DepthPeelingOutput WeightedBlendFrag(Varyings input) : SV_Target
        {
            float4 color = RenderFragment(input);
            float w = Weight(input.positionCS.z, color.a);

            color.rgb = color.rgb * color.a;
            DepthPeelingOutput output;
            output.color = float4(color.rgb * w, color.a);
            output.alpha = color.a * w;
            return output;
        }
        ENDHLSL

        Pass
        {
            Name "WeightedBlendTransparent"
            Tags
            {
                "LightMode"="WeightedBlendTransparent"
            }
            Blend One One, Zero OneMinusSrcAlpha
            ZTest Off
            ZWrite Off

            HLSLPROGRAM
            #pragma vertex DefaultVert
            #pragma fragment WeightedBlendFrag
            ENDHLSL
        }
    }
}
