Shader "LcL/ToonFace"
{
    Properties
    {
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode ("CullMode", float) = 2

        _BaseMap ("Base Texture", 2D) = "white" { }
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)

        [Toggle(_UseUVChannel2)] _UseUVChannel2 ("Toggle", float) = 0
        [NoScaleOffset]_FaceMap ("FaceMap(R-Outline,G-AO,B-Specular,A-RampLevel)", 2D) = "white" { }

        [Foldout()]_EMISSION ("Emission", float) = 0
        _EmissionThreshold ("Emission Threshold", Range(0, 1)) = 0.5
        _mBloomIntensity0 ("BloomIntensity0", Range(0, 1)) = 0.3
        _mBloomIntensity1 ("BloomIntensity1", Range(0, 1)) = 0.3
        [FoldoutEnd]_EmissionIntensity ("Emission Intensity", Range(0, 10)) = 3


        [Foldout]_Shadow ("Shadow", float) = 0
        _ShadowOffset ("Shadow Offset", Range(-1, 1)) = 0
        _ShadowSmoothness ("Shadow Smoothness", Range(0,0.1)) = 0.001
        _ShadowColor ("Shadow Color", Color) = (0.97, 0.73, 0.65, 1)
        _EyeShadowColor ("Eye Shadow Color", Color) = (0.78741, 0.72036, 0.71313, 1.00)
        [FoldoutEnd]_FresnelBSI ("Fresnel BSI", Vector) = (1, 1, 0, 0)

        [Foldout]_EYE_INFO ("Eye", float) = 0
        _EyeBaseShadowColor ("Eye Base Shadow Color", Color) = (1.00, 1.00, 1.00, 1.00)
        _EyeShadowAngleMin ("Eye Shadow Angle Min", Range(0, 1)) = 0.85
        _EyeShadowMaxAngle ("Eye Shadow Max Angle", Range(0, 1)) = 1.0
        _UseSpecialEye ("Use Special Eye", float) = 0
        _EyeCenter ("Eye Center", Vector) = (0.0, 0.0, 0, 0)
        _EyeSPColor1 ("Eye SP Color1", Color) = (1.00, 1.00, 1.00, 1.00)
        _EyeSPColor2 ("Eye SP Color2", Color) = (1.00, 1.00, 1.00, 1.00)
        [FoldoutEnd]_SpecialEyeIntensity ("Special Eye Intensity", Range(0, 1)) = 1.0


        [Foldout]_SkinLight ("Skin Light", float) = 0
        _ES_LevelSkinLightColor ("LevelSkinLightColor", Color) = (1.00, 1.00, 1.00, 0.50)
        _ES_LevelSkinShadowColor ("LevelSkinShadowColor", Color) = ( 1.00, 1.00, 1.00, 0.50)
        [FoldoutEnd]_ES_LevelEyeShadowIntensity ("LevelEyeShadowIntensity", Range(0, 1)) = 0

        [Foldout]_NoseLine ("Nose Line", float) = 0
        _NoseLineColor ("Nose Line Color", Color) = (0.17144, 0.07421, 0.07421, 1.00)
        [FoldoutEnd]_NoseLinePower ("Nose Line Power", Range(0, 20)) = 4

        [Foldout]_CharacterOnly ("Character Only", float) = 0

        _ES_LevelHighLight ("ES Level HighLight", Range(0, 1)) = 1
        _ES_LevelMid ("ES Level Mid", Range(0, 1)) = 0.55
        _ES_LevelShadow ("ES Level Shadow", Range(0, 1)) = 0

        [Toggle(_ES_LEVEL_ADJUST_ON)] _ES_LEVEL_ADJUST_ON ("Level Adjust ON", float) = 1
        _CharacterLocalMainLightDark ("CharacterLocalMainLightDark", Vector) = (0, 0, 0)
        _CharacterLocalMainLightDark1 ("CharacterLocalMainLightDark1", Vector) = (0, 0, 0)
        _CharacterLocalMainLightColor1 ("CharacterLocalMainLightColor1", Color) = (1, 1, 1, 1)
        _CharacterLocalMainLightColor2 ("CharacterLocalMainLightColor2", Color) = (1, 1, 1, 1)
        _CharacterLocalMainLightPosition ("CharacterLocalMainLightPosition", Vector) = (-0.0595, 0.43589, 0.89803, 0.00)
        [FoldoutEnd]_ES_CharacterShadowFactor ("ES_CharacterShadowFactor", Range(0, 1)) = 1


        [Foldout]_TOON_OUT_LINE ("Outline", float) = 1
        [Toggle()] _UseSelfOutline ("UseSelfOutline", float) = 1
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 0)
        _OutlineWidth ("Outline Width", Range(0, 0.2)) = 0.005
        _OutlineScale ("Outline Scale", Range(0, 1)) = 0.015
        _OutlineOffset ("Outline Offset", Range(0, 1)) = 0
        _OutlineExtdStart ("Outline Extd Start", Range(0, 10)) = 6.52
        _OutlineExtdMax ("Outline Extd Max", Range(0, 30)) = 18.16
        [FoldoutEnd]_OffsetFactor ("Offset Factor", Range(-10, 10)) = -0.3
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"
        }
        Cull [_CullMode]

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        CBUFFER_START(UnityPerMaterial)
            float _Cutoff;
            //UnityPerMaterial
            float4 _BaseMap_ST;
            float4 _BaseColor;
            float4 _EyeShadowColor;

            float _ExMapThreshold;
            float _ExSpecularIntensity;
            float _ExCheekIntensity;
            float _ExShyIntensity;
            float _ExShadowIntensity;
            float4 _ExCheekColor;
            float4 _ExShyColor;
            float4 _ExShadowColor;
            float4 _ExEyeColor;
            float _EyeEffectProcs;
            float4 _EyeEffectColor;
            float _EmissionThreshold;
            float _EmissionIntensity;
            float _NoseLinePower;
            float4 _NoseLineColor;
            int _ShowPartID;

            int _HideCharaParts;
            int _HideNPCParts;
            float _FresnelColorStrength;
            float4 _FresnelColor;
            float4 _FresnelBSI;

            //UnityPerMaterialCharacterOnly
            float4 _ShadowColor;
            float4 _EyeBaseShadowColor;
            float _EyeShadowAngleMin;
            float _EyeShadowMaxAngle;
            float _UseUVChannel2;
            float _UseSpecialEye;
            float4 _SpecialEyeShapeTexture_ST;
            float4 _EyeCenter;
            float4 _EyeSPColor1;
            float4 _EyeSPColor2;
            float _SpecialEyeIntensity;

            float4 _LipLinefixColor;
            float _LipLineFixThrd;
            float _LipLineFixStart;
            float _LipLineFixMax;
            float _LipLineFixScale;
            float _LipLineFixSC;


            //CharacterSvarogBuffer
            float3 _RimShadowColor;
            float _RimShadowCt;
            float _RimShadowIntensity;
            float _RimShadowWidth;
            float _RimShadowFeather;

            float _ShadowSmoothness;
            float _ShadowOffset;

            float _ES_LEVEL_ADJUST_ON;
            float4 _CharacterLocalMainLightDark1;
            float4 _NewLocalLightStrength;
            float4 _CharacterLocalMainLightPosition;

            float4 _ES_AddColor;
            float _ES_CharacterShadowFactor;
            float _ES_HeightLerpTop;
            float _ES_HeightLerpBottom;
            float4 _ES_HeightLerpTopColor;
            float4 _ES_HeightLerpMiddleColor;
            float4 _ES_HeightLerpBottomColor;
            float4 _ES_LevelSkinLightColor;
            float4 _ES_LevelSkinShadowColor;
            float _ES_LevelEyeShadowIntensity;
            float _ES_LevelShadow;
            float _ES_LevelMid;
            float _ES_LevelHighLight;

            float _mBloomIntensity0;
            float _mBloomIntensity1;


            //OutLine---------------------
            float _UseSelfOutline;
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

        TEXTURE2D(_FaceMap);
        SAMPLER(sampler_FaceMap);

        TEXTURE2D(_FaceExpression);
        SAMPLER(sampler_FaceExpression);
        ENDHLSL

        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            Stencil
            {
                Ref 1
                Comp always
                Pass replace
            }
            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma only_renderers gles gles3 glcore d3d11

            #pragma vertex vert
            #pragma fragment frag

            // #pragma shader_feature _ALPHATEST_ON
            // #pragma shader_feature _ALPHAPREMULTIPLY_ON
            // #pragma shader_feature _EMISSION
            // #pragma shader_feature _RECEIVE_SHADOWS_OFF

            // URP Keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT

            #pragma multi_compile_fog

            // Includes
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            #include "Assets/Shaders/Libraries/Node.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float4 color : COLOR;
                float4 uv : TEXCOORD0;
                float4 faceShadowUV : TEXCOORD1;
                float4 positionWS : TEXCOORD2;
                float3 normalWS : TEXCOORD3;
                float3 viewDirWS : TEXCOORD5;
                half4 fogFactorAndVertexLight : TEXCOORD6;

                #ifdef REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
                float4 shadowCoord : TEXCOORD7;
                #endif
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                Light mainLight = GetMainLight();
                float3 L = mainLight.direction;

                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = positionInputs.positionCS;
                output.uv.xy = TRANSFORM_TEX(input.uv, _BaseMap);
                output.uv.zw = _UseUVChannel2 > 0.5 ? input.uv2 : float2(0, 0);

                float3 normalWS = TransformObjectToWorldNormal(input.normalOS, true);

                //代表的是世界空间中的 y 轴在对象空间中的表示。这个向量的方向是对象空间中的 "up" 方向
                float3 upOS = float3(UNITY_MATRIX_I_M[0].y, UNITY_MATRIX_I_M[1].y, UNITY_MATRIX_I_M[2].y);
                upOS = SafeNormalize(upOS);

                float UdotL = dot(L, upOS);

                output.color = input.color;
                output.positionWS.xyz = positionInputs.positionWS;
                output.positionWS.w = saturate(UdotL + 1);
                output.normalWS = normalWS;
                output.viewDirWS = GetWorldSpaceViewDir(positionInputs.positionWS);


                float3 forward = GetModelForwardDir();
                float3 left = -GetModelRightDir();

                //L.xz:光源方向在水平面上的投影
                float lightAtten = 1 - (dot(L.xz, forward.xz) * 0.5 + 0.5);
                float filpU = sign(dot(L.xz, left.xz));
                output.faceShadowUV.xy = input.uv * float2(filpU, 1);
                output.faceShadowUV.z = lightAtten;

                //
                half3 vertexLight = VertexLighting(positionInputs.positionWS, normalWS);
                half fogFactor = ComputeFogFactor(positionInputs.positionCS.z);
                output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
                //
                #ifdef REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
                output.shadowCoord = GetShadowCoord(positionInputs);
                #endif

                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                float3 finalColor = 0;
                float3 positionWS = input.positionWS.xyz;
                float faceShadowThreshold = input.faceShadowUV.z;

                float UdotL = input.positionWS.w;
                float4 vertexColor = input.color;
                float3 viewDirWS = normalize(GetWorldSpaceViewDir(positionWS));
                float3 normalWS = normalize(input.normalWS);

                Light light = GetMainLight();
                float3 L = light.direction;
                float shadowAtten = light.shadowAttenuation;
                float NdotV = dot(normalWS, viewDirWS);

                //所有角色贴图不要开启Mipmap
                half4 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
                float4 faceMap = SAMPLE_TEXTURE2D(_FaceMap, sampler_FaceMap, input.uv);

                // mihoyo
                // float shaodwRamp = SAMPLE_TEXTURE2D(_FaceMap, sampler_FaceMap, input.faceShadowUV.xy).a;
                // float shadowValue0 = faceShadowThreshold - _ShadowSmoothness;
                // float shadowValue1 = min(faceShadowThreshold + _ShadowSmoothness, 1);
                // float faceShadow = smoothstep(shadowValue0, shadowValue1, shaodwRamp);
                //
                // Face Shadow-----------------------
                float3 forward = GetModelForwardDir();
                float lightAtten = 1 - (dot(L.xz, forward.xz) * 0.5 + 0.5);
                float3 shaodwRamp = SAMPLE_TEXTURE2D(_FaceMap, sampler_FaceMap, input.faceShadowUV.xy).a;
                float faceShadow = SmoothValue(lightAtten + _ShadowOffset, _ShadowSmoothness, shaodwRamp.r);
                faceShadow = faceShadow * shadowAtten;
                // Face Shadow-----------------------

                //鼻线--------------------------------
                viewDirWS.y = viewDirWS.y * 0.5;
                float NdotV2 = dot(normalWS, viewDirWS);
                float2 noseSP = float2(NdotV2, _NoseLinePower * 8.0);
                noseSP = max(noseSP, float2(0.001, 0.1));
                float specular = pow(noseSP.x, noseSP.y);
                specular = min(specular, 1.0);
                specular = specular * faceMap.z;
                float noseLineMask = specular > 0.1 ? 1 : 0;
                float3 noseColor = lerp(albedo.rgb, _NoseLineColor.rgb, noseLineMask);
                finalColor = noseColor;

                //唇线--------------------------------
                //--------------------------------

                float3 eyeBaseColor = lerp(_EyeBaseShadowColor, 1, vertexColor.x) * _BaseColor.rgb;
                finalColor = finalColor * eyeBaseColor;

                //Emission------------------
                half isEmission = _EmissionThreshold < albedo.w;
                half emissionThreshold = albedo.w - _EmissionThreshold;
                half emissionThresholdInv = max(1 - _EmissionThreshold, 0.001);
                half3 emissionFactor = emissionThreshold / emissionThresholdInv;
                emissionFactor = isEmission ? emissionFactor : 0;

                half isEmission2 = _EmissionThreshold >= albedo.w;
                half3 emissionFactor2 = albedo.w / _EmissionThreshold;
                emissionFactor2 = isEmission2 ? emissionFactor2 : 1;


                finalColor = finalColor * emissionFactor * _EmissionIntensity.xxx + finalColor;

                //Eye--------------------------------
                float dist = distance(input.positionWS, GetCameraPositionWS());
                bool distRange = dist > 5.0;


                bool4 u_xlatb26 = (float4(0.0, 0.0, 0.1, 0.1) < faceMap.xxxx);
                float2 eyeMask = u_xlatb26.z ? float2(1.0, 0.0) : float2(0.0, 1.0);

                float3 dir = (u_xlatb26.z && faceMap.x < 0.8) ? float3(1.0, -1.0, 0.5) : float3(0, 0, 0);
                float eye = eyeMask.x + dir.y + dir.z;

                float eyeShadow = smoothstep(_EyeShadowAngleMin - 0.36, _EyeShadowMaxAngle, UdotL);
                eyeShadow = lerp(1, eyeShadow * eye, eye);

                float3 eyeShadowColor = lerp(_ShadowColor.xyz, _EyeShadowColor.xyz, eyeMask.xxx);
                float3 localLightDark1 = lerp(1, _CharacterLocalMainLightDark1.xyz, _NewLocalLightStrength.zzz);

                float3 eyeColor = eyeShadowColor * localLightDark1;

                float3 darkColor = lerp(eyeColor, 1, eyeShadow * faceShadow);

                float3 levelSkinLightColor = _ES_LevelSkinLightColor.www * _ES_LevelSkinLightColor.xyz;
                float3 levelSkinLightColor2 = levelSkinLightColor + levelSkinLightColor;
                float3 levelSkinShadowColor = _ES_LevelSkinShadowColor.www * _ES_LevelSkinShadowColor.xyz;
                float3 levelSkinShadowColor2 = levelSkinShadowColor + levelSkinShadowColor;

                float3 skinColor = lerp(levelSkinShadowColor2, levelSkinLightColor2, eyeShadow);
                skinColor = lerp(1, skinColor, _ES_LevelEyeShadowIntensity);

                float2 lightLevel = float2(_ES_LevelHighLight, _ES_LevelMid) - float2(_ES_LevelMid, _ES_LevelShadow);
                float3 rampDiffuse = darkColor - _ES_LevelMid.xxx;
                rampDiffuse = rampDiffuse / lightLevel.xxx;
                rampDiffuse = rampDiffuse * 0.5 + 0.5;
                rampDiffuse = clamp(rampDiffuse, 0.0, 1.0);

                float3 diffuseColor = lerp(levelSkinLightColor2, skinColor, eyeMask.x) * rampDiffuse;

                float3 rampDiffuse2 = _ES_LevelMid.xxx - darkColor;
                rampDiffuse2 = rampDiffuse2 / lightLevel.yyy;
                rampDiffuse2 = -rampDiffuse2 * 0.5 + 0.5;
                rampDiffuse2 = clamp(rampDiffuse2, 0.0, 1.0);

                float3 diffuseColor2 = lerp(levelSkinShadowColor2, skinColor, eyeMask.x) * rampDiffuse2;

                float characterLocalLight = max(_CharacterLocalMainLightPosition.w, 0.0099999998);

                diffuseColor = faceShadow >= characterLocalLight ? diffuseColor : diffuseColor2;
                darkColor = _ES_LEVEL_ADJUST_ON > 0.5 ? diffuseColor : darkColor;


                // darkColor = darkColor * Emission;
                finalColor = finalColor * darkColor;


                //BloomIntensity------------------
                float bloomIntensity = (faceMap.x < 0.8 && faceMap.x > 0.1) ? _mBloomIntensity1 : 0;

                finalColor = finalColor + finalColor * bloomIntensity;

                finalColor.rgb = MixFog(finalColor.rgb, input.fogFactorAndVertexLight.x);

                return half4(finalColor, 1);

                // // ---------------------------------------------------------
                // //渐变---------------------------------------------------------
                // //从上到下渐变mask(0-1), 角色世界坐标在y=0的位置
                // float heightLerpBottom = max(_ES_HeightLerpBottom, 0.001);
                // float heightLerp01 = 1 - smoothstep(_CharaWorldSpaceOffset.y,
                //                     heightLerpBottom + _CharaWorldSpaceOffset.y,
                //                     input.positionWS.y);
                //
                //
                // //从上到下渐变mask(1-0), 角色世界坐标在y=0的位置
                // float height = input.positionWS.y - _CharaWorldSpaceOffset.y;
                // height = height - _ES_HeightLerpTop;
                // height = height + height;
                // float heightLerp10 = smoothstep(0, 1, height);
                //
                // // return half4(heightLerp10.xxx, 1);
                //
                // float heightMask = saturate(1 - heightLerp01 - heightLerp10);
                //
                //
                // half3 heightBottomColor = heightLerp01 * _ES_HeightLerpBottomColor.xyz;
                // half3 heightMiddleColor = heightMask.xxx * _ES_HeightLerpMiddleColor.xyz;
                // heightMiddleColor = heightMiddleColor * _ES_HeightLerpMiddleColor.www;
                // heightMiddleColor = heightBottomColor * _ES_HeightLerpBottomColor.www + heightMiddleColor;
                // half3 heightTopColor = heightLerp10 * _ES_HeightLerpTopColor.xyz;
                // heightTopColor = heightTopColor * _ES_HeightLerpTopColor.www + heightMiddleColor;
                // heightTopColor = saturate(heightTopColor);
                //
                //
                // color = heightTopColor * color;
                // color = color + color;
                //
                //
                // #ifdef _USE_MATERIAL_VALUES_LUT
                //
                //     packuv = float3(rampLevel.x, 6, 7);
                //     materialLUT.x = LOAD_TEXTURE2D(_MaterialValuesPackLUT, packuv.xy).z;
                //     materialLUT2 = LOAD_TEXTURE2D(_MaterialValuesPackLUT, packuv.xz).xyz;
                //     float bloomIntensity = materialLUT.x;
                //     float3 bloomColor = materialLUT2;
                //
                // #else
                // float bloomIntensity = 1;
                // float3 bloomColor = 1;
                // #endif
                //
                // color = color * (bloomIntensity * bloomColor + 1);
                //
                // color = color - prevPassColor + prevPassColor;

                // color.rgb = MixFog(color.rgb, inputData.fogCoord);
                // return half4(color.rgb, 1);
                // return 1;
            }
            ENDHLSL
        }

        Pass
        {
            Tags
            {
                "LightMode" = "ToonOutlineLit"
            }
            Offset [_OffsetFactor], 0
            Stencil
            {
                Ref 1
                Comp NotEqual
            }
            Cull Front
            //ZWrite Off

            HLSLPROGRAM
            #define _TOON_HAIR

            #pragma vertex ToonOutlineVertex
            #pragma fragment ToonOutlineFragment

            #include "ToonOutlineCore.hlsl"
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

            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON


            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }
    }
    CustomEditor "LcLShaderEditor.LcLShaderGUI"
}
