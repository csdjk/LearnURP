Shader "LcL/ToonFace"
{
    Properties
    {
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode ("CullMode", float) = 2

        _BaseMap ("Base Texture", 2D) = "white" { }
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)

        [NoScaleOffset]_FaceMap ("R-Outline,G-AO,B-Specular,A-RampLevel", 2D) = "white" { }
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5
        _Metallic ("Metallic", Range(0.0, 1.0)) = 0.0
        _OcclusionPower ("OcclusionPower", Range(0, 1)) = 1

        [Foldout(_EMISSION)]_EMISSION ("Emission", float) = 0
        [Emission]_EmissionColor ("Emission Color", Color) = (0, 0, 0, 0)
        _EmissionThreshold ("Emission Threshold", Range(0,1)) = 0.5
        [FoldoutEnd]_EmissionIntensity ("Emission Intensity", Range(0,10)) = 3


        [Foldout]_SelfShadow ("Self Shadow", float) = 0
        _DiffuseRampMultiTex ("Diffuse Ramp Texture", 2D) = "white" { }
        _DiffuseCoolRampMultiTex ("Diffuse Cool Ramp Texture", 2D) = "white" { }
        [FoldoutEnd]_RampLevel ("Ramp Level", int) = 8

        //        _ShadowColor ("Shadow Color", Color) = (0, 0, 0, 1)
        //        _ShadowThreshold ("Shadow Threshold", Range(0,1)) = 0.5
        //        _ShadowSmoothness ("Shadow Smoothness", Range(0,1)) = 0.5

        [Foldout]_Specular ("Specular", float) = 0
        [Toggle(_USE_MATERIAL_VALUES_LUT)]_USE_MATERIAL_VALUES_LUT ("UseMaterialValuesLUT", float) = 1
        [ShowIf(_USE_MATERIAL_VALUES_LUT)]_MaterialValuesPackLUT ("MaterialValuesPackLUT", 2D) = "white" { }
        _ES_SPColor ("SP Color", Color) = (1,1,1,1)
        _SpecularColor ("Specular Color", Color) = (1,1,1,1)
        _SpecularIntensity ("Specular Intensity", Range(0,1)) = 1
        _SpecularRoughness ("Specular Roughness", Range(0,1)) = 0
        _SpecularShininess ("Specular Shininess", Range(0,100)) = 1
        [FoldoutEnd]_ES_SPIntensity ("SP Intensity", Range(0,1)) = 1

        [Foldout]_Fresnel ("Fresnel", float) = 0
        _FresnelColor ("Fresnel Color", Color) = (1,1,1,1)
        _FresnelColorStrength ("Fresnel Color Strength", Range(0,1)) = 1
        [FoldoutEnd]_FresnelBSI ("Fresnel BSI",Vector) = (1,1,0,0)

        [Foldout]_HeightLerp ("Height Lerp", float) = 0
        _ES_HeightLerpTop ("ES Height Lerp Top", Range(0,1)) = 0.2
        _ES_HeightLerpBottom ("ES Height Lerp Bottom", Range(0,1)) = 0.4
        _ES_HeightLerpTopColor ("ES Height Lerp Top Color", Color) = (1,1,1,0.5)
        _ES_HeightLerpMiddleColor ("ES Height Lerp Middle Color", Color) = (1,1,1,0.5)
        _ES_HeightLerpBottomColor ("ES Height Lerp Bottom Color", Color) = (0.3125,0.3125,0.484,0.5)
        [FoldoutEnd]_CharaWorldSpaceOffset ("Chara World Space Offset", Vector) = (0,0,0,0)


        [Foldout]_CharacterOnly ("Character Only", float) = 0
        _ShadowRamp ("Shadow Ramp", Range(0,1)) = 1
        [FoldoutEnd]_Test1 ("_Test", Range(0,1)) = 0.5



        [Foldout]_ActorLightInfo ("Actor Light Info", float) = 0
        _ES_LevelHighLight ("ES Level HighLight", Range(0,1)) = 1
        _ES_LevelMid ("ES Level Mid", Range(0,1)) = 0.55
        _ES_LevelShadow ("ES Level Shadow", Range(0,1)) = 0

        _NewLocalLightStrength ("New Local Light Strength", Vector) = (0,0,0,0)


        _CharacterLocalMainLightDark ("_CharacterLocalMainLightDark", Vector) = (0,0,0)
        _CharacterLocalMainLightDark1 ("_CharacterLocalMainLightDark1", Vector) = (0,0,0)
        _CharacterLocalMainLightColor1 ("_CharacterLocalMainLightColor1", Color) = (1,1,1,1)
        _CharacterLocalMainLightColor2 ("_CharacterLocalMainLightColor2", Color) = (1,1,1,1)
        _ES_CharacterDisableLocalMainLight ("_ES_CharacterDisableLocalMainLight", float) = 1

        _ES_CharacterShadowFactor ("_ES_CharacterShadowFactor", Range(0,1)) = 1
        [FoldoutEnd]_Test ("_Test", Range(0,1)) = 0.5


        _CustomMainLightDir ("Custom Main Light Dir", Vector) = (1,1,1,0)
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
            float _EmissionIntensity;

            float _BumpScale;
            float _Smoothness;
            float _Metallic;
            float _OcclusionPower;
            float _Cutoff;
            float _ShadowThreshold;
            float _ShadowSmoothness;

            float4 _CharacterLocalMainLightColor1;
            float4 _CharacterLocalMainLightColor2;
            float4 _CharacterLocalMainLightDark;
            float4 _CharacterLocalMainLightDark1;
            float _ShadowRamp;

            int _RampLevel;
            float _ES_Indoor;
            float _ES_LEVEL_ADJUST_ON;
            float _ES_CharacterToonRampMode;
            float _ES_CharacterDisableLocalMainLight;
            float4 _ES_RimShadowColor;
            float _ES_RimShadowIntensity;
            float _ES_CharacterShadowFactor;
            float4 _ES_LevelSkinLightColor;
            float4 _ES_LevelSkinShadowColor;
            float4 _ES_LevelHighLightColor;
            float4 _ES_LevelShadowColor;
            float _ES_LevelShadow;
            float _ES_LevelMid;
            float _ES_LevelHighLight;
            float _ES_IndoorCharShadowAsCookie;

            //pass2

            float4 _CustomMainLightDir;

            //specular
            float4 _SpecularColor;
            float _SpecularShininess;
            float _SpecularIntensity;
            float _SpecularRoughness;

            float _EmissionThreshold;

            float4 _FresnelColor;
            float4 _FresnelBSI;
            float _FresnelColorStrength;

            float4 _CharaWorldSpaceOffset;
        CBUFFER_END

        float4 _ES_AddColor;
        float4 _ES_SPColor;
        float _ES_SPIntensity;

        float4 _ES_ShadowColor;
        float4 _NewLocalLightStrength;

        float _ES_HeightLerpTop;
        float _ES_HeightLerpBottom;
        float4 _ES_HeightLerpTopColor;
        float4 _ES_HeightLerpMiddleColor;
        float4 _ES_HeightLerpBottomColor;

        TEXTURE2D(_FaceMap);
        SAMPLER(sampler_FaceMap);

        TEXTURE2D(_DiffuseRampMultiTex);
        SAMPLER(sampler_DiffuseRampMultiTex);

        TEXTURE2D(_DiffuseCoolRampMultiTex);
        SAMPLER(sampler_DiffuseCoolRampMultiTex);

        TEXTURE2D(_MaterialValuesPackLUT);
        SAMPLER(sampler_MaterialValuesPackLUT);
        ENDHLSL

        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            Cull [_CullMode]

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
            #pragma shader_feature _USE_MATERIAL_VALUES_LUT

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
            #define  BUMP_SCALE_NOT_SUPPORTED 0
            // Includes
            #include "ToonLighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "ToonCore.hlsl"

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

            Varyings vert(Attributes input)
            {
                Varyings output;

                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = positionInputs.positionCS;
                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                output.color = input.color;
                output.positionWS = positionInputs.positionWS;
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

                inputData.positionWS = input.positionWS;
                inputData.normalWS = NormalizeNormalPerPixel(input.normalWS);
                inputData.viewDirectionWS = SafeNormalize(input.viewDirWS);

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
                surfaceData.albedo = albedoAlpha.rgb * _BaseColor.rgb;


                // surfaceData.albedo = outline;
                // surfaceData.metallic = mask.r * _Metallic;
                // surfaceData.smoothness = mask.g * _Smoothness;
                surfaceData.normalTS = SampleNormal(input.uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);

                // surfaceData.occlusion = LerpWhiteTo(mask.b, _OcclusionPower);


                // #ifdef _EMISSION
                // surfaceData.emission = albedoAlpha.rgb * _EmissionColor * mask.a;
                // #else
                //     surfaceData.emission = half3(0, 0, 0);
                // #endif


                return surfaceData;
            }

            half4 frag(Varyings input, half facing:VFACE) : SV_Target
            {
                SurfaceData surfaceData = InitializeSurfaceData(input);
                InputData inputData = InitializeInputData(input, surfaceData.normalTS);

                half2 screenUV = input.positionCS.xy / _ScaledScreenParams.xy;
                //所有角色贴图不要开启Mipmap
                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
                half4 albedo = baseMap * _BaseColor;

                //r = Outline, g = AO, b = 高光强度
                //A 通道不同的颜色阈值（8个色阶）用于区分部位，进行Ramp的区分采样
                half4 mask = SAMPLE_TEXTURE2D(_FaceMap, sampler_FaceMap, input.uv);

                half shadowAO = (mask.y + mask.y) * input.color.x;
                // A通道不同的颜色阈值（8个色阶）用于区分部位，进行Ramp的区分采样
                float rampLevel = floor(mask.a * 8.0);
                rampLevel = frac(0.125 * rampLevel) * 8;
                float rampUV_Y = (rampLevel * 2 + 1) * 0.0625;

                // maskA skin和cloth 区分, skin==0 cloth==1
                //对应frag的408行

                half4 shadowMask = CalculateShadowMask(inputData);
                AmbientOcclusionFactor aoFactor = CreateAmbientOcclusionFactor(inputData, surfaceData);
                Light mainLight = GetMainLight(inputData, shadowMask, aoFactor);
                half3 lightColor = mainLight.color;
                // half3 lightDir = mainLight.direction;
                half shoadow = mainLight.shadowAttenuation;

                half NdotL = saturate(dot(inputData.normalWS, mainLight.direction));
                half halfLambert = saturate(NdotL * 0.5 + 0.5);
                halfLambert = dot(halfLambert.xx, shadowAO.xx) * shadowAO;

                halfLambert = clamp(halfLambert, 0.0, 1.0);
                //...

                float u_xlat54 = 1.0;

                float characterShadowFactor = min(1, _ES_CharacterShadowFactor * halfLambert);

                half u_xlat16_56 = mask.y * input.color.x;
                u_xlat16_56 = min(u_xlat16_56, 0.8);
                u_xlat16_56 = u_xlat54 < 0.1 ? u_xlat16_56 : 1.0;

                //Diffuse Ramp UV
                halfLambert = halfLambert * 0.85 + 0.15;
                half2 diffuseRampUV;
                diffuseRampUV.x = _ShadowRamp < characterShadowFactor ? 1 : halfLambert;
                //y 可以直接取 mask.a , 但是为了容错, 用rampLevel
                diffuseRampUV.y = rampUV_Y;


                half3 ramp = SAMPLE_TEXTURE2D(_DiffuseRampMultiTex, sampler_DiffuseRampMultiTex, diffuseRampUV).rgb;
                half3 rampCool = SAMPLE_TEXTURE2D(_DiffuseCoolRampMultiTex, sampler_DiffuseCoolRampMultiTex,
                                                  diffuseRampUV).rgb;


                float _ES_CharacterToonRampMode = 0;
                float _CharacterToonRampModeCompensation = 0;

                float rampMode = _ES_CharacterToonRampMode - _CharacterToonRampModeCompensation;
                rampMode = clamp(rampMode, 0.0, 1.0);
                float3 rampColor = rampCool.xyz - ramp.xyz;
                rampColor = rampMode.xxx * rampColor.xyz + ramp.xyz;

                //---------------------------------------------
                u_xlat16_56 = 1.0;
                float diffuseShadowMask = diffuseRampUV.x * u_xlat16_56 - 0.8;
                diffuseShadowMask = diffuseShadowMask.x * 10;
                diffuseShadowMask = 1 - smoothstep(0.0, 1.0, diffuseShadowMask.x);
                diffuseShadowMask = diffuseShadowMask * _NewLocalLightStrength.z;
                float3 characterLocalMainLightDark1 = diffuseShadowMask.xxx * (_CharacterLocalMainLightDark1.xyz - 1) +
                    1;
                float3 darkColor1 = characterLocalMainLightDark1 * rampColor;
                // return half4(diffuseShadowMask.xxx, 1);

                float3 characterLocalMainLightDark = diffuseShadowMask.xxx * (_CharacterLocalMainLightDark.xyz - 1) + 1;
                float3 darkColor = characterLocalMainLightDark * rampColor;

                float skinMask = round(rampLevel);
                darkColor = skinMask == 0.0 ? darkColor1 : darkColor;

                // u_xlat16_20.x = dot(darkColor, float3(1, 1, 1));
                //----------------Ramp Diffuse----------------
                float2 lightLevel = float2(_ES_LevelHighLight, _ES_LevelMid) - float2(_ES_LevelMid, _ES_LevelShadow);
                float3 rampDiffuse = darkColor - _ES_LevelMid.xxx;

                rampDiffuse.xyz = rampDiffuse.xyz / lightLevel.xxx;
                rampDiffuse.xyz = rampDiffuse.xyz * 0.5 + 0.5;
                rampDiffuse.xyz = clamp(rampDiffuse.xyz, 0.0, 1.0);

                half3 prevPassColor = albedo.rgb * rampDiffuse.xyz;

                // return half4(finalColor, 1);
                //-----------------------------------------Pass 2-------------------------
                float3 viewDirWS = inputData.viewDirectionWS;

                float3 lightDir = _CustomMainLightDir.xyz - _MainLightPosition.xyz;
                lightDir = _CustomMainLightDir.www * lightDir.xyz + _MainLightPosition.xyz;

                float3 halfDir = normalize(lightDir + viewDirWS);


                float3 normalWS = inputData.normalWS;

                float face = facing > 0 ? 1 : -1;

                normalWS = face * normalWS;
                float NdotV = dot(normalWS, viewDirWS);


                #ifdef _USE_MATERIAL_VALUES_LUT
                //MaterialValuesPackLUT
                float3 packuv = float3(rampLevel.x, 1, 0);
                float3 valuesPackLUT1 = LOAD_TEXTURE2D(_MaterialValuesPackLUT, packuv.xz);
                float3 valuesPackLUT2 = LOAD_TEXTURE2D(_MaterialValuesPackLUT, packuv.xy);

                float3 specularColor = valuesPackLUT1;
                float specularRoughness = valuesPackLUT2.y;
                float specularIntensity = valuesPackLUT2.z;
                float specularShininess = valuesPackLUT2.x;
                #else
                float3 specularColor = _SpecularColor.rgb;
                float specularRoughness = _SpecularRoughness;
                float specularIntensity = _SpecularIntensity;
                float specularShininess = _SpecularShininess;

                #endif


                float3 u_xlat16_12 = _ES_SPColor.xyz - 1;
                (u_xlat16_12.xyz = ((_ES_SPColor.www * u_xlat16_12.xyz) + float3(1.0, 1.0, 1.0)));
                (u_xlat16_12.xyz = (u_xlat16_12.xyz * _ES_SPIntensity));
                specularColor = specularColor * u_xlat16_12.xyz;

                float NdotH = dot(normalWS, halfDir);

                float specular = pow(max(NdotH, 0.001), specularShininess);

                specularRoughness = max(specularRoughness, 0.001);

                float invMaskZ = 1 - mask.z;
                float u_xlat16_33 = invMaskZ - specularRoughness;

                float u_xlat16_32 = specularRoughness + invMaskZ;

                u_xlat16_32 = u_xlat16_32 - u_xlat16_33;

                specular = specular * shoadow - u_xlat16_33;

                (u_xlat16_32 = (1.0 / u_xlat16_32));
                (specular = (u_xlat16_32 * specular));

                specular = smoothstep(0, 1, specular);

                float3 specColor = specularColor * specular * specularIntensity;


                //Emission
                half isEmission = _EmissionThreshold < albedo.w;
                half emissionThreshold = albedo.w - _EmissionThreshold;
                half emissionThresholdInv = max(1 - _EmissionThreshold, 0.001);
                half3 u_xlat28 = saturate(emissionThreshold / emissionThresholdInv);
                u_xlat28 = isEmission ? u_xlat28 : 0;
                half3 emissionColor = albedo.xyz * _EmissionIntensity - prevPassColor;
                emissionColor = u_xlat28 * emissionColor.xyz + prevPassColor.xyz;

                //Fresnel
                float fresnel = 1 - abs(NdotV) - _FresnelBSI.x;
                fresnel = fresnel / _FresnelBSI.y;
                fresnel = saturate(fresnel);
                half3 fresnelColor = _FresnelColor.xyz * fresnel * _FresnelColorStrength;
                fresnelColor = max(fresnelColor, 0);

                // return half4(fresnelColor.rgb, 1);

                float3 color = specColor * albedo.xyz + emissionColor.xyz;
                color = color * lightColor + fresnelColor.xyz;
                color = _ES_AddColor.xyz * albedo.xyz + color;

                // ---------------------------------------------------------
                //渐变---------------------------------------------------------
                //从上到下渐变mask(0-1), 角色世界坐标在y=0的位置
                float height = input.positionWS.y - _CharaWorldSpaceOffset.y;

                //从上到下渐变mask(1-0), 角色世界坐标在y=0的位置
                float heightLerpBottom = max(_ES_HeightLerpBottom, 0.001);
                float heightLerp01 = 1 - smoothstep(0, 1, height / heightLerpBottom);

                //从上到下渐变mask(1-0), 角色世界坐标在y=0的位置
                height = height - _ES_HeightLerpTop;
                height = height + height;
                float heightLerp10 = smoothstep(0, 1, height);

                float heightMask = saturate(1 - heightLerp01 - heightLerp10);

                half3 heightBottomColor = heightLerp01 * _ES_HeightLerpBottomColor.xyz;
                half3 heightMiddleColor = heightMask.xxx * _ES_HeightLerpMiddleColor.xyz;
                heightMiddleColor = heightMiddleColor * _ES_HeightLerpMiddleColor.www;
                heightMiddleColor = heightBottomColor * _ES_HeightLerpBottomColor.www + heightMiddleColor;
                half3 heightTopColor = heightLerp10 * _ES_HeightLerpTopColor.xyz;
                heightTopColor = heightTopColor * _ES_HeightLerpTopColor.www + heightMiddleColor;
                heightTopColor = saturate(heightTopColor);

                color = heightTopColor * color;
                color = color + color;


                #ifdef _USE_MATERIAL_VALUES_LUT
                //MaterialValuesPackLUT
                packuv = float3(rampLevel.x, 6, 7);
                valuesPackLUT1.x = LOAD_TEXTURE2D(_MaterialValuesPackLUT, packuv.xy).z;
                valuesPackLUT2 = LOAD_TEXTURE2D(_MaterialValuesPackLUT, packuv.xz).xyz;

                float bloomIntensity = valuesPackLUT1.x;
                float3 bloomColor = valuesPackLUT2;
                #else
                    float bloomIntensity = 1;
                    float3 bloomColor = 1;
                #endif

                color = color * (bloomIntensity * bloomColor + 1);


                color = color - prevPassColor + prevPassColor;

                color.rgb = MixFog(color.rgb, inputData.fogCoord);
                return half4(color.rgb, 1);

                //-----------------------------------------Self-------------------------
                // NdotL = CalculateRamp(_ShadowThreshold, _ShadowSmoothness, NdotL);

                // return half4(halfLambert.xxx, 1);

                // color.a = saturate(color.a);
                return specular;
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
