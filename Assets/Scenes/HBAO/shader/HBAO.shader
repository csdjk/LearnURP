Shader "Hidden/LcLPostProcess/HBAO"
{
    HLSLINCLUDE
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl"


    TEXTURE2D(_SourceTex);
    TEXTURE2D(_NoiseTex);

    float4 _SourceSize;
    SamplerState sampler_LinearClamp;
    SamplerState sampler_PointRepeat;


    float4x4 _FrustumCornersRay;
    float4 _Jitter;
    float4 _Params;
    float4 _Params2;


    #define _Radius _Params.x
    #define _AngleBias _Params.y
    #define _Intensity _Params.z
    #define _MaxRadiusPixels _Params.w

    #define _MaxDistance _Params2.x
    #define _DistanceFalloff _Params2.y
    #define _NegInvRadius2 _Params2.z
    #define _AoMultiplier _Params2.w

    #define NORMALS_RECONSTRUCT4
    #define INTERLEAVED_GRADIENT_NOISE

    #define NUM_DIRECTIONS  4
    #define NUM_STEPS  4


    struct Attributes
    {
        float4 positionHCS : POSITION;
        float2 uv : TEXCOORD0;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float2 uv : TEXCOORD0;
        float3 viewFrustumVectors : TEXCOORD1;
        UNITY_VERTEX_OUTPUT_STEREO
    };

    // #pragma enable_d3d11_debug_symbols
    Varyings FullscreenVert(Attributes input)
    {
        Varyings output;
        UNITY_SETUP_INSTANCE_ID(input);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
        output.positionCS = TransformObjectToHClip(input.positionHCS.xyz);
        output.uv = input.uv;

        //uv: (0,0) (1,0) (0,1) (1,1)
        //index: 0 1 2 3
        int index = int(input.uv.x + 0.5) + 2 * int(input.uv.y + 0.5);
        output.viewFrustumVectors = _FrustumCornersRay[index].xyz;
        return output;
    }


    float3 ComputePositionVS(float2 uv, float3 ray)
    {
        float depth = SampleSceneDepth(uv);

        depth = LinearEyeDepth(depth, _ZBufferParams);
        float3 positionVS = ray * depth;

        return positionVS;
    }

    float3 FetchViewPos(float2 uv)
    {
        float depth = SampleSceneDepth(uv);
        float2 newUV = float2(uv.x, uv.y);
        newUV = newUV * 2 - 1;
        float4 viewPos = mul(UNITY_MATRIX_I_P, float4(newUV, depth, 1));
        viewPos /= viewPos.w;
        viewPos.z = -viewPos.z;
        return viewPos.xyz;
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
                    float2 snappedUV = round(rayPixels * Direction) * control.InvQuarterResolution + uv;
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
#pragma enable_d3d11_debug_symbols
    half4 Frag(Varyings input) : SV_Target
    {
        float2 uv = input.uv;
        half3 color = SAMPLE_TEXTURE2D(_SourceTex, sampler_LinearClamp, uv).xyz;

        // float3 positionWS = ComputePositionVS(uv, input.viewFrustumVectors);
        float3 positionVS = FetchViewPos(uv);
        // float3 normalVS = FetchViewNormals(uv);
        float3 normalVS = FetchViewNormals(uv, _SourceSize.zw, positionVS);
        float2 jitter = GetJitter(uv);

        // return half4(jitter.xxx, 1);

        float ao = ComputeCoarseAO(uv, positionVS, normalVS, jitter);

        //根据距离进行衰减,
        float fallOffStart = _MaxDistance - _DistanceFalloff;
        float distFactor = saturate((positionVS.z - fallOffStart) / (_MaxDistance - fallOffStart));

        ao = lerp(ao, 1, distFactor);

        return ao;
        return half4(normalVS, 1);
    }
    ENDHLSL

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        LOD 100
        ZTest Always ZWrite Off Cull Off

        Pass
        {
            Name "LcLRenderShader"

            HLSLPROGRAM
            #pragma vertex FullscreenVert
            #pragma fragment Frag
            #pragma target 4.5
            ENDHLSL
        }
    }
}
