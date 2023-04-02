Shader "lcl/GPUInstance/Grass"
{
    Properties
    {
        //Lighting
        [MainTexture] _BaseMap ("Albedo", 2D) = "white" { }
        _Cutoff ("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

        [Header(Mask)]
        // _MaskMap ("Mask(R-AO)", 2D) = "white" { }
        _OcclusionStrength ("Ambient Occlusion", Range(0.0, 1.0)) = 0.25

        [Header(Shading)]
        [MainColor] _BaseColor ("Color", Color) = (0.49, 0.89, 0.12, 1.0)
        _HueVariation ("Hue Variation (Alpha = Intensity)", Color) = (1, 0.63, 0, 0.15)
        _BaseColor2 ("Color2", Color) = (0.7, 1, 0, 1)
        _BumpMap ("Normal Map", 2D) = "bump" { }
        _BumpScale ("Normal Scale", Float) = 1.0
        _Smoothness ("Reflectivity", Range(0.0, 1.0)) = 0.5
        _ShadowStrength ("Shadow Strength", Range(0.0, 1.0)) = 1
        _IndirectStrength ("Indirect Strength", Range(0.0, 1.0)) = 1

        [Header(SSS)]
        _Translucency ("Translucency", Range(0.0, 1.0)) = 0.2
        _Distortion ("Distortion", Range(0.0, 1.0)) = 0
        _ScaterPower ("Scater Power", Range(1, 10.0)) = 1
        _ScaterScale ("Scater Scale", Range(0.0, 10.0)) = 1

        [Header(Wind)]
        [NoScaleOffset] _WindMap ("Wind Noise", 2D) = "black" { }
        _WindAmbientStrength ("Ambient Strength", Range(0.0, 1.0)) = 0.2
        _WindSpeed ("Wind Speed", Range(0.0, 10.0)) = 3.0
        _WindDirection ("Wind Direction", vector) = (1, 0, 0, 0)
        _WindSwinging ("Swinging", Range(0.0, 1.0)) = 0.15
        _WindGustStrength ("Gusting strength", Range(0.0, 1.0)) = 0.2
        _WindGustFreq ("Gusting frequency", Range(0.0, 10.0)) = 4
        _WindGustTint ("Gusting tint", Range(0.0, 1.0)) = 0.066

        [Header(Rendering)]
        [MaterialEnum(Both, 0, Front, 1, Back, 2)] _Cull ("Render faces", Float) = 0
        // [Toggle] _AlphaToCoverage ("Alpha to coverage", Float) = 0.0

    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "AlphaTest" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True" "NatureRendererInstancing" = "True" }
        
        LOD 600
        Pass
        {
            Tags { "LightMode" = "UniversalForward" }

            // AlphaToMask [_AlphaToCoverage]
            Blend One Zero, One Zero
            Cull [_Cull]
            ZTest LEqual
            ZWrite On

            HLSLPROGRAM

            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
           #pragma enable_d3d11_debug_symbols
            // -------------------------------------
            // Enable feature
            #define _ALPHATEST_ON
            // #define _ADVANCED_LIGHTING
            #define SHADERPASS_FORWARD
            // #define _NORMALMAP
            #define _AO_ON
            #define _SHADOWBIAS_CORRECTION
            // #define _RECEIVE_SHADOWS_OFF
            // #define _ENVIRONMENTREFLECTIONS_OFF


            //Disable features
            #undef _ALPHAPREMULTIPLY_ON
            #undef _EMISSION
            #undef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #undef _OCCLUSIONMAP
            #undef _METALLICSPECGLOSSMAP
            #define _SPECULARHIGHLIGHTS_OFF
            
            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK

            #ifdef _RECEIVE_SHADOWS_OFF
                #undef _MAIN_LIGHT_SHADOWS
                #undef _MAIN_LIGHT_SHADOWS_CASCADE
                #undef _ADDITIONAL_LIGHT_SHADOWS
                #undef _SHADOWS_SOFT
            #endif

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #include "Assets/Scenes/GpuInstance/StylizedGrass.hlsl"
            
            #include "Assets/Shaders/Libraries/VS_InstancedIndirect.cginc"
            #pragma instancing_options assumeuniformscaling renderinglayer procedural:setup
            // #pragma instancing_options procedural:setup


            #pragma vertex LitPassVertex
            #pragma fragment ForwardPassFragment
            // #pragma enable_d3d11_debug_symbols
            
            ENDHLSL

        }

        // Pass
        // {
        //     Name "ShadowCaster"
        //     Tags { "LightMode" = "ShadowCaster" }

        //     ZWrite On
        //     ZTest LEqual
        //     Cull[_Cull]

        //     HLSLPROGRAM

        //     // Required to compile gles 2.0 with standard srp library
        //     #pragma prefer_hlslcc gles
        //     #pragma exclude_renderers d3d11_9x
        //     #pragma target 2.0

        //     //--------------------------------------
        //     // GPU Instancing
        //     #pragma multi_compile_vertex LOD_FADE_PERCENTAGE LOD_FADE_CROSSFADE
        //     #pragma multi_compile_fragment __ LOD_FADE_CROSSFADE
        //     #pragma multi_compile_instancing
        //     #pragma shader_feature_local _BILLBOARD
        //     // #pragma shader_feature_local_fragment _ANGLE_FADING
        //     #define _ALPHATEST_ON

        //     #define SHADERPASS_SHADOWCASTER
        //     #pragma vertex ShadowPassVertex
        //     #pragma fragment ShadowPassFragment

        //     #include "Assets/Shaders/Libraries/Input.hlsl"

        //     #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        //     #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        //     #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"

        //     #include "Assets/Shaders/Libraries/Common.hlsl"
        //     /* start VegetationStudio */
        //     #include "Assets/Shaders/Libraries/VS_InstancedIndirect.cginc"
        //     #pragma instancing_options assumeuniformscaling renderinglayer procedural:setup
        //     /* end VegetationStudio */


        //     #include "Assets/Scenes/GpuInstance/PlantShadowPass.hlsl"

        //     ENDHLSL

        // }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    // CustomEditor "StylizedGrass.StylizedGrassShaderGUI"

}
