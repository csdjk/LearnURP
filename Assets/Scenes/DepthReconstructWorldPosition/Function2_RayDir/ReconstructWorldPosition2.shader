Shader "LcL/Depth/ReconstructWorldPosition2"
{
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        ZTest Always ZWrite Off Cull Off
        Pass
        {
            Name "ReconstructWorldPosition_RayDir"
            Tags { "LightMode" = "UniversalForward" }
            
            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile _ _USE_VERTEX_ID
            
            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                uint vid : SV_VertexID;
            };
            
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 rayDir : TEXCOORD1;
            };
            
            float4x4 _ViewPortRay;

            
            Varyings vert(Attributes input)
            {
                Varyings output;
                
                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = positionInputs.positionCS;
                output.uv = input.uv;

                //用texcoord区分四个角，就四个点，if无所谓
                int index = 0;

                #if defined(_USE_VERTEX_ID)
                    index = input.vid;
                #else
                    if (input.uv.x < 0.5 && input.uv.y < 0.5)
                        index = 0;
                    else if (input.uv.x < 0.5 && input.uv.y > 0.5)
                        index = 1;
                    else if (input.uv.x > 0.5 && input.uv.y > 0.5)
                        index = 2;
                    else
                        index = 3;
                #endif
                
                output.rayDir = _ViewPortRay[index];
                return output;
            }
            
            half4 frag(Varyings input) : SV_Target
            {
                float2 uv = input.uv;
                float depth = SampleSceneDepth(uv);
                
                if (IsPerspectiveProjection())
                {
                    // 透视相机下，_CameraDepthTexture存储的是ndc.z值，且：不是线性的。
                    depth = Linear01Depth(depth, _ZBufferParams);
                    //worldpos = campos + 射线方向 * depth
                    float3 worldPos = GetCurrentViewPosition() + depth * input.rayDir.xyz;
                }
                else
                {
                    // 正交摄像机的深度是反的

                    // 正交相机下，_CameraDepthTexture存储的是线性值，
                    // 并且距离镜头远的物体，深度值小，距离镜头近的物体，深度值大
                    #if defined(UNITY_REVERSED_Z)
                        depth = 1 - depth;
                    #endif
                    float3 worldPos = GetCurrentViewPosition() + depth * _CameraForward + input.rayDir.xyz;
                }
                return float4(worldPos, 1);
            }
            ENDHLSL
        }
    }
}