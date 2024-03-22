Shader "LcL/ToonBody"
{
    Properties
    {
        _BaseMap ("Base Texture", 2D) = "white" { }
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)

        [Toggle(_TOON_HAIR)]_TOON_HAIR ("Is Hair", float) = 0
        [ShowIf(_TOON_HAIR)]_BackColor ("Base Color", Color) = (1, 1, 1, 1)

        [NoScaleOffset]_LightMap ("_LightMap(R-Outline,G-AO,B-Specular,A-RampLevel)", 2D) = "white" { }

        [Foldout(_EMISSION)]_EMISSION ("Emission", float) = 0
        //        [Emission]_EmissionColor ("Emission Color", Color) = (0, 0, 0, 0)
        _EmissionThreshold ("Emission Threshold", Range(0,1)) = 0.5
        [FoldoutEnd]_EmissionIntensity ("Emission Intensity", Range(0,10)) = 3


        [Foldout]_DIFFUSE_RAMP ("Ramp", float) = 0
        _DiffuseRampMultiTex ("Diffuse Ramp Texture", 2D) = "white" { }
        _DiffuseCoolRampMultiTex ("Diffuse Cool Ramp Texture", 2D) = "white" { }
        [FoldoutEnd]_RampLevel ("Ramp Level", int) = 8

        [Foldout]_Specular ("Specular", float) = 0
        [Toggle(_USE_MATERIAL_VALUES_LUT)]_USE_MATERIAL_VALUES_LUT ("UseMaterialValuesLUT", float) = 1
        [ShowIf(_USE_MATERIAL_VALUES_LUT)]_MaterialValuesPackLUT ("MaterialValuesPackLUT", 2D) = "white" { }
        [ShowIf(_USE_MATERIAL_VALUES_LUT,0)]_SpecularColor ("Specular Color", Color) = (1,1,1,1)
        [ShowIf(_USE_MATERIAL_VALUES_LUT,0)]_SpecularIntensity ("Specular Intensity", Range(0,1)) = 1
        [ShowIf(_USE_MATERIAL_VALUES_LUT,0)]_SpecularRoughness ("Specular Roughness", Range(0,1)) = 0
        [ShowIf(_USE_MATERIAL_VALUES_LUT,0)]_SpecularShininess ("Specular Shininess", Range(0,100)) = 1
        [ShowIf(_TOON_HAIR)]_SpecularShadowOffset ("Specular Shadow Offset", Range(0,1)) = 0.75
        [ShowIf(_TOON_HAIR)]_SpecularShadowIntensity ("Specular Shadow Intensity", Range(0,1)) = 0

        _ES_SPColor ("ES SP Color", Color) = (1,1,1,1)
        [FoldoutEnd]_ES_SPIntensity ("SP Intensity", Range(0,10)) = 1

        [Foldout]_Fresnel ("Fresnel", float) = 0
        _FresnelColor ("Fresnel Color", Color) = (1,1,1,1)
        _FresnelColorStrength ("Fresnel Color Strength", Range(0,1)) = 1
        [FoldoutEnd]_FresnelBSI ("Fresnel BSI",Vector) = (1,1,0,0)

        [Foldout]_Rim ("Rim", float) = 0
        _RimShadowColor ("Rim Shadow Color", Color) = (0,0,0,1)
        _RimShadowCt ("Rim Shadow Ct", Range(0,10)) = 1
        _RimShadowWidth ("Rim Shadow Width", Range(0,10)) = 1
        _RimShadowFeather ("Rim Shadow Feather", Range(0,1)) = 0.0
        _RimShadowIntensity ("Rim Shadow Intensity", Range(0,3)) = 1
        [FoldoutEnd]_RimShadowOffset ("Rim Shadow Offset ",Range(0,1)) = 0.0

        [Foldout]_HeightLerp ("Height Lerp", float) = 0
        _ES_HeightLerpTop ("ES Height Lerp Top", Range(0,1)) = 0.2
        _ES_HeightLerpBottom ("ES Height Lerp Bottom", Range(0,1)) = 0.4
        //注意Color.a 在线性空间, 0.5 = pow(0.218,0.45)
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

        //hair (1,1,1,0.5)
        _ES_LevelHighLightColor ("ES Level HighLight Color", Color) = (1,1,1,0.5)
        _ES_LevelShadowColor ("ES Level Shadow Color", Color) = (0,0,0,1)
        //hair 1,
        [Toggle(_ES_LEVEL_ADJUST_ON)]_ES_LEVEL_ADJUST_ON ("Level Adjust", float) = 1

        _NewLocalLightStrength ("New Local Light Strength", Vector) = (0,0,0,0)


        _CharacterLocalMainLightDark ("_CharacterLocalMainLightDark", Vector) = (0,0,0)
        _CharacterLocalMainLightDark1 ("_CharacterLocalMainLightDark1", Vector) = (0,0,0)
        _CharacterLocalMainLightColor1 ("_CharacterLocalMainLightColor1", Color) = (1,1,1,1)
        _CharacterLocalMainLightColor2 ("_CharacterLocalMainLightColor2", Color) = (1,1,1,1)
        //hair 1,
        _ES_CharacterDisableLocalMainLight ("_ES_CharacterDisableLocalMainLight", float) = 1

        _ES_CharacterShadowFactor ("_ES_CharacterShadowFactor", Range(0,1)) = 1
        [FoldoutEnd]_Test ("_Test", Range(0,1)) = 0.5
        _CustomMainLightDir ("Custom Main Light Dir", Vector) = (1,1,1,0)





        [Foldout]_TOON_OUT_LINE ("Outline", float) = 1
        _OutlineWidth ("Outline Width", Range(0, 0.2)) = 0.05
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 0)
        _OutlineColorIntensity ("Outline Intensity", Range(0, 1)) = 1

        _OutlineExtdStart ("Outline Extd Start", Range(0, 10)) = 6.52
        _OutlineExtdMax ("Outline Extd Max", Range(0, 30)) = 18.16
        _OutlineScale ("Outline Scale", Range(0, 1)) = 0.015
        _OutlineOffset ("Outline Offset", Range(0, 1)) = 0

        [ShowIf(_TOON_HAIR,0)]_ES_OutLineLightedVal ("OutLineLightedVal", Range(0, 1)) = 0
        [ShowIf(_TOON_HAIR,0)]_ES_OutLineDarkenVal ("OutLineDarkenVal", Range(0, 1)) = 0.0

        _OffsetFactor ("Offset Factor", Range(-10, 10)) = -0.3
        [FoldoutEnd]_OffsetUnits ("Offset Units", Range(-10, 10)) = -0.3
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
            float4 _BackColor;
            float _EmissionIntensity;
            float _EmissionThreshold;

            float _Cutoff;
            float _BumpScale;
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
            //Hair
            float _SpecularShadowOffset;
            float _SpecularShadowIntensity;
            //

            float4 _FresnelColor;
            float4 _FresnelBSI;
            float _FresnelColorStrength;

            float4 _RimShadowColor;
            float _RimShadowCt;
            float _RimShadowWidth;
            float _RimShadowOffset;
            float _RimShadowFeather;
            float _RimShadowIntensity;
            float4 _CharaWorldSpaceOffset;


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

            //OutLine---------------------
            float4 _OutlineColor;
            float _OutlineWidth;
            float _OutlineOffset;
            float _OutlineScale;
            float _OutlineExtdStart;
            float _OutlineExtdMax;
            float _OutlineColorIntensity;
            float _ES_OutLineDarkenVal;
            float _ES_OutLineLightedVal;
        CBUFFER_END


        TEXTURE2D(_LightMap);
        SAMPLER(sampler_LightMap);

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

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma only_renderers gles gles3 glcore d3d11

            #pragma vertex vert
            #pragma fragment frag

            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _EMISSION
            #pragma shader_feature _RECEIVE_SHADOWS_OFF

            #pragma shader_feature _TOON_HAIR
            #pragma shader_feature _USE_MATERIAL_VALUES_LUT

            // URP Keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE

            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog

            #define  _NORMALMAP
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
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD2;
                float3 normalWS : TEXCOORD3;
                float4 tangentWS : TEXCOORD4;
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
                real sign = input.tangentOS.w * GetOddNegativeScale();
                output.tangentWS = half4(normalInputs.tangentWS.xyz, sign);

                half3 vertexLight = VertexLighting(positionInputs.positionWS, normalInputs.normalWS);
                half fogFactor = ComputeFogFactor(positionInputs.positionCS.z);

                output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

                #ifdef REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
                    output.shadowCoord = GetShadowCoord(positionInputs);
                #endif

                return output;
            }

            InputData InitializeInputData(Varyings input)
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
                return inputData;
            }

            half4 frag(Varyings input, half facing:VFACE) : SV_Target
            {
                InputData inputData = InitializeInputData(input);

                half2 screenUV = input.positionCS.xy / _ScaledScreenParams.xy;
                //所有角色贴图不要开启Mipmap
                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
                #ifdef _TOON_HAIR
                half4 faceColor = facing > 0 ? _BaseColor : _BackColor;
                half4 albedo = baseMap * faceColor;
                #else
                half4 albedo = baseMap * _BaseColor;
                #endif

                //r = Outline, g = AO, b = 高光强度
                //A 通道不同的颜色阈值（8个色阶）用于区分部位，进行Ramp的区分采样
                half4 mask = SAMPLE_TEXTURE2D(_LightMap, sampler_LightMap, input.uv);

                #ifdef _TOON_HAIR
                half shadowAO = (mask.y + mask.y);
                #else
                half shadowAO = (mask.y + mask.y) * input.color.x;
                #endif

                // A通道不同的颜色阈值（8个色阶）用于区分部位，进行Ramp的区分采样
                float rampLevel = floor(mask.a * 8.0);
                rampLevel = frac(0.125 * rampLevel) * 8;

                half4 shadowMask = CalculateShadowMask(inputData);
                Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, shadowMask);

                half3 lightColor = mainLight.color;
                // half3 lightDir = mainLight.direction;
                half shadowAtten = mainLight.shadowAttenuation;

                float3 viewDirWS = inputData.viewDirectionWS;
                float3 lightDir = _CustomMainLightDir.xyz - _MainLightPosition.xyz;
                lightDir = _CustomMainLightDir.www * lightDir.xyz + _MainLightPosition.xyz;
                float3 halfDir = normalize(lightDir + viewDirWS);
                float3 normalWS = inputData.normalWS;
                float face = facing > 0 ? 1 : -1;


                normalWS = face * normalWS;
                float NdotV = dot(normalWS, viewDirWS);
                float NdotH = dot(normalWS, halfDir);

                half NdotL = saturate(dot(inputData.normalWS, mainLight.direction));
                half halfLambert = saturate(NdotL * 0.5 + 0.5);
                //todo:这里计算有可能有问题
                #ifdef _TOON_HAIR
                halfLambert = dot(halfLambert.xx, shadowAO.xx);
                #else
                halfLambert = dot(halfLambert.xx, shadowAO.xx) * shadowAO;
                #endif

                halfLambert = clamp(halfLambert, 0.0, 1.0);
                //...

                float characterShadowFactor = min(1, _ES_CharacterShadowFactor * halfLambert);

                float u_xlat54 = 1.0;
                #ifdef _TOON_HAIR
                half maskY = mask.y;
                #else
                half maskY = mask.y * input.color.x;
                #endif

                maskY = min(maskY, 0.8);
                maskY = u_xlat54 < 0.1 ? maskY : 1.0;

                //Diffuse Ramp UV
                half halfLambert2 = halfLambert * 0.85 + 0.15;
                half2 diffuseRampUV;
                diffuseRampUV.x = _ShadowRamp < characterShadowFactor ? 1 : halfLambert2;
                #ifdef _TOON_HAIR
                diffuseRampUV.y = 0.0625;
                #else
                //y 可以直接取 mask.a , 但是为了容错, 用rampLevel
                diffuseRampUV.y = (rampLevel * 2 + 1) * 0.0625;
                #endif


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
                float diffuseShadowMask = diffuseRampUV.x * 1 - 0.8;
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
                float3 levelHightLightColor = _ES_LevelHighLightColor.www * _ES_LevelHighLightColor.xyz;
                levelHightLightColor = levelHightLightColor + levelHightLightColor;
                levelHightLightColor = levelHightLightColor * rampDiffuse;

                float3 rampDiffuse2 = _ES_LevelMid.xxx - darkColor;
                rampDiffuse2 = rampDiffuse2 / lightLevel.yyy;
                rampDiffuse2 = -rampDiffuse2 * 0.5 + 0.5;
                rampDiffuse2 = clamp(rampDiffuse2, 0.0, 1.0);
                float3 levelShadowColor = _ES_LevelShadowColor.www * _ES_LevelShadowColor.xyz;
                levelShadowColor = levelShadowColor + levelShadowColor;
                levelShadowColor = levelShadowColor * rampDiffuse2;

                float diffuseMask = dot(darkColor, float3(1, 1, 1));

                levelShadowColor = 2.9 < diffuseMask ? levelHightLightColor : levelShadowColor;
                levelShadowColor = 0.5 < _ES_LEVEL_ADJUST_ON ? levelShadowColor : darkColor;

                levelShadowColor = levelShadowColor * shadowAtten;
                levelShadowColor = levelShadowColor * albedo;

                float3 temp = 1 - levelShadowColor;
                temp = temp + temp;
                temp = 1 - temp;


                // Rim Shadow

                #ifdef _USE_MATERIAL_VALUES_LUT
                float3 packuv = float3(rampLevel.x, 5, 6);
                float3 materialLUT = LOAD_TEXTURE2D(_MaterialValuesPackLUT, packuv.xy);
                float3 materialLUT2 = LOAD_TEXTURE2D(_MaterialValuesPackLUT, packuv.xz);

                float3 rimShadowColor = materialLUT;
                float rimShadowWidth = materialLUT2.x;
                float rimShadowFeather = materialLUT2.y;
                #else

                float3 rimShadowColor = _RimShadowColor.rgb;
                float rimShadowWidth = _RimShadowWidth;
                float rimShadowFeather = _RimShadowFeather;

                #endif

                float rimShadow = max(1 - saturate(NdotV), 0.001);
                rimShadow = pow(rimShadow, _RimShadowCt) * rimShadowWidth;
                rimShadow = saturate(rimShadow);
                rimShadow = smoothstep(rimShadowFeather, 1, rimShadow) * _RimShadowIntensity * 0.25;
                float3 rimColor = rimShadow * rimShadowColor.rgb;
                //-----------------------------------------------------------------

                half3 prevPassColor = albedo.rgb * rampDiffuse.xyz;

                // return half4(prevPassColor, 1);
                //-----------------------------------------Pass 2-------------------------

                //Specular---------------------------------
                #ifdef _USE_MATERIAL_VALUES_LUT
                //MaterialValuesPackLUT
                packuv = float3(rampLevel.x, 1, 0);
                materialLUT = LOAD_TEXTURE2D(_MaterialValuesPackLUT, packuv.xz);
                materialLUT2 = LOAD_TEXTURE2D(_MaterialValuesPackLUT, packuv.xy);

                float3 specularColor = materialLUT;
                float specularRoughness = materialLUT2.y;
                float specularIntensity = materialLUT2.z;
                float specularShininess = materialLUT2.x;
                #else
                float3 specularColor = _SpecularColor.rgb;
                float specularRoughness = _SpecularRoughness;
                float specularIntensity = _SpecularIntensity;
                float specularShininess = _SpecularShininess;

                #endif

                float specular = pow(max(NdotH, 0.001), specularShininess);

                float3 SPColor = _ES_SPColor.xyz - 1;
                SPColor = _ES_SPColor.www * SPColor + 1.0;
                SPColor = SPColor * _ES_SPIntensity;
                specularColor = specularColor * SPColor;
                //-----------------------------------------

                // return half4(specular.xxx, 1);

                specularRoughness = max(specularRoughness, 0.001);

                float invMaskZ = 1 - mask.z;

                #ifdef _TOON_HAIR
                half shadowValue = dot(halfLambert, shadowAO) * shadowAtten;
                float specularShadow = _SpecularShadowOffset < shadowValue ? 1.0 : _SpecularShadowIntensity;
                specular = min(specular, 1.0);
                specular = smoothstep(invMaskZ - specularRoughness, invMaskZ + specularRoughness, specular);
                #else
                specular = smoothstep(invMaskZ - specularRoughness, invMaskZ + specularRoughness, specular*shadowAtten);
                #endif

                float3 specColor = specularColor * specular * specularIntensity;
                // -----------------------------------------


                //Emission---------------------------------
                half isEmission = _EmissionThreshold < albedo.w;
                half emissionThreshold = albedo.w - _EmissionThreshold;
                half emissionThresholdInv = max(1 - _EmissionThreshold, 0.001);
                half3 u_xlat28 = saturate(emissionThreshold / emissionThresholdInv);
                u_xlat28 = isEmission ? u_xlat28 : 0;
                half3 emissionColor = albedo.xyz * _EmissionIntensity - prevPassColor;
                emissionColor = u_xlat28 * emissionColor.xyz + prevPassColor.xyz;
                //-----------------------------------------

                //Fresnel---------------------------------
                float fresnel = 1 - abs(NdotV) - _FresnelBSI.x;
                fresnel = fresnel / _FresnelBSI.y;
                fresnel = saturate(fresnel);
                half3 fresnelColor = _FresnelColor.xyz * fresnel * _FresnelColorStrength;
                fresnelColor = max(fresnelColor, 0);
                //-----------------------------------------

                // return half4(fresnelColor.rgb, 1);

                #ifdef _TOON_HAIR
                albedo.rgb = albedo.rgb * specularShadow;
                #endif

                float3 color = specColor * albedo.xyz + emissionColor.xyz;
                color = color * lightColor + fresnelColor.xyz;
                color = _ES_AddColor.xyz * albedo.xyz + color;

                // ---------------------------------------------------------
                //渐变---------------------------------------------------------
                //从上到下渐变mask(0-1), 角色世界坐标在y=0的位置
                float heightLerpBottom = max(_ES_HeightLerpBottom, 0.001);
                float heightLerp01 = 1 - smoothstep(_CharaWorldSpaceOffset.y,
                                                    heightLerpBottom + _CharaWorldSpaceOffset.y,
                                                    input.positionWS.y);


                //从上到下渐变mask(1-0), 角色世界坐标在y=0的位置
                float height = input.positionWS.y - _CharaWorldSpaceOffset.y;
                height = height - _ES_HeightLerpTop;
                height = height + height;
                float heightLerp10 = smoothstep(0, 1, height);

                // return half4(heightLerp10.xxx, 1);

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

                packuv = float3(rampLevel.x, 6, 7);
                materialLUT.x = LOAD_TEXTURE2D(_MaterialValuesPackLUT, packuv.xy).z;
                materialLUT2 = LOAD_TEXTURE2D(_MaterialValuesPackLUT, packuv.xz).xyz;
                float bloomIntensity = materialLUT.x;
                float3 bloomColor = materialLUT2;

                #else
                    float bloomIntensity = 1;
                    float3 bloomColor = 1;
                #endif

                color = color * (bloomIntensity * bloomColor + 1);

                color = color - prevPassColor + prevPassColor;

                color.rgb = MixFog(color.rgb, inputData.fogCoord);
                return half4(color.rgb, 1);
            }
            ENDHLSL
        }

//        Pass
//        {
//            Tags
//            {
//                "LightMode" = "ToonOutlineLit"
//            }
//            Offset [_OffsetFactor], [_OffsetUnits]
//
//            Blend SrcAlpha OneMinusSrcAlpha
//            Cull Front
//            ZWrite Off
//
//            HLSLPROGRAM
//            #pragma shader_feature _TOON_HAIR
//            #pragma shader_feature _USE_MATERIAL_VALUES_LUT
//
//            #pragma vertex ToonOutlineVertex
//            #pragma fragment ToonOutlineFragment
//
//            #include "ToonOutlineCore.hlsl"
//            ENDHLSL
//        }

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
