Shader "LcL/Depth/ReconstructWorldPosition1"
{
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        ZTest Always ZWrite Off Cull Off
        Pass
        {
            Name "ReconstructWorldPosition_InvMatrix"
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
                float2 uv : TEXCOORD0;
            };
            
            float4x4 _InverseVPMatrix;

            
            Varyings vert(Attributes input)
            {
                Varyings output;
                
                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = positionInputs.positionCS;
                output.uv = input.uv;
                return output;
            }
            
            half4 frag(Varyings input) : SV_Target
            {
                float2 uv = input.uv;
                float depth = SampleSceneDepth(input.uv);
                #if defined(UNITY_REVERSED_Z)
                    depth = 1 - depth;
                #endif
                
                // 转换到ndc空间[-1,1]
                float4 ndc = float4(uv.xy * 2 - 1, depth * 2 - 1, 1);
                
                float4 worldPos = mul(_InverseVPMatrix, ndc);
                worldPos /= worldPos.w;
                return worldPos;

            }
            ENDHLSL
        }
    }
}