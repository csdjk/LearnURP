Shader "lcl/Depth/DepthBuffer"
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
                float3 positionVS : TEXCOORD2;
            };
            Varyings vert(Attributes input)
            {
                Varyings output;
                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = positionInputs.positionCS;
                output.positionVS = positionInputs.positionVS;
                output.positionNDC = positionInputs.positionNDC;
                return output;
            }
            // https://www.cyanilux.com/tutorials/depth/
            /**
            在 DirectX 中，NDC 空间的范围是：
            X轴：-1 到 1
            Y轴：-1 到 1
            Z轴：0 到 1

            在 OpenGL 中，NDC 空间的范围是：
            X轴：-1 到 1
            Y轴：-1 到 1
            Z轴：-1 到 1

            Unity可以用UNITY_NEAR_CLIP_VALUE获取z方向近平面的值，在openGL环境下是-1.0，DirectX中是0.0。
            **/
            half4 frag(Varyings input) : SV_Target
            {
                float4 visual = float4(0, 0, 0, 1);
                // ================================ Scene Depth ================================
                half2 screen_uv = input.positionCS.xy / _ScaledScreenParams.xy;


                float depth = SampleSceneDepth(screen_uv);
                float depth01_scene = Linear01Depth(depth, _ZBufferParams);
                float depthEye_scene = LinearEyeDepth(depth, _ZBufferParams);

                visual = half4(depth01_scene.xxx * 200, 1);

                // ================================ Self Depth ================================
                // 第一种方法:
                // 这里的input.positionCS.z是由于GPU自己做透视除法将顶点转到NDC。也就是z表示写入到深度缓冲中的值
                float depth01_self = Linear01Depth(input.positionCS.z, _ZBufferParams);

                // 第二种方法:
                // 自己做透视除法
                float3 pd = input.positionNDC.xyz / input.positionNDC.w;
                depth01_self = Linear01Depth(pd.z, _ZBufferParams);

                // 测试值是否一样
                if (abs(depth01_scene - depth01_self) <= 0.0001)
                {
                    visual.rgb = 0;
                }

                // visual = half4(depth01_self.xxx * 200, 1);
                visual.rgb = frac(depth * 50);


                visual.rgb = frac(-input.positionVS.z * 0.02);
                visual.rgb = frac(depthEye_scene * 0.02);
                // if (abs(-input.positionVS.z - depthEye_scene) <= 0.01)
                // {
                //     visual.rgb = 0;
                // }

                return visual;
            }
            ENDHLSL
        }
    }
}
