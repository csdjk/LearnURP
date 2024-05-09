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
                float3 viewRay : TEXCOORD1;
            };

            float4x4 _FrustumCornersRay;


            Varyings vert(Attributes input)
            {
                Varyings output;

                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = positionInputs.positionCS;
                output.uv = input.uv;

                //根据UV区分四个角
                //uv: (0,0) (1,0) (0,1) (1,1)
                //index: 0 1 2 3
                int index = int(input.uv.x + 0.5) + 2 * int(input.uv.y + 0.5);
                output.viewRay = _FrustumCornersRay[index].xyz;
                return output;
            }


            float3 ComputePositionWS(float2 uv, float3 ray)
            {
                float depth = SampleSceneDepth(uv);
                float3 positionWS = 0;
                if (IsPerspectiveProjection())
                {
                    // 透视相机下，_CameraDepthTexture存储的是ndc.z值，且：不是线性的。
                    depth = Linear01Depth(depth, _ZBufferParams);
                    positionWS = GetCurrentViewPosition() + depth * ray;
                }
                else
                {
                    // 正交相机下，_CameraDepthTexture存储的是线性值，
                    // 并且距离镜头远的物体，深度值小，距离镜头近的物体，深度值大
                    #if defined(UNITY_REVERSED_Z)
                        depth = 1 - depth;
                    #endif
                    float farClipPlane = _ProjectionParams.z;

                    // float3 forward = UNITY_MATRIX_V[2].xyz;
                    float3 forward = unity_WorldToCamera[2].xyz;
                    float3 cameraForward = normalize(forward) * farClipPlane;
                    positionWS = GetCurrentViewPosition() + depth * cameraForward + ray.xyz;
                }
                return positionWS;
            }


            half4 frag(Varyings input) : SV_Target
            {
                // float2 screenUV = input.positionCS.xy / _ScaledScreenParams.xy;
                float2 screenUV = input.uv;
                float3 positionWS = ComputePositionWS(screenUV, input.viewRay);
                return float4(positionWS, 1);
            }
            ENDHLSL
        }
    }
}
