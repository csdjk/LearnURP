Shader "LcL/ToonPlane"
{
    Properties
    {
        _AdditionalReflectionCube ("Additional Reflection Cube", CUBE) = "" {}
        _ReflectionColor ("Reflection Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _BaseTex ("Base Tex", 2D) = "white" {}
        _BottomTex ("Bottom Tex", 2D) = "white" {}
        _LightTex ("Light Tex", 2D) = "white" {}

        _BaseColor ("Base Color", Color) = (0.03869, 0.04065, 0.1238, 1.0)
        _BottomColor ("Bottom Color", Color) = (0.10946, 0.14126, 0.54572, 1.0)
        _RimColor ("Rim Color", Color) = (0.8712, 0.85377, 1.0, 1.0)
        _MainSpeed ("Main Speed", Vector) = (0.0, 0.0, 0.0, 0.0)
        _ReflectWeight ("Reflect Weight", Range(0, 1)) = 1.0
        _LightIntensity ("Light Intensity", Range(0, 2)) = 0.909
        _LightPower ("Light Power", Range(0, 2)) = 1.29
        _LightOffset ("Light Offset", Range(0, 2)) = 0.53
        _ViewOffset ("View Offset", Range(0, 2)) = 0.80
        _RimRange ("Rim Range", Range(0, 5)) = 3.20
        _BottomCorrection ("Bottom Correction", Range(0, 2)) = 0.0
        _AdditionalReflectionCubeMip ("Additional Reflection Cube Mip", Range(0, 2)) = 0.0
        _AdditionalReflectionColor ("Additional Reflection Color", Color) = (1.36608, 1.36608, 1.97667, 1.0)
        _AddtionalReflactionAlpha ("Additional Reflection Alpha", Range(0, 1)) = 0.638
        _Angle ("Angle", Range(0, 5)) = 3.28
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
            float4 _BaseTex_ST;
            float4 _BottomTex_ST;
            float4 _LightTex_ST;
            float4 _BaseColor;
            float4 _BottomColor;
            float4 _LightColor;
            float4 _RimColor;
            float4 _MainSpeed;
            float _ReflectWeight;
            float _LightIntensity;
            float _LightPower;
            float _LightOffset;
            float _ViewOffset;
            float _RimRange;
            float _BottomCorrection;
            float _AdditionalReflectionCubeMip;
            float4 _AdditionalReflectionColor;
            float _AddtionalReflactionAlpha;
            float _Angle;
        CBUFFER_END
        ENDHLSL

        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

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
                float3 normalWS : TEXCOORD1;
                float3 viewDirWS : TEXCOORD2;
                float4 color : COLOR;
            };

            TEXTURE2D(_ReflectionColor);
            SAMPLER(sampler_ReflectionColor);

            TEXTURE2D(_BaseTex);
            SAMPLER(sampler_BaseTex);

            TEXTURE2D(_BottomTex);
            SAMPLER(sampler_BottomTex);

            TEXTURE2D(_LightTex);
            SAMPLER(sampler_LightTex);

            TEXTURECUBE(_AdditionalReflectionCube);
            SAMPLER(sampler_AdditionalReflectionCube);

            Varyings vert(Attributes input)
            {
                Varyings output;

                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = positionInputs.positionCS;
                output.uv = input.uv;
                output.color = input.color;

                VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS.xyz);
                output.normalWS = normalize(normalInputs.normalWS);
                output.viewDirWS = GetWorldSpaceViewDir(positionInputs.positionWS);
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                float2 uv = input.uv.xy;

                float3 vs_TEXCOORD3 = input.viewDirWS;
                float3 vs_TEXCOORD2 = input.normalWS;
                float2 vs_TEXCOORD1 = input.uv;
                float2 vs_TEXCOORD0 = input.positionCS / _ScaledScreenParams.xy;
                float4 vs_TEXCOORD4 = input.color;
                float4 u_xlat0;
                float4 u_xlat1;
                float4 u_xlat16_0;
                float4 u_xlat16_1;
                float4 u_xlat16_2;
                float4 u_xlat16_3;
                float4 u_xlat16_4;
                float4 u_xlat16_5;
                float4 u_xlat16_9;
                float4 u_xlat16_14;
                float4 u_xlat16_20;
                float4 u_xlat13;
                float4 u_xlat7;
                float4 u_xlat5;
                float u_xlat18;
                float u_xlat6;

                float4 finalColor = 0;

                u_xlat0.x = dot(vs_TEXCOORD3.xyz, vs_TEXCOORD3.xyz);
                u_xlat0.x = rsqrt(u_xlat0.x);
                u_xlat0.xyz = u_xlat0.xxx * vs_TEXCOORD3.xyz;

                //
                u_xlat1.xyz = u_xlat0.yyy * UNITY_MATRIX_I_M[1].xyz;
                u_xlat1.xyz = UNITY_MATRIX_I_M[0].xyz * u_xlat0.xxx + u_xlat1.xyz;
                u_xlat1.xyz = UNITY_MATRIX_I_M[2].xyz * u_xlat0.zzz + u_xlat1.xyz;
// u_xlat1.xyz = TransformWorldToObject()

                u_xlat18 = dot(u_xlat1.xyz, u_xlat1.xyz);
                u_xlat18 = rsqrt(u_xlat18);
                u_xlat1.xyz = u_xlat18 * u_xlat1.xyz;
                u_xlat16_2.xyz = u_xlat1.yyy * float3(-0.0, -2.0, -0.0) + u_xlat1.xyz;
                u_xlat16_3.x = sin(_Angle);
                u_xlat16_4.x = cos(_Angle);
                u_xlat16_9.xy = u_xlat16_2.xz * u_xlat16_4.xx;
                u_xlat16_4.x = u_xlat16_3.x * u_xlat16_2.z + u_xlat16_9.x;
                u_xlat16_14 = sin(-_Angle);
                u_xlat16_4.z = u_xlat16_14 * u_xlat16_2.x + u_xlat16_9.y;
                u_xlat16_4.y = u_xlat16_2.y;
                u_xlat16_1.xyz = SAMPLE_TEXTURECUBE_LOD(_AdditionalReflectionCube,sampler_AdditionalReflectionCube,u_xlat16_4.xyz,_AdditionalReflectionCubeMip).xyz;
                u_xlat16_2.xyz = u_xlat16_1.xyz * _AdditionalReflectionColor.xyz;
                u_xlat18 = dot(vs_TEXCOORD2.xyz, vs_TEXCOORD2.xyz);
                u_xlat18 = rsqrt(u_xlat18);
                u_xlat1.xyz = u_xlat18 * vs_TEXCOORD2.xyz;
                u_xlat6 = dot(u_xlat1.xyz, u_xlat0.xyz);
                u_xlat6 = -u_xlat6 + 1.0;
                u_xlat6 = max(u_xlat6, 9.9999997e-05);
                u_xlat6 = log2(u_xlat6);
                u_xlat6 = u_xlat6 * _RimRange;
                u_xlat6 = exp2(u_xlat6);
                u_xlat1.xy = vs_TEXCOORD1.xy * _BottomTex_ST.xy + _BottomTex_ST.zw;
                u_xlat13.xy = _Time.yy * _MainSpeed.xy;
                u_xlat1.xy = u_xlat13.xy * float2(_BottomCorrection, _BottomCorrection) + u_xlat1.xy;
                u_xlat0.xz = u_xlat0.xz * _ViewOffset + u_xlat1.xy;
                u_xlat16_0.xzw = SAMPLE_TEXTURE2D(_BottomTex,sampler_BottomTex, u_xlat0.xz).xyz;
                u_xlat1.xy = vs_TEXCOORD1.xy * _BaseTex_ST.xy + _BaseTex_ST.zw;
                u_xlat16_1.xyz = SAMPLE_TEXTURE2D(_BaseTex,sampler_BaseTex, u_xlat1.xy).xzw;
                u_xlat0.xzw = u_xlat16_0.xzw * u_xlat16_1.yyy;
                u_xlat16_3.xyz = u_xlat0.xzw * _BottomColor.xyz;
                u_xlat0.xzw = -u_xlat0.xzw * _BottomColor.xyz + _RimColor.xyz;
                u_xlat0.xyz = u_xlat6 * u_xlat0.xzw + u_xlat16_3.xyz;
                u_xlat7.xz = vs_TEXCOORD1.xy + float2(-0.5, -0.5);
                u_xlat18 = dot(-u_xlat7.xz, -u_xlat7.xz);
                u_xlat18 = sqrt(u_xlat18);
                u_xlat18 = u_xlat18 * 2.0 + 0.30000001;
                u_xlat18 = min(u_xlat18, 1.0);
                u_xlat18 = -u_xlat18 + 1.0;
                u_xlat16_20 = u_xlat18 * _ReflectWeight;
                u_xlat5.xy = vs_TEXCOORD0.xy;
                u_xlat5.z = -u_xlat5.x + 1.0;
                u_xlat16_5.xyz = SAMPLE_TEXTURE2D(_ReflectionColor,sampler_ReflectionColor, u_xlat5.zy).xyz;
                u_xlat16_3.xyz = u_xlat16_20 * u_xlat16_5.xyz + u_xlat0.xyz;
                u_xlat16_3.xyz = u_xlat16_1.xxx * _BaseColor.xyz + u_xlat16_3.xyz;
                u_xlat16_20 = u_xlat16_1.z * _BaseColor.w;
                finalColor.w = u_xlat16_20 * vs_TEXCOORD4.w;
                u_xlat16_2.xyz = u_xlat16_3.xyz * u_xlat16_2.xyz - u_xlat16_3.xyz;
                u_xlat16_2.xyz = _AddtionalReflactionAlpha * u_xlat16_2.xyz + u_xlat16_3.xyz;
                u_xlat0.xy = vs_TEXCOORD1.xy * _LightTex_ST.xy + _LightTex_ST.zw;
                u_xlat16_0.x = SAMPLE_TEXTURE2D(_LightTex,sampler_LightTex, u_xlat0.xy).x;
                u_xlat16_20 = log2(u_xlat16_0.x);
                u_xlat16_20 = u_xlat16_20 * _LightPower;
                u_xlat16_20 = exp2(u_xlat16_20);
                u_xlat16_20 = u_xlat16_20 * _LightColor.x;
                u_xlat16_20 = u_xlat16_20 * _LightIntensity + _LightOffset;
                u_xlat16_20 = clamp(u_xlat16_20, 0.0, 1.0);
                finalColor.xyz = u_xlat16_20 * u_xlat16_2.xyz;


                return finalColor;
            }
            ENDHLSL
        }
    }
    CustomEditor "LcLShaderEditor.LcLShaderGUI"
}
