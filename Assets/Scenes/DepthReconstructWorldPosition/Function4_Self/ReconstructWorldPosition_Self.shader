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
                float4 cameraForward : TEXCOORD2;
                float4 viewRayOh : TEXCOORD3;
            };
            float3 GetCameraForwardDir()
            {
                return normalize(UNITY_MATRIX_V[2].xyz);
            }
            Varyings vert(Attributes input)
            {
                Varyings output;
                
                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = positionInputs.positionCS;

                
                if (IsPerspectiveProjection())
                {
                    output.viewRayWS.xyz = GetWorldSpaceViewDir(positionInputs.positionWS);
                    // 由于Unity的视图空间是右手坐标系，z需要取反（view space z）
                    output.viewRayWS.w = -mul(UNITY_MATRIX_V, float4(output.viewRayWS.xyz, 0.0)).z;
                }
                else
                {
                    float3 viewRay = positionInputs.positionVS;
                    viewRay.z = 0;
                    float3 positionWS = mul(UNITY_MATRIX_I_V, float4(viewRay, 1)).xyz;
                    output.viewRayWS.xyz = positionWS - GetCurrentViewPosition();
                }

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

                float3 worldPos;
                // 透视投影
                if (IsPerspectiveProjection())
                {
                    depth = LinearEyeDepth(depth, _ZBufferParams);

                    // 参考https://zhuanlan.zhihu.com/p/590873962
                    // VP = VR/VZ * VD
                    input.viewRayWS.xyz = input.viewRayWS.xyz / input.viewRayWS.w * depth;
                    // MP = MV + VP
                    worldPos = GetCurrentViewPosition() + input.viewRayWS.xyz;
                }
                else
                {
                    // 正交投影
                    depth = LinearDepthToEyeDepth(depth);
                    float3 cameraForward = GetViewForwardDir();
                    worldPos = GetCurrentViewPosition() + input.viewRayWS.xyz + cameraForward * depth;
                }

                

                return half4(worldPos, 1);
            }
            ENDHLSL
        }
    }
}