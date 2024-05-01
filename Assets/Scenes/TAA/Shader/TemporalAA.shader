Shader "Hidden/LcL/TemporalAA"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
    }

    HLSLINCLUDE
    // #pragma multi_compile _ _USE_DRAW_PROCEDURAL
    #pragma multi_compile_local_fragment _ _TAA_MotionVector
    #pragma multi_compile_local_fragment _ _TAA_ClipAABB
    #pragma multi_compile_local_fragment _ _TAA_YCOCG
    // #pragma multi_compile_local_fragment _ _TAA_Nudge
    #pragma multi_compile_local_fragment _ _TAA_FindClosest
    #pragma multi_compile_local_fragment _ _TAA_Tonemap
    #pragma multi_compile_local_fragment _ _TAA_Anti_Ghosting

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
    #include "Assets/Shaders/Libraries/Node.hlsl"

    float4 _CameraDepthTexture_TexelSize;
    float4 _MainTex_TexelSize;

    TEXTURE2D(_MainTex);
    TEXTURE2D(_HistoryTexture);
    TEXTURE2D_FLOAT(_MotionVectorTexture);

    float4x4 _FrustumCornersRay;
    float4x4 _PrevViewProj;

    float _Sharpness;
    float4 _Params;
    #define _Offset _Params.xy
    #define _Blend _Params.z

    struct DefaultVaryings
    {
        float4 positionCS : SV_POSITION;
        float2 uv : TEXCOORD0;
        float3 ray : TEXCOORD1;
        UNITY_VERTEX_OUTPUT_STEREO
    };

    DefaultVaryings Vertex(Attributes input)
    {
        DefaultVaryings output;
        UNITY_SETUP_INSTANCE_ID(input);

        output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
        output.uv = input.uv;

        #if !defined(_TAA_MotionVector)
        output.ray = CalculateViewRay(input.uv, _FrustumCornersRay);
        #endif
        return output;
    }

    //重投影
    inline float2 Reprojection(float2 uv, float3 ray, float depth)
    {
        float3 worldPos = ReconstructPositionWS(uv, ray, depth);
        float4 prevClipPos = mul(_PrevViewProj, float4(worldPos, 1.0));
        float2 prevPosCS = prevClipPos.xy / prevClipPos.w;
        return prevPosCS * 0.5 + 0.5;
    }

    //https://github.com/Unity-Technologies/Graphics/blob/c8df1d81db96da3d951b102d792852e6712a1a10/com.unity.postprocessing/PostProcessing/Shaders/Builtins/TemporalAntialiasing.shader#L29
    // float2 GetClosestFragment(float2 uv, float depth)
    // {
    //     #if !defined(_TAA_FindClosest)
    //         return uv;
    //     #endif

    //     const float2 k = _CameraDepthTexture_TexelSize.xy;

    //     const float4 neighborhood = float4(
    //         SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_PointClamp, uv - k),
    //         SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_PointClamp, uv + float2(k.x, -k.y)),
    //         SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_PointClamp, uv + float2(-k.x, k.y)),
    //         SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_PointClamp, uv + k)
    //     );
    //     #if defined(UNITY_REVERSED_Z)
    //         #define COMPARE_DEPTH(a, b) step(b, a)
    //     #else
    //         #define COMPARE_DEPTH(a, b) step(a, b)
    //     #endif
    //     float3 result = float3(0.0, 0.0, depth);
    //     result = lerp(result, float3(-1.0, -1.0, neighborhood.x), COMPARE_DEPTH(neighborhood.x, result.z));
    //     result = lerp(result, float3(1.0, -1.0, neighborhood.y), COMPARE_DEPTH(neighborhood.y, result.z));
    //     result = lerp(result, float3(-1.0, 1.0, neighborhood.z), COMPARE_DEPTH(neighborhood.z, result.z));
    //     result = lerp(result, float3(1.0, 1.0, neighborhood.w), COMPARE_DEPTH(neighborhood.w, result.z));


    //     return (uv + result.xy * k);
    // }

    // ================================ 找到最近点 ================================
    float2 GetClosestFragment(float2 uv, float depth)
    {
        #if !defined(_TAA_FindClosest)
        return uv;
        #endif

        const float2 k = _CameraDepthTexture_TexelSize.xy;

        float3 dtl = float3(-1, -1, SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_PointClamp, uv - k));
        float3 dtc = float3(0, -1, SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_PointClamp, uv + float2(k.x, -k.y)));
        float3 dtr = float3(1, -1, SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_PointClamp, uv + float2(-k.x, k.y)));
        float3 dml = float3(-1, 0, SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_PointClamp, uv + k));
        float3 dmc = float3(0, 0, depth);

        #if UNITY_REVERSED_Z
        #define ZCMP_GT(a, b) (a < b)
        #else
            #define ZCMP_GT(a, b) (a > b)
        #endif

        float3 dmin = dtl;
        if (ZCMP_GT(dmin.z, dtc.z)) dmin = dtc;
        if (ZCMP_GT(dmin.z, dtr.z)) dmin = dtr;
        if (ZCMP_GT(dmin.z, dml.z)) dmin = dml;
        if (ZCMP_GT(dmin.z, dmc.z)) dmin = dmc;

        return (uv + dmin.xy * k);
    }


    float2 GetClosestFragmentHigh(float depth, float2 uv)
    {
        #if UNITY_REVERSED_Z
        #define ZCMP_GT(a, b) (a < b)
        #else
            #define ZCMP_GT(a, b) (a > b)
        #endif

        float2 dd = _CameraDepthTexture_TexelSize.xy;
        float2 du = float2(dd.x, 0.0);
        float2 dv = float2(0.0, dd.y);

        float3 dtl = float3(-1, -1, SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_PointClamp, uv - dv - du).r);
        float3 dtc = float3(0, -1, SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_PointClamp, uv - dv).r);
        float3 dtr = float3(1, -1, SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_PointClamp, uv - dv + du).r);

        float3 dml = float3(-1, 0, SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_PointClamp, uv - du).r);
        float3 dmc = float3(0, 0, depth);
        float3 dmr = float3(1, 0, SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_PointClamp, uv + du).r);

        float3 dbl = float3(-1, 1, SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_PointClamp, uv + dv - du).r);
        float3 dbc = float3(0, 1, SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_PointClamp, uv + dv).r);
        float3 dbr = float3(1, 1, SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_PointClamp, uv + dv + du).r);

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


    // void GetMinMaxColor(float4 color, float2 uv, out float4 minimum, out float4 maximum)
    // {
    //     const float2 k = _MainTex_TexelSize.xy;
    //     float4 c00 = SAMPLE_DEPTH_TEXTURE(_MainTex, sampler_PointClamp, uv - k);
    //     float4 c10 = SAMPLE_DEPTH_TEXTURE(_MainTex, sampler_PointClamp, uv + float2(k.x, -k.y));
    //     float4 c01 = SAMPLE_DEPTH_TEXTURE(_MainTex, sampler_PointClamp, uv + float2(-k.x, k.y));
    //     float4 c11 = SAMPLE_DEPTH_TEXTURE(_MainTex, sampler_PointClamp, uv + k);
    //     minimum = min(color, min(c00, min(c10, min(c01, c11))));
    //     maximum = max(color, max(c00, max(c10, max(c01, c11))));
    // }

    void GetMinMaxColorHigh(float depth, float2 uv, float motionLength, out float3 minimum, out float3 maximum)
    {
        const float2 k = _MainTex_TexelSize.xy;

        const float _SubpixelThreshold = 0.5;
        const float _GatherBase = 0.5;
        const float _GatherSubpixelMotion = 0.1666;

        float2 texel_vel = motionLength / k;
        float texel_vel_mag = length(texel_vel) * depth;
        float k_subpixel_motion = saturate(_SubpixelThreshold / (FLT_EPS + texel_vel_mag));
        float k_min_max_support = _GatherBase + _GatherSubpixelMotion * k_subpixel_motion;

        float2 ss_offset01 = k_min_max_support * float2(-k.x, k.y);
        float2 ss_offset11 = k_min_max_support * float2(k.x, k.y);
        float3 c00 = SAMPLE_TEXTURE2D_X(_MainTex, sampler_LinearClamp, uv - ss_offset11);
        float3 c10 = SAMPLE_TEXTURE2D_X(_MainTex, sampler_LinearClamp, uv - ss_offset01);
        float3 c01 = SAMPLE_TEXTURE2D_X(_MainTex, sampler_LinearClamp, uv + ss_offset01);
        float3 c11 = SAMPLE_TEXTURE2D_X(_MainTex, sampler_LinearClamp, uv + ss_offset11);
        #ifdef _TAA_YCOCG
            c00 = RGBToYCoCg(c00);
            c10 = RGBToYCoCg(c10);
            c01 = RGBToYCoCg(c01);
            c11 = RGBToYCoCg(c11);
        #endif

        minimum = min(c00, min(c10, min(c01, c11)));
        maximum = max(c00, max(c10, max(c01, c11)));
    }

    void GetMinMaxColor(float4 color, float2 uv, float motionLength, out float4 minimum, out float4 maximum)
    {
        const float2 k = _MainTex_TexelSize.xy;

        float4 topLeft = SAMPLE_TEXTURE2D(_MainTex, sampler_PointClamp, (uv - k * 0.5));
        float4 bottomRight = SAMPLE_TEXTURE2D(_MainTex, sampler_PointClamp, (uv + k * 0.5));

        #ifdef _TAA_YCOCG
            topLeft.rgb = RGBToYCoCg(topLeft.rgb);
            bottomRight.rgb = RGBToYCoCg(bottomRight.rgb);
        #endif

        // nudge 的作用是用于微调最小值和最大值。它的值是基于运动长度和亮度差的，运动长度越大或亮度差越大，"nudge" 的值就越大。
        // 这样做的目的是在颜色变化较大或运动较快的情况下，增大颜色的最小值和最大值的范围，从而减少抖动和闪烁
        #ifdef _TAA_Nudge
            float4 corners = 4.0 * (topLeft + bottomRight) - 2.0 * color;
            float4 average = (corners + color) * 0.142857;
            float2 luma = float2(Luminance(average), Luminance(color));
            //float nudge = 4.0 * abs(luma.x - luma.y);
            float nudge = lerp(4.0, 0.25, saturate(motionLength * 100.0)) * abs(luma.x - luma.y);

            minimum = min(bottomRight, topLeft) - nudge;
            maximum = max(topLeft, bottomRight) + nudge;
        #else
        minimum = min(bottomRight, topLeft);
        maximum = max(topLeft, bottomRight);
        #endif
    }

    // half3 ClipToAABB(half3 history, half3 minimum, half3 maximum)
    // {
    //     // note: only clips towards aabb center (but fast!)
    //     half3 center  = 0.5 * (maximum + minimum);
    //     half3 extents = 0.5 * (maximum - minimum);
    //
    //     // This is actually `distance`, however the keyword is reserved
    //     half3 offset = history - center;
    //     half3 v_unit = offset.xyz / extents.xyz;
    //     half3 absUnit = abs(v_unit);
    //     half maxUnit = Max3(absUnit.x, absUnit.y, absUnit.z);
    //     if (maxUnit > 1.0)
    //         return center + (offset / maxUnit);
    //     else
    //         return history;
    // }
    inline float3 ClipToAABB(float3 color, float3 minimum, float3 maximum)
    {
        // Note: only clips towards aabb center (but fast!)
        float3 center = 0.5 * (maximum + minimum);
        float3 extents = 0.5 * (maximum - minimum);

        // This is actually `distance`, however the keyword is reserved
        float3 offset = color - center;

        float3 ts = abs(extents / (offset + 0.0001));
        float t = saturate(Min3(ts.x, ts.y, ts.z));
        color = center + offset * t;
        return color;
    }


    inline float3 ClipColor(float3 color, float3 minimum, float3 maximum)
    {
        #ifdef _ClipAABB
            return ClipToAABB(color, minimum, maximum);
        #else
        return clamp(color, minimum, maximum);
        #endif
    }

    // #pragma enable_d3d11_debug_symbols
    //获取当前像素的运动向量和上一帧的uv
    inline void GetPrevUV(DefaultVaryings input, float depth, out float2 motion, out float2 prev_uv)
    {
        float2 uv = input.uv;
        #ifdef _TAA_MotionVector
            float2 closest = GetClosestFragment(uv, depth);
            motion = SAMPLE_TEXTURE2D(_MotionVectorTexture, sampler_LinearClamp, closest).rg;
            prev_uv = uv - motion - _Offset;
            motion = uv - prev_uv;
        #else
        prev_uv = Reprojection(input.uv, input.ray, depth);
        motion = uv - prev_uv;
        #endif
    }

    inline float3 ReinhardToneMap(float3 c)
    {
        return c * rcp(Luminance(c) + 1.0);
    }

    inline float3 InverseReinhardToneMap(float3 c)
    {
        return c * rcp(1.0 - Luminance(c));
    }

    half4 Fragment(DefaultVaryings input) : SV_Target
    {
        float2 uv = input.uv;
        float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, uv);
        float depth = SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_PointClamp, uv).r;

        float2 motion, prev_uv;
        GetPrevUV(input, depth, motion, prev_uv);

        if (prev_uv.x > 1.0 || prev_uv.y > 1.0 || prev_uv.x < 0.0 || prev_uv.y < 0.0)
        {
            return float4(max(float3(0.0, 0.0, 0.0), color), 1.0);
        }

        float4 historyColor = SAMPLE_TEXTURE2D(_HistoryTexture, sampler_LinearClamp, prev_uv);
        float motionLength = length(motion);


        // #if defined(_TAA_Tonemap)
        //     color.rgb = ReinhardToneMap(color.rgb);
        //     historyColor.rgb = ReinhardToneMap(historyColor.rgb);
        // #endif
        #ifdef _TAA_YCOCG
            color.rgb = RGBToYCoCg(color.rgb);
            historyColor.rgb = RGBToYCoCg(historyColor.rgb);
        #endif

        #ifdef _TAA_Anti_Ghosting
            float3 minimum, maximum;
            // GetMinMaxColor(color, uv, minimum, maximum);
            GetMinMaxColorHigh(depth, uv, motionLength, minimum, maximum);
            // Clip history color to the AABB of the current color
            historyColor.rgb = ClipColor(historyColor.rgb, minimum, maximum);
        #endif

        //根据运动距离调整混合系数,距离越大,就越接近当前帧
        float blend = lerp(_Blend, 0.2, saturate(motionLength * 20.0));
        color = lerp(color, historyColor, blend);

        // #if defined(_TAA_Tonemap)
        //     color.rgb = InverseReinhardToneMap(color.rgb);
        // #endif

        #ifdef _TAA_YCOCG
            color.rgb = YCoCgToRGB(color.rgb);
        #endif

        return color;
    }
    ENDHLSL

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"
        }
        LOD 100
        ZTest Always ZWrite Off Cull Off

        Pass
        {
            Name ""

            HLSLPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment
            ENDHLSL
        }
    }
}
