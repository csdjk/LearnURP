Shader "Hidden/OIT/WeightedBlend"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent"
        }
        ZTest Always
        ZWrite Off
        Cull Off
        Pass
        {
            Name "ColorBlitPass"
            Blend One OneMinusSrcAlpha
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _SourceTex_TexelSize;

            TEXTURE2D(_AccumTexture);
            SAMPLER(sampler_AccumTexture);

            TEXTURE2D(_RevealageTexture);
            SAMPLER(sampler_RevealageTexture);

            Varyings vert(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = input.uv;
                return output;
            }


            half4 frag(Varyings input) : SV_Target
            {
                // float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, input.uv);
                float4 accum = SAMPLE_TEXTURE2D(_AccumTexture, sampler_LinearClamp, input.uv);
                float r = 1 - accum.a;
                accum.a = SAMPLE_TEXTURE2D(_RevealageTexture, sampler_LinearClamp, input.uv).r;
                //1e-4 = 1*10^-4 = 0.0001
                //5e4 = 5*10^4 = 50000
                return float4(accum.rgb / clamp(accum.a, 1e-4, 5e4), r);
            }
            ENDHLSL
        }
    }
}
