Shader "Hidden/LcLPostProcess/HBAO"
{
    HLSLINCLUDE
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl"


    TEXTURE2D(_SourceTex);
    TEXTURE2D(_NoiseTex);
    TEXTURE2D(_HBAOTexture);


    float4 _SourceSize;
    SamplerState sampler_LinearClamp;
    SamplerState sampler_PointRepeat;


    float4 _Jitter;
    float4 _Params;
    float4 _Params2;
    float4 _BlurOffset;


    #define _Radius _Params.x
    #define _AngleBias _Params.y
    #define _Intensity _Params.z
    #define _MaxRadiusPixels _Params.w

    #define _MaxDistance _Params2.x
    #define _DistanceFalloff _Params2.y
    #define _NegInvRadius2 _Params2.z
    #define _AoMultiplier _Params2.w


    #define NUM_DIRECTIONS  4
    #define NUM_STEPS  4

    static const half kGeometryCoeff = half(0.8);

    struct Attributes
    {
        float4 positionOS : POSITION;
        float2 uv : TEXCOORD0;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float2 uv : TEXCOORD0;
        UNITY_VERTEX_OUTPUT_STEREO
    };

    Varyings DefaultVertex(Attributes input)
    {
        Varyings output;
        UNITY_SETUP_INSTANCE_ID(input);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
        output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
        output.uv = input.uv;
        return output;
    }

    inline half4 PackNormalAO(half3 n, half ao)
    {
        return half4(n * half(0.5) + half(0.5), ao);
    }
    inline half3 GetPackedNormal(half4 p)
    {
        return p.rgb * half(2.0) - half(1.0);
    }
    inline half GetPackedAO(half4 p)
    {
        return p.a;
    }

    //https://forum.unity.com/threads/horizon-based-ambient-occlusion-hbao-image-effect.387374/page-21
    inline float3 FetchViewPos(float2 uv)
    {
        float3x3 camProj = (float3x3)unity_CameraProjection;
        //投影矩阵的元素11和22分别对应于相机的水平和垂直视场（FOV），
        //元素13和23对应于相机的主点偏移（通常为0，除非相机被偏移）
        float2 p11_22 = rcp(float2(camProj._11, camProj._22));
        float2 p13_23 = float2(camProj._13, camProj._23);

        float3 viewPos;
        float depth = SampleSceneDepth(uv);
        if (IsPerspectiveProjection())
        {
            depth = LinearEyeDepth(depth, _ZBufferParams);
            viewPos = float3(depth * ((uv.xy * 2.0 - 1.0 - p13_23) * p11_22), depth);
        }
        else
        {
            #if UNITY_REVERSED_Z
                depth = 1 - depth;
            #endif
            // near + depth * (far - near)
            depth = _ProjectionParams.y + depth * (_ProjectionParams.z - _ProjectionParams.y);
            viewPos = float3(((uv.xy * 2.0 - 1.0 - p13_23) * p11_22), depth);
        }

        viewPos.y *= -1;
        return viewPos;
    }

    inline float3 MinDiff(float3 P, float3 Pr, float3 Pl)
    {
        float3 V1 = Pr - P;
        float3 V2 = P - Pl;
        return (dot(V1, V1) < dot(V2, V2)) ? V1 : V2;
    }

    inline float3 FetchViewNormals(float2 uv, float2 delta, float3 P)
    {
        #ifdef NORMALS_RECONSTRUCT4
            float3 Pr, Pl, Pt, Pb;
            Pr = FetchViewPos(uv + float2(delta.x, 0));
            Pl = FetchViewPos(uv + float2(-delta.x, 0));
            Pt = FetchViewPos(uv + float2(0, delta.y));
            Pb = FetchViewPos(uv + float2(0, -delta.y));
            float3 N = normalize(cross(MinDiff(P, Pr, Pl), MinDiff(P, Pt, Pb)));
        #elif NORMALS_RECONSTRUCT2
            float3 Pr, Pt;
            Pr = FetchViewPos(uv + float2(delta.x, 0));
            Pt = FetchViewPos(uv + float2(0, delta.y));
            float3 N = normalize(cross(Pt - P, P - Pr));
        #else
            float3 N = SampleSceneNormals(uv) * 2 - 1;
            N = mul(unity_WorldToCamera, float4(N, 0)).xyz;
            N = normalize(N);
            N = float3(N.x, -N.yz);
        #endif
        return N;
    }


    inline float2 FetchNoise(float2 screenPos)
    {
        #ifdef INTERLEAVED_GRADIENT_NOISE
            // Use Jorge Jimenez's IGN noise and GTAO spatial offsets distribution
            // https://blog.selfshadow.com/publications/s2016-shading-course/activision/s2016_pbs_activision_occlusion.pdf (slide 93)
            // return float2(InterleavedGradientNoise(screenPos, 0), SAMPLE_TEXTURE2D(_NoiseTex, sampler_PointRepeat, screenPos / 4.0).g);
            return InterleavedGradientNoise(screenPos, 0);
        #else
            // (cos(alpha), sin(alpha), jitter)
            return SAMPLE_TEXTURE2D(_NoiseTex, sampler_PointRepeat, screenPos / 4.0).rg;
        #endif
    }

    inline float2 GetJitter(float2 screenPos)
    {
        #if AO_DEINTERLEAVED
            return _Jitter;
        #else
            return FetchNoise(screenPos * _SourceSize.xy);
        #endif
    }


    float Falloff(float DistanceSquare)
    {
        // 1 scalar mad instruction
        return DistanceSquare * _NegInvRadius2 + 1.0;
    }

    //----------------------------------------------------------------------------------
    // P = view-space position at the kernel center
    // N = view-space normal at the kernel center
    // S = view-space position of the current sample
    //----------------------------------------------------------------------------------
    float ComputeAO(float3 P, float3 N, float3 S)
    {
        float3 V = S - P;
        float VdotV = dot(V, V);
        float NdotV = dot(N, V) * rsqrt(VdotV);

        // Use saturate(x) instead of max(x,0.f) because that is faster on Kepler
        return clamp(NdotV - _AngleBias, 0, 1) * clamp(Falloff(VdotV), 0, 1);
    }

    float2 RotateDirection(float2 Dir, float2 CosSin)
    {
        return float2(Dir.x * CosSin.x - Dir.y * CosSin.y, Dir.x * CosSin.y + Dir.y * CosSin.x);
    }

    float ComputeCoarseAO(float2 uv, float3 positionVS, float3 normalVS, float2 rand)
    {
        #if AO_DEINTERLEAVED
            radius /= 4.0;
        #endif

        // Divide by NUM_STEPS+1 so that the farthest samples are not fully attenuated
        // float stepSize = 50 / (NUM_STEPS + 1);
        float stepSize = min((_Radius / positionVS.z), _MaxRadiusPixels) / (NUM_STEPS + 1.0);

        const float alpha = 2.0 * PI / NUM_DIRECTIONS;
        float ao = 0;

        UNITY_UNROLL
        for (float d = 0; d < NUM_DIRECTIONS; ++d)
        {
            // float angle = alpha * float(d);
            float angle = alpha * (float(d) + rand.x);

            // Compute normalized 2D direction
            float cosA, sinA;
            sincos(angle, sinA, cosA);
            // float2 direction = RotateDirection(float2(cosA, sinA), rand.xy);
            float2 direction = float2(cosA, sinA);

            // Jitter starting sample within the first step
            float rayPixels = (frac(rand.y) * stepSize + 1.0);

            for (float step = 0; step < NUM_STEPS; ++step)
            {
                #if AO_DEINTERLEAVED
                    float2 snappedUV = round(rayPixels * direction) * control.InvQuarterResolution + uv;
                    float3 S = FetchQuarterResViewPos(snappedUV);
                #else
                    float2 snappedUV = round(rayPixels * direction) * _SourceSize.zw + uv;
                    float3 S = FetchViewPos(snappedUV);
                #endif

                rayPixels += stepSize;

                ao += ComputeAO(positionVS, normalVS, S);
            }
        }

        ao = ao * _AoMultiplier / (NUM_DIRECTIONS * NUM_STEPS);
        ao = saturate(ao * _Intensity);

        return 1 - ao;
    }




    half4 HBAOFragment(Varyings input) : SV_Target
    {
        float2 uv = input.uv;
        float3 positionVS = FetchViewPos(uv);
        float3 normalVS = FetchViewNormals(uv, _SourceSize.zw, positionVS);
        float2 jitter = GetJitter(uv);

        float ao = ComputeCoarseAO(uv, positionVS, normalVS, jitter);

        //根据距离进行衰减,
        float fallOffStart = _MaxDistance - _DistanceFalloff;
        float distFactor = saturate((positionVS.z - fallOffStart) / (_MaxDistance - fallOffStart));

        ao = lerp(ao, 1, distFactor);

        return PackNormalAO(normalVS, ao);
    }

    // ================================ Blur ================================
    struct BlurVaryings
    {
        float4 positionCS : SV_POSITION;
        float2 uv : TEXCOORD0;
        float4 uv01 : TEXCOORD1;
        float4 uv23 : TEXCOORD2;
    };
    BlurVaryings BlurVertex(Attributes input)
    {
        BlurVaryings ouput;
        ouput.positionCS = TransformWorldToHClip(input.positionOS);
        float2 uv = input.uv;
        ouput.uv = uv;

        float4 offset = _BlurOffset * _SourceSize.zwzw;
        ouput.uv01 = uv.xyxy + offset.xyxy * float4(1, 1, -1, -1);
        ouput.uv23 = uv.xyxy + offset.xyxy * float4(1, 1, -1, -1) * 2.0;
        return ouput;
    }

    half CompareNormal(float3 normal1, float3 normal2)
    {
        return smoothstep(kGeometryCoeff, 1.0, dot(normal1, normal2));
    }

    half4 BlurFragment(BlurVaryings i) : SV_Target
    {
        float4 color0 = SAMPLE_TEXTURE2D(_SourceTex, sampler_LinearClamp, i.uv);
        float4 color1 = SAMPLE_TEXTURE2D(_SourceTex, sampler_LinearClamp, i.uv01.xy);
        float4 color2 = SAMPLE_TEXTURE2D(_SourceTex, sampler_LinearClamp, i.uv01.zw);
        float4 color3 = SAMPLE_TEXTURE2D(_SourceTex, sampler_LinearClamp, i.uv23.xy);
        float4 color4 = SAMPLE_TEXTURE2D(_SourceTex, sampler_LinearClamp, i.uv23.zw);


        float3 normal0 = GetPackedNormal(color0);
        float3 normal1 = GetPackedNormal(color1);
        float3 normal2 = GetPackedNormal(color2);
        float3 normal3 = GetPackedNormal(color3);
        float3 normal4 = GetPackedNormal(color4);

        float w0 = 0.4026;
        float w1 = CompareNormal(normal0, normal1) * 0.2442;
        float w2 = CompareNormal(normal0, normal2) * 0.2442;
        float w3 = CompareNormal(normal0, normal3) * 0.0545;
        float w4 = CompareNormal(normal0, normal4) * 0.0545;

        half ao = 0;
        ao += w0 * GetPackedAO(color0);
        ao += w1 * GetPackedAO(color1);
        ao += w2 * GetPackedAO(color2);
        ao += w3 * GetPackedAO(color3);
        ao += w4 * GetPackedAO(color4);

        ao *= rcp(w0 + w1 + w2 + w3 + w4);

        return PackNormalAO(normal0, ao);
    }

    // ================================ Combine ================================
    half4 CombineFragment(Varyings input) : SV_Target
    {
        half ao = SAMPLE_TEXTURE2D(_HBAOTexture, sampler_LinearClamp, input.uv).a;
        return ao;
    }
    ENDHLSL

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        LOD 100
        ZTest Always ZWrite Off Cull Off

        Pass
        {
            Name "HBAO"

            HLSLPROGRAM

            #pragma multi_compile_local __ INTERLEAVED_GRADIENT_NOISE
            #pragma multi_compile_local __ NORMALS_RECONSTRUCT2 NORMALS_RECONSTRUCT4 NORMALS_CAMERA

            #pragma vertex DefaultVertex
            #pragma fragment HBAOFragment
            #pragma target 4.5
            ENDHLSL
        }

        Pass
        {
            Name "HBAO Blur"

            HLSLPROGRAM
            #pragma vertex BlurVertex
            #pragma fragment BlurFragment
            #pragma target 4.5
            ENDHLSL
        }

        Pass
        {
            Name "HBAO Combine"
            Blend DstColor Zero

            HLSLPROGRAM
            #pragma vertex DefaultVertex
            #pragma fragment CombineFragment
            #pragma target 4.5
            ENDHLSL
        }
    }
}
