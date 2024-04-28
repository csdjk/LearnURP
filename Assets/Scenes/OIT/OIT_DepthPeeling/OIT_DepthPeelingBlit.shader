Shader "LcL/OIT/DepthPeelingBlit"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" { }
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"

        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        float4 _MainTex_ST;
        TEXTURE2D(_DepthTexture);

        // Blend
        float4 DepthPeelingFrag(Varyings input, out float deputOut : SV_DEPTH) : SV_Target
        {
            half4 baseMap = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
            deputOut = SAMPLE_DEPTH_TEXTURE(_DepthTexture, sampler_PointClamp, input.uv).r;
            return baseMap;
        }
        ENDHLSL

        Pass
        {
            Name "DepthPeelingBlitPass"
            ZTest Off
            Cull Off
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex FullscreenVert
            #pragma fragment DepthPeelingFrag
            ENDHLSL
        }
    }
}
