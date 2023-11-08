Shader "LcL/Depth/ReconstructWorldPosition_Self"
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
                // 由于Unity的视图空间是右手坐标系，z需要取反（view space z）
                output.viewRayWS.w = -mul(UNITY_MATRIX_V, float4(output.viewRayWS.xyz, 0.0)).z;
                return output;
            }
            
            half4 frag(Varyings input) : SV_Target
            {
                float2 screenUV = input.positionCS.xy / _ScaledScreenParams.xy;

                #if UNITY_REVERSED_Z
                    real depth = SampleSceneDepth(screenUV);
                #else
                    real depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, SampleSceneDepth(screenUV));
                #endif
                // 参考https://zhuanlan.zhihu.com/p/590873962
                depth = LinearEyeDepth(depth, _ZBufferParams);
                // VP = VR/VZ * VD
                input.viewRayWS.xyz = input.viewRayWS.xyz / input.viewRayWS.w * depth;
                // MP = MV + VP
                float3 worldPos = GetCurrentViewPosition() + input.viewRayWS.xyz;

                return half4(worldPos, 1);
            }
            ENDHLSL
        }
    }
}