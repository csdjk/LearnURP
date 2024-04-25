Shader "Hidden/GameOldBoy/TAA"
{
    HLSLINCLUDE
        #pragma multi_compile_local_fragment _ _TAA_AntiGhosting
        #pragma multi_compile_local_fragment _ _TAA_UseMotionVector
        #pragma multi_compile_local_fragment _ _TAA_UseBlurSharpenFilter
        #pragma multi_compile_local_fragment _ _TAA_UseBicubicFilter
        #pragma multi_compile_local_fragment _ _TAA_UseClipAABB
        #pragma multi_compile_local_fragment _ _TAA_UseDilation
        #pragma multi_compile_local_fragment _ _TAA_UseTonemap
        #pragma multi_compile_local_fragment _ _TAA_UseVarianceClipping
        #pragma multi_compile_local_fragment _ _TAA_UseYCoCgSpace
        #pragma multi_compile_local_fragment _ _TAA_Use4Tap
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

        float4 _CameraDepthTexture_TexelSize;
        TEXTURE2D_X_FLOAT(_MotionVectorTexture);
        TEXTURE2D_X(_SourceTex);
        float4 _SourceTex_TexelSize;
        TEXTURE2D_X(_TAA_Texture);
        float4 _TAA_Texture_TexelSize;

        float4x4 _TAA_PrevViewProj;
        float2 _TAA_Offset;
        float4 _TAA_Params0;
        #define _TAA_Blend _TAA_Params0.x
        #define _TAA_Gamma _TAA_Params0.y
        #define _TAA_Sharp _TAA_Params0.z
        #define _TAA_PrevSharp _TAA_Params0.w

        struct VaryingsTAA
        {
            float4 positionCS    : SV_POSITION;
            float4 uv            : TEXCOORD0;
            UNITY_VERTEX_OUTPUT_STEREO
        };

        VaryingsTAA VertTAA(Attributes input)
        {
            VaryingsTAA output;
            UNITY_SETUP_INSTANCE_ID(input);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

            output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
            output.uv.xy = input.uv;

            float4 projPos = output.positionCS * 0.5;
            projPos.xy = projPos.xy + projPos.w;
            output.uv.zw = projPos.xy;

            return output;
        }

    #if _TAA_AntiGhosting
        float3 clip_color(float3 min_color, float3 max_color, float3 color)
        {
        #if _TAA_UseClipAABB
            float3 p_clip = 0.5 * (max_color + min_color);
            float3 e_clip = 0.5 * (max_color - min_color) + FLT_EPS;

            float3 v_clip = color - p_clip;
            float3 v_unit = v_clip / e_clip;
            float3 a_unit = abs(v_unit);
            float ma_unit = max(a_unit.x, max(a_unit.y, a_unit.z));

            if (ma_unit > 1.0)
                return p_clip + v_clip / ma_unit;
            else
                return color;
        #else
            return clamp(color, min_color, max_color);
        #endif
        }

        void minmax(float3 samples[9], out float3 min_color, out float3 max_color)
        {
            float3 color[9];
        #if _TAA_UseYCoCgSpace
            color[0] = RGBToYCoCg(samples[0]);
            color[1] = RGBToYCoCg(samples[1]);
            color[2] = RGBToYCoCg(samples[2]);
            color[3] = RGBToYCoCg(samples[3]);
            color[4] = RGBToYCoCg(samples[4]);
            color[5] = RGBToYCoCg(samples[5]);
            color[6] = RGBToYCoCg(samples[6]);
            color[7] = RGBToYCoCg(samples[7]);
            color[8] = RGBToYCoCg(samples[8]);
        #else
            color[0] = samples[0];
            color[1] = samples[1];
            color[2] = samples[2];
            color[3] = samples[3];
            color[4] = samples[4];
            color[5] = samples[5];
            color[6] = samples[6];
            color[7] = samples[7];
            color[8] = samples[8];
        #endif
        #if _TAA_UseVarianceClipping
            float3 m1 = color[0] + color[1] + color[2]
                      + color[3] + color[4] + color[5]
                      + color[6] + color[7] + color[8];
            float3 m2 = color[0] * color[0] + color[1] * color[1] + color[2] * color[2]
                      + color[3] * color[3] + color[4] * color[4] + color[5] * color[5]
                      + color[6] * color[6] + color[7] * color[7] + color[8] * color[8];
            float3 mu = m1 / 9;
            float3 sigma = sqrt(abs(m2 / 9 - mu * mu));
            min_color = mu - _TAA_Gamma * sigma;
            max_color = mu + _TAA_Gamma * sigma;
        #else
            min_color = min(color[0], min(color[1], min(color[2], min(color[3], min(color[4], min(color[5], min(color[6], min(color[7], color[8]))))))));
            max_color = max(color[0], max(color[1], max(color[2], max(color[3], max(color[4], max(color[5], max(color[6], max(color[7], color[8]))))))));
            float3 min_color5 = min(color[1], min(color[3], min(color[4], min(color[5], color[7]))));
			float3 max_color5 = max(color[1], max(color[3], max(color[4], max(color[5], color[7]))));
            min_color = 0.5 * (min_color + min_color5);
            max_color = 0.5 * (max_color + max_color5);
        #endif
        }

        void minmax_4tap(float2 uv, float2 mv, float depth, out float3 min_color, out float3 max_color)
        {
            const float _SubpixelThreshold = 0.5;
            const float _GatherBase = 0.5;
            const float _GatherSubpixelMotion = 0.1666;

            float2 texel_vel = mv / _SourceTex_TexelSize.xy;
            float texel_vel_mag = length(texel_vel) * depth;
            float k_subpixel_motion = saturate(_SubpixelThreshold / (FLT_EPS + texel_vel_mag));
            float k_min_max_support = _GatherBase + _GatherSubpixelMotion * k_subpixel_motion;

            float2 ss_offset01 = k_min_max_support * float2(-_SourceTex_TexelSize.x, _SourceTex_TexelSize.y);
            float2 ss_offset11 = k_min_max_support * float2(_SourceTex_TexelSize.x, _SourceTex_TexelSize.y);
            float3 c00 = SAMPLE_TEXTURE2D_X(_SourceTex,sampler_LinearClamp, uv - ss_offset11).rgb;
            float3 c10 = SAMPLE_TEXTURE2D_X(_SourceTex,sampler_LinearClamp, uv - ss_offset01).rgb;
            float3 c01 = SAMPLE_TEXTURE2D_X(_SourceTex,sampler_LinearClamp, uv + ss_offset01).rgb;
            float3 c11 = SAMPLE_TEXTURE2D_X(_SourceTex,sampler_LinearClamp, uv + ss_offset11).rgb;
        #if _TAA_UseYCoCgSpace
            c00 = RGBToYCoCg(c00);
            c10 = RGBToYCoCg(c10);
            c01 = RGBToYCoCg(c01);
            c11 = RGBToYCoCg(c11);
        #endif

            min_color = min(c00, min(c10, min(c01, c11)));
            max_color = max(c00, max(c10, max(c01, c11)));
        }
    #endif

        float3 filter(float3 _sample)
        {
            return _sample;
        }

        float3 filter(float3 samples[9])
        {
        #if _TAA_UseBlurSharpenFilter
            const float k_blur0 = 0.6915221;
            const float k_blur1 = 0.07002799;
            const float k_blur2 = 0.007091487;
            float3 blur_color = (samples[0] + samples[2] + samples[6] + samples[8]) * k_blur2 +
                                (samples[1] + samples[3] + samples[5] + samples[7]) * k_blur1 +
                                 samples[4] * k_blur0;
            float3 avg_color = (samples[0] + samples[1] + samples[2]
                              + samples[3] + samples[4] + samples[5]
                              + samples[6] + samples[7] + samples[8]) / 9;
            float3 sharp_color = blur_color + (blur_color - avg_color) * _TAA_Sharp * 3;
            return clamp(sharp_color, 0, 65472.0);
        #else
            return samples[4];
        #endif
        }

        void get_samples(float2 uv, out float3 _sample)
        {
            _sample = SAMPLE_TEXTURE2D_X(_SourceTex, sampler_PointClamp, uv).rgb;
        }

        void get_samples(float2 uv, out float3 samples[9])
        {
            samples[0] = SAMPLE_TEXTURE2D_X(_SourceTex, sampler_PointClamp, uv + _SourceTex_TexelSize.xy * float2(-1, -1)).rgb;
            samples[1] = SAMPLE_TEXTURE2D_X(_SourceTex, sampler_PointClamp, uv + _SourceTex_TexelSize.xy * float2( 0, -1)).rgb;
            samples[2] = SAMPLE_TEXTURE2D_X(_SourceTex, sampler_PointClamp, uv + _SourceTex_TexelSize.xy * float2( 1, -1)).rgb;
            samples[3] = SAMPLE_TEXTURE2D_X(_SourceTex, sampler_PointClamp, uv + _SourceTex_TexelSize.xy * float2(-1,  0)).rgb;
            get_samples(uv, samples[4]);
            samples[5] = SAMPLE_TEXTURE2D_X(_SourceTex, sampler_PointClamp, uv + _SourceTex_TexelSize.xy * float2( 1,  0)).rgb;
            samples[6] = SAMPLE_TEXTURE2D_X(_SourceTex, sampler_PointClamp, uv + _SourceTex_TexelSize.xy * float2(-1,  1)).rgb;
            samples[7] = SAMPLE_TEXTURE2D_X(_SourceTex, sampler_PointClamp, uv + _SourceTex_TexelSize.xy * float2( 0,  1)).rgb;
            samples[8] = SAMPLE_TEXTURE2D_X(_SourceTex, sampler_PointClamp, uv + _SourceTex_TexelSize.xy * float2( 1,  1)).rgb;
        }

        float3 sample_taa_tex(float2 uv)
        {
        #if _TAA_UseBicubicFilter
            float2 samplePos = uv * _TAA_Texture_TexelSize.zw;
            float2 tc1 = floor(samplePos - 0.5) + 0.5;
            float2 f = samplePos - tc1;
            float2 f2 = f * f;
            float2 f3 = f * f2;

            const float c = _TAA_PrevSharp;

            float2 w0 = -c         * f3 +  2.0 * c         * f2 - c * f;
            float2 w1 =  (2.0 - c) * f3 - (3.0 - c)        * f2          + 1.0;
            float2 w2 = -(2.0 - c) * f3 + (3.0 - 2.0 * c)  * f2 + c * f;
            float2 w3 = c          * f3 - c                * f2;

            float2 w12 = w1 + w2;
            float2 tc0 = _TAA_Texture_TexelSize.xy * (tc1 - 1.0);
            float2 tc3 = _TAA_Texture_TexelSize.xy * (tc1 + 2.0);
            float2 tc12 = _TAA_Texture_TexelSize.xy  * (tc1 + w2 / w12);

            float3 s0 = SAMPLE_TEXTURE2D_X(_TAA_Texture, sampler_LinearClamp, float2(tc12.x, tc0.y)).rgb;
            float3 s1 = SAMPLE_TEXTURE2D_X(_TAA_Texture, sampler_LinearClamp, float2(tc0.x, tc12.y)).rgb;
            float3 s2 = SAMPLE_TEXTURE2D_X(_TAA_Texture, sampler_LinearClamp, float2(tc12.x, tc12.y)).rgb;
            float3 s3 = SAMPLE_TEXTURE2D_X(_TAA_Texture, sampler_LinearClamp, float2(tc3.x, tc0.y)).rgb;
            float3 s4 = SAMPLE_TEXTURE2D_X(_TAA_Texture, sampler_LinearClamp, float2(tc12.x, tc3.y)).rgb;

            float cw0 = (w12.x * w0.y);
            float cw1 = (w0.x * w12.y);
            float cw2 = (w12.x * w12.y);
            float cw3 = (w3.x * w12.y);
            float cw4 = (w12.x *  w3.y);

            float3 min_color = min(s0, min(s1, s2));
            min_color = min(min_color, min(s3, s4));

            float3 max_color = max(s0, max(s1, s2));
            max_color = max(max_color, max(s3, s4));

            s0 *= cw0;
            s1 *= cw1;
            s2 *= cw2;
            s3 *= cw3;
            s4 *= cw4;

            float3 historyFiltered = s0 + s1 + s2 + s3 + s4;
            float weightSum = cw0 + cw1 + cw2 + cw3 + cw4;

            float3 filteredVal = historyFiltered * rcp(weightSum);

            return clamp(filteredVal, min_color, max_color);
        #else
            return SAMPLE_TEXTURE2D_X(_TAA_Texture, sampler_LinearClamp, uv).rgb;
        #endif
        }

        float3 ReinhardToneMap(float3 c)
        {
            return c * rcp(Luminance(c) + 1.0);
        }

        float3 InverseReinhardToneMap(float3 c)
        {
            return c * rcp(1.0 - Luminance(c));
        }

    #if UNITY_REVERSED_Z
    #define ZCMP_GT(a, b) (a < b)
    #else
    #define ZCMP_GT(a, b) (a > b)
    #endif

        float2 find_closest_uv(float depth, float2 uv)
        {
            float2 dd = _CameraDepthTexture_TexelSize.xy;
            float2 du = float2(dd.x, 0.0);
            float2 dv = float2(0.0, dd.y);

            float3 dtl = float3(-1, -1, SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_PointClamp, uv - dv - du).r);
            float3 dtc = float3( 0, -1, SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_PointClamp, uv - dv).r);
            float3 dtr = float3( 1, -1, SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_PointClamp, uv - dv + du).r);

            float3 dml = float3(-1, 0, SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_PointClamp, uv - du).r);
            float3 dmc = float3( 0, 0, depth);
            float3 dmr = float3( 1, 0, SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_PointClamp, uv + du).r);

            float3 dbl = float3(-1, 1, SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_PointClamp, uv + dv - du).r);
            float3 dbc = float3( 0, 1, SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_PointClamp, uv + dv).r);
            float3 dbr = float3( 1, 1, SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_PointClamp, uv + dv + du).r);

            float3 dmin = dtl;
            if (ZCMP_GT(dmin.z, dtc.z)) dmin = dtc;
            if (ZCMP_GT(dmin.z, dtr.z)) dmin = dtr;

            if (ZCMP_GT(dmin.z, dml.z)) dmin = dml;
            if (ZCMP_GT(dmin.z, dmc.z)) dmin = dmc;
            if (ZCMP_GT(dmin.z, dmr.z)) dmin = dmr;

            if (ZCMP_GT(dmin.z, dbl.z)) dmin = dbl;
            if (ZCMP_GT(dmin.z, dbc.z)) dmin = dbc;
            if (ZCMP_GT(dmin.z, dbr.z)) dmin = dbr;

            return uv + dd.xy * dmin.xy;
        }

        float2 reprojection(float depth, float2 uv)
        {
        #if UNITY_REVERSED_Z
            depth = 1.0 - depth;
        #endif

            depth = 2.0 * depth - 1.0;

            float3 viewPos = ComputeViewSpacePosition(uv, depth, unity_CameraInvProjection);
            float4 worldPos = float4(mul(unity_CameraToWorld, float4(viewPos, 1.0)).xyz, 1.0);

            float4 prevClipPos = mul(_TAA_PrevViewProj, worldPos);
            float2 prevPosCS = prevClipPos.xy / prevClipPos.w;
            return prevPosCS * 0.5 + 0.5;
        }

        float4 Frag(VaryingsTAA input) : SV_Target
        {
            UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
            float2 uv = UnityStereoTransformScreenSpaceTex(input.uv.xy);
            float depth = SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_PointClamp, uv).r;
        #if _TAA_UseMotionVector
        #if _TAA_UseDilation
            float2 mv = SAMPLE_TEXTURE2D_X(_MotionVectorTexture, sampler_LinearClamp, find_closest_uv(depth, uv)).rg;
        #else
            float2 mv = SAMPLE_TEXTURE2D_X(_MotionVectorTexture, sampler_LinearClamp, uv).rg;
        #endif
            float2 prev_uv = uv - mv - _TAA_Offset;
            mv = uv - prev_uv;
        #else
            float2 prev_uv = reprojection(depth, input.uv.zw);
            float2 mv = uv - prev_uv;
        #endif
        #if _TAA_Use4Tap
            float3 samples;
        #else
            float3 samples[9];
        #endif
            get_samples(uv, samples);
            if (prev_uv.x > 1.0 || prev_uv.y > 1.0 || prev_uv.x < 0.0 || prev_uv.y < 0.0)
            {
                return float4(max(float3(0.0, 0.0, 0.0), filter(samples)), 1.0);
            }
            float3 prev_color = sample_taa_tex(prev_uv);
        #if _TAA_AntiGhosting
            float3 min_color, max_color;
        #if _TAA_Use4Tap
            minmax_4tap(uv, mv, depth, min_color, max_color);
        #else
            minmax(samples, min_color, max_color);
        #endif
        #if _TAA_UseYCoCgSpace
            prev_color = YCoCgToRGB(clip_color(min_color, max_color, RGBToYCoCg(prev_color)));
        #else
            prev_color = clip_color(min_color, max_color, prev_color);
        #endif
        #endif
        float final_blend = lerp(_TAA_Blend, 0.2, saturate(length(mv) * 20.0));
        #if _TAA_UseTonemap
            float3 color = ReinhardToneMap(filter(samples));
            prev_color = ReinhardToneMap(prev_color);
            float3 final_color = InverseReinhardToneMap(lerp(color, prev_color, final_blend));
        #else
            float3 color = filter(samples);
            float3 final_color = lerp(color, prev_color, final_blend);
        #endif
            return float4(max(float3(0.0, 0.0, 0.0), final_color), 1.0);
        }

        Varyings VertBlit(Attributes input)
        {
            Varyings output;
            UNITY_SETUP_INSTANCE_ID(input);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

            output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
            output.uv = input.uv;

            return output;
        }

        half4 FragBlit(Varyings input) : SV_Target
        {
            UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
            float2 uv = UnityStereoTransformScreenSpaceTex(input.uv);
            return half4(SAMPLE_TEXTURE2D_X(_SourceTex, sampler_PointClamp, uv).rgb, 1.0);
        }

    ENDHLSL

    SubShader
    {
        Tags{ "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
            LOD 100
            ZTest Always ZWrite Off Cull Off

        Pass // Index 0
        {
            Name "TAA"

            HLSLPROGRAM
                #pragma vertex VertTAA
                #pragma fragment Frag
            ENDHLSL
        }

        Pass // Index 1
        {
            Name "Blit"

            HLSLPROGRAM
                #pragma vertex VertBlit
                #pragma fragment FragBlit
            ENDHLSL
        }
    }
}
