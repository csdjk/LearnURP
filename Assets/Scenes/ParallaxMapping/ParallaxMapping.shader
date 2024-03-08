Shader "LcL/ParallaxMapping"
{
    Properties
    {
        _BaseMap ("Base Texture", 2D) = "white" { }
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)

        [Normal]_BumpMap ("Normal Texture", 2D) = "bump" { }
        _BumpScale ("Normal Scale", Float) = 1

        [NoScaleOffset]_MetallicSmoothnessMap ("R-Metallic,G-Smoothness,B-AO,A-Emission", 2D) = "white" { }
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5
        _Metallic ("Metallic", Range(0.0, 1.0)) = 0.0
        _OcclusionPower ("OcclusionPower", Range(0, 1)) = 1

        [Foldout(_EMISSION)]_EMISSION ("Emission", float) = 0
        [FoldoutEnd][Emission]_EmissionColor ("Emission Color", Color) = (0, 0, 0, 0)

        [Foldout()]_PARALLAX ("ParallaxMapping", Float) = 0
        [NoScaleOffset]_ParallaxMap ("ParallaxMap", 2D) = "white" { }
        [Foldout(_POM)] _POM ("POM", float) = 0
        [ShowIf(_POM)]_Steps ("Steps", Range(1, 64)) = 8
        [Toggle(_JITTER)] _JITTER ("Jitter", float) = 0
        [FoldoutEnd][ShowIf(_JITTER)]_JitterScale ("JitterScale", Range(0, 1)) = 0.5
        [FoldoutEnd] _ParallaxAmplitude ("Parallax Amplitude", Range(0, 0.2)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            float4 _BaseColor;
            float _BumpScale;
            float4 _EmissionColor;
            float _Smoothness;
            float _Metallic;
            float _OcclusionPower;
            float _Cutoff;
            float _Parallax;
            float _ParallaxAmplitude;
            float _Steps;
            float _JitterScale;
        CBUFFER_END

        TEXTURE2D(_MetallicSmoothnessMap);
        SAMPLER(sampler_MetallicSmoothnessMap);

        TEXTURE2D(_ParallaxMap);
        SAMPLER(sampler_ParallaxMap);
        ENDHLSL

        Pass
        {
            Tags { "LightMode" = "UniversalForward" }

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
            #pragma shader_feature _POM
            #pragma shader_feature _JITTER

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
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ParallaxMapping.hlsl"
            #include "Assets/Shaders/Libraries/Noise.hlsl"

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
                half4 fogFactorAndVertexLight : TEXCOORD6;

                #ifdef REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
                    float4 shadowCoord : TEXCOORD7;
                #endif
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
                    float sgn = input.tangentWS.w;
                    float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
                    inputData.tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
                    inputData.normalWS = TransformTangentToWorld(normalTS, inputData.tangentToWorld);
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

            inline float2 ParallaxOcclusionMapping(TEXTURE2D_PARAM(heightMap, sampler_heightMap), float2 uvs, float2 dx, float2 dy,
            float3 viewDirTan, int numSteps, float parallax, float refPlane)
            {
                float3 result = 0;
                int stepIndex = 0;
                float layerHeight = 1.0 / numSteps;
                float2 plane = parallax * (viewDirTan.xy / viewDirTan.z);
                uvs.xy += refPlane * plane;
                float2 deltaTex = -plane * layerHeight;
                float2 prevTexOffset = 0;
                float prevRayZ = 1.0f;
                float prevHeight = 0.0f;
                float2 currTexOffset = deltaTex;
                float currRayZ = 1.0f - layerHeight;
                float currHeight = 0.0f;
                float intersection = 0;
                float2 finalTexOffset = 0;
                while (stepIndex < numSteps + 1)
                {
                    currHeight = SAMPLE_TEXTURE2D_GRAD(heightMap, sampler_heightMap, uvs + currTexOffset, dx, dy).r;
                    if (currHeight > currRayZ)
                    {
                        stepIndex = numSteps + 1;
                    }
                    else
                    {
                        stepIndex++;
                        prevTexOffset = currTexOffset ;
                        prevRayZ = currRayZ;
                        prevHeight = currHeight;
                        currTexOffset += deltaTex;
                        currRayZ -= layerHeight;
                    }
                }
                int sectionSteps = 2;
                int sectionIndex = 0;
                float newZ = 0;
                float newHeight = 0;
                while (sectionIndex < sectionSteps)
                {
                    intersection = (prevHeight - prevRayZ) / (prevHeight - currHeight + currRayZ - prevRayZ);
                    finalTexOffset = prevTexOffset +intersection * deltaTex;
                    newZ = prevRayZ - intersection * layerHeight;
                    newHeight = SAMPLE_TEXTURE2D_GRAD(heightMap, sampler_heightMap, uvs + finalTexOffset, dx, dy).r;
                    if (newHeight > newZ)
                    {
                        currTexOffset = finalTexOffset;
                        currHeight = newHeight;
                        currRayZ = newZ;
                        deltaTex = intersection * deltaTex;
                        layerHeight = intersection * layerHeight;
                    }
                    else
                    {
                        prevTexOffset = finalTexOffset;
                        prevHeight = newHeight;
                        prevRayZ = newZ;
                        deltaTex = (1 - intersection) * deltaTex;
                        layerHeight = (1 - intersection) * layerHeight;
                    }
                    sectionIndex++;
                }
                return uvs.xy + finalTexOffset;
            }

            half4 frag(Varyings input) : SV_Target
            {
                half3 viewDirWS = SafeNormalize(input.viewDirWS);
                float3 viewDirTS = GetViewDirectionTangentSpace(input.tangentWS, input.normalWS, viewDirWS);

                #if defined(_POM)
                    uint minSteps = 1;
                    uint maxSteps = _Steps;

                    #ifdef _JITTER
                        float noise = InterleavedGradientNoise(input.positionCS, 0);
                        noise = noise * _JitterScale;
                        maxSteps = maxSteps * 0.5 + maxSteps * noise;
                        maxSteps = max(maxSteps, 1);
                    #endif
                    // 根据视角距离计算迭代次数(视角越远迭代次数越少)
                    float distMask = 1 - saturate(length(input.viewDirWS) * 0.01);
                    // 根据法线和视角夹角计算迭代次数(法线和视角夹角越大迭代次数越少)
                    float NdotV = 1 - saturate(dot(input.normalWS, viewDirWS));

                    distMask *= NdotV;
                    int numSteps = (int)lerp((float)minSteps, (float)maxSteps, distMask);

                    float2 offset = ParallaxOcclusionMapping(TEXTURE2D_ARGS(_ParallaxMap, sampler_ParallaxMap), input.uv,
                    ddx(input.uv), ddy(input.uv), viewDirTS, numSteps, _ParallaxAmplitude, 0);
                    input.uv = offset;
                #else
                    float2 offset = ParallaxMapping(TEXTURE2D_ARGS(_ParallaxMap, sampler_ParallaxMap), viewDirTS, _ParallaxAmplitude, input.uv);
                    input.uv += offset;
                #endif



                SurfaceData surfaceData = InitializeSurfaceData(input);
                InputData inputData = InitializeInputData(input, surfaceData.normalTS);
                half4 color = UniversalFragmentPBR(inputData, surfaceData);

                color.rgb = MixFog(color.rgb, inputData.fogCoord);
                color.a = saturate(color.a);
                return color;
            }
            ENDHLSL
        }


        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

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
