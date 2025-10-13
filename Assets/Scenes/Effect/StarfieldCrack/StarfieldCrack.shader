Shader "LcL/StarfieldCrack"
{
    Properties
    {
        [Foldout()]_BASE ("Base", float) = 0
        _BaseMap ("Background Texture", 2D) = "white" { }
        [FoldoutEnd]_StarfieldColor ("Starfield Color", Color) = (1, 1, 1, 1)


        [Foldout()]_Starfield ("Starfield Crack", float) = 0
        _NoiseMap ("Noise Map", 2D) = "white" { }
        [HDR]_CrackColor ("Crack Color", Color) = (0, 7, 10, 1)
        _CenterRadiuse ("Center", Vector) = (0.5, 0.5, 0.8, 0.3)
        _NoiseSpeed ("Noise Speed", Vector) = (-1, 0, 0, 0)
        _NoiseStrength ("Noise Strength", Range(0,0.5)) = 0.1
        _CrackWidth ("Crack Width", Range(0, 1)) = 0.1
        [FoldoutEnd]_SmoothWidth ("Smooth Width", Range(0, 0.1)) = 0.01

        [Foldout()]_TriplanarCameraVector ("TriplanarCameraVector", float) = 0
        _AxisFadeContrast ("Axis Fade Contrast", Range(1, 10)) = 4
        _Tilling ("Tilling", Vector) = (1, 1, 1, 1)
        [FoldoutEnd]_Offset ("Offset", Vector) = (0, 0, 0, 0)

    }
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+1"
        }

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            float3 _Tilling;
            float3 _Offset;
            float _AxisFadeContrast;

            float4 _NoiseMap_ST;
            float4 _CenterRadiuse;
            float2 _NoiseSpeed;
            float _NoiseStrength;
            float _CrackWidth;
            float _SmoothWidth;
            float4 _CrackColor;
            float4 _StarfieldColor;
        CBUFFER_END

        TEXTURE2D(_MetallicSmoothnessMap);
        SAMPLER(sampler_MetallicSmoothnessMap);
        ENDHLSL

        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma only_renderers gles gles3 glcore d3d11

            #pragma vertex vert
            #pragma fragment frag

            #define  _NORMALMAP
            #define BUMP_SCALE_NOT_SUPPORTED 0
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "Assets/Shaders/Libraries/Node.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
                float2 lightmapUV : TEXCOORD1;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD2;
                float3 normalWS : TEXCOORD3;
                float3 viewDirWS : TEXCOORD5;
            };

            TEXTURE2D(_NoiseMap);
            SAMPLER(sampler_NoiseMap);

            Varyings vert(Attributes input)
            {
                Varyings output;

                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = positionInputs.positionCS;
                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                output.color = input.color;
                output.viewDirWS = GetWorldSpaceViewDir(positionInputs.positionWS);
                VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                output.normalWS = normalInputs.normalWS;
                return output;
            }

            // 在 Node.hlsl 中添加以下函数
            float4 StarfieldCrack(
                TEXTURE2D_PARAM(noise_map, sampler_noise_map),
                float2 uv,
                float2 center,
                float2 noise_tilling,
                float2 noise_speed,
                float noise_strength,
                float2 radius,
                float crack_width,
                float smooth_width,
                float4 crack_color,
                float4 starfield_color
            )
            {
                // UV偏移
                float2 uv_offset = uv - center;

                // 转换为极坐标
                float2 polar;
                polar.x = length(uv_offset) * 2;
                polar.y = atan2(uv_offset.x, uv_offset.y) / 6.28318;
                polar = polar * noise_tilling;

                // 添加时间动画
                polar = polar + _Time.y * noise_speed;

                // 采样噪声图并计算扰动
                float noise = SAMPLE_TEXTURE2D(noise_map, sampler_noise_map, polar).r;
                noise = (noise * 2 - 1) * noise_strength;

                // 扰动UV
                uv = uv + noise;

                // 重新计算偏移量用于SDF
                uv_offset = uv - center;
                float k = length(uv_offset / radius);
                float sdf = k;

                // 计算裂缝边缘
                float range = 0.5;
                float threshold1 = range - crack_width;
                float threshold2 = range + crack_width;

                // 计算内外SDF
                float innerSDF = 1 - smoothstep(threshold1 - smooth_width, threshold1 + smooth_width, sdf);
                float outerSDF = 1 - smoothstep(threshold2 - smooth_width, threshold2 + smooth_width, sdf);
                float crack_mask = saturate(outerSDF - innerSDF);

                // 混合颜色
                float4 final_crack_color = crack_mask * crack_color;
                float4 final_color = lerp(final_crack_color, starfield_color, innerSDF);
                final_color.a = outerSDF;
                return final_color;
            }


            half4 frag(Varyings input) : SV_Target
            {
                half3 viewDirWS = SafeNormalize(input.viewDirWS);

                float4 starColor = TriplanarCameraVector(
                    TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap),
                    viewDirWS, _Tilling, _Offset, _AxisFadeContrast) * _StarfieldColor;

                float4 color = StarfieldCrack(
                    TEXTURE2D_ARGS(_NoiseMap, sampler_NoiseMap),
                    input.uv,
                    _CenterRadiuse.xy,
                    _NoiseMap_ST.xy,
                    _NoiseSpeed,
                    _NoiseStrength,
                    _CenterRadiuse.zw,
                    _CrackWidth,
                    _SmoothWidth,
                    _CrackColor,
                    starColor);

                return color;
            }
            ENDHLSL
        }
    }
    CustomEditor "LcLShaderEditor.LcLShaderGUI"
}
