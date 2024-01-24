Shader "Hidden/ScreenSpaceReflection"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
    }
    SubShader
    {
        Pass
        {
            Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            struct Attributes
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            struct Varyings
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 viewRay : TEXCOORD1;
            };
            #define BinarySearchIterations 10

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            // clamp sampler
            SamplerState sampler_LinearClamp;
            SamplerState sampler_LinearRepeat;

            TEXTURE2D(_CameraDepthNormalsTexture);
            SAMPLER(sampler_CameraDepthNormalsTexture);

            CBUFFER_START(UnityPerMaterial)
                int _MaxStep;
                float _StepSize;
                float _MaxDistance;
                float _Thickness;
                float _NoiseIntensity;
            CBUFFER_END

            //===========================================================================
            inline float3 DecodeViewNormalStereo(float4 enc4)
            {
                float kScale = 1.7777;
                float3 nn = enc4.xyz * float3(2 * kScale, 2 * kScale, 0) + float3(-kScale, -kScale, 1);
                float g = 2.0 / dot(nn.xyz, nn.xyz);
                float3 n;
                n.xy = g * nn.xy;
                n.z = g - 1;
                return n;
            }
            inline float DecodeFloatRG(float2 enc)
            {
                float2 kDecodeDot = float2(1.0, 1 / 255.0);
                return dot(enc, kDecodeDot);
            }
            inline void DecodeDepthNormal(float4 enc, out float depth, out float3 normal)
            {
                depth = DecodeFloatRG(enc.zw);
                normal = DecodeViewNormalStereo(enc);
            }
            //===========================================================================
            Varyings vert(Attributes input)
            {
                Varyings o;
                o.pos = TransformObjectToHClip(input.vertex);
                o.uv = input.uv;

                half4 viewRayNDC = half4(input.uv * 2 - 1, 1, 1);
                float4 viewRayPS = viewRayNDC * _ProjectionParams.z;
                o.viewRay = mul(unity_CameraInvProjection, viewRayPS);
                return o;
            }

            inline bool rayIntersectsDepth(float reflDepth, float2 screenUV)
            {
                float4 depthNormal = SAMPLE_TEXTURE2D(_CameraDepthNormalsTexture, sampler_CameraDepthNormalsTexture, screenUV);
                float depth = DecodeFloatRG(depthNormal.zw) * _ProjectionParams.z + 0.2;
                float dist = abs(depth - reflDepth);
                return dist < _Thickness;
            }

            float3 hash33(float3 p3)
            {
                p3 = frac(p3 * float3(0.1031, 0.1030, 0.0973));
                p3 += dot(p3, p3.yxz + 33.33);
                return frac((p3.xxy + p3.yxx) * p3.zyx);
            }

            inline float3 Noise(float3 positionVS, float intensity)
            {
                return (hash33(positionVS * 10) - 0.5) * intensity;
            }


            half4 frag(Varyings input) : SV_Target
            {

                half4 depthNormals = SAMPLE_TEXTURE2D(_CameraDepthNormalsTexture, sampler_CameraDepthNormalsTexture, input.uv);
                float linear01Depth;float3 normalVS;
                DecodeDepthNormal(depthNormals, linear01Depth, normalVS);

                //重建视空间下点的坐标
                float3 positionVS = linear01Depth * input.viewRay;

                float3 viewDir = normalize(positionVS);
                normalVS = normalize(normalVS);
                half3 reflectDir = reflect(viewDir, normalVS);


                // ---------------------------------------------------
                float3 rayOrg = positionVS;
                float3 dither = Noise(positionVS, _NoiseIntensity);
                float3 rayDir = reflectDir + dither;
                float3 deltaStep = rayDir * _StepSize;
                float3 currentPos = rayOrg;

                bool intersect = false;
                float2 reflUV = 0;
                // https://zenn.dev/mebiusbox/articles/43ecf1bb12831c
                UNITY_LOOP
                for (int i = 0; i < _MaxStep; i++)
                {
                    if (intersect) break;

                    currentPos += deltaStep ;
                    float reflDepth = -currentPos.z;

                    float4 currentPosCS = mul(unity_CameraProjection, float4(currentPos, 1));
                    currentPosCS.xy /= currentPosCS.w;
                    reflUV = currentPosCS.xy * 0.5 + 0.5;

                    if (reflUV.x >= 1 || reflUV.y >= 1 || reflUV.x < 0 || reflUV.y < 0) break;

                    intersect = rayIntersectsDepth(reflDepth, reflUV);
                }

                // 二分搜索细化
                if (intersect)
                {
                    currentPos -= deltaStep * dither;
                    deltaStep /= BinarySearchIterations;

                    float originalStride = BinarySearchIterations * 0.5;
                    float stride = originalStride;

                    for (int j = 0; j < BinarySearchIterations; j++)
                    {
                        currentPos += deltaStep * stride;
                        float4 currentPosCS = mul(unity_CameraProjection, float4(currentPos, 1));
                        currentPosCS.xy /= currentPosCS.w;
                        reflUV = currentPosCS.xy * 0.5 + 0.5;

                        originalStride *= 0.5;
                        stride = rayIntersectsDepth(currentPos.z, reflUV) ? - originalStride : originalStride;
                    }
                }
                half4 finCol = 0;
                if (intersect)
                {
                    finCol = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, reflUV);
                }



                return finCol;
            }
            ENDHLSL
        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
