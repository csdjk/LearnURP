Shader "Hidden/VolumeCloudBake2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
    }
    SubShader
    {
        Pass
        {
            // Blend SrcAlpha One
            // Blend SrcAlpha OneMinusSrcAlpha
            // Blend One OneMinusSrcAlpha
            // Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "VolumeCloudCore.hlsl"
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            struct Attributes
            {
                float4 vertex : POSITION;
                uint vertexID : SV_VertexID;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 viewRay : TEXCOORD1;
            };


            matrix _FrustumCornersRay;
            int _MaxStep;
            float3 _BoundsMin;
            float3 _BoundsMax;
            float3 _NoiseTiling;
            float4 _NoiseOffset;
            float4 _Color;
            float4 _ShadowColor;
            float4 _CloudData;
            #define _SDFThreshold _CloudData.x
            #define _SDFScale _CloudData.y
            #define _DensityScale _CloudData.z
            #define _LightAbsorption  _CloudData.w

            float4 _ScatterData;

            #define _ScatterForward _ScatterData.x
            #define _ScatterBackward _ScatterData.y
            #define _ScatterWeight _ScatterData.z
            #define _DarknessThreshold _ScatterData.w

            //===========================================================================
            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.vertex);
                output.uv = input.uv;
                // (0,0) (1,0) (0,1) (1,1)
                // 0 1 2 3
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
                // float4 backgroundCol = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);

                float2 screenUV = input.positionCS.xy / _ScaledScreenParams.xy;
                float3 positionWS = ComputePositionWS(input.uv, input.viewRay);


                float3 rayPos = GetCameraPositionWS();
                float3 rayDirection = normalize(positionWS - rayPos);


                float depthEyeLinear = length(positionWS.xyz - _WorldSpaceCameraPos);
                float2 rayToContainerInfo = rayBoxDst(_BoundsMin, _BoundsMax, rayPos, rayDirection);
                float dstToBox = rayToContainerInfo.x; //相机到容器的距离
                float dstInsideBox = rayToContainerInfo.y; // 射线穿过包围盒的距离
                //(相机到物体的距离 - 相机到容器的距离)与射线穿过包围盒的距离，取最小值
                float dstLimit = min(depthEyeLinear - dstToBox, dstInsideBox);


                float3 boundBoxScale = (_BoundsMax - _BoundsMin);
                float boundBoxScaleMax = max(max(boundBoxScale.x, boundBoxScale.y), boundBoxScale.z);

                if (dstLimit < 0 || dstInsideBox == 0)
                {
                    return half4(0, 0, 0, 1);
                }
                float3 startPoint = rayPos + rayDirection * dstToBox;
                float3 curPoint = startPoint;
                float stepSize = dstInsideBox / (float)_MaxStep;

                Light mainLight = GetMainLight();
                float3 lightDir = mainLight.direction;

                float phase = HGScatterLerp(dot(rayDirection, lightDir), _ScatterForward, _ScatterBackward,
                                            _ScatterWeight);
                // ------------------ Ray Marching ------------------
                float3 cloudData;
                float transmittance = 1;
                float totalDensity = 0;
                float rayLength = 0;
                float finalLight = 0;
                for (int i = 0; i < _MaxStep; i++)
                {
                    if (rayLength >= dstLimit)
                    {
                        break;
                    }
                    // 映射到包围盒
                    float3 uvw = (curPoint - _BoundsMin) / (_BoundsMax - _BoundsMin);
                    uvw = uvw * _NoiseTiling + _NoiseOffset;

                    cloudData = SampleDensity(uvw);
                    if (cloudData.x <= _SDFThreshold)
                    {
                        break;
                    }
                    float sdf = cloudData.x * boundBoxScaleMax * _SDFScale;
                    float3 newPoint = curPoint + rayDirection * sdf;

                    totalDensity = totalDensity + cloudData.y * _DensityScale;

                    rayLength += sdf;
                    curPoint = curPoint + rayDirection * sdf;
                }

                totalDensity = saturate(totalDensity);

                // float3 cloud = lerp(_Color, _ShadowColor, 1 - saturate(density));
                // float3 cloud = lerp(backgroundCol, 1, (totalDensity));

                float4 finalColor;
                finalColor.rgb = totalDensity;
                finalColor.a = 1;
                return finalColor;
            }
            ENDHLSL
        }
        pass
        {
            Blend One SrcAlpha

            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #pragma vertex vert
            #pragma fragment frag

            TEXTURE2D(_VolumeCloud);
            SAMPLER(sampler_VolumeCloud);

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(appdata input)
            {
                v2f output;

                VertexPositionInputs vertexPos = GetVertexPositionInputs(input.vertex.xyz);
                output.positionCS = vertexPos.positionCS;
                output.uv = input.uv;
                return output;
            }

            half4 frag(v2f input) : SV_Target
            {
                return SAMPLE_TEXTURE2D(_VolumeCloud, sampler_VolumeCloud, input.uv);
            }
            ENDHLSL
        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
