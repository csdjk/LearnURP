Shader "Custom/Diamond"
{
    Properties
    {
        [Header(Base)]
        _BaseColor          ("Base Color",          Color)  = (0.75, 0.90, 1.00, 0.85)
        _BaseMap            ("Base Texture",         2D)    = "white" {}

        [Header(Diamond Facets)]
        _FacetScale         ("Facet Scale",          Float)  = 20.0
        _FacetDepth         ("Facet Depth",          Range(0.1, 4.0)) = 1.2
        _FacetRandom        ("Facet Random Angle",   Range(0.0, 1.0)) = 0.6

        [Header(Normal Map Override)]
        [Toggle(_USE_NORMALMAP)] _UseNormalMap ("Use Normal Map", Float) = 0
        _NormalMap          ("Normal Map",           2D)    = "bump" {}
        _NormalStrength     ("Normal Strength",      Range(0.0, 3.0)) = 1.0

        [Header(Specular)]
        _Smoothness         ("Smoothness",           Range(0.0, 1.0)) = 0.97
        _SpecularStrength    ("Specular Strength",   Range(0.0, 8.0)) = 4.0
        _SpecularColor      ("Specular Color",       Color)  = (1.0, 1.0, 1.0, 1.0)

        [Header(Fresnel)]
        _FresnelPow         ("Fresnel Power",        Range(0.5, 8.0)) = 3.0
        _FresnelColor       ("Fresnel Color",        Color)  = (0.7, 0.88, 1.00, 1.0)
        _FresnelStrength    ("Fresnel Strength",     Range(0.0, 2.0)) = 1.0

        [Header(Prism Dispersion)]
        _DispersionStrength    ("Dispersion Strength",     Range(0.0, 1.0))  = 0.35
        _DispersionTiling      ("Dispersion Tiling",       Range(0.5, 8.0))  = 2.0
        _DispersionHueOffset   ("Hue Offset",              Range(0.0, 1.0))  = 0.0
        _DispersionSaturation  ("Saturation",              Range(0.0, 1.0))  = 1.0
        _DispersionContrast    ("Contrast",                Range(0.1, 4.0))  = 1.0
        _DispersionFresnelMask ("Fresnel Mask Strength",   Range(0.0, 1.0))  = 1.0

        [Header(Glitter Sparkle)]
        _SparkleScale       ("Sparkle Scale",        Float)  = 60.0
        _SparkleSharpness   ("Sparkle Sharpness",    Range(100.0, 4096.0)) = 1024.0
        _SparkleStrength    ("Sparkle Strength",     Range(0.0, 20.0)) = 8.0
        _SparkleColor       ("Sparkle Color",        Color)  = (1.0, 0.95, 0.85, 1.0)
        _SparkleTilt        ("Sparkle Tilt Range",   Range(0.0, 1.0)) = 0.7

        [Header(Environment Reflection)]
        _ReflectionCubeMap  ("Reflection CubeMap",   CUBE) = "" {}
        _ReflectionStrength ("Reflection Strength",  Range(0.0, 2.0)) = 1.0

        [Header(Blending)]
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend", Float) = 10
        [Enum(Off, 0, On, 1)] _ZWrite ("ZWrite", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "RenderType"        = "Transparent"
            "Queue"             = "Transparent+10"
            "RenderPipeline"    = "UniversalPipeline"
            "IgnoreProjector"   = "True"
        }

        Blend [_SrcBlend] [_DstBlend]
        ZWrite [_ZWrite]
        Cull Back

        Pass
        {
            Name "DiamondForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex   DiamondVert
            #pragma fragment DiamondFrag

            #pragma shader_feature_local _USE_NORMALMAP

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fog

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            // ────────────────────────────────────────────────────────────────
            // Textures
            // ────────────────────────────────────────────────────────────────
            TEXTURE2D(_BaseMap);    SAMPLER(sampler_BaseMap);
            TEXTURE2D(_NormalMap);  SAMPLER(sampler_NormalMap);
            TEXTURECUBE(_ReflectionCubeMap); SAMPLER(sampler_ReflectionCubeMap);

            // ────────────────────────────────────────────────────────────────
            // Constant Buffer
            // ────────────────────────────────────────────────────────────────
            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float4 _BaseMap_ST;
                float4 _NormalMap_ST;
                float  _NormalStrength;
                float  _FacetScale;
                float  _FacetDepth;
                float  _FacetRandom;
                float  _UseNormalMap;
                float  _Smoothness;
                float  _SpecularStrength;
                float4 _SpecularColor;
                float  _FresnelPow;
                float4 _FresnelColor;
                float  _FresnelStrength;
                float  _DispersionStrength;
                float  _DispersionTiling;
                float  _DispersionHueOffset;
                float  _DispersionSaturation;
                float  _DispersionContrast;
                float  _DispersionFresnelMask;
                float  _SparkleScale;
                float  _SparkleSharpness;
                float  _SparkleStrength;
                float4 _SparkleColor;
                float  _SparkleTilt;
                float  _ReflectionStrength;
            CBUFFER_END

            // ────────────────────────────────────────────────────────────────
            // Vertex / Fragment structs
            // ────────────────────────────────────────────────────────────────
            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normalOS     : NORMAL;
                float4 tangentOS    : TANGENT;
                float2 uv           : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float2 uv           : TEXCOORD0;
                float3 normalWS     : TEXCOORD1;
                float3 tangentWS    : TEXCOORD2;
                float3 bitangentWS  : TEXCOORD3;
                float3 positionWS   : TEXCOORD4;
                float  fogFactor    : TEXCOORD5;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            // ────────────────────────────────────────────────────────────────
            // Helper: fast hash
            // ────────────────────────────────────────────────────────────────
            float Hash21(float2 p)
            {
                return frac(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);
            }

            // ────────────────────────────────────────────────────────────────
            // Procedural Diamond Facet Normal (Tangent Space)
            //
            //  Each UV cell is split diagonally into 2 triangles.
            //  Each cell gets a random rotation so the facets look
            //  like irregular diamond / gemstone cuts.
            // ────────────────────────────────────────────────────────────────
            float3 DiamondFacetNormal(float2 uv)
            {
                float2 p     = uv * _FacetScale;
                float2 cell  = floor(p);
                float2 local = frac(p);          // [0,1)² inside the cell

                // Random per-cell rotation angle
                float  rnd    = Hash21(cell);
                float  angle  = rnd * TWO_PI * _FacetRandom;
                float  ca     = cos(angle);
                float  sa     = sin(angle);
                float2 rotUV  = float2(ca * local.x - sa * local.y,
                                       sa * local.x + ca * local.y);

                // Split cell by diagonal of the rotated coords
                // → two triangular faces, each with a different tilt direction
                float  slope = 1.0 / max(_FacetDepth, 0.01);
                float3 n;
                if (rotUV.x + rotUV.y < 1.0)
                    n = float3(-slope, -slope, 1.0);   // lower-left triangle
                else
                    n = float3( slope,  slope, 1.0);   // upper-right triangle

                // Additional random tilt per-cell (makes cuts irregular)
                float3 tilt = float3(
                    (Hash21(cell + 0.1)  - 0.5) * _FacetDepth,
                    (Hash21(cell + 13.7) - 0.5) * _FacetDepth,
                    1.0);

                return normalize(n * tilt);
            }

            // ────────────────────────────────────────────────────────────────
            // Helper: prismatic / rainbow colour from a [0,1] hue parameter
            // ────────────────────────────────────────────────────────────────
            float3 PrismColor(float hue)
            {
                // Smooth HSV-like rainbow
                float3 c;
                c.r = saturate(2.0 - abs(hue * 6.0 - 0.0) );
                c.g = saturate(2.0 - abs(hue * 6.0 - 2.0) );
                c.b = saturate(2.0 - abs(hue * 6.0 - 4.0) );
                // Keep only max channel bright to stay jewel-like
                float peak = max(max(c.r, c.g), c.b);
                return c / max(peak, 0.001);
            }

            // ────────────────────────────────────────────────────────────────
            // Fresnel (Schlick)
            // ────────────────────────────────────────────────────────────────
            float CalcFresnel(float3 normalWS, float3 viewDir)
            {
                float NdotV = saturate(dot(normalWS, viewDir));
                return pow(1.0 - NdotV, _FresnelPow) * _FresnelStrength;
            }

            // ────────────────────────────────────────────────────────────────
            // Environment cubemap reflection
            // ────────────────────────────────────────────────────────────────
            float3 CalcEnvReflection(float3 reflDir)
            {
                float  mip       = (1.0 - _Smoothness) * UNITY_SPECCUBE_LOD_STEPS;
                float4 envSample = SAMPLE_TEXTURECUBE_LOD(_ReflectionCubeMap,
                                                          sampler_ReflectionCubeMap,
                                                          reflDir, mip);
                return envSample.rgb * _ReflectionStrength;
            }

            // ────────────────────────────────────────────────────────────────
            // Prismatic dispersion
            //   reflDir          : world-space reflection vector
            //   fresnel          : fresnel factor (drives edge glow)
            //   _DispersionHueOffset   : rotates the entire rainbow [0,1]
            //   _DispersionSaturation  : 0=white  1=full rainbow
            //   _DispersionContrast    : sharpens/flattens colour bands
            //   _DispersionFresnelMask : 0=ignore fresnel  1=fully fresnel-masked
            // ────────────────────────────────────────────────────────────────
            float3 CalcDispersion(float3 reflDir, float fresnel)
            {
                // Project reflection onto the colour wheel, apply tiling + hue offset
                float raw = dot(reflDir, float3(0.6, 0.5, 0.5)) * _DispersionTiling;
                float hue = frac(raw + _DispersionHueOffset);

                // Contrast: remap hue so bands become sharper or softer
                // contrast > 1 → narrow vivid bands, < 1 → blurred pastel wash
                // hue = frac(hue * _DispersionContrast);

                // Base rainbow colour
                float3 rainbow = PrismColor(hue);

                // return hue;

                // Saturation blend: lerp toward white
                float3 col = lerp(float3(1.0, 1.0, 1.0), rainbow, _DispersionSaturation);

                // Fresnel mask: blend between full-surface and edge-only dispersion
                float mask = lerp(1.0, fresnel, _DispersionFresnelMask);


                return col * mask * _DispersionStrength;
            }

            // ────────────────────────────────────────────────────────────────
            // Surface specular (Blinn-Phong)
            // ────────────────────────────────────────────────────────────────
            float3 CalcSurfaceSpecular(float NdotH, float3 lightColor, float shadowAtten)
            {
                float specPow = exp2(_Smoothness * 12.0 + 2.0);
                float spec    = pow(NdotH, specPow) * _SpecularStrength;
                return spec * _SpecularColor.rgb * lightColor * shadowAtten;
            }

            // ────────────────────────────────────────────────────────────────
            // Diffuse
            // ────────────────────────────────────────────────────────────────
            float3 CalcDiffuse(float3 baseColor, float NdotL, float3 lightColor, float shadowAtten)
            {
                return baseColor * NdotL * lightColor * shadowAtten * 0.3;
            }

            // ────────────────────────────────────────────────────────────────
            // Per-cell glitter sparkle
            //
            //  Each UV cell gets a random normal on the upper hemisphere.
            //  When that normal aligns with the half-vector H (view+light),
            //  the cell fires a needle-sharp highlight.
            //  As the camera moves, H shifts → different cells light up in
            //  sequence → the "diamond twinkling" effect.
            // ────────────────────────────────────────────────────────────────
            float3 DiamondSparkle(float2 uv, float3 H, float3 tangentWS,
                                  float3 bitangentWS, float3 normalWS)
            {
                float2 p    = uv * _SparkleScale;
                float2 cell = floor(p);

                // Two independent random values per cell → random tangent-space normal
                float rx = (Hash21(cell)          - 0.5) * 2.0 * _SparkleTilt;
                float ry = (Hash21(cell + 17.39)  - 0.5) * 2.0 * _SparkleTilt;
                // z always positive → stays on upper hemisphere
                float rz = sqrt(max(1e-4, 1.0 - rx * rx - ry * ry));

                // Bring random normal into world space via TBN
                float3 facetN = normalize(rx * tangentWS + ry * bitangentWS + rz * normalWS);

                // Needle-sharp Blinn-Phong lobe for this cell
                float NdotH   = saturate(dot(facetN, H));
                float sparkle = pow(NdotH, _SparkleSharpness) * _SparkleStrength;

                // Optional: per-cell colour tint (slight rainbow variation)
                float hue   = Hash21(cell + 3.71);
                float3 tint = lerp(float3(1, 1, 1), PrismColor(hue), 0.35);

                return sparkle * _SparkleColor.rgb * tint;
            }

            // ────────────────────────────────────────────────────────────────
            // Vertex
            // ────────────────────────────────────────────────────────────────
            Varyings DiamondVert(Attributes IN)
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                Varyings OUT;
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

                VertexPositionInputs posInputs  = GetVertexPositionInputs(IN.positionOS.xyz);
                VertexNormalInputs   normInputs = GetVertexNormalInputs(IN.normalOS, IN.tangentOS);

                OUT.positionHCS  = posInputs.positionCS;
                OUT.positionWS   = posInputs.positionWS;
                OUT.normalWS     = normInputs.normalWS;
                OUT.tangentWS    = normInputs.tangentWS;
                OUT.bitangentWS  = normInputs.bitangentWS;
                OUT.uv           = TRANSFORM_TEX(IN.uv, _BaseMap);
                OUT.fogFactor    = ComputeFogFactor(posInputs.positionCS.z);
                return OUT;
            }

            // ────────────────────────────────────────────────────────────────
            // Fragment
            // ────────────────────────────────────────────────────────────────
            half4 DiamondFrag(Varyings IN) : SV_Target
            {
                // ── Base colour ──────────────────────────────────────────────
                float4 base = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv) * _BaseColor;

                // ── Normal (tangent space) ───────────────────────────────────
                float3 normalTS;
            #if defined(_USE_NORMALMAP)
                float4 ns = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap,
                                             TRANSFORM_TEX(IN.uv, _NormalMap));
                normalTS = UnpackNormalScale(ns, _NormalStrength);
            #else
                normalTS = DiamondFacetNormal(IN.uv);
            #endif

                // Tangent → World
                float3x3 TBN     = float3x3(normalize(IN.tangentWS),
                                            normalize(IN.bitangentWS),
                                            normalize(IN.normalWS));
                float3 normalWS  = normalize(mul(normalTS, TBN));

                // ── View / Reflect ───────────────────────────────────────────
                float3 viewDir   = normalize(GetCameraPositionWS() - IN.positionWS);
                float3 reflDir   = reflect(-viewDir, normalWS);

                // ── Fresnel ──────────────────────────────────────────────────
                float  fresnel   = CalcFresnel(normalWS, viewDir);

                // ── Environment Reflection ───────────────────────────────────
                float3 reflColor = CalcEnvReflection(reflDir);

                // ── Prismatic Dispersion ─────────────────────────────────────
                float3 dispersion = CalcDispersion(reflDir, fresnel);
                // return half4(dispersion, 1.0);

                // ── Main Light ───────────────────────────────────────────────
                Light  mainLight = GetMainLight(TransformWorldToShadowCoord(IN.positionWS));
                float3 L         = normalize(mainLight.direction);
                float3 H         = normalize(L + viewDir);

                float  NdotL     = saturate(dot(normalWS, L));
                float  NdotH     = saturate(dot(normalWS, H));

                float3 specColor    = CalcSurfaceSpecular(NdotH, mainLight.color, mainLight.shadowAttenuation);
                float3 sparkleColor = DiamondSparkle(IN.uv, H,
                                                     normalize(IN.tangentWS),
                                                     normalize(IN.bitangentWS),
                                                     normalize(IN.normalWS))
                                      * mainLight.color * mainLight.shadowAttenuation;
                float3 diffuse      = CalcDiffuse(base.rgb, NdotL, mainLight.color, mainLight.shadowAttenuation);


                // ── Combine ──────────────────────────────────────────────────
                float3 finalRGB =
                    diffuse                                        // subtle surface colour
                    + specColor                                    // surface-level specular
                    + sparkleColor                                 // per-facet twinkling glitter
                    + reflColor * (0.15 + fresnel * 0.85)         // environment reflection
                    + _FresnelColor.rgb * fresnel                  // rim glow
                    + dispersion;                                  // prismatic rainbow

                finalRGB = MixFog(finalRGB, IN.fogFactor);

                // Alpha: more opaque at grazing angles (physically correct for gems)
                float alpha = base.a + fresnel * (1.0 - base.a) * 0.8;

                return half4(finalRGB, saturate(alpha));
            }
            ENDHLSL
        }

    }

    FallBack "Universal Render Pipeline/Lit"
    CustomEditor "UnityEditor.ShaderGUI"
}
