Shader "LcL/Depth/ReconstructWorldPosition_Self2"
{
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Transparent+100" "RenderPipeline" = "UniversalPipeline" }
        ZTest Always ZWrite Off Cull Off

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

        ENDHLSL
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 viewRayWS : TEXCOORD1;
            };

            Varyings vert(Attributes input)
            {
                Varyings output;

                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = positionInputs.positionCS;

                output.viewRayWS.xyz = GetWorldSpaceViewDir(positionInputs.positionWS);

                return output;
            }


            //https://assetstore.unity.com/packages/vfx/shaders/stylized-water-2-170386
            //water shader中的ReconstructWorldPosition函数
            float3 ReconstructPositionWS(float2 uv, float4 positionCS, float3 viewDir)
            {
                #if UNITY_REVERSED_Z
                    real depth = SampleSceneDepth(uv);
                #else
                    real depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, SampleSceneDepth(uv));
                #endif

                float eyeDepth = LinearEyeDepth(depth, _ZBufferParams);

                float3 camPos = GetCurrentViewPosition();
                float3 worldPos = camPos - eyeDepth * (viewDir / positionCS.w);
                return worldPos;
            }


            half4 frag(Varyings input) : SV_Target
            {
                float2 screenUV = input.positionCS.xy / _ScaledScreenParams.xy;
                float3 positionWS = ReconstructPositionWS(screenUV, input.positionCS, input.viewRayWS);
                return half4(positionWS, 1);
            }
            ENDHLSL
        }
    }
}
