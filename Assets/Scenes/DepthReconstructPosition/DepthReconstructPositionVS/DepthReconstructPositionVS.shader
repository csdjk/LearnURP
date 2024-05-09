Shader "Hidden/LcL/Depth/DepthReconstructPositionVS"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }

    HLSLINCLUDE
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"
    #include "Packages/com.unity.render-pipelines.universal@12.1.7/ShaderLibrary/DeclareDepthTexture.hlsl"

    float _ShowViewPos;
    TEXTURE2D(_MainTex);

    float3 ReconstructViewPos(float2 uv)
    {
        float depth = SampleSceneDepth(uv);
        float2 newUV = float2(uv.x, uv.y);
        newUV = newUV * 2 - 1;
        float4 viewPos = mul(UNITY_MATRIX_I_P, float4(newUV, depth, 1));
        viewPos /= viewPos.w;
        viewPos.z = -viewPos.z;
        return viewPos.xyz;
    }

    //https://forum.unity.com/threads/horizon-based-ambient-occlusion-hbao-image-effect.387374/page-21
    inline float3 ReconstructViewPos2(float2 uv)
    {
        // float3x3 camProj = (float3x3)UNITY_MATRIX_P;
        float3x3 camProj = (float3x3)unity_CameraProjection;
        float2 p11_22 = rcp(float2(camProj._11, camProj._22));
        float2 p13_31 = float2(camProj._13, camProj._23);

        float3 viewPos;
        float depth = SampleSceneDepth(uv);
        if (IsPerspectiveProjection())
        {
            depth = LinearEyeDepth(depth, _ZBufferParams);
            viewPos = float3(depth * ((uv.xy * 2.0 - 1.0 - p13_31) * p11_22), depth);
        }
        else
        {
            #if UNITY_REVERSED_Z
			depth = 1 - depth;
            #endif
            // near + depth * (far - near)
            depth = _ProjectionParams.y + depth * (_ProjectionParams.z - _ProjectionParams.y);
            viewPos = float3(((uv.xy * 2.0 - 1.0 - p13_31) * p11_22), depth);
        }

        viewPos.y *= -1;
        return viewPos;
    }

    half4 Frag(Varyings input) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        float2 uv = UnityStereoTransformScreenSpaceTex(input.uv);

        if (_ShowViewPos == 0)
        {
            half4 color = SAMPLE_TEXTURE2D_X(_MainTex, sampler_PointClamp, uv);
            return color;
        }
        else
        {
            // float3 viewPos = ReconstructViewPos(uv);
            float3 viewPos = ReconstructViewPos2(uv);
            return float4(viewPos, 1);
        }
    }
    ENDHLSL

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"
        }
        LOD 100
        ZTest Always ZWrite Off Cull Off

        Pass
        {

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            ENDHLSL
        }
    }
}
