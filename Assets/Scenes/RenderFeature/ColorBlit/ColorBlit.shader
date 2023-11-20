Shader "Hidden/ColorBlit"
{
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        ZTest Always
        ZWrite Off 
        Cull Off
        Pass
        {
            Name "ColorBlitPass"

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"

            TEXTURE2D(_SourceTex);
            float4 _SourceSize;
            float4 _SourceTex_TexelSize;

            Varyings vert(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                // output.positionCS = float4(input.positionHCS.xyz, 1.0);

                // #if UNITY_UV_STARTS_AT_TOP
                //     output.positionCS.y *= -1;
                // #endif

                output.uv = input.uv;
                return output;
            }

            float _Intensity;

            half4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float4 color = SAMPLE_TEXTURE2D(_SourceTex, sampler_LinearClamp, input.uv);
                return color * float4(0, _Intensity, 0, 1);
            }
            ENDHLSL
        }
    }
}
