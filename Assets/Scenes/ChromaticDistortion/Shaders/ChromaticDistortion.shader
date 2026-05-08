Shader "Hidden/LcLPostProcess/ChromaticDistortion"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
    }

    HLSLINCLUDE
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

    TEXTURE2D(_MainTex);
    float4 _MainTex_TexelSize;
    SAMPLER(sampler_LinearClamp);

    float  _AberrationStrength;
    float  _DistortionStrength;
    float  _DistortionFrequency;
    float  _DistortionSpeed;
    float  _VignetteStrength;
    float  _PoisonTint;

    struct DefaultVertexInput
    {
        float4 positionOS : POSITION;
        float2 uv         : TEXCOORD0;
    };

    struct DefaultVaryings
    {
        float4 positionCS : SV_POSITION;
        float2 uv         : TEXCOORD0;
    };

    DefaultVaryings Vertex(DefaultVertexInput input)
    {
        DefaultVaryings output;
        output.positionCS = TransformWorldToHClip(input.positionOS);
        output.uv = input.uv;
        return output;
    }

    // 波纹扭曲偏移
    float2 WaveDistortion(float2 uv, float time)
    {
        float2 offset;
        offset.x  = sin(uv.y * _DistortionFrequency + time * _DistortionSpeed)          * _DistortionStrength * 0.01;
        offset.y  = cos(uv.x * _DistortionFrequency * 0.7 + time * _DistortionSpeed * 1.3) * _DistortionStrength * 0.01;
        offset.x += cos(uv.y * _DistortionFrequency * 0.5 + time * _DistortionSpeed * 0.6) * _DistortionStrength * 0.005;
        offset.y += sin(uv.x * _DistortionFrequency * 0.8 + time * _DistortionSpeed * 0.8) * _DistortionStrength * 0.005;
        return offset;
    }

    // 暗角
    float Vignette(float2 uv, float strength)
    {
        float2 c = uv - 0.5;
        return 1.0 - dot(c, c) * strength * 4.0;
    }

    half4 Fragment(DefaultVaryings i) : SV_Target
    {
        float2 uv   = i.uv;
        float  time = _Time.y;

        // 1. 扭曲
        float2 distUV = uv + WaveDistortion(uv, time);

        // 2. 色散：RGB 三通道向屏幕中心方向偏移不同量
        float2 dir    = distUV - float2(0.5, 0.5);
        float  dirLen = length(dir) + 0.0001;
        float2 aberrationOffset = (dir / dirLen) * (_AberrationStrength * 0.02) * (dirLen * 2.0);

        float r = SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, distUV + aberrationOffset).r;
        float g = SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, distUV).g;
        float b = SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, distUV - aberrationOffset).b;

        half4 color = half4(r, g, b, 1.0);

        // 3. 中毒色调（随时间脉动）
        float tintPulse = (sin(time * 2.0) * 0.5 + 0.5) * _PoisonTint;
        color.r *= 1.0 + tintPulse * 0.5;
        color.g *= 1.0 + tintPulse * 0.3;
        color.b *= max(0.0, 1.0 - tintPulse * 0.6);

        // 4. 暗角
        color.rgb *= saturate(Vignette(uv, _VignetteStrength));

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
            Name "ChromaticDistortion"
            HLSLPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment
            ENDHLSL
        }
    }
}
