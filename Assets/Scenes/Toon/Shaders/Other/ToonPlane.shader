Shader "LcL/ToonPlane"
{
    Properties
    {
        _BaseTex ("Base Tex", 2D) = "white" { }
        _BaseColor ("Base Color", Color) = (0.03869, 0.04065, 0.1238, 1.0)


        [Foldout()]_AdditionalReflection ("Additional Reflection", float) = 1
        _AdditionalReflectionCube ("Additional Reflection Cube", CUBE) = "" { }
        _AdditionalReflectionCubeMip ("Additional Reflection Cube Mip", Range(0, 10)) = 0.0
        [HDR]_AdditionalReflectionColor ("Additional Reflection Color", Color) = (1.36608, 1.36608, 1.97667, 1.0)
        _AddtionalReflactionAlpha ("Additional Reflection Alpha", Range(0, 1)) = 0.638
        [FoldoutEnd]_Angle ("Angle", Range(0, 5)) = 3.28

        [Foldout()]_Bottom ("Bottom Color", float) = 1
        _BottomTex ("Bottom Tex", 2D) = "white" { }
        _BottomColor ("Bottom Color", Color) = (0.10946, 0.14126, 0.54572, 1.0)
        _ViewOffset ("View Offset", Range(0, 2)) = 0.80
        _RimColor ("Rim Color", Color) = (0.8712, 0.85377, 1.0, 1.0)
        _RimRange ("Rim Range", Range(0, 50)) = 3.20
        _MainSpeed ("Main Speed", Vector) = (0.0, 0.0, 0.0, 0.0)
        [FoldoutEnd] _BottomCorrection ("Bottom Correction", Range(0, 2)) = 0.0

        [Foldout()]_Light ("Light", float) = 1
        _LightColor ("Light Color", Color) = (1, 1, 1, 1.0)

        _LightTex ("Light Tex", 2D) = "white" { }
        _LightIntensity ("Light Intensity", Range(0, 2)) = 0.909
        _LightPower ("Light Power", Range(0, 2)) = 1.29
        [FoldoutEnd]_LightOffset ("Light Offset", Range(0, 2)) = 0.53


        _ReflectWeight ("Reflect Weight", Range(0, 1)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent+1" }

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
            Tags { "LightMode" = "UniversalForward" }
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

            TEXTURE2D(_PlanarReflectionTexture);
            SAMPLER(sampler_PlanarReflectionTexture);

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
                float2 uv = input.uv;
                float2 screenUV = input.positionCS / _ScaledScreenParams.xy;
                float4 vertexColor = input.color;


                float4 finalColor = 0;


                float3 viewDirWS = normalize(input.viewDirWS);

                float3 viewDirOS = TransformWorldToObjectDir(viewDirWS, true);
                viewDirOS = viewDirOS.yyy * float3(-0.0, -2.0, -0.0) + viewDirOS;

                float sinAngle = sin(_Angle);
                float cosAngle = cos(_Angle);
                float sinNegAngle = sin(-_Angle);

                float3 rotatedViewDir;
                rotatedViewDir.x = sinAngle * viewDirOS.z + viewDirOS.x * cosAngle;
                rotatedViewDir.y = viewDirOS.y;
                rotatedViewDir.z = sinNegAngle * viewDirOS.x + viewDirOS.z * cosAngle;

                float3 addReflectionColor = SAMPLE_TEXTURECUBE_LOD(_AdditionalReflectionCube,
                sampler_AdditionalReflectionCube, rotatedViewDir,
                _AdditionalReflectionCubeMip).xyz;

                // addReflectionColor = Gamma20ToLinear(addReflectionColor);

                // return half4(addReflectionColor,1);

                addReflectionColor = addReflectionColor * _AdditionalReflectionColor.xyz;


                float3 normalWS = normalize(input.normalWS);

                float NdotV = dot(normalWS, viewDirWS);
                NdotV = max(1 - NdotV, 0);
                NdotV = pow(NdotV, _RimRange);

                float2 bottomUV = TRANSFORM_TEX(uv, _BottomTex);
                bottomUV = _Time.yy * _MainSpeed.xy * _BottomCorrection + bottomUV;
                float3 bottomColor = SAMPLE_TEXTURE2D(_BottomTex, sampler_BottomTex,
                viewDirWS.xz * _ViewOffset +bottomUV).xyz;


                float2 baseUV = TRANSFORM_TEX(uv, _BaseTex);
                float3 baseColor = SAMPLE_TEXTURE2D(_BaseTex, sampler_BaseTex, baseUV).xzw;
                float3 bottomColor0 = bottomColor * baseColor.yyy;
                bottomColor0 = _RimColor.xyz - bottomColor0 * _BottomColor.xyz;
                float3 rimColor = NdotV * bottomColor0 + bottomColor0 * _BottomColor.xyz;


                float2 center = uv - 0.5;
                float dist = length(center);
                dist = dist * 2.0 + 0.3;
                dist = 1.0 - min(dist, 1.0);

                float reflectionMask = dist * _ReflectWeight;
                // screenUV.x = 1.0 - screenUV.x;

                float3 reflectionColor = SAMPLE_TEXTURE2D(_PlanarReflectionTexture, sampler_PlanarReflectionTexture,
                screenUV).xyz;

                // reflectionColor = LinearToGamma20(reflectionColor);
                // reflectionColor = Gamma20ToLinear(reflectionColor);


                // blend color
                float3 blendColor = reflectionMask * reflectionColor + rimColor;
                blendColor = baseColor.xxx * _BaseColor.xyz + blendColor;


                float3 color = lerp(blendColor, blendColor * addReflectionColor, _AddtionalReflactionAlpha);

                float2 lightUV = TRANSFORM_TEX(input.uv, _LightTex);
                float lightMask = SAMPLE_TEXTURE2D(_LightTex, sampler_LightTex, lightUV).x;
                lightMask = pow(lightMask, _LightPower);

                lightMask = lightMask * _LightColor.x;
                lightMask = lightMask * _LightIntensity + _LightOffset;
                lightMask = clamp(lightMask, 0.0, 1.0);
                finalColor.xyz = lightMask * color;


                finalColor.a = baseColor.z * _BaseColor.w * vertexColor.w;
                return finalColor;
            }
            ENDHLSL
        }
    }
    CustomEditor "LcLShaderEditor.LcLShaderGUI"
}
