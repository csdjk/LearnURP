Shader "LcL/SimpleFurInstance"
{
    Properties
    {
        [Toggle(_SHADOW_ON)]_SHADOW_ON ("Receive Shadow", float) = 1

        _MainTex ("Albedo Tex", 2D) = "white" { }
        _DiffuseColor ("Diffuse Color", Color) = (1, 1, 1, 1)

        _OcclusionColor ("Occlusion Color", Color) = (0.8, 0.8, 0.8, 1)
        _FresnelLV ("Fresnel LV", Range(0, 1)) = 1
        _LightFilter ("Light Filter", Range(-0.5, 0.5)) = 0.5

        _FurNoiseTex ("Fur Noise", 2D) = "white" { }
        _FurLength ("Fur Length", Range(.0002, 0.3)) = .03
        _EdgeFade ("Edge Fade", Range(0, 1)) = 0.4
        _Gravity ("Gravity", Vector) = (0, -1, 0, 0)
        _GravityStrength ("Gravity Strength", Range(0, 1)) = 0.1

        [Toggle(_SOFT)] _SOFT ("Soft", float) = 1
        [ShowIf(_SOFT, 0)]_CutoffStart ("Alpha Cutoff", Range(0, 1)) = 0.06
        [ShowIf(_SOFT, 0)]_CutoffEnd ("Alpha Cutoff End", Range(0, 1)) = 0.9
        [ShowIf(_SOFT, 1)]_AlphaBase ("Alpha Base", Range(0, 1)) = 0.1
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent+100" "RenderType" = "Transparent"
        }

        LOD 300
        Pass
        {
            Name "SimpleFur"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
//            ZTest Off
//            ZWrite Off

            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma target 2.0
            #pragma only_renderers gles gles3 glcore metal vulkan d3d11

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ACTOR_SHADOW
            #pragma multi_compile _ _DEPTH_FOG

            #pragma shader_feature _ _SOFT
            #pragma shader_feature_local __ _SHADOW_ON
            #pragma multi_compile_instancing

            #define FUR_INSTANCING_ENABLED

            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment

            #include "SimpleFurCore.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "SceneShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
            ZWrite On
            ZTest LEqual
            ColorMask 0
            HLSLPROGRAM
            #pragma target 2.0
            #pragma only_renderers gles gles3 glcore metal vulkan d3d11
            #pragma multi_compile_instancing

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "SimpleFurCore.hlsl"
            ENDHLSL
        }
    }
    Fallback "Transparent/VertexLit"
    CustomEditor "LcLShaderEditor.LcLShaderGUI"
}
