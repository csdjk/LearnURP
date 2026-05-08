Shader "Custom/AnisotropicSpecular_KK"
{
    Properties
    {
        [Header(Anisotropic Specular)]
        _FlowMap ("Flow Map (RG=Direction)", 2D) = "gray" { }
        _NoiseMap ("Noise Map", 2D) = "black" { }
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        _RoughnessT ("Roughness T (Primary Band)", Range(0.01, 1)) = 0.1
        _AnisoRot ("Anisotropic Rotation", Range(0, 1)) = 0.3
        _FlowMapScale ("FlowMap Intensity", Range(0, 1)) = 1.0
        _NormalOffset ("Normal Offset  (整体偏移)", Range(-5, 5)) = -0.2
        _NoiseOffset ("Noise Offset   (抖动偏移)", Range(0, 1)) = 0.2
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry" }

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex   vert
            #pragma fragment frag
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile_fog

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            // ── CBUFFER ────────────────────────────────────────────────────
            CBUFFER_START(UnityPerMaterial)
                float4 _NoiseMap_ST;
                float4 _SpecularColor;
                float _RoughnessT;
                float _RoughnessB;
                float _FlowMapScale;
                float _NormalOffset;
                float _NoiseOffset;
                float _AnisoRot;
            CBUFFER_END

            TEXTURE2D(_FlowMap); SAMPLER(sampler_FlowMap);
            TEXTURE2D(_NoiseMap); SAMPLER(sampler_NoiseMap);

            // ── Structs ────────────────────────────────────────────────────
            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                float3 tangentWS : TEXCOORD3;
                float3 binormalWS : TEXCOORD4;
                float fogFactor : TEXCOORD5;
            };

            // ── Vertex ─────────────────────────────────────────────────────
            Varyings vert(Attributes input)
            {
                Varyings o;
                VertexPositionInputs posInputs = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs   nrmInputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);

                o.positionCS = posInputs.positionCS;
                o.positionWS = posInputs.positionWS;
                o.normalWS = nrmInputs.normalWS;
                o.tangentWS = nrmInputs.tangentWS;
                o.binormalWS = nrmInputs.bitangentWS;
                o.uv = TRANSFORM_TEX(input.uv, _NoiseMap);
                o.fogFactor = ComputeFogFactor(posInputs.positionCS.z);
                return o;
            }

            // ── Scheuermann StrandSpecular ─────────────────────────────────
            //   H      = normalize(V + L)
            //   HdotT  = dot(T, H)
            //   sinTH  = sqrt(1 - HdotT²)          ← sin of angle(T, H)
            //   band   = smoothstep(-1,0,HdotT) * pow(sinTH, 1/roughness²)
            //
            //   The highlight band is PERPENDICULAR to T:
            //   for vertical hair T, the band runs horizontally.
            float StrandSpecular(float3 T, float3 V, float3 L, float roughness)
            {
                float3 H = normalize(V + L);
                float HdotT = dot(T, H);
                float sinTH = sqrt(max(0.0, 1.0 - HdotT * HdotT));
                float dirAtten = smoothstep(-1.0, 0.0, HdotT);  // 消除背面漏光
                float power = max(1.0, 1.0 / (roughness * roughness));
                return dirAtten * pow(sinTH, power);
            }

            // ── Fragment ───────────────────────────────────────────────────
            half4 frag(Varyings i) : SV_Target
            {
                // ── 基础向量 ──────────────────────────────────────────────
                float3 N = normalize(i.normalWS);
                float3 T = normalize(i.tangentWS);
                float3 B = normalize(i.binormalWS);
                float3 V = normalize(GetWorldSpaceViewDir(i.positionWS));

                // ── FlowMap → 切线空间方向 → 世界空间 ─────────────────────
                float4 flow = SAMPLE_TEXTURE2D(_FlowMap, sampler_FlowMap, i.uv);
                float noise = SAMPLE_TEXTURE2D(_NoiseMap, sampler_NoiseMap, i.uv).r;
                

                float4 decoded = flow * 2.0 - 1.0;
                float3 anisoDir = normalize(decoded.x * T + decoded.y * B);

                float shiftNoise = (noise * 2 - 1) * _NoiseOffset;
                half3 T1 = ShiftTangent(anisoDir, N, _NormalOffset +shiftNoise);

                // ── 主光源 ─────────────────────────────────────────────────
                Light  mainLight = GetMainLight(TransformWorldToShadowCoord(i.positionWS));
                float3 L = normalize(mainLight.direction);
                float shadow = mainLight.shadowAttenuation;

                // ── StrandSpecular ────────────────────────────────────
                float s1 = StrandSpecular(T1, V, L, _RoughnessT);

                // 合并两层，副层强度减半避免过亮
                float3 specular = s1;

                // ── 纯高光输出 ─────────────────────────────────────────────
                return half4(specular, 1.0);
            }
            ENDHLSL
        }
    }
}