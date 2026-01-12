Shader "LcL/Cloth/Stockings"
{
    Properties
    {
//        _BaseMap ("BaseMap", 2D) = "white" { }
        _StockMap ("Stock Map", 2D) = "white" { }

        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _StockColor ("Stockings Color", Color) = (0.83, 0.72, 0.64, 1)
        _StockDarkColor ("Stockings Dark Color", Color) = (0.0, 0.0, 0.0, 1)
        _StockDarkWidth ("Stockings Dark Width", Range(0, 1)) = 0.2
        _StockDarkSoftness ("Stockings Dark Softness", Range(0, 1)) = 0.1
        _StockPow ("Stockings Edge Power", Range(0, 100)) = 5.0
        _StockRoughness ("Stockings Roughness", Range(0, 1)) = 0.5
        _StockThicknessPow ("Stockings Thickness Power", Range(0.1, 5)) = 1.0
        _StockThickness ("Stockings Thickness", Range(0, 1)) = 0

        [Foldout]_HeightMask ("Height Mask", float) = 0
        _ObjectBoundY ("Object Bound Y", Vector) = (0, 1, 0, 0)
        _HeightMaskThreshold ("Height Mask Threshold", Range(0, 1)) = 0.8
        [FoldoutEnd]_HeightMaskSmoothness ("Height Mask Smoothness", Range(0, 1)) = 0.1

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
            float4 _StockMap_ST;
            float4 _BaseColor;
            float _Cutoff;

            float _StockThicknessPow;
            float _StockRoughness;
            float _StockDarkWidth;
            float _StockDarkSoftness;
            float _StockPow;
            float _StockThickness;
            float4 _StockColor;
            float4 _StockDarkColor;

            float4 _ObjectBoundY;
            float _HeightMaskThreshold;
            float _HeightMaskSmoothness;
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
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
                float3 normalWS : NORMAL;
                float3 positionWS : TEXCOORD1;
                float3 positionOS : TEXCOORD2;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            TEXTURE2D(_StockMap);
            SAMPLER(sampler_StockMap);


            Varyings vert(Attributes input)
            {
                Varyings output;

                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = positionInputs.positionCS;

                output.uv = input.uv;
                output.color = input.color;

                output.positionOS = input.positionOS.xyz;
                output.positionWS = positionInputs.positionWS;

                VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS.xyz);
                output.normalWS = normalInputs.normalWS;

                return output;
            }

            float ObjectBound01(float3 positionOS)
            {
                float objMinY = _ObjectBoundY.x;
                float objMaxY = _ObjectBoundY.y;

                float heightNorm = (positionOS.y - objMinY) / (objMaxY - objMinY);
                return saturate(heightNorm);
            }

            float HeightMask(float3 positionOS)
            {
                float height01 = ObjectBound01(positionOS);
                float height_mask = smoothstep(_HeightMaskThreshold - _HeightMaskSmoothness, _HeightMaskThreshold + _HeightMaskSmoothness, height01);
                return height_mask;
            }

            float3 Stockings(float2 uv, float3 N, float3 V, float3 baseColor, float height_mask)
            {
                float stockRangeZ = SAMPLE_TEXTURE2D(_StockMap, sampler_StockMap, uv * _StockMap_ST.xy).z;
                float2 stockMap = SAMPLE_TEXTURE2D(_StockMap, sampler_StockMap, uv).xy;

                // stockMap.y = 1;
                float stock_thickness_map = pow(stockMap.y, _StockThicknessPow);
                // return stockMap.y;

                // 粗糙度调节
                float roughnessAdjust = (stockRangeZ * 0.5) - 0.5;
                float finalRoughness = _StockRoughness * roughnessAdjust + 1.0;


                float rimValue = max(dot(N, V), 0.001);
                // 暗部宽度计算
                float rimGradient = 1 - smoothstep(_StockDarkWidth - _StockDarkSoftness, _StockDarkWidth + _StockDarkSoftness, rimValue);

                rimGradient = rimGradient + height_mask - rimGradient * height_mask;

                rimGradient = 1-(1-rimGradient) * stock_thickness_map;

                // 暗部颜色混合
                float3 darkColorBlend = lerp(1, _StockDarkColor.xyz, rimGradient);
                float3 stockDarkResult = lerp(1, baseColor.xyz * darkColorBlend, rimGradient);

                // 丝袜透明度计算
                float stockAlpha = (finalRoughness * stockMap.y);
                stockAlpha = (stockAlpha * (1 - _StockThickness));

                // 边缘光照强度
                float edgeLight = max(pow(rimValue, _StockPow), 0.004);
                stockAlpha = stockAlpha * (1 - height_mask);

                stockAlpha = clamp(stockAlpha * edgeLight, 0.0, 1.0);

                // 丝袜颜色混合
                float3 finalStockColor = lerp(baseColor.xyz * stockDarkResult, _StockColor.xyz, stockAlpha);

                return finalStockColor;
            }

            float4 frag(Varyings input) : SV_Target
            {
                // float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS.xyz);
                // Light light = GetMainLight(shadowCoord);
                float3 V = GetWorldSpaceViewDir(input.positionWS);
                V = normalize(V);
                float height_mask = HeightMask(input.positionOS);
                float3 shading = Stockings(input.uv, normalize(input.normalWS), V, _BaseColor.rgb, height_mask);

                return float4(shading, 1);
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
    CustomEditor "LcLShaderEditor.LcLShaderGUI"

}
