Shader "lcl/ScreenSpaceDecal"
{
    Properties
    {
        [MainTexture]_MainTex ("Texture", 2D) = "white" { }
        [Toggle(_ProjectionAngleDiscardEnable)] _ProjectionAngleDiscardEnable ("_ProjectionAngleDiscardEnable (default = off)", float) = 0
        _ProjectionAngleDiscardThreshold ("_ProjectionAngleDiscardThreshold (default = 0)", range(-1.1, 1.1)) = 0
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
            #pragma shader_feature_local_fragment _ProjectionAngleDiscardEnable

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
            float3 GetDecalSpaceScenePos(v2f i)
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
                float3 decalSpaceScenePos = GetDecalSpaceScenePos(i);

                float shouldClip = 0;
                float3 decalSpaceHardNormal = 0;
                #if _ProjectionAngleDiscardEnable
                    decalSpaceHardNormal = normalize(cross(ddy(decalSpaceScenePos), ddx(decalSpaceScenePos)));
                    //因为用的是xy方向作为uv,所以z
                    shouldClip = decalSpaceHardNormal.z > _ProjectionAngleDiscardThreshold ? 0 : 1;
                #endif

                clip(0.5 - abs(decalSpaceScenePos) - shouldClip);
                float2 decalSpaceUV = decalSpaceScenePos.xy + 0.5;
                float2 uv = decalSpaceUV.xy * _MainTex_ST.xy + _MainTex_ST.zw;

                half4 col = tex2D(_MainTex, uv);

                return float4(col.xyz, col.x * col.w);
            }
            ENDHLSL
        }
    }
}
