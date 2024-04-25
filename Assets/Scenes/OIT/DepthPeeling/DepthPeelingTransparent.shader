Shader "LcL/OIT/DepthPeelingTransparent"
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
            float depth : SV_TARGET1;
        };

        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);

        TEXTURE2D(_DepthTexture);

        TEXTURE2D(_PrevCameraDepthTexture);
        SAMPLER(sampler_PrevCameraDepthTexture);

        SamplerState sampler_PointClamp;

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

        DepthPeelingOutput DepthPeelingFirstFrag(Varyings input) : SV_Target
        {
            DepthPeelingOutput output;
            output.color = RenderFragment(input);
            output.depth = input.positionCS.z;
            return output;
        }

        DepthPeelingOutput DepthPeelingFrag(Varyings input) : SV_Target
        {
            float2 screenUV = input.positionCS.xy / _ScaledScreenParams.xy;
            float prevDepth = SAMPLE_DEPTH_TEXTURE(_PrevCameraDepthTexture, sampler_PointClamp, screenUV).r;
            float selfDepth = input.positionCS.z;

            if (selfDepth >= prevDepth)
            {
                discard;
            }

            DepthPeelingOutput output;
            output.color = RenderFragment(input);
            output.depth = input.positionCS.z;
            return output;
        }

        float4 DepthPeelingBlendFrag(Varyings input, out float deputOut:SV_DEPTH) : SV_Target
        {
            half4 baseMap = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
            deputOut = SAMPLE_DEPTH_TEXTURE(_DepthTexture, sampler_PointClamp, input.uv).r;
            return baseMap;
        }
        ENDHLSL

        Pass
        {
            Name "DepthPeelingTransparentFirstPass"
            Tags
            {
                "LightMode"="DepthPeelingTransparentFirst"
            }
            Cull Off

            HLSLPROGRAM
            #pragma vertex DefaultVert
            #pragma fragment DepthPeelingFirstFrag
            ENDHLSL
        }

        Pass
        {
            Name "DepthPeelingTransparentPass"
            Tags
            {
                "LightMode"="DepthPeelingTransparent"
            }
            Cull Off

            HLSLPROGRAM
            #pragma vertex DefaultVert
            #pragma fragment DepthPeelingFrag
            ENDHLSL
        }

        Pass
        {
            Name "DepthPeelingBlendPass"
            Tags
            {
                "LightMode"="DepthPeelingTransparent"
            }
            Cull Off
            ZTest Off
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex DefaultVert
            #pragma fragment DepthPeelingBlendFrag
            ENDHLSL
        }
    }
}
