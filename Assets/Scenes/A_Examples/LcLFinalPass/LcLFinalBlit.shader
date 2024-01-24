Shader "Hidden/LcLFinalBlit"
{
    HLSLINCLUDE
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

    TEXTURE2D_X(_SourceTex);
    float4 _SourceSize;
    SamplerState sampler_LinearClamp;

    struct Attributes
    {
        float4 positionHCS : POSITION;
        float2 uv : TEXCOORD0;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float2 uv : TEXCOORD0;
        UNITY_VERTEX_OUTPUT_STEREO
    };

    Varyings FullscreenVert2(Attributes input)
    {
        Varyings output;
        UNITY_SETUP_INSTANCE_ID(input);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
        output.positionCS = float4(input.positionHCS.xyz, 1.0);
        output.positionCS = TransformObjectToHClip(input.positionHCS.xyz);
        // #if UNITY_UV_STARTS_AT_TOP
        //     output.positionCS.y *= -1;
        // #endif
        output.uv = input.uv;

        return output;
    }

    half4 Frag(Varyings input) : SV_Target
    {
        float2 uv = input.uv;
        half3 color = SAMPLE_TEXTURE2D(_SourceTex, sampler_LinearClamp, uv).xyz;
        half4 finalColor = half4(color * float3(0, 1, 0), 1);
        return finalColor;
    }

    ENDHLSL

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        LOD 100
        ZTest Always ZWrite Off Cull Off

        Pass
        {
            Name "LcLRenderShader"

            HLSLPROGRAM
            #pragma vertex FullscreenVert2
            #pragma fragment Frag
            #pragma target 4.5
            ENDHLSL
        }
    }
}
