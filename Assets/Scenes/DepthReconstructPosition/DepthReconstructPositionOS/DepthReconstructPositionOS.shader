Shader "lcl/DepthReconstructPositionOS"
{
    Properties
    {

    }

    SubShader
    {
        Tags { "RenderType" = "Overlay" "Queue" = "Transparent-499" "DisableBatching" = "True" }
        ZWrite off
        Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
            Stencil
            {
                Ref 1
                Comp NotEqual
            }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #pragma target 3.0

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderVariablesFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            struct appdata
            {
                float3 positionOS : POSITION;
            };
            struct v2f
            {
                float4 positionCS : SV_POSITION;
                float4 viewRayOS : TEXCOORD0;
                float4 cameraPosOS : TEXCOORD1;
                float4 screenSpaceOS : TEXCOORD2;
                float4 cameraForward : TEXCOORD3;
            };

            sampler2D _MainTex;
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float _ProjectionAngleDiscardThreshold;
            CBUFFER_END
            v2f vert(appdata input)
            {
                v2f o = (v2f)0;
                VertexPositionInputs vertexPositionInput = GetVertexPositionInputs(input.positionOS);
                o.positionCS = vertexPositionInput.positionCS;

                float3 viewRay = vertexPositionInput.positionVS;

                o.viewRayOS.w = -viewRay.z;

                float4x4 ViewToObjectMatrix = mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V);
                o.viewRayOS.xyz = mul((float3x3)ViewToObjectMatrix, viewRay);
                o.cameraPosOS.xyz = mul(ViewToObjectMatrix, float4(0, 0, 0, 1)).xyz;


                viewRay.z = 0;
                //cube上的点在正交相机屏幕平面内的投射向量,在objectSpace中
                o.screenSpaceOS.xyz = mul((float3x3)ViewToObjectMatrix, viewRay);
                //正交相机的在objectSpace中的朝向
                o.cameraForward.xyz = mul((float3x3)ViewToObjectMatrix, float3(0, 0, -1));
                return o;
            }

            //计算线性深度值
            float SampleAndGetLinearEyeDepth(float2 screenUV)
            {
                float sceneRawDepth = SampleSceneDepth(screenUV);
                if (!IsPerspectiveProjection())
                {
                    return LinearDepthToEyeDepth(sceneRawDepth);
                }
                else
                {
                    return LinearEyeDepth(sceneRawDepth, _ZBufferParams);
                }
            }

            //计算模型空间坐标
            float3 ReconstructPositionOS(v2f i)
            {
                float2 screenUV = i.positionCS.xy / _ScaledScreenParams.xy;
                float sceneDepthVS = SampleAndGetLinearEyeDepth(screenUV);
                if (!IsPerspectiveProjection())
                {
                    //正交相机,只需要i.viewRayOS.xyz的方向
                    return i.cameraPosOS.xyz + (i.screenSpaceOS.xyz + i.cameraForward.xyz * sceneDepthVS);
                }
                else
                {
                    i.viewRayOS.xyz /= i.viewRayOS.w;
                    return i.cameraPosOS.xyz + i.viewRayOS.xyz * sceneDepthVS;
                }
            }

            half4 frag(v2f i) : SV_Target
            {
                float3 positionOS = ReconstructPositionOS(i);

                return float4(positionOS,1);
            }
            ENDHLSL
        }
    }
}
