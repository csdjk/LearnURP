Shader "Hidden/LcLPostProcess/GaussianBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
    }

    HLSLINCLUDE
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

    TEXTURE2D(_MainTex);
    float4 _MainTex_TexelSize;
    SAMPLER(sampler_LinearClamp);
    float4 _Offset;

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

    half4 Fragment(DefaultVaryings i) : SV_Target
    {
        half4 color = half4(0, 0, 0, 0);
        color += 0.4026 * SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, i.uv);
        color += 0.2442 * SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, i.uv01.xy);
        color += 0.2442 * SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, i.uv01.zw);
        color += 0.0545 * SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, i.uv23.xy);
        color += 0.0545 * SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, i.uv23.zw);
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
            Name "Gauss Blur"
            HLSLPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment
            ENDHLSL
        }
    }
}
