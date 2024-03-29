Shader "LcL/DepthRim"
{
    Properties
    {
        _BaseMap ("Base Texture", 2D) = "white" { }
        _BaseColor ("Example Color", Color) = (1, 1, 1, 1)

        [Normal]_BumpMap ("Normal Texture", 2D) = "bump" { }
        _BumpScale ("Normal Scale", Float) = 1

        [NoScaleOffset]_MetallicSmoothnessMap ("R-Metallic,G-Smoothness,B-AO,A-Emission", 2D) = "white" { }
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5
        _Metallic ("Metallic", Range(0.0, 1.0)) = 0.0
        _OcclusionPower ("OcclusionPower", Range(0, 1)) = 1

        [Foldout(_EMISSION)]_EMISSION ("Emission", float) = 0
        [FoldoutEnd][Emission]_EmissionColor ("Emission Color", Color) = (0, 0, 0, 0)


        [Foldout()]_RIM_LIGHT ("Rim Light", float) = 0
        _RimLightColor ("Rim Light Color", Color) = (1, 1, 1, 1)
        _RimLightWidth ("Rim Light Width", Range(0, 0.1)) = 0.005
        _RimLightThreshold ("Rim Light Threshold", Range(0, 1)) = 0.5
        [FoldoutEnd]_RimLightSmoothness ("Rim Light Smoothness", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"
        }

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            float4 _BaseColor;
            float4 _EmissionColor;

            float4 _RimLightColor;
            float _BumpScale;
            float _Smoothness;
            float _Metallic;
            float _OcclusionPower;
            float _Cutoff;

            float _RimLightWidth;
            float _RimLightThreshold;
            float _RimLightSmoothness;
        CBUFFER_END

        TEXTURE2D(_MetallicSmoothnessMap);
        SAMPLER(sampler_MetallicSmoothnessMap);
        ENDHLSL

        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma only_renderers gles gles3 glcore d3d11

            #pragma vertex vert
            #pragma fragment frag

            #pragma shader_feature _NORMALMAP
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _EMISSION
            //#pragma shader_feature _METALLICSPECGLOSSMAP
            //#pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            //#pragma shader_feature _OCCLUSIONMAP
            //#pragma shader_feature _ _CLEARCOAT _CLEARCOATMAP // URP v10+

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

            #define  _NORMALMAP
            #define BUMP_SCALE_NOT_SUPPORTED 0
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"


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

                float4 positionNDC : TEXCOORD8;
            };

            Varyings vert(Attributes input)
            {
                Varyings output;

                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = positionInputs.positionCS;
                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                output.color = input.color;

                #ifdef REQUIRES_WORLD_SPACE_POS_INTERPOLATOR
                output.positionWS = positionInputs.positionWS;
                #endif

                output.viewDirWS = GetWorldSpaceViewDir(positionInputs.positionWS);

                VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                output.normalWS = normalInputs.normalWS;
                #ifdef _NORMALMAP
                real sign = input.tangentOS.w * GetOddNegativeScale();
                output.tangentWS = half4(normalInputs.tangentWS.xyz, sign);
                #endif

                half3 vertexLight = VertexLighting(positionInputs.positionWS, normalInputs.normalWS);
                half fogFactor = ComputeFogFactor(positionInputs.positionCS.z);

                output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

                OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
                OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

                #ifdef REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
                    output.shadowCoord = GetShadowCoord(positionInputs);
                #endif

                output.positionNDC = positionInputs.positionNDC;

                return output;
            }

            InputData InitializeInputData(Varyings input, half3 normalTS)
            {
                InputData inputData = (InputData)0;

                #if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
                inputData.positionWS = input.positionWS;
                #endif

                half3 viewDirWS = SafeNormalize(input.viewDirWS);
                #ifdef _NORMALMAP
                float sgn = input.tangentWS.w; // should be either +1 or -1
                float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
                inputData.normalWS = TransformTangentToWorld(
                    normalTS, half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz));
                #else
                    inputData.normalWS = input.normalWS;
                #endif

                inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
                inputData.viewDirectionWS = viewDirWS;

                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    inputData.shadowCoord = input.shadowCoord;
                #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
                    inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
                #else
                inputData.shadowCoord = float4(0, 0, 0, 0);
                #endif

                inputData.fogCoord = input.fogFactorAndVertexLight.x;
                inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
                inputData.bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, inputData.normalWS);
                return inputData;
            }

            SurfaceData InitializeSurfaceData(Varyings input)
            {
                SurfaceData surfaceData = (SurfaceData)0;

                half4 albedoAlpha = SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
                surfaceData.alpha = Alpha(albedoAlpha.a, _BaseColor, _Cutoff);
                surfaceData.albedo = albedoAlpha.rgb * _BaseColor.rgb * input.color.rgb;

                half4 mask = SAMPLE_TEXTURE2D(_MetallicSmoothnessMap, sampler_MetallicSmoothnessMap, input.uv);

                surfaceData.metallic = mask.r * _Metallic;
                surfaceData.smoothness = mask.g * _Smoothness;
                surfaceData.normalTS = SampleNormal(input.uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);

                surfaceData.occlusion = LerpWhiteTo(mask.b, _OcclusionPower);
                #ifdef _EMISSION
                    surfaceData.emission = albedoAlpha.rgb * _EmissionColor * mask.a;
                #else
                surfaceData.emission = half3(0, 0, 0);
                #endif
                return surfaceData;
            }

            float3 CalculateDepthRimLight(float2 screenPos, float3 normalWS, float depth)
            {
                float3 normalVS = TransformWorldToViewDir(normalWS, true);

                //Self Depth
                float depthSelf = LinearEyeDepth(depth, _ZBufferParams);

                //Offset Depth
                float2 offset = screenPos + normalVS * _RimLightWidth;
                float depthOffset = SampleSceneDepth(offset);
                depthOffset = LinearEyeDepth(depthOffset, _ZBufferParams);

                // Depth Diff
                float depthDiff = depthOffset - depthSelf;

                half rimIntensity = smoothstep(_RimLightThreshold - _RimLightSmoothness,
                _RimLightThreshold + _RimLightSmoothness, depthDiff);

                // half rimIntensity = smoothstep(0, 1, depthDiff);
                half3 rimLight = rimIntensity * _RimLightColor;

                return rimLight;
            }


            half4 frag(Varyings input) : SV_Target
            {
                SurfaceData surfaceData = InitializeSurfaceData(input);
                InputData inputData = InitializeInputData(input, surfaceData.normalTS);
                half4 color = UniversalFragmentPBR(inputData, surfaceData);


                half2 screenPos = input.positionCS.xy / _ScaledScreenParams.xy;
                half3 rimLight = CalculateDepthRimLight(screenPos, input.normalWS, input.positionCS.z);
                color.rgb += rimLight;

                color.rgb = MixFog(color.rgb, inputData.fogCoord);

                color.a = saturate(color.a);

                return color;
            }
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            ZWrite On
            ZTest LEqual

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma only_renderers gles gles3 glcore d3d11

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
