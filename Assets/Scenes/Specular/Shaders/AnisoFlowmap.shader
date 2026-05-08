// ===========================================================================
//  AnisoFlowmap.shader
//  Anisotropic Specular (Flowmap-Driven) — URP Lit-compatible
//
//  Based on vbr.fx (netease F-PBR) ANISO_ENABLE logic:
//
//  sam_other4 (FlowMap):
//    .xy  — flowmap direction in [0,1], decoded to [-1,1] tangent-space dir
//    .z   — per-pixel noise bias for the aniso highlight band
//    .w   — (optional extra mask, unused here)
//
//  Core highlight model (Kajiya-Kay style):
//    anisoDir  = normalize( flowX * tangent + flowY * binormal )
//    shiftedN  = normalize( normal * (normal_offset + (flow.z - 0.5) * noise_offset)
//                          + anisoDir )
//    NdotV     = saturate( dot(shiftedN, viewDir) )
//    highlight = max( sin(NdotV * PI), 0 )
//
//  Environment-sample direction is also blended toward shiftedN when
//  newAnisoFactor.z/w are non-zero.
// ===========================================================================

Shader "Custom/AnisoFlowmap"
{
    Properties
    {
        // ── Base PBR ────────────────────────────────────────────────────────
        [MainTexture] _BaseMap          ("Base Color (RGB) Alpha (A)", 2D)      = "white" {}
        _OtherMap1                      ("PBR Map (R:Metal G:SSS B:Rough W:?)", 2D) = "white" {}
        [Normal] _NormalMap             ("Normal Map",                  2D)      = "bump"  {}

        // ── FlowMap ─────────────────────────────────────────────────────────
        [Header(Anisotropic Flowmap)]
        _FlowMap                        ("Flow Map  (RG:Dir  B:Noise)", 2D)      = "gray"  {}

        // ── Anisotropic Parameters ───────────────────────────────────────────
        _NormalOffset                   ("Normal Offset  (整体偏移)",  Range(-5, 5))   = -0.2
        _NoiseOffset                    ("Noise Offset   (抖动偏移)",  Range( 0, 1))   =  0.2
        // newAnisoFactor: x=unused  y=unused  z=envir blend  w=view atten
        _NewAnisoFactor                 ("Aniso Factor (z:EnvBlend w:ViewAtten)", Vector) = (60,0,1,0)
        _AnisoSpecIntensity             ("Aniso Spec Intensity",       Range( 0,10))   =  1.0
        _AnisoSpecPower                 ("Aniso Spec Power (sin^p)",   Range( 1,256))  =  8.0

        // ── Standard PBR multipliers ─────────────────────────────────────────
        _MetalMulti                     ("Metal Offset",   Range(-1, 1))   = 0.0
        _RoughMulti                     ("Rough Offset",   Range(-1, 1))   = 0.0

        // ── Light ─────────────────────────────────────────────────────────────
        _DiffuseIntensity               ("Diffuse Intensity",          Range( 0, 5))   = 1.0
    }

    SubShader
    {
        Tags
        {
            "RenderType"      = "Opaque"
            "RenderPipeline"  = "UniversalPipeline"
            "Queue"           = "Geometry"
        }

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            Cull Back
            ZWrite On
            ZTest LEqual

            HLSLPROGRAM
            #pragma vertex   vert
            #pragma fragment frag

            // URP keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fog

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            // ── Textures ────────────────────────────────────────────────────
            TEXTURE2D(_BaseMap);   SAMPLER(sampler_BaseMap);
            TEXTURE2D(_OtherMap1); SAMPLER(sampler_OtherMap1);
            TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap);
            TEXTURE2D(_FlowMap);   SAMPLER(sampler_FlowMap);

            // ── Uniforms ────────────────────────────────────────────────────
            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                float  _NormalOffset;
                float  _NoiseOffset;
                float4 _NewAnisoFactor;
                float  _AnisoSpecIntensity;
                float  _AnisoSpecPower;
                float  _MetalMulti;
                float  _RoughMulti;
                float  _DiffuseIntensity;
            CBUFFER_END

            // ── Structs ─────────────────────────────────────────────────────
            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float4 tangentOS  : TANGENT;
                float2 uv         : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS  : SV_POSITION;
                float2 uv          : TEXCOORD0;
                float3 positionWS  : TEXCOORD1;
                float3 normalWS    : TEXCOORD2;
                float3 tangentWS   : TEXCOORD3;
                float3 binormalWS  : TEXCOORD4;
            };

            // ── Vertex ──────────────────────────────────────────────────────
            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.positionCS = TransformWorldToHClip(OUT.positionWS);

                OUT.normalWS  = normalize(TransformObjectToWorldNormal(IN.normalOS));
                OUT.tangentWS = normalize(TransformObjectToWorldDir(IN.tangentOS.xyz));

                // Reconstruct binormal (tangent.w encodes handedness)
                float sign = IN.tangentOS.w * GetOddNegativeScale();
                OUT.binormalWS = normalize(cross(OUT.normalWS, OUT.tangentWS) * sign);

                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                return OUT;
            }

            // ── Helpers ─────────────────────────────────────────────────────
            // NOTE: Renamed to avoid conflict with URP's built-in functions
            //       (F_Schlick / D_GGX / G_SchlickGGX are defined in Lighting.hlsl)

            // Schlick Fresnel approximation
            float3 Aniso_F_Schlick(float3 f0, float VdotH)
            {
                float t = pow(1.0 - VdotH, 5.0);
                return f0 + (1.0 - f0) * t;
            }

            // GGX Normal Distribution
            float Aniso_D_GGX(float roughness, float NdotH)
            {
                float a  = roughness * roughness;
                float a2 = a * a;
                float d  = NdotH * NdotH * (a2 - 1.0) + 1.0;
                return a2 / max(PI * d * d, 1e-5);
            }

            // Disney Schlick Geometry
            float Aniso_G_Schlick(float roughness, float NdotV, float NdotL)
            {
                float k  = 0.5 * roughness;
                float gv = NdotV * (1.0 - k) + k;
                float gl = NdotL * (1.0 - k) + k;
                return 0.25 / max(gv * gl, 1e-5);
            }

            // EnvBRDF approximation (Lazarov 2013, matches vbr.fx EnvBRDFApprox)
            float2 Aniso_EnvBRDFApprox(float roughness, float NdotV)
            {
                const float4 c0 = float4(-1.0, -0.0275, -0.572,  0.022);
                const float4 c1 = float4( 1.0,  0.0425,  1.040, -0.040);
                float4 r   = roughness * c0 + c1;
                float  a004 = min(r.x * r.x, exp2(-9.28 * NdotV)) * r.x + r.y;
                return float2(-1.04, 1.04) * a004 + r.zw;
            }

            // ── Anisotropic highlight (Kajiya-Kay) ─────────────────────────
            //  Proper Kajiya-Kay specular band:
            //
            //  T (fiber/strand direction) comes from the FlowMap:
            //    anisoDir  = normalize( flowX*tangent + flowY*binormal )
            //    shiftedT  = normalize( N*(normalOffset + noise) + anisoDir )
            //
            //  The highlight band is PERPENDICULAR to the strand direction:
            //    TdotL = dot(shiftedT, L)
            //    TdotV = dot(shiftedT, V)
            //    highlight = sinTL * sinTV - TdotL * TdotV   (Kajiya-Kay)
            //              = sqrt(1-TdotL²) * sqrt(1-TdotV²) - TdotL*TdotV
            //
            //  This creates a transverse highlight band: for vertical hair the
            //  band runs HORIZONTALLY, not along the strand direction.
            //
            float3 AnisoHighlight(
                float4 flow,
                float3 N, float3 T, float3 B,
                float3 V, float3 L,             // both V and L required
                float  normalOffset, float noiseOffset,
                float  specIntensity, float specPower,
                float3 specColor)
            {
                // Decode flowmap to [-1,1]
                float4 decoded   = (flow - 0.5) * 2.0;

                // Hair fiber/strand direction in world space
                float3 anisoDir  = normalize(decoded.x * T + decoded.y * B);
                // float3 anisoDir  = normalize(decoded.y * T + decoded.x * B);
                // float3 anisoDir  = normalize(decoded.x * B + decoded.y * T);

                // Shift strand direction along N for per-pixel noise bias
                float  noiseBias = normalOffset + (flow.z - 0.5) * noiseOffset;
                float3 shiftedT  = normalize(N * noiseBias + anisoDir);

                // Kajiya-Kay: highlight band perpendicular to shiftedT
                //   max when both L and V are perpendicular to the fiber (TdotL≈0, TdotV≈0)
                float  TdotL     = dot(shiftedT, L);
                float  TdotV     = dot(shiftedT, V);
                float  sinTL     = sqrt(max(0.0, 1.0 - TdotL * TdotL));
                float  sinTV     = sqrt(max(0.0, 1.0 - TdotV * TdotV));
                float  highlight = max(sinTL * sinTV - TdotL * TdotV, 0.0);

                // Apply power to sharpen/widen the band
                highlight = pow(highlight, specPower);

                return specColor * highlight * specIntensity;
            }

            // ── Fragment ────────────────────────────────────────────────────
            float4 frag(Varyings IN) : SV_Target
            {
                float2 uv = IN.uv;

                // ── Sample textures ──────────────────────────────────────────
                float4 baseColor = SAMPLE_TEXTURE2D(_BaseMap,   sampler_BaseMap,   uv);
                float4 pbrMap    = SAMPLE_TEXTURE2D(_OtherMap1, sampler_OtherMap1, uv);
                float4 normalSample = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uv);
                float4 flowSample   = SAMPLE_TEXTURE2D(_FlowMap,   sampler_FlowMap,   uv);

                // ── Decode normal ────────────────────────────────────────────
                float3 tangentNormal;
                tangentNormal.xy = normalSample.xy * 2.0 - 1.0;
                tangentNormal.z  = sqrt(max(0.0, 1.0 - dot(tangentNormal.xy, tangentNormal.xy)));

                float3 N = normalize(
                    tangentNormal.x * IN.tangentWS
                  + tangentNormal.y * IN.binormalWS
                  + tangentNormal.z * IN.normalWS);

                float3 T = normalize(IN.tangentWS);
                float3 B = normalize(IN.binormalWS);
                float3 V = normalize(GetCameraPositionWS() - IN.positionWS);

                // ── PBR parameters ────────────────────────────────────────────
                //  pbrMap: R=metal  G=sss  B=rough  W=unused(match vbr layout)
                float metallic  = saturate(pbrMap.r + _MetalMulti);
                float roughness = saturate(pbrMap.b + _RoughMulti);

                // ── Main light ───────────────────────────────────────────────
                float4 shadowCoord = TransformWorldToShadowCoord(IN.positionWS);
                Light  mainLight   = GetMainLight(shadowCoord);

                float3 L       = normalize(mainLight.direction);
                float3 H       = normalize(V + L);
                float  NdotL   = saturate(dot(N, L));
                float  NdotV   = saturate(dot(N, V));
                float  NdotH   = saturate(dot(N, H));
                float  VdotH   = saturate(dot(V, H));
                float  NdotL_o = max(dot(N, L), 0.0);  // unclamped for G term

                // ── Fresnel F0 ───────────────────────────────────────────────
                float3 f0 = lerp(float3(0.04, 0.04, 0.04), baseColor.rgb, metallic);

                // ── Standard Specular BxDF (GGX Cook-Torrance) ───────────────
                float3 F   = Aniso_F_Schlick(f0, VdotH);
                float  D   = Aniso_D_GGX(roughness, NdotH);
                float  G   = Aniso_G_Schlick(roughness, NdotV, NdotL_o);
                float3 specStd = F * D * G;

                // ── Diffuse ──────────────────────────────────────────────────
                float3 kD = (1.0 - metallic) * (1.0 - F);
                float3 diffuse = kD * baseColor.rgb * baseColor.rgb * _DiffuseIntensity; // gamma-like square

                // ── Anisotropic highlight (vbr.fx Kajiya-Kay sin-band) ────────
                //  specColor = F0 tinted by base color at grazing angle
                float3 anisoSpecColor = lerp(f0, baseColor.rgb, roughness * 0.5);

                float3 anisoHighlight = AnisoHighlight(
                    flowSample,
                    N, T, B, V, L,          // pass L for proper Kajiya-Kay
                    _NormalOffset,  _NoiseOffset,
                    _AnisoSpecIntensity,  _AnisoSpecPower,
                    anisoSpecColor
                );

                return float4(anisoHighlight, 1);

                // ── Environment reflection (blended N for aniso env sample) ──
                //  newAnisoFactor.z  : how much shiftedN blends into envir dir
                //  newAnisoFactor.w  : view-dot-based attenuation weight
                float4 decoded       = (flowSample - 0.5) * 2.0;
                float3 anisoDir      = normalize(decoded.x * T + decoded.y * B);
                float  noiseBias     = _NormalOffset + (flowSample.z - 0.5) * _NoiseOffset;
                float3 shiftedN      = normalize(N * noiseBias + anisoDir);

                float  viewAtten     = _NewAnisoFactor.z + _NewAnisoFactor.w * NdotV;
                float3 reflDir       = normalize(lerp(reflect(-V, N),
                                                      reflect(-V, shiftedN),
                                                      saturate(viewAtten)));
                // Simple mip-based environment via URP GlossyEnvironmentReflection
                half   perceptualRoughness = sqrt(roughness);
                float3 envColor = GlossyEnvironmentReflection(
                    reflDir,
                    IN.positionWS,
                    perceptualRoughness,
                    /*occlusion=*/ 1.0);

                // EnvBRDF approximation (Lazarov, matches vbr.fx)
                float2 envBRDF     = Aniso_EnvBRDFApprox(roughness, NdotV);
                float3 envSpecular = envColor * (f0 * envBRDF.x + envBRDF.y);

                // ── Combine ──────────────────────────────────────────────────
                float3 radiance    = mainLight.color * mainLight.shadowAttenuation;

                float3 color  = (diffuse + specStd) * NdotL * radiance;
                color        += envSpecular;
                // Kajiya-Kay already contains sinTL (light angle factor),
                // so don't multiply by NdotL again — only apply shadow/light color.
                color        += anisoHighlight * mainLight.shadowAttenuation * mainLight.color;

                return float4(color, baseColor.a);
            }

            ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
