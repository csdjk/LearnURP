Shader "LcL/Depth/ReconstructWorldPosition4"
{
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        // ZTest Always ZWrite Off Cull Off
        Pass
        {
            Name "ReconstructWorldPosition_Object"
            Tags { "LightMode" = "UniversalForward" }
            
            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

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
                float4 screenPos : TEXCOORD0;
                float3 viewWS : TEXCOORD1;
                float viewSpaceZ : TEXCOORD2;
            };
            
            Varyings vert(Attributes input)
            {
                Varyings output;
                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = positionInputs.positionCS;
                // output.uv = input.uv;
                output.screenPos = ComputeScreenPos(positionInputs.positionCS);


                output.viewWS = GetCurrentViewPosition() - positionInputs.positionWS;
                output.viewSpaceZ = mul(UNITY_MATRIX_V, float4(output.viewWS, 0.0)).z;
                
                return output;
            }
            
            half4 frag(Varyings input) : SV_Target
            {
                // float2 uv = input.uv;
                float2 uv = input.screenPos.xy / input.screenPos.w;
                
                float depth = SampleSceneDepth(uv);
                
                depth = LinearEyeDepth(depth, _ZBufferParams);
                //worldpos = campos + 射线方向 * depth
                input.viewWS *= -depth / input.viewSpaceZ;

                float3 worldPos = GetCurrentViewPosition() + input.viewWS;

                // return float4(1, 1, 1, 1);
                return float4(worldPos, 1);

            }
            ENDHLSL
        }
    }
}