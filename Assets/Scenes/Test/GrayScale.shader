Shader "Hidden/Universal Render Pipeline/Custom/GrayScale"
{
    Properties
    {
        _MainTex ("Source", 2D) = "white" { }
    }

    HLSLINCLUDE
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"

    TEXTURE2D_X(_MainTex);

    half4 Frag(Varyings input) : SV_Target
    {
        float4 source = SAMPLE_TEXTURE2D_X(_MainTex, sampler_LinearClamp, input.uv);
        float y = 0.299 * source.r + 0.587 * source.g + 0.144 * source.b;
        return half4(y, y, y, 1.0);
    }

    ENDHLSL

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        LOD 100
        ZTest Always ZWrite Off Cull Off

        Pass
        {
            Name "GrayScale"

            HLSLPROGRAM

            #pragma vertex Vert
            #pragma fragment Frag
            ENDHLSL

        }
    }
}
