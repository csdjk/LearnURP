Shader "LcL/SDF/SDFTest"
{
    Properties
    {
        _CloudTexture ("Texture", 3D) = "white" { }
        _ColorRamp ("Color Ramp", 2D) = "white" { }
        _VoxelSize ("Voxel Size", Vector) = (1, 1, 1, 1)
        _InvScale ("Inverse Scale", Vector) = (1, 1, 1, 1)
        _GlobalScale ("Global Scale", Vector) = (1, 1, 1, 1)
        _InvResolution ("Inverse Resolution", Float) = 1
        _Scale ("Scale", Float) = 1
        _Offset ("Offset", Float) = 0
    }
    
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Transparent" "RenderPipeline" = "UniversalPipeline" }
        ZTest Always ZWrite Off Cull Off
        Blend SrcAlpha OneMinusSrcAlpha

        
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
        #include "VolumeCloudCore.hlsl"
        ENDHLSL

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };
            
            struct v2f
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 viewRayWS : TEXCOORD1;
                float4 cameraForward : TEXCOORD2;
                float3 samplePos : TEXCOORD3;
            };

            struct f2s
            {
                float4 color : SV_Target;
                float depth : SV_Depth;
            };

            float4 _GlobalScale;
            float _InvResolution;
            float _Scale;
            float _Offset;
            
            TEXTURE3D(_CloudTexture);
            SAMPLER(sampler_CloudTexture);

            
            float4 _CloudTexture_ST;
            SamplerState custom_linear_clamp_sampler;
            
            TEXTURE3D(_ColorRamp);
            SAMPLER(sampler_ColorRamp);

            float3 _VoxelSize;
            float4 _InvScale;
            int _IsNormalMap;

            float sampleSurface(float3 pos)
            {
                return (_CloudTexture.Sample(sampler_CloudTexture, pos).x + _Offset * _InvResolution) * _Scale * _InvResolution;
            }
            float2 RayBoxIntersection(float3 ro, float3 rd, float3 boxSize)
            {
                float3 m = 1.0 / rd;
                float3 n = m * ro;
                float3 k = abs(m) * boxSize;
                float3 t1 = -n - k;
                float3 t2 = -n + k;
                float tN = max(max(t1.x, t1.y), t1.z);
                float tF = min(min(t2.x, t2.y), t2.z);
                if (tN > tF || tF < 0.0) return -1; // no intersection
                return float2(tN, tF);
            }
            // float4 SampleColorRamp(float time)
            // {
            //     return SAMPLE_TEXTURE2D_LOD(_ColorRamp, sampler_ColorRamp,float2(time, 0), 0);
            // }
            f2s raymarch(f2s fragOut, float3 origin, float3 direction, float2 minmaxt, float minSurfaceDist)
            {
                float t = minmaxt.x;
                UNITY_LOOP for (int it = 0; it < 500 && t < minmaxt.y; it++)
                {
                    float3 position = origin + direction * t;
                    float3 scaledPosition = position * _InvScale;
                    float sampleDistance = sampleSurface(scaledPosition + float3(0.5, 0.5, 0.5));
                    t += sampleDistance;

                    if (sampleDistance < minSurfaceDist)
                    {
                        float3 deltaShift = 2 * _InvScale * _InvResolution;

                        float3 delta = float3(sampleSurface(scaledPosition + float3(0.5 + deltaShift.x, 0.5, 0.5)),
                        sampleSurface(scaledPosition + float3(0.5, 0.5 + deltaShift.y, 0.5)),
                        sampleSurface(scaledPosition + float3(0.5, 0.5, 0.5 + deltaShift.z))) - sampleDistance;

                        float3 normal = normalize(float3(delta.x / deltaShift.x, delta.y / deltaShift.y, delta.z / deltaShift.z));

                        float3 eyeNormal = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, normal).xyz);

                        float3 farPoint = -direction * length(_GlobalScale) / 2;
                        float3 nearPoint = -farPoint;
                        float ratio = length(position - nearPoint) / length(farPoint - nearPoint);
                        // fragOut.color.rgb = SampleColorRamp(1 - ratio);
                        fragOut.color.rgb = 1 ;

                        float rim = clamp(pow(1 - abs(eyeNormal.z), 3), 0, 1);
                        fragOut.color.rgb = lerp(fragOut.color.rgb, float3(0.1, 0.1, 0.1), rim);

                        float4 clipPos = TransformObjectToHClip(origin + direction * max(t, 0.1f));
                        fragOut.depth = clipPos.z / clipPos.w;
                        fragOut.color.a = 1;
                        break;
                    }
                }

                return fragOut;
            }
            
            v2f vert(Attributes input)
            {
                v2f output;
                
                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = positionInputs.positionCS;
                output.samplePos = positionInputs.positionWS;
                
                if (IsPerspectiveProjection())
                {
                    output.viewRayWS.xyz = GetWorldSpaceViewDir(positionInputs.positionWS);
                    // 由于Unity的视图空间是右手坐标系，z需要取反（view space z）
                    output.viewRayWS.w = -mul(UNITY_MATRIX_V, float4(output.viewRayWS.xyz, 0.0)).z;
                }
                else
                {
                    float3 viewRay = positionInputs.positionVS;
                    viewRay.z = 0;
                    float3 positionWS = mul(UNITY_MATRIX_I_V, float4(viewRay, 1)).xyz;
                    output.viewRayWS.xyz = positionWS - GetCurrentViewPosition();
                }

                return output;
            }

            //
            float3 ComputePositionWS(float2 screenUV, float4 viewRayWS)
            {
                float3 worldPos;
                real depth = SampleSceneDepth(screenUV);
                // 透视投影
                if (IsPerspectiveProjection())
                {
                    depth = LinearEyeDepth(depth, _ZBufferParams);

                    // 参考https://zhuanlan.zhihu.com/p/590873962
                    // VP = VR/VZ * VD
                    viewRayWS.xyz = viewRayWS.xyz / viewRayWS.w * depth;
                    // MP = MV + VP
                    worldPos = GetCurrentViewPosition() + viewRayWS.xyz;
                }
                else
                {
                    #if !defined(UNITY_REVERSED_Z)
                        depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, depth);
                    #endif
                    // 正交投影
                    depth = LinearDepthToEyeDepth(depth);
                    float3 cameraForward = GetViewForwardDir();
                    worldPos = GetCurrentViewPosition() + viewRayWS.xyz + cameraForward * depth;
                }
                return worldPos;
            }

            
            f2s frag(v2f input) : SV_Target
            {
                f2s fragOut;
                fragOut.color = float4(0, 0, 0, 0);
                fragOut.depth = 0;
                
                float2 screenUV = input.positionCS.xy / _ScaledScreenParams.xy;

                float3 positionWS = ComputePositionWS(screenUV, input.viewRayWS);

                float3 rayOrigin = _WorldSpaceCameraPos;
                float3 rayDirection = normalize(input.samplePos - rayOrigin);

                rayOrigin = mul(unity_WorldToObject, float4(rayOrigin, 1)).xyz;
                rayDirection = mul(unity_WorldToObject, float4(rayDirection, 0)).xyz;

                float minSurfaceDist = pow(_InvResolution, 2);

                float2 isect = RayBoxIntersection(rayOrigin, rayDirection, 0.5 * _VoxelSize);
                if (isect.y < 0.0)
                {
                    fragOut.color = 1 - fragOut.color;
                }
                else
                {
                    isect.x = max(isect.x, 0.0);
                    fragOut = raymarch(fragOut, rayOrigin, rayDirection, isect, minSurfaceDist);
                }


                return fragOut;
            }
            ENDHLSL
        }
    }
}