Shader "LcL/Effect/EffectFire"
{
    Properties
    {
        [Toggle(_USE_FACE_REMOVE)] _USE_FACE_REMOVE ("面片感消除", Float) = 0
        [ShowIf(_USE_FACE_REMOVE)]_FaceRemovePow ("Face Remove Power", Range(0.1, 10)) = 1.0

        _FireAlpha ("Fire Alpha", Range(0, 1)) = 1.0

        [Foldout]_FireColor ("火焰颜色", float) = 0
        [SingleLine]_FireMap ("Fire Map", 2D) = "white" { }
        [Toggle(_USE_RAMP)] _USE_RAMP ("Use Ramp", Float) = 0
        [ShowIf(_USE_RAMP)]_RampMap ("Ramp Map", 2D) = "white" { }
        [ShowIf(_USE_RAMP)]_RampHue ("色相偏移", Range(0, 1)) = 0.0
        _FireLevelPow ("火焰色阶对比度", Range(0.1, 10)) = 1.0
        _RampColorInt ("颜色强度", Range(0, 10)) = 1.0

        [ShowIf(_USE_RAMP, 0)][HDR]_FireColor1 ("Fire Color 1", Color) = (0.43, 0, 1, 1)
        [ShowIf(_USE_RAMP, 0)][HDR]_FireColor2 ("Fire Color 2", Color) = (1, 0.04, 0.53, 1)
        [ShowIf(_USE_RAMP, 0)][HDR]_FireColor3 ("Fire Color 3", Color) = (1, 0.0, 0, 1)
        [ShowIf(_USE_RAMP, 0)][HDR]_FireColor4 ("Fire Color 4", Color) = (0, 0.36, 1, 1)
        [ShowIf(_USE_RAMP, 0)][HDR]_FireColor5 ("Fire Color 5", Color) = (0, 1, 0.6, 1)

        [ShowIf(_USE_RAMP, 0)]_FireBoundary1 ("Fire Boundary 1", Range(0, 1)) = 0.1
        [ShowIf(_USE_RAMP, 0)]_FireBoundary2 ("Fire Boundary 2", Range(0, 1)) = 0.3
        [ShowIf(_USE_RAMP, 0)]_FireBoundary3 ("Fire Boundary 3", Range(0, 1)) = 0.5
        [ShowIf(_USE_RAMP, 0)]_FireBoundary4 ("Fire Boundary 4", Range(0, 1)) = 0.7
        [FoldoutEnd][ShowIf(_USE_RAMP, 0)]_FireBoundary5 ("Fire Boundary 5", Range(0, 1)) = 1

        [Foldout]_Dist ("扭曲", float) = 0
        [SingleLine]_DistNoiseMap ("Distortion Noise Map", 2D) = "white" { }
        _DistNoiseTilingSpeed ("Dist Tiling Speed", Vector) = (5, 5, 0, 1)
        _DistIntAttenAdjust ("Dist Int Atten Adjust", Vector) = (1, 1, 0, 0)
        [FoldoutEnd]_DistInt ("Distortion Intensity", Range(0, 0.5)) = 0.1

        [Foldout]_AlphaNoise ("Alpha Noise", float) = 0
        [Toggle(_USE_ALPHA_NOISE)] _USE_ALPHA_NOISE ("Use Alpha Noise", Float) = 0
        [SingleLine]_DistNoiseAMap ("Alpha Noise", 2D) = "white" { }
        _DistNoiseTilingSpeedA ("Alpha Noise Tiling Speed", Vector) = (1, 1, 0, 1)
        _DistIntAttenAdjustA ("Alpha Int Atten Adjust A", Vector) = (1, 1, 0, 0)
        [FoldoutEnd]_DistIntA ("Alpha Intensity A", Range(0, 1)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" "RenderPipeline" = "UniversalPipeline" }

        HLSLINCLUDE
        #pragma target 3.5

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        CBUFFER_START(UnityPerMaterial)
            float _Cutoff;

            float _DistInt;
            float _DistIntA;
            float _FaceRemovePow;
            float _FireAlpha;
            float _RampColorInt;
            float _RampHue;
            float _FireLevelPow;
            float _FireBoundary1, _FireBoundary2, _FireBoundary3, _FireBoundary4, _FireBoundary5;

            float2 _DistIntAttenAdjust;
            float2 _DistIntAttenAdjustA;
            float4 _DistNoiseTilingSpeed;
            float4 _DistNoiseTilingSpeedA;

            float4 _FireColor1, _FireColor2, _FireColor3, _FireColor4, _FireColor5;
        CBUFFER_END
        ENDHLSL

        Pass
        {
            Tags { "LightMode" = "UniversalForward" }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT

            #pragma shader_feature _ _USE_RAMP
            #pragma shader_feature _ _USE_ALPHA_NOISE
            #pragma shader_feature _ _USE_FACE_REMOVE

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
                float4 color : COLOR;
                float3 normalWS : NORMAL;
                float4 uv : TEXCOORD0;
                float4 uv2 : TEXCOORD1;
                float3 positionWS : TEXCOORD3;
            };

            TEXTURE2D(_DistNoiseMap);
            SAMPLER(sampler_DistNoiseMap);
            TEXTURE2D(_DistNoiseAMap);
            SAMPLER(sampler_DistNoiseAMap);
            TEXTURE2D(_FireMap);
            SAMPLER(sampler_FireMap);
            TEXTURE2D(_RampMap);
            SAMPLER(sampler_RampMap);

            // 渐变颜色混合
            float4 FireColorBlend(float level, float4 fireColor1, float4 fireColor2, float4 fireColor3, float4 fireColor4, float4 fireColor5,
            float boundary1, float boundary2, float boundary3, float boundary4, float boundary5)
            {
                float weight1 = saturate((level - boundary1) / (boundary2 - boundary1));
                float weight2 = saturate((level - boundary2) / (boundary3 - boundary2));
                float weight3 = saturate((level - boundary3) / (boundary4 - boundary3));
                float weight4 = saturate((level - boundary4) / (boundary5 - boundary4));

                float4 color = fireColor1;
                color = lerp(color, fireColor2, weight1);
                color = lerp(color, fireColor3, weight2);
                color = lerp(color, fireColor4, weight3);
                color = lerp(color, fireColor5, weight4);

                return color;
            }

            // 绕轴旋转函数
            float3 RotateAboutAxis(float4 axisAndAngle, float3 pivot, float3 position)
            {
                float3 axis = normalize(axisAndAngle.xyz);
                float angle = axisAndAngle.w;
                float3 toRotate = position - pivot;
                float cosAngle = cos(angle);
                float sinAngle = sin(angle);
                return pivot + cosAngle * toRotate + sinAngle * cross(axis, toRotate) +
                (1.0 - cosAngle) * dot(axis, toRotate) * axis;
            }

            Varyings vert(Attributes input)
            {
                Varyings output;

                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = positionInputs.positionCS;
                output.color = input.color;
                VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS.xyz);
                output.normalWS = normalInputs.normalWS;

                output.uv.xy = input.uv;
                output.uv.zw = _Time.y * _DistNoiseTilingSpeed.zw + input.uv * _DistNoiseTilingSpeed.xy;
                output.uv2.xy = _Time.y * _DistNoiseTilingSpeedA.zw + input.uv * _DistNoiseTilingSpeedA.xy;

                output.positionWS = positionInputs.positionWS;
                return output;
            }

            half4 frag(Varyings input, half facing : VFACE) : SV_Target
            {
                float2 uv = input.uv.xy;
                float2 distortionUV1 = input.uv.zw;
                float3 positionWS = input.positionWS;
                float3 normalWS = normalize(input.normalWS);


                float3 finalColor;
                float finalAlpha;

                // 扰动采样
                float4 distortionNoise = SAMPLE_TEXTURE2D(_DistNoiseMap, sampler_DistNoiseMap, distortionUV1);
                float distortionIntensity = _DistInt * lerp(_DistIntAttenAdjust.x, _DistIntAttenAdjust.y, uv.y);
                float distortion = (distortionNoise.x * 2.0 - 1.0) * distortionIntensity;

                // 火焰贴图采样（R-色阶，G-Alpha，B-Alpha遮罩）
                float4 fireTexture = SAMPLE_TEXTURE2D(_FireMap, sampler_FireMap, uv + distortion);
                // 计算火焰色阶
                float fireLevel = fireTexture.x;
                float rampLevel = pow(max(0, fireLevel), _FireLevelPow);


                // 渐变色
                #if defined(_USE_RAMP)
                    float2 rampUV = float2(rampLevel, 0.5);
                    float4 rampColor = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, rampUV);
                    // 色相
                    float3 rotatedRampColor = RotateAboutAxis(float4(normalize(float3(1, 1, 1)), _RampHue * 6.28318),
                    float3(0, 0, 0), rampColor.rgb);
                    finalColor = (rotatedRampColor + rampColor.rgb) * _RampColorInt;
                #else
                    // 火焰颜色混合
                    float4 customFireColor = FireColorBlend(rampLevel, _FireColor1, _FireColor2, _FireColor3,
                    _FireColor4, _FireColor5,
                    _FireBoundary1, _FireBoundary2, _FireBoundary3,
                    _FireBoundary4, _FireBoundary5);
                    finalColor = customFireColor.rgb * _RampColorInt;
                #endif

                // Alpha计算
                float alphaFromFire = fireTexture.y;
                float alphaFromOriginal = SAMPLE_TEXTURE2D(_FireMap, sampler_FireMap, uv).z;

                // Alpha噪声
                float alphaNoiseFactor = 1.0;
                #ifdef _USE_ALPHA_NOISE
                    float2 alphaNoiseUV = input.uv2.xy;
                    float4 alphaNoise = SAMPLE_TEXTURE2D(_DistNoiseAMap, sampler_DistNoiseAMap, alphaNoiseUV);
                    float alphaNoiseIntensity = _DistIntA * lerp(_DistIntAttenAdjustA.x, _DistIntAttenAdjustA.y, uv.y);
                    alphaNoiseFactor = lerp(1.0, alphaNoise.x, alphaNoiseIntensity);
                #endif

                // 面片感消除
                float faceRemoveFactor = 1.0;
                #ifdef _USE_FACE_REMOVE
                    float3 viewDirection = SafeNormalize(GetWorldSpaceViewDir(positionWS));
                    float faceDot = dot(viewDirection, normalWS * facing);
                    faceRemoveFactor = pow(max(0, faceDot), _FaceRemovePow);
                #endif

                // 最终Alpha
                finalAlpha = saturate(alphaFromFire * alphaFromOriginal * _FireAlpha *
                alphaNoiseFactor * faceRemoveFactor);

                return half4(finalColor, finalAlpha);
            }
            ENDHLSL
        }

        //        Pass
        //        {
        //            Name "ShadowCaster"
        //            Tags
        //            { // "LightMode" = "ShadowCaster"
        //            }
        //
        //            ZWrite On
        //            ZTest LEqual
        //
        //            HLSLPROGRAM
        //            #pragma prefer_hlslcc gles
        //            #pragma only_renderers gles gles3 glcore d3d11
        //
        //            // Material Keywords
        //            #pragma shader_feature _ALPHATEST_ON
        //            #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        //
        //            // GPU Instancing
        //            #pragma multi_compile_instancing
        //
        //            #pragma vertex ShadowPassVertex
        //            #pragma fragment ShadowPassFragment
        //
        //            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
        //            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
        //            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
        //            ENDHLSL
        //        }

    }
    CustomEditor "LcLShaderEditor.LcLShaderGUI"
}
