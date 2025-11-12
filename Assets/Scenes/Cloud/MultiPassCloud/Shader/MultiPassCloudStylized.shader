Shader "LcL/Cloud/MultiPassCloud"
{
    Properties
    {
        [Toggle(_SHADOW_ON)]_SHADOW_ON ("Receive Shadow", float) = 1

        _MainTex ("Albedo Tex", 2D) = "white" { }
        _DiffuseColor ("Diffuse Color", Color) = (1, 1, 1, 1)

        _OcclusionColor ("Occlusion Color", Color) = (0.8, 0.8, 0.8, 1)
        _FresnelLV ("Fresnel LV", Range(0, 1)) = 1
        _LightThreshold ("Light Threshold", Range(0, 1)) = 0.5
        _LightSmooth ("Light Smooth", Range(0.001, 0.5)) = 0.05



        [Foldout]_Alpha ("Alpha", float) = 0
        _OffsetIntensity ("Offset Intensity", Range(.0002, 0.3)) = .03
        _CutoffStart ("Cutoff Start", Range(0, 1)) = 0
        _CutoffEnd ("Cutoff End", Range(0, 1)) = 1
        _EdgeFade ("Edge Fade", Range(0, 1)) = 0.4
        [FoldoutEnd]_AlphaBase ("Alpha Base", Range(0, 1)) = 0.1

        [Foldout]_Noise ("Noise", float) = 0
        [Toggle(_USE_3D_NOISE)] _USE_3D_NOISE ("3D Noise", float) = 1
        [ShowIf(_USE_3D_NOISE, 0)]_CloudNoiseTex ("Cloud Noise", 2D) = "white" { }
        [ShowIf(_USE_3D_NOISE, 1)]_CloudNoiseTex3D ("Cloud Noise 3D", 3D) = "" { }
        _NoiseScale ("Noise Scale", Range(0.001,10)) = 1
        _NoisePow ("Noise Power", Range(0.1,5)) = 1
        [FoldoutEnd]_NoiseSpeed ("Noise Speed", Vector) = (0,0,0,0)

        [Foldout]_RIM_LIGHT ("Rim", float) = 0
        _RimColor ("Rim Color", Color) = (1, 1, 1, 1)
        _RimPow ("Rim Power", Range(0.1, 10)) = 2
        [FoldoutEnd]_RimIntensity ("Rim Intensity", Range(0, 5)) = 1

        [Foldout]_SSS ("SSS", float) = 0
        _Ambient ("Ambient", Color) = (0.5, 0.5, 0.5, 1)
        _NormalDist ("Normal Distortion", Range(0, 1)) = 0
        _Scattering ("Scattering", Range(0.001, 5)) = 1
        _Direct ("Direct", Range(0, 1)) = 0.5
        [FoldoutEnd]_Translucency ("Translucency", Range(0, 1)) = 0.5


    }
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent+100" "RenderType" = "Transparent"
        }
//        Cull Off

        LOD 300
        Pass
        {
            Name "Cloud"
            Tags
            {
                "LightMode" = "UniversalCloud"
            }

            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma target 2.0
            #pragma only_renderers gles gles3 glcore metal vulkan d3d11

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ACTOR_SHADOW
            #pragma multi_compile _ _DEPTH_FOG

            #pragma multi_compile _ _USE_3D_NOISE
            #pragma shader_feature_local __ _SHADOW_ON


            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment

            #include "MultiPassCloudCoreStylized.hlsl"
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

            #include "MultiPassCloudCore.hlsl"
            ENDHLSL
        }
    }
    Fallback "Transparent/VertexLit"
    CustomEditor "LcLShaderEditor.LcLShaderGUI"
}
