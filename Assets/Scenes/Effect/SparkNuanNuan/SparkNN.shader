Shader "cb_10726/SparkTest"
{
    Properties
    {
        // ── Sparkle 基础 ──────────────────────────────────────────────────────
        [Header(Sparkle)]
        _SparkleColor ("Sparkle Color", Color) = (0.60784, 0.79726, 1, 1)
        _SparkLightDir ("Spark Light Dir (world space)", Vector) = (0, 1, 0, 0)
        [Space(4)]
        _SparkleDensity ("Density", Range(0, 1)) = 0.44
        _SparkleNdotHFreq ("NdotH Freq", Range(0, 10)) = 0.63
        _SparkleRoughness ("Roughness", Range(0, 1)) = 0.45
        _SparkleMinHash ("Min Hash", Range(0, 1)) = 1.0

        // ── Sparkle 尺寸 ──────────────────────────────────────────────────────
        [Header(Sparkle Size)]
        _SparkleCellSizeX ("Cell Size X", Range(1, 500)) = 50.0
        _SparkleCellSizeY ("Cell Size Y", Range(1, 500)) = 50.0
        _SparkleHashScaleZ ("Hash Scale Z", Range(0.001, 5)) = 0.0025
        _SparkleHashScaleW ("Hash Scale W", Range(0.001, 5)) = 0.0025

        // ── Sparkle 颜色模式 ──────────────────────────────────────────────────
        [Header(Sparkle Color Mode)]
        [KeywordEnum(Off, Rainbow, RandomColor)] _SparkleColorMode ("Color Mode", Float) = 0
        _SparkleRainbowSat ("Color Saturation", Range(0, 1)) = 0.8
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry" }

        Pass
        {
            Name "SparkTest"
            Tags { "LightMode" = "UniversalForward" }

            Cull Back
            ZWrite On
            ZTest LEqual
            Blend Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature_local_fragment _SPARKLECOLORMODE_OFF _SPARKLECOLORMODE_RAINBOW _SPARKLECOLORMODE_RANDOMCOLOR
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile_fragment _ _SHADOWS_SOFT

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float3 _SparkleColor;
                float _SparkleDensity;
                float _SparkleNdotHFreq;
                float _SparkleRoughness;
                float _SparkleMinHash;
                float _SparkleCellSizeX;
                float _SparkleCellSizeY;
                float _SparkleHashScaleZ;
                float _SparkleHashScaleW;
                float3 _SparkLightDir;
                float _SparkleRainbowSat;   // Color Saturation，Rainbow 和 RandomColor 共用
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv0 : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 mainUV : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            // ── 工具函数：Hue [0,1] → RGB ─────────────────────────────────────
            // 标准 HSV → RGB，饱和度固定为 1，明度固定为 1
            float3 HueToRGB(float hue)
            {
                float3 rgb = abs(frac(hue + float3(0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0) - 1.0;
                return saturate(rgb);
            }

            // ── Sparkle ───────────────────────────────────────────────────────
            float3 CalculateSpark(
                float2 mainUV,
                float3 normalWS,
                float3 viewDir,
                float3 lightDir)
            {
                float spkRough = _SparkleRoughness * _SparkleRoughness;
                float spkAlpha2 = max(spkRough, 0.1);
                spkAlpha2 = spkAlpha2 * spkAlpha2;

                float2 spkUV = mainUV * float2(_SparkleCellSizeX, _SparkleCellSizeY);
                float2 spkF = floor(spkUV);
                float2 spkFrac = spkUV - spkF;
                float2 spkOff = sign(spkFrac - 0.5);

                // 4 个相邻 cell 坐标打包为 float4，每 lane 独立
                // Cell 布局: lane0=(0,0)  lane1=(0,offY)  lane2=(offX,0)  lane3=(offX,offY)
                float4 cx = (spkF.x + float4(0, 0, spkOff.x, spkOff.x)) * _SparkleHashScaleZ;
                float4 cy = (spkF.y + float4(0, spkOff.y, 0, spkOff.y)) * _SparkleHashScaleW;

                // Polynomial hash — Pass A: X 偏移 / density；Pass B: Y 偏移；Pass C: 色相（RandomColor 专用）
                float4 pa = cy * cx;
                float4 sa = cy + cx;
                float4 hashR = frac((pa * 0.4 + sa * 0.6) * 2611.1409 + 5.381);
                hashR = frac(hashR * 63.780998);
                float4 yHash = frac((pa * sa) * 2611.1409 + 5.381);
                yHash = frac(yHash * 63.780998);
                #if defined(_SPARKLECOLORMODE_RANDOMCOLOR)
                    // 用不同的混合系数产出独立色相 hash，与 hashR/yHash 不相关
                    float4 colorHash = frac((pa * 0.7 + sa * 0.3) * 3571.3917 + 9.173);
                    colorHash = frac(colorHash * 47.524);
                #endif

                float4 vis = step(hashR, _SparkleDensity);
                float4 invDen = 1.0 / (hashR * (1.0 - _SparkleMinHash) + _SparkleMinHash);

                float4 distX = abs((spkFrac.x - hashR) - float4(0, 0, spkOff.x, spkOff.x)) * invDen;
                float4 distY = abs((spkFrac.y - yHash) - float4(0, spkOff.y, 0, spkOff.y)) * invDen;

                float4 sparkMask = vis * max(1.0 - (distX * distX + distY * distY) * 4.0, 0.0);

                // GGX 高光：hashR 扰动 NdotH，锯齿波映射
                float3 halfVec = normalize(viewDir + lightDir);
                float NdotH = dot(normalWS, halfVec);
                float4 spkH4 = abs(frac(hashR * _SparkleNdotHFreq + NdotH) - 0.5) * 2.0;
                float4 denom = (spkH4 * spkAlpha2 - spkH4) * spkH4 + 1.0;
                float4 spkSpec = min(spkAlpha2 * 0.31830987 / (denom * denom), 100.0);

                float3 colResult = 0;
                #if defined(_SPARKLECOLORMODE_RAINBOW)
                    // 视角相关色相 + per-cell hashR 偏移
                    float4 cellHue = frac(dot(normalWS, viewDir) + hashR);
                    [unroll] for (int i = 0; i < 4; i++)
                    colResult += lerp(1.0, HueToRGB(cellHue[i]), _SparkleRainbowSat) * spkSpec[i] * sparkMask[i];
                #elif defined(_SPARKLECOLORMODE_RANDOMCOLOR)
                    // per-cell 固定随机色相（与视角无关，每个闪点颜色恒定）
                    [unroll] for (int i = 0; i < 4; i++)
                    colResult += lerp(1.0, HueToRGB(colorHash[i]), _SparkleRainbowSat) * spkSpec[i] * sparkMask[i];
                #else
                    // Off：单色模式
                    colResult = dot(spkSpec, sparkMask);
                #endif

                return abs(dot(normalWS, lightDir)) * colResult * _SparkleColor;
            }

            Varyings vert(Attributes IN)
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                Varyings OUT;
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                float3 posWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.positionCS = TransformWorldToHClip(posWS);
                OUT.positionWS = posWS;
                OUT.normalWS = normalize(TransformObjectToWorldNormal(IN.normalOS));
                OUT.mainUV = IN.uv0;
                return OUT;
            }

            float4 frag(Varyings IN) : SV_Target
            {
                float3 lightDir = normalize(_SparkLightDir);
                float3 viewDir = GetWorldSpaceNormalizeViewDir(IN.positionWS);
                return float4(CalculateSpark(IN.mainUV, IN.normalWS, viewDir, lightDir), 1.0);
            }

            ENDHLSL
        }
    }
    CustomEditor "LcLShaderEditor.LcLShaderGUI"
    FallBack "Hidden/InternalErrorShader"
}