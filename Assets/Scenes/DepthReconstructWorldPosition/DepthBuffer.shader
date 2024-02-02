Shader "Custom/LambertShaderExample"
{
    Properties
    {
        _BaseMap ("Texture", 2D) = "white" { }
        _BaseColor ("Example Colour", Color) = (0, 0.66, 0.73, 1)
        _Cutoff ("Alpha Cutoff", Float) = 0.5
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent" }
        Pass
        {
            Tags { "LightMode" = "UniversalForward" }
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            CBUFFER_START(UnityPerMaterial)
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 positionNDC : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
            };
            Varyings vert(Attributes input)
            {
                Varyings output;
                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = positionInputs.positionCS;
                output.positionWS = positionInputs.positionWS;
                output.positionNDC = positionInputs.positionNDC;
                return output;
            }
            // https://www.cyanilux.com/tutorials/depth/
            half4 frag(Varyings input) : SV_Target
            {
                float4 visual = float4(0, 0, 0, 1);
                // ================================ Scene Depth ================================
                half2 screen_uv = input.positionCS.xy / _ScaledScreenParams.xy;
                float depth_scene = SampleSceneDepth(screen_uv);
                float depth01_scene = Linear01Depth(depth_scene, _ZBufferParams);
                float depthEye_scene = LinearEyeDepth(depth_scene, _ZBufferParams);

                visual = half4(depth01_scene.xxx * 200, 1);

                // ================================ Self Depth ================================
                float depth_self = input.positionCS.z;

                // 1
                float depth01_self = Linear01Depth(depth_self, _ZBufferParams);

                // 2
                float3 pd = input.positionNDC.xyz / input.positionNDC.w;
                depth_self = pd.z;

                depth01_self = Linear01Depth(pd.z, _ZBufferParams);

                //

                // visual = half4(depth01_self.xxx * 200, 1);
                visual.rgb = frac(depth_scene * 50);

                return visual;
            }
            ENDHLSL
        }
    }
}
