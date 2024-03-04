Shader "lcl/FloorWater"
{
    Properties
    {
        _BaseMap ("Base Texture", 2D) = "white" { }
        _BaseColor ("Colour", Color) = (0, 0.66, 0.73, 1)
        _ColorPower ("Color Power", Range(0, 10)) = 1
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5

        _BumpMap ("Normal Texture", 2D) = "bump" { }
        _BumpScale ("Normal Scale", Float) = 1
        _OcclusionMap ("Occlusion Texture", 2D) = "white" { }

        _WaterSmoothnessAdd ("Water Smoothness Add", Range(-1, 1)) = 0
        [Foldout()] _WATER ("Water", float) = 0
        _WaterColor ("Water Color(A-Smoothness)", Color) = (0, 0, 0, 1)
        _WaterColorPower ("Water Color Power", Range(1, 2)) = 1.5
        _WaterMetallic ("Water Metallic", Range(0, 1)) = 0.2

        _HeightMap ("Height Texture", 2D) = "black" { }
        _WaterHeight ("Water Height", Range(0, 1)) = 0
        _WaterBlend ("Water Blend", Range(0, 1)) = 0.5

        _RippleMap ("Ripple Flow Texture", 2D) = "white" { }
        _RippleGrid ("Ripple Grid", Vector) = (8, 8, 0, 0)
        [Foldout(_WATER_RIPPLE)] _WATER_RIPPLE ("Ripple", float) = 0
        [Toggle(_WATER_RIPPLE_ADVANCED)] _WATER_RIPPLE_ADVANCED ("Advanced", float) = 0
        [ShowIf(_WATER_RIPPLE_ADVANCED)]_RippleMapAdvanced ("Ripple Texture Advanced", 2D) = "white" { }
        [ShowIf(_WATER_RIPPLE_ADVANCED)]_RippleWeight ("Ripple Weight", Range(0, 5)) = 1
        [ShowIf(_WATER_RIPPLE_ADVANCED)]_RippleFrequency ("Ripple Frequency", Range(0, 15)) = 9
        [ShowIf(_WATER_RIPPLE_ADVANCED)]_RippleFrequencyMax ("Ripple Frequency Max", Range(0, 6)) = 3

        _RippleSpeed ("Ripple Speed", Float) = 10
        [FoldoutEnd]_RippleIntensity ("Ripple Intensity", Range(0, 10)) = 1

        [Foldout(_WATER_FLOW)] _WATER_FLOW ("Water Flow", float) = 0
        _FlowSpeed ("Flow Speed", Float) = 10
        [FoldoutEnd]_FlowIntensity ("Flow Intensity", Range(0, 2)) = 1
        [FoldoutEnd]_FlowDirection ("Flow Direction", Vector) = (0, 0, 0, 0)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            float4 _BaseColor;
            float4 _EmissionColor;
            float _Smoothness;
            float _Cutoff;
            float _BumpScale;
            float _ColorPower;

            // Water Properties
            float4 _WaterColor;
            float4 _RippleMap_ST;
            float2 _RippleGrid;
            float _RippleWeight;
            float _RippleSpeed;
            float _RippleIntensity;
            float _RippleFrequency;
            float _RippleFrequencyMax;

            float _FlowSpeed;
            float _FlowIntensity;


            float _WaterHeight;
            float _WaterBlend;
            float _WaterColorPower;
            float _WaterSmoothnessAdd;
            float _WaterMetallic;

        CBUFFER_END

        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        ENDHLSL

        Pass
        {
            Name "Example"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard SRP library
            // All shaders must be compiled with HLSLcc and currently only gles is not using HLSLcc by default
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x gles
            // #pragma enable_d3d11_debug_symbols

            #pragma vertex vert
            #pragma fragment frag

            #define BUMP_SCALE_NOT_SUPPORTED 0

            // Material Keywords
            #pragma shader_feature _NORMALMAP
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _EMISSION
            //#pragma shader_feature _METALLICSPECGLOSSMAP
            //#pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            //#pragma shader_feature _OCCLUSIONMAP

            //#pragma shader_feature _SPECULARHIGHLIGHTS_OFF
            //#pragma shader_feature _ENVIRONMENTREFLECTIONS_OFF
            //#pragma shader_feature _SPECULAR_SETUP
            #pragma shader_feature _RECEIVE_SHADOWS_OFF
            // URP Keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE

            // Unity defined keywords
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog


            #pragma multi_compile _ _WATER_FLOW
            #pragma multi_compile _ _WATER_RIPPLE
            #pragma multi_compile _ _WATER_RIPPLE_ADVANCED


            // Includes
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "Assets\Scenes\RainRipple\Shader\WeaterCore.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
                float2 lightmapUV : TEXCOORD1;
            };


            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
                DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);

                #ifdef REQUIRES_WORLD_SPACE_POS_INTERPOLATOR
                    float3 positionWS : TEXCOORD2;
                #endif

                float3 normalWS : TEXCOORD3;
                #ifdef _NORMALMAP
                    float4 tangentWS : TEXCOORD4;
                #endif

                float3 viewDirWS : TEXCOORD5;
                half4 fogFactorAndVertexLight : TEXCOORD6; // x: fogFactor, yzw: vertex light

                #ifdef REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
                    float4 shadowCoord : TEXCOORD7;
                #endif
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS.xyz);
                OUT.positionCS = positionInputs.positionCS;
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);

                OUT.color = IN.color;

                #ifdef REQUIRES_WORLD_SPACE_POS_INTERPOLATOR
                    OUT.positionWS = positionInputs.positionWS;
                #endif

                OUT.viewDirWS = GetWorldSpaceViewDir(positionInputs.positionWS);

                VertexNormalInputs normalInputs = GetVertexNormalInputs(IN.normalOS, IN.tangentOS);
                OUT.normalWS = normalInputs.normalWS;
                #ifdef _NORMALMAP
                    real sign = IN.tangentOS.w * GetOddNegativeScale();
                    OUT.tangentWS = half4(normalInputs.tangentWS.xyz, sign);
                #endif

                half3 vertexLight = VertexLighting(positionInputs.positionWS, normalInputs.normalWS);
                half fogFactor = ComputeFogFactor(positionInputs.positionCS.z);

                OUT.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

                OUTPUT_LIGHTMAP_UV(IN.lightmapUV, unity_LightmapST, OUT.lightmapUV);
                OUTPUT_SH(OUT.normalWS.xyz, OUT.vertexSH);

                #ifdef REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
                    OUT.shadowCoord = GetShadowCoord(positionInputs);
                #endif

                return OUT;
            }

            InputData InitializeInputData(Varyings IN, half3 normalTS)
            {
                InputData inputData = (InputData)0;

                #if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
                    inputData.positionWS = IN.positionWS;
                #endif

                half3 viewDirWS = SafeNormalize(IN.viewDirWS);
                #ifdef _NORMALMAP
                    float sgn = IN.tangentWS.w; // should be either +1 or -1
                    float3 bitangent = sgn * cross(IN.normalWS.xyz, IN.tangentWS.xyz);
                    inputData.normalWS = TransformTangentToWorld(normalTS, half3x3(IN.tangentWS.xyz, bitangent.xyz, IN.normalWS.xyz));
                #else
                    inputData.normalWS = IN.normalWS;
                #endif

                inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
                inputData.viewDirectionWS = viewDirWS;

                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    inputData.shadowCoord = IN.shadowCoord;
                #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
                    inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
                #else
                    inputData.shadowCoord = float4(0, 0, 0, 0);
                #endif

                inputData.fogCoord = IN.fogFactorAndVertexLight.x;
                inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
                inputData.bakedGI = SAMPLE_GI(IN.lightmapUV, IN.vertexSH, inputData.normalWS);
                return inputData;
            }

            SurfaceData InitializeSurfaceData(Varyings IN)
            {
                SurfaceData surfaceData = (SurfaceData)0;

                half4 albedoAlpha = SampleAlbedoAlpha(IN.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
                surfaceData.alpha = Alpha(albedoAlpha.a, _BaseColor, _Cutoff);
                surfaceData.albedo = albedoAlpha.rgb * _BaseColor.rgb * IN.color.rgb;

                surfaceData.normalTS = SampleNormal(IN.uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
                surfaceData.emission = SampleEmission(IN.uv, _EmissionColor.rgb,
                TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap));
                surfaceData.occlusion = SAMPLE_TEXTURE2D(_OcclusionMap, sampler_OcclusionMap, IN.uv).r;
                surfaceData.smoothness = _Smoothness;
                surfaceData.metallic = 0;
                return surfaceData;
            }


            half4 frag(Varyings IN) : SV_Target
            {
                SurfaceData surfaceData = InitializeSurfaceData(IN);

                WetlandData wetlandData = InitWetlandData(surfaceData.albedo, surfaceData.normalTS,
                surfaceData.smoothness,
                surfaceData.metallic, _ColorPower);

                WaterData waterData = InitWaterData(_WaterColor.rgb, _WaterColorPower,
                _WaterSmoothnessAdd, _WaterMetallic, _WaterHeight, _WaterBlend);
                float4 ripple_uv = IN.uv.xyxy * _RippleMap_ST;

                wetlandData = BlendWater(
                    wetlandData, waterData, IN.uv, ripple_uv, float2(_RippleSpeed, _FlowSpeed),
                    float2(_RippleIntensity, _FlowIntensity), _RippleGrid, _RippleWeight, _RippleFrequency, _RippleFrequencyMax
                );
                surfaceData.albedo = wetlandData.albedo;
                surfaceData.smoothness = wetlandData.smoothness;
                surfaceData.normalTS = wetlandData.normalTS;
                surfaceData.metallic = wetlandData.metallic;

                InputData inputData = InitializeInputData(IN, surfaceData.normalTS);

                half4 color = UniversalFragmentPBR(inputData, surfaceData.albedo, surfaceData.metallic,
                surfaceData.specular, surfaceData.smoothness,
                surfaceData.occlusion,
                surfaceData.emission, surfaceData.alpha);

                color.rgb = MixFog(color.rgb, inputData.fogCoord);
                color.a = saturate(color.a);
                return color;
            }
            ENDHLSL
        }

        // UsePass "Universal Render Pipeline/Lit/ShadowCaster"
        // Note, you can do this, but it will break batching with the SRP Batcher currently due to the CBUFFERs not being the same.
        // So instead, we'll define the pass manually :
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On
            ZTest LEqual

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x gles
            //#pragma target 4.5

            // Material Keywords
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }
    }
    CustomEditor "LcLShaderEditor.LcLShaderGUI"
}
