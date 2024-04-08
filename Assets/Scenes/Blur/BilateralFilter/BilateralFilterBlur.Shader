Shader "Hidden/LcLPostProcess/BilateralFilterBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
    }

    HLSLINCLUDE
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

    TEXTURE2D(_MainTex);
    SAMPLER(sampler_LinearClamp);

    float4 _MainTex_TexelSize;
    float4 _Offset;
    float _BilateralFilterFactor;


    struct DefaultVertexInput
    {
        float4 positionOS : POSITION;
        float2 uv : TEXCOORD0;
    };
    struct DefaultVaryings
    {
        float4 positionCS : SV_POSITION;
        float2 uv : TEXCOORD0;
        float4 uv01 : TEXCOORD1;
        float4 uv23 : TEXCOORD2;
    };

    DefaultVaryings Vertex(DefaultVertexInput input)
    {
        DefaultVaryings ouput;
        ouput.positionCS = TransformWorldToHClip(input.positionOS);
        float2 uv = input.uv;
        ouput.uv = uv;

        float4 offset = _Offset * _MainTex_TexelSize.xyxy;
        ouput.uv01 = uv.xyxy + offset.xyxy * float4(1, 1, -1, -1);
        ouput.uv23 = uv.xyxy + offset.xyxy * float4(1, 1, -1, -1) * 2.0;
        return ouput;
    }

    // ================================ 基于Color的双边滤波 ================================

    //根据颜色差值计算权重
    half CompareColor(half4 col1, half4 col2)
    {
        float l1 = Luminance(col1.rgb);
        float l2 = Luminance(col2.rgb);
        float colorDiff = abs(l1 - l2);
        return smoothstep(_BilateralFilterFactor, 1.0, 1.0 - colorDiff);
    }
    half4 FragmentBaseColor(DefaultVaryings i) : SV_Target
    {
        float2 delta = _MainTex_TexelSize.xy * _Offset.xy;

        half4 color0 = SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, i.uv);
        half4 color1 = SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, i.uv01.xy);
        half4 color2 = SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, i.uv01.zw);
        half4 color3 = SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, i.uv23.xy);
        half4 color4 = SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, i.uv23.zw);

        float w0 = 0.4026;
        float w1 = CompareColor(color0, color1) * 0.2442;
        float w2 = CompareColor(color0, color2) * 0.2442;
        float w3 = CompareColor(color0, color3) * 0.0545;
        float w4 = CompareColor(color0, color4) * 0.0545;

        float4 color = half4(0, 0, 0, 0);
        color += w0 * color0;
        color += w1 * color1;
        color += w2 * color2;
        color += w3 * color3;
        color += w4 * color4;

        color *= rcp(w0 + w1 + w2 + w3 + w4);

        return color;
    }

    // ================================ 基于Normal的双边滤波 ================================
    float3 GetNormal(float2 uv)
    {
        float3 normal = SampleSceneNormals(uv);
        return normal;
    }

    half CompareNormal(float3 normal1, float3 normal2)
    {
        return smoothstep(_BilateralFilterFactor, 1.0, dot(normal1, normal2));
    }


    half4 FragmentBaseNormal(DefaultVaryings i) : SV_Target
    {
        half4 color0 = SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, i.uv);
        half4 color1 = SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, i.uv01.xy);
        half4 color2 = SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, i.uv01.zw);
        half4 color3 = SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, i.uv23.xy);
        half4 color4 = SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, i.uv23.zw);


        float3 normal0 = GetNormal(i.uv);
        float3 normal1 = GetNormal(i.uv01.xy);
        float3 normal2 = GetNormal(i.uv01.zw);
        float3 normal3 = GetNormal(i.uv23.xy);
        float3 normal4 = GetNormal(i.uv23.zw);

        float w0 = 0.4026;
        float w1 = CompareNormal(normal0, normal1) * 0.2442;
        float w2 = CompareNormal(normal0, normal2) * 0.2442;
        float w3 = CompareNormal(normal0, normal3) * 0.0545;
        float w4 = CompareNormal(normal0, normal4) * 0.0545;

        float4 color = half4(0, 0, 0, 0);
        color += w0 * color0;
        color += w1 * color1;
        color += w2 * color2;
        color += w3 * color3;
        color += w4 * color4;

        color *= rcp(w0 + w1 + w2 + w3 + w4);

        return color;
    }
    // ================================================================

    // ================================ 基于Depth的双边滤波 ================================
    //HDRP: BilateralFilter.hlsl -> ComputeBilateralWeight
    half CompareDepth(half depth1, half depth2)
    {
        float depthWeight = max(0.0, 1.0 - abs(depth1 - depth2));
        float weight = smoothstep(_BilateralFilterFactor, 1.0, depthWeight);
        return weight;
    }

    float GetDepth(float2 uv)
    {
        float depth = SampleSceneDepth(uv);
        depth = Linear01Depth(depth, _ZBufferParams);
        return depth;
    }

    half4 FragmentBaseDepth(DefaultVaryings i) : SV_Target
    {
        half4 color0 = SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, i.uv);
        half4 color1 = SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, i.uv01.xy);
        half4 color2 = SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, i.uv01.zw);
        half4 color3 = SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, i.uv23.xy);
        half4 color4 = SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, i.uv23.zw);

        float depth0 = GetDepth(i.uv);
        float depth1 = GetDepth(i.uv01.xy);
        float depth2 = GetDepth(i.uv01.zw);
        float depth3 = GetDepth(i.uv23.xy);
        float depth4 = GetDepth(i.uv23.zw);

        float w0 = 0.4026;
        float w1 = CompareDepth(depth0, depth1) * 0.2442;
        float w2 = CompareDepth(depth0, depth2) * 0.2442;
        float w3 = CompareDepth(depth0, depth3) * 0.0545;
        float w4 = CompareDepth(depth0, depth4) * 0.0545;

        float4 color = half4(0, 0, 0, 0);
        color += w0 * color0;
        color += w1 * color1;
        color += w2 * color2;
        color += w3 * color3;
        color += w4 * color4;

        color *= rcp(w0 + w1 + w2 + w3 + w4);

        return color;
    }

    half4 FragmentDepthNormal(DefaultVaryings i) : SV_Target
    {
        half4 color0 = SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, i.uv);
        half4 color1 = SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, i.uv01.xy);
        half4 color2 = SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, i.uv01.zw);
        half4 color3 = SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, i.uv23.xy);
        half4 color4 = SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, i.uv23.zw);

        float depth0 = GetDepth(i.uv);
        float depth1 = GetDepth(i.uv01.xy);
        float depth2 = GetDepth(i.uv01.zw);
        float depth3 = GetDepth(i.uv23.xy);
        float depth4 = GetDepth(i.uv23.zw);

        float3 normal0 = GetNormal(i.uv);
        float3 normal1 = GetNormal(i.uv01.xy);
        float3 normal2 = GetNormal(i.uv01.zw);
        float3 normal3 = GetNormal(i.uv23.xy);
        float3 normal4 = GetNormal(i.uv23.zw);

        float w0 = 0.4026;
        float w1 = CompareNormal(normal0, normal1) * CompareDepth(depth0, depth1) * 0.2442;
        float w2 = CompareNormal(normal0, normal2) * CompareDepth(depth0, depth2) * 0.2442;
        float w3 = CompareNormal(normal0, normal3) * CompareDepth(depth0, normal3) * 0.0545;
        float w4 = CompareNormal(normal0, normal4) * CompareDepth(depth0, normal4) * 0.0545;

        float4 color = half4(0, 0, 0, 0);
        color += w0 * color0;
        color += w1 * color1;
        color += w2 * color2;
        color += w3 * color3;
        color += w4 * color4;

        color *= rcp(w0 + w1 + w2 + w3 + w4);

        return color;
    }


    ENDHLSL

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        ZTest Always
        Cull Off
        ZWrite Off
        Pass
        {
            Name "Bilateral Filter Base Color"
            HLSLPROGRAM
            #pragma vertex Vertex
            #pragma fragment FragmentBaseColor
            ENDHLSL
        }

        Pass
        {
            Name "Bilateral Filter Base Normal"
            HLSLPROGRAM
            #pragma vertex Vertex
            #pragma fragment FragmentBaseNormal
            ENDHLSL
        }

        Pass
        {
            Name "Bilateral Filter Base Depth"
            HLSLPROGRAM
            #pragma vertex Vertex
            #pragma fragment FragmentBaseDepth
            ENDHLSL
        }

        Pass
        {
            Name "Bilateral Filter Depth Normal"
            HLSLPROGRAM
            #pragma vertex Vertex
            #pragma fragment FragmentDepthNormal
            ENDHLSL
        }
    }
}
