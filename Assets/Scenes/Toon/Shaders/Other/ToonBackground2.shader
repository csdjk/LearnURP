Shader "LcL/ToonBackground2"
{
    Properties
    {
        _MainColor ("Main Color", Color) = (1.00, 1.00, 1.00, 0.62353)
        _MainTex ("Main Texture", 2D) = "white" { }
        _MainTexScale ("Main Texture Scale", Float) = 2.37

        _EmissionTex ("Emission Texture", 2D) = "white" { }
        _EmissionColor ("Emission Color", Color) = (0.3769, 0.30657, 1.00, 1.00)
        _EmissionFlowInverse ("Emission Flow Inverse", Range(0, 1)) = 0.00
        _EmissionFlowStrength ("Emission Flow Strength", Range(0, 1)) = 1.00
        _EmissionStrength ("Emission Strength", Float) = 11.92
        _FlipOnBackface ("Flip On Backface", Range(0, 1)) = 0.00
        _LerpColor ("Lerp Color", Color) = (1.00, 1.00, 1.00, 1.00)
        _LerpValue ("Lerp Value", Range(0, 1)) = 0.00
        _LinearToGamma ("Linear To Gamma", Range(0, 1)) = 0.00
        _Progress ("Progress", Range(0, 1)) = 0.00
        _UseEmissionFlow ("Use Emission Flow", Range(0, 1)) = 0.00
        _UseEmissionFlowAdd ("Use Emission Flow Add", Range(0, 1)) = 0.00
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent"
        }

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _EmissionColor;
            float _EmissionFlowInverse;
            float _EmissionFlowStrength;
            float _EmissionStrength;
            float4 _EmissionTex_ST;
            float _FlipOnBackface;
            float4 _LerpColor;
            float _LerpValue;
            float _LinearToGamma;
            float4 _MainColor;
            float _MainTexScale;
            float _Progress;
            float _UseEmissionFlow;
            float _UseEmissionFlowAdd;
        CBUFFER_END
        ENDHLSL

        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZWrite Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float4 uv : TEXCOORD0;
            };

            TEXTURE2D(_EmissionTex);
            SAMPLER(sampler_EmissionTex);
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            Varyings vert(Attributes input)
            {
                Varyings output;

                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = positionInputs.positionCS;
                output.uv.xy = TRANSFORM_TEX(input.uv, _MainTex);
                output.uv.zw = TRANSFORM_TEX(input.uv, _EmissionTex);
                return output;
            }

            half4 frag(Varyings input, float facing: VFACE) : SV_Target
            {
                float2 uv = input.uv.xy;
                float2 emissionUV = input.uv.zw;

                float4 u_xlat0;
                float4 u_xlat16_0;
                float4 u_xlat16_1;
                float4 u_xlat16_2;
                float4 u_xlat16_5;
                float4 u_xlat3;
                bool u_xlatb0;

                u_xlat16_0 = SAMPLE_TEXTURE2D(_EmissionTex, sampler_EmissionTex, emissionUV);
                u_xlat16_1.x = -u_xlat16_0.w + _Progress;
                u_xlat16_5.xyz = u_xlat16_0.xyz * _EmissionColor.xyz;
                u_xlat16_5.xyz = u_xlat16_5.xyz * float3(_EmissionStrength, _EmissionStrength, _EmissionStrength);
                u_xlat16_1.x = u_xlat16_1.x + 1.0;
                u_xlatb0 = 1.0 < u_xlat16_1.x;
                u_xlat16_2.xyz = u_xlatb0 ? float3(1.0, -0.0, -1.0) : float3(0.0, 1.0, -0.0);
                u_xlat16_1.x = u_xlat16_2.z + u_xlat16_2.y;
                u_xlat16_1.x = _EmissionFlowInverse * u_xlat16_1.x + u_xlat16_2.x;
                u_xlat16_2.xyz = u_xlat16_5.xyz * u_xlat16_1.xxx - u_xlat16_5.xyz;
                u_xlat16_2.xyz = _UseEmissionFlow * u_xlat16_2.xyz + u_xlat16_5.xyz;
                u_xlat16_2.xyz = u_xlat16_2.xyz * _EmissionFlowStrength;
                u_xlat16_1.xyz = _UseEmissionFlowAdd * u_xlat16_2.xyz + u_xlat16_5.xyz;

                u_xlat0.xy = uv * float2(-1.0, 1.0) + float2(1.0, 0.0);

                u_xlat0.xy = facing > 0 ? uv : u_xlat0.xy;

                u_xlat16_2.xy = u_xlat0.xy - uv;
                u_xlat16_2.xy = _FlipOnBackface * u_xlat16_2.xy + uv;
                u_xlat16_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, u_xlat16_2.xy);
                u_xlat0 = u_xlat16_0 * _MainColor;
                u_xlat0.xyz = u_xlat0.xyz * _MainTexScale;
                u_xlat16_2.xyz = u_xlat0.xyz * 0.30530602 + 0.68217111;
                u_xlat16_2.xyz = u_xlat0.xyz * u_xlat16_2.xyz + 0.012522878;
                u_xlat3.xyz = u_xlat0.xyz * u_xlat16_2.xyz - u_xlat0.xyz;
                u_xlat0.xyz = _LinearToGamma * u_xlat3.xyz + u_xlat0.xyz;
                u_xlat16_1.xyz = u_xlat16_1.xyz + u_xlat0.xyz;
                u_xlat16_2.xyz = -u_xlat16_1.xyz;
                u_xlat16_2.w = -u_xlat0.w;
                u_xlat16_2 = u_xlat16_2 + _LerpColor;

                float4 color;
                color.xyz = _LerpValue * u_xlat16_2.xyz + u_xlat16_1.xyz;
                color.w = _LerpValue * u_xlat16_2.w + u_xlat0.w;

                return color;
            }
            ENDHLSL
        }
    }
    CustomEditor "LcLShaderEditor.LcLShaderGUI"
}
