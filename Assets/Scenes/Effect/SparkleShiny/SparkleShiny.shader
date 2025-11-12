Shader "LcL/Effect/SparkleShiny"
{
    Properties
    {
        _BaseColor ("Color", Color) = (1, 1, 1, 1)
        _Cutoff ("Alpha Cutoff", Float) = 0.5

        _SparkleNormalMap ("Sparkle Normal Map", 2D) = "bump" { }
        _SparkleUVTiling ("Sparkle UV Tiling", Range(0,100)) = 10.0
        _SparkleNormalScale ("Sparkle Normal Scale", Range(0,10)) = 1.0
        _SparkleLightSpawn ("Sparkle Light Spawn", Range(0,10)) = 1.0
        _SparkleLightOffset ("Sparkle Light Offset", Range(0,1)) = 0.0
        _SparkleSaturation ("Sparkle Saturation", Range(0,10)) = 1.0
        _SparklePower ("Sparkle Power", Range(0,100)) = 32.0
        _SparkleIntensity ("Sparkle Intensity", Range(0,10)) = 1.0
        _SparkleLightIntensity ("Sparkle Light Intensity", Float) = 1.
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque" "Queue" = "Geometry" "RenderPipeline" = "UniversalPipeline"
        }

        HLSLINCLUDE
        #pragma target 3.5

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            float4 _BaseColor;
            float _Cutoff;

            float _SparkleUVTiling;
            float _SparkleLightSpawn;
            float _SparkleLightOffset;
            float _SparkleSaturation;
            float _SparklePower;
            float _SparkleIntensity;
            float _SparkleLightIntensity;
            float _SparkleNormalScale;
        CBUFFER_END
        ENDHLSL

        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }

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
                float4 tangentOS : TANGENT;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
                float3 normalWS : NORMAL;
                float4 tangentWS : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
            };

            TEXTURE2D(_SparkleNormalMap);
            SAMPLER(sampler_SparkleNormalMap);

            Varyings vert(Attributes input)
            {
                Varyings output;

                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = positionInputs.positionCS;

                output.uv = input.uv;
                output.color = input.color;

                output.positionWS = positionInputs.positionWS;

                VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS.xyz);
                output.normalWS = normalInputs.normalWS;

                real sign = input.tangentOS.w * GetOddNegativeScale();
                output.tangentWS = half4(normalInputs.tangentWS.xyz, sign);
                return output;
            }

            /// <summary>
            /// 计算闪光效果的反照率颜色
            /// </summary>
            /// <param name="viewDir">视线方向(已归一化)</param>
            /// <param name="worldNormal">世界空间法线(已归一化)</param>
            /// <param name="lightDir">主光源方向(已归一化)</param>
            /// <param name="uv">纹理坐标</param>
            /// <returns>闪光效果的最终颜色</returns>
            float3 CalculateSparkleAlbedo(
                float3 viewDir,
                float3 worldNormal,
                float3 lightDir,
                float2 uv,
                float3x3 TBN)
            {
                // 1. 采样闪光法线贴图
                float2 tiledUV = uv * _SparkleUVTiling;
                float4 sparkNormal = SAMPLE_TEXTURE2D(_SparkleNormalMap, sampler_SparkleNormalMap, tiledUV);

                // 2. 解压法线并混合到世界法线
                float3 unpackedNormal = UnpackNormalScale(sparkNormal, _SparkleNormalScale);
                unpackedNormal = TransformTangentToWorld(unpackedNormal, TBN);
                float3 perturbedNormal = normalize(worldNormal + unpackedNormal);

                // 3. 计算闪光相位值 (基于菲涅尔效应: 1 - N·V)
                float ndotV = dot(viewDir, perturbedNormal);
                float sparklePhase = (1.0 - ndotV) * _SparkleLightSpawn + _SparkleLightOffset;

                // 4. HSV到RGB的色彩转换 (生成彩虹渐变效果)
                float3 hsvToRgb = float3(
                    abs(sparklePhase * 6.0 - 3.0) - 1.0,
                    2.0 - abs(sparklePhase * 6.0 - 2.0),
                    2.0 - abs(sparklePhase * 6.0 - 4.0)
                );

                // 5. 应用饱和度调整
                float3 saturatedColor = (saturate(hsvToRgb) - 1.0) * _SparkleSaturation + 1.0;

                // 6. Gamma校正 (转换到线性空间)
                float3 linearColor = pow(max(0.0, saturatedColor), 2.2);

                // 7. 采样闪光遮罩 (alpha通道)
                float4 sparkleMaskSample = SAMPLE_TEXTURE2D(_SparkleNormalMap, sampler_SparkleNormalMap, uv);
                float sparkleMask = sparkleMaskSample.a;

                // 8. 计算Blinn-Phong高光项
                float3 halfVector = normalize(lightDir + viewDir);
                float ndotH = dot(halfVector, perturbedNormal);
                float specularTerm = pow(max(0.0, ndotH), _SparklePower) * _SparkleIntensity;

                // 9. 合成最终闪光颜色: 高光 * (颜色 * 遮罩) * 强度
                float3 sparkleColor = linearColor * sparkleMask;
                float3 finalColor = saturate(specularTerm) * sparkleColor * _SparkleLightIntensity;

                return finalColor;
            }

            half4 frag(Varyings input) : SV_Target
            {
                float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS.xyz);
                Light light = GetMainLight(shadowCoord);
                float3 view = normalize(GetWorldSpaceViewDir(input.positionWS));
                float3 N = normalize(input.normalWS);

                float sgn = input.tangentWS.w; // should be either +1 or -1
                float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
                float3x3 TBN = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);

                half3 shading = CalculateSparkleAlbedo(view, N, light.direction, input.uv, TBN);

                return half4(shading, 1);
            }
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            ZWrite On
            ZTest LEqual

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma only_renderers gles gles3 glcore d3d11

            // Material Keywords
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            ZWrite On
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment
            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
            ENDHLSL
        }
    }
}
