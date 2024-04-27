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
            "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"
        }
        ZTest Always
        ZWrite Off
        Cull Off
        Blend Off
        Pass
        {
            Name "Weighted Blend Blit"

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"


            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

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
                // float3 sceneColor = SampleSceneColor(input.uv);
                float4 mainColor = SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, input.uv);
                // float4 mainColor = half4(sceneColor, 1);

                float4 accum = SAMPLE_TEXTURE2D(_AccumTexture, sampler_LinearClamp, input.uv);
                float r = SAMPLE_TEXTURE2D_X(_RevealageTexture, sampler_LinearClamp, input.uv).r;
                //1e-4 = 1*10^-4 = 0.0001
                //5e4 = 5*10^4 = 50000
                float4 color = float4(accum.rgb / clamp(accum.a, 1e-4, 5e4), r);

                return (1.0 - color.a) * color + color.a * mainColor;
            }
            ENDHLSL
        }
    }
}
