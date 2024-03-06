Shader "LcL/Rain"
{
    SubShader
    {
        Pass
        {
            Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
            Cull Front ZWrite Off ZTest Off
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"
            #include "Assets/Shaders/Libraries/Node.hlsl"

            #pragma multi_compile _DOUBLE_RAIN
            struct a2v
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 color : COLOR;
            };

            struct v2f
            {
                float4 positionCS : SV_POSITION;
                float4 screenPos : TEXCOORD0;
                float4 uv : TEXCOORD1;
                float3 color : COLOR;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _RainColor;
                float2 _RainIntensity;

                float4 _FarTillingSpeed;
                float4 _FarDepthSmooth;
                float4 _NearTillingSpeed;
                float4 _NearDepthSmooth;

                float4x4 _DepthCameraMatrixVP;
            CBUFFER_END


            TEXTURE2D(_SourceTex);
            SAMPLER(sampler_SourceTex);

            TEXTURE2D(_RainTexture);
            SAMPLER(sampler_RainTexture);

            TEXTURE2D(_SceneHeightTex);
            SAMPLER(sampler_SceneHeightTex);

            inline float DecodeFloatRGBA(float4 enc)
            {
                float4 kDecodeDot = float4(1.0, 1 / 255.0, 1 / 65025.0, 1 / 16581375.0);
                return dot(enc, kDecodeDot);
            }

            float3 ComputeWorldPosition(float2 screen_uv, float eyeDepth)
            {
                // NDC
                float4 ndcPos = float4(screen_uv * 2 - 1, 0, 1);
                // 裁剪空间
                float4 clipPos = mul(unity_CameraInvProjection, ndcPos);
                clipPos = float4(((clipPos.xyz / clipPos.w) * float3(1, 1, -1)), 1.0);
                clipPos.z = eyeDepth;
                return mul(unity_CameraToWorld, clipPos);
            }

            //计算高度遮挡
            float CalculateHeightVisibility(float4 heightCameraPos)
            {
                float3 uvw = 0;
                heightCameraPos.xyz = heightCameraPos.xyz / heightCameraPos.w;
                uvw.xy = heightCameraPos.xy * 0.5 + 0.5;

                #if defined(SHADER_API_GLES) || defined(SHADER_API_GLES3)
                    uvw.z = heightCameraPos.z * 0.5 + 0.5; //[-1, 1]-->[0, 1]
                #elif defined(UNITY_REVERSED_Z)
                    uvw.z = 1 - heightCameraPos.z;
                #endif
                float4 height = SAMPLE_TEXTURE2D(_SceneHeightTex, sampler_SceneHeightTex, uvw.xy);
                float sceneHeight = DecodeFloatRGBA(height);
                // float visibility = uvw.z > sceneHeight ? 0 : 1;
                float visibility = step(uvw.z, sceneHeight);
                return visibility;
            }


            // 计算遮挡
            float CalculateRainVisibility(float2 screen_uv, float eyeDepth, float sceneViewDepth)
            {
                float sceneEyeDepth = LinearEyeDepth(sceneViewDepth, _ZBufferParams);
                // 主摄像机水平遮挡
                float visibilityH = step(eyeDepth, sceneEyeDepth);

                float3 rainPositionWS = ComputeWorldPosition(screen_uv, eyeDepth);
                float4 heightCameraPos = mul(_DepthCameraMatrixVP, float4(rainPositionWS, 1.0));
                //高度遮挡
                float visibilityV = CalculateHeightVisibility(heightCameraPos);
                return visibilityH * visibilityV;
            }


            v2f vert(a2v input)
            {
                v2f output;
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.vertex.xyz);
                output.positionCS = vertexInput.positionCS;

                output.screenPos = ComputeScreenPos(output.positionCS);
                float2 farTilling = _FarTillingSpeed.xy;
                float2 farSpeed = _FarTillingSpeed.zw;

                float2 nearTilling = _NearTillingSpeed.xy;
                float2 nearSpeed = _NearTillingSpeed.zw;

                output.uv.xy = input.uv * nearTilling + nearSpeed * _Time.x;
                output.uv.zw = input.uv * farTilling + farSpeed * _Time.x;

                output.color = input.color;
                return output;
            }

            half4 frag(v2f i) : SV_Target
            {
                float2 screen_uv = i.screenPos.xy / i.screenPos.w;
                float2 nearDepthBaseRange = _NearDepthSmooth.xy;
                float2 farDepthBaseRange = _FarDepthSmooth.xy;
                // ==================================计算遮挡==================================
                float sceneViewDepth = SampleSceneDepth(screen_uv);

                float2 nearRain = SAMPLE_TEXTURE2D(_RainTexture, sampler_RainTexture, i.uv.xy).xz;
                float nearRainDepth = nearRain.y * nearDepthBaseRange.y + nearDepthBaseRange.x;
                float nearRainLayer = CalculateRainVisibility(screen_uv, nearRainDepth, sceneViewDepth);


                // #if defined(_DOUBLE_RAIN)
                float2 farRain = SAMPLE_TEXTURE2D(_RainTexture, sampler_RainTexture, i.uv.zw).yz;
                float farRainDepth = farRain.y * farDepthBaseRange.y + farDepthBaseRange.x;
                float farRainLayer = CalculateRainVisibility(screen_uv, farRainDepth, sceneViewDepth);
                // #endif

                // ==================================Blend Color==================================
                half3 color = _RainColor;
                nearRain.x = SmoothValue(_NearDepthSmooth.z, _NearDepthSmooth.w, nearRain.x);


                half rainAlpha = 0;
                rainAlpha += nearRain.x * nearRainLayer * _RainIntensity.r;

                // #if defined(_DOUBLE_RAIN)
                    rainAlpha += farRain.x * farRainLayer * _RainIntensity.g;
                // #endif

                rainAlpha = rainAlpha * _RainColor.a * i.color.r;
                return half4(color, rainAlpha);
            }
            ENDHLSL
        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
