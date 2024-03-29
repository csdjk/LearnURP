#version 450
uniform vec4 _MainLightPosition;
uniform vec2 _DisableCharacterLocalLight;
uniform vec4 _CharacterLocalMainLightPosition;
uniform vec4 _CharacterLocalMainLightColor1;
uniform vec4 _CharacterLocalMainLightColor2;
uniform vec4 _CharacterLocalMainLightDark;
uniform vec4 _CharacterLocalMainLightDark1;
uniform vec4 _NewLocalLightDir;
uniform vec4 _NewLocalLightCharCenter;
uniform vec4 _NewLocalLightStrength;
uniform vec4 hlslcc_mtx4x4unity_MatrixV[4];
uniform vec4 _CustomMainLightDir;
uniform vec3 _ES_MonsterLightDir;
uniform vec4 hlslcc_mtx4x4_MainLightWorldToShadow[20];
uniform vec4 _CascadeShadowSplitSpheres0;
uniform vec4 _CascadeShadowSplitSpheres1;
uniform vec4 _CascadeShadowSplitSpheres2;
uniform vec4 _CascadeShadowSplitSpheres3;
uniform vec4 _CascadeShadowSplitSphereRadii;
uniform vec4 _MainLightShadowParams;
uniform vec4 _MainLightShadowmapSize;
uniform float _ES_Indoor;
uniform float _ES_LEVEL_ADJUST_ON;
uniform float _ES_CharacterToonRampMode;
uniform float _ES_CharacterDisableLocalMainLight;
uniform vec4 _ES_RimShadowColor;
uniform float _ES_RimShadowIntensity;
uniform float _ES_CharacterShadowFactor;
uniform vec4 _ES_LevelSkinLightColor;
uniform vec4 _ES_LevelSkinShadowColor;
uniform vec4 _ES_LevelHighLightColor;
uniform vec4 _ES_LevelShadowColor;
uniform float _ES_LevelShadow;
uniform float _ES_LevelMid;
uniform float _ES_LevelHighLight;
uniform float _ES_IndoorCharShadowAsCookie;
layout(std140, binding = 0) uniform CharacterSvarogBuffer{
    float Xhlslcc_UnusedX_DissolveEmisRange;
    float Xhlslcc_UnusedX_DissolveEmisScale;
    vec4 Xhlslcc_UnusedX_DissolveColor;
    float Xhlslcc_UnusedX_DissolveDirectionalRange;
    float Xhlslcc_UnusedX_DissolveDirectionalOffset;
    vec2 Xhlslcc_UnusedX_DissolveDirection;
    float Xhlslcc_UnusedX_RimEdgeSoftness0;
    float Xhlslcc_UnusedX_RimType0;
    float Xhlslcc_UnusedX_RimDark0;
    vec3 Xhlslcc_UnusedX_RimShadowColor;
    float _RimShadowCt;
    float _RimShadowIntensity;
    float Xhlslcc_UnusedX_RimShadowWidth;
    float Xhlslcc_UnusedX_RimShadowFeather;
    vec4 _RimShadowColor0;
    float _RimShadowWidth0;
    float _RimShadowFeather0;
    vec3 _RimShadowOffset;
    vec4 Xhlslcc_UnusedX_SkyTex_ST;
    vec4 Xhlslcc_UnusedX_SkyMask_ST;
    vec4 Xhlslcc_UnusedX_SkyStarTex_ST;
    vec4 Xhlslcc_UnusedX_SkyStarMaskTex_ST;
    float Xhlslcc_UnusedX_SkyRange;
    vec4 Xhlslcc_UnusedX_SkyStarColor;
    vec4 Xhlslcc_UnusedX_SkyFresnelColor;
    vec2 Xhlslcc_UnusedX_SkyStarSpeed;
    float Xhlslcc_UnusedX_SkyStarTexScale;
    float Xhlslcc_UnusedX_SkyStarDepthScale;
    float Xhlslcc_UnusedX_SkyStarMaskTexScale;
    float Xhlslcc_UnusedX_SkyStarMaskTexSpeed;
    float Xhlslcc_UnusedX_SkyFresnelBaise;
    float Xhlslcc_UnusedX_SkyFresnelSmooth;
    float Xhlslcc_UnusedX_SkyFresnelScale;
    float Xhlslcc_UnusedX_OSScale;
    float Xhlslcc_UnusedX_StarDensity;
    float Xhlslcc_UnusedX_StarMode;
    int Xhlslcc_UnusedX_FlameID;
    vec4 Xhlslcc_UnusedX_FlameColorOut;
    vec4 Xhlslcc_UnusedX_FlameColorIn;
    vec4 Xhlslcc_UnusedX_EffectColor0;
    vec4 Xhlslcc_UnusedX_EffectColor1;
    vec4 Xhlslcc_UnusedX_EffectColor2;
    vec4 Xhlslcc_UnusedX_EffectColor3;
    vec4 Xhlslcc_UnusedX_EffectColor4;
    vec4 Xhlslcc_UnusedX_EffectColor5;
    vec4 Xhlslcc_UnusedX_EffectColor6;
    vec4 Xhlslcc_UnusedX_EffectColor7;
    float Xhlslcc_UnusedX_FlameHeight;
    float Xhlslcc_UnusedX_FlameWidth;
    float Xhlslcc_UnusedX_FlameSpeed;
    float Xhlslcc_UnusedX_FlameSwirilTexScale;
    float Xhlslcc_UnusedX_FlameSwirilSpeed;
    float Xhlslcc_UnusedX_FlameSwirilScale;
    float Xhlslcc_UnusedX_CrystalTransparency;
    float Xhlslcc_UnusedX_CrystalRange1;
    float Xhlslcc_UnusedX_CrystalRange2;
    float Xhlslcc_UnusedX_ColorIntensity;
    float Xhlslcc_UnusedX_ScreenNoiseInst;
    vec4 Xhlslcc_UnusedX_ScreenNoiseST;
    float Xhlslcc_UnusedX_ScreenLineInst;
    vec4 Xhlslcc_UnusedX_ScreenLineST;
    float Xhlslcc_UnusedX_ScreenNoiseseed2;
    vec4 Xhlslcc_UnusedX_SunGlassesTilingOffset;
    vec4 Xhlslcc_UnusedX_SunglassesSpecluarColor;
    float Xhlslcc_UnusedX_HighlightWidthL;
    float Xhlslcc_UnusedX_HighlightWidthR;
    float Xhlslcc_UnusedX_TotalSizeL;
    float Xhlslcc_UnusedX_TotalSizeR;
    float Xhlslcc_UnusedX_BlendRadiusL;
    float Xhlslcc_UnusedX_BlendRadiusR;
    float Xhlslcc_UnusedX_HighlightAngleL;
    float Xhlslcc_UnusedX_HighlightAngleR;
    float Xhlslcc_UnusedX_HighlightOffsetL;
    float Xhlslcc_UnusedX_HighlightOffsetR;
    float Xhlslcc_UnusedX_BendValue;
    float Xhlslcc_UnusedX_ReflectionRoughness;
    float Xhlslcc_UnusedX_ReflectionThreshold;
    float Xhlslcc_UnusedX_ReflectionSoftness;
    float Xhlslcc_UnusedX_ReflectionBlendThreshold;
    float Xhlslcc_UnusedX_ReflectionReversedThreshold;
    float Xhlslcc_UnusedX_FakeRefBlendIntensity;
    float Xhlslcc_UnusedX_FakeRefAddIntensity;
    vec4 Xhlslcc_UnusedX_ReflectionColor;
    vec4 Xhlslcc_UnusedX_ReflectionBlendColor;
};
layout(std140, binding = 1) uniform UnityPerMaterial{
    vec3 _CharaWorldSpaceOffset;
    float Xhlslcc_UnusedX_DisableWorldSpaceGradient;
    vec4 _Color;
    vec4 Xhlslcc_UnusedX_BackColor;
    vec4 _MainTex_ST;
    vec4 Xhlslcc_UnusedX_EyeShadowColor;
    vec4 Xhlslcc_UnusedX_BrightDiffuseColor;
    vec4 Xhlslcc_UnusedX_ShadowDiffuseColor;
    vec4 Xhlslcc_UnusedX_SpecularColor0;
    float _IsMonster;
    float Xhlslcc_UnusedX_AlphaCutoff;
    float Xhlslcc_UnusedX_NormalScale;
    float Xhlslcc_UnusedX_ShadowThreshold;
    float Xhlslcc_UnusedX_ShadowFeather;
    float Xhlslcc_UnusedX_SpecularShininess;
    float Xhlslcc_UnusedX_SpecularShininess0;
    float Xhlslcc_UnusedX_SpecularIntensity;
    float Xhlslcc_UnusedX_SpecularIntensity0;
    float Xhlslcc_UnusedX_SpecularRoughness0;
    float Xhlslcc_UnusedX_SpecularThreshold;
    float Xhlslcc_UnusedX_SpecularShadowOffset;
    float Xhlslcc_UnusedX_SpecularShadowIntensity;
    float Xhlslcc_UnusedX_ExMapThreshold;
    float Xhlslcc_UnusedX_ExSpecularIntensity;
    float Xhlslcc_UnusedX_ExCheekIntensity;
    float Xhlslcc_UnusedX_ExShyIntensity;
    float Xhlslcc_UnusedX_ExShadowIntensity;
    vec4 Xhlslcc_UnusedX_ExCheekColor;
    vec4 Xhlslcc_UnusedX_ExShyColor;
    vec4 Xhlslcc_UnusedX_ExShadowColor;
    vec4 Xhlslcc_UnusedX_ExEyeColor;
    float Xhlslcc_UnusedX_HairBlendWeight;
    float Xhlslcc_UnusedX_HairBlendOffset;
    float Xhlslcc_UnusedX_EyeEffectProcs;
    float Xhlslcc_UnusedX_EyeEffectPower;
    vec4 Xhlslcc_UnusedX_EyeEffectColor;
    float Xhlslcc_UnusedX_EyeEffectDarken;
    float Xhlslcc_UnusedX_EmissionThreshold;
    float Xhlslcc_UnusedX_EmissionIntensity;
    float Xhlslcc_UnusedX_NoseLinePower;
    vec4 Xhlslcc_UnusedX_NoseLineColor;
    int _ShowPartID;
    vec4 Xhlslcc_UnusedX_OutlineColor;
    vec4 Xhlslcc_UnusedX_OutlineColor0;
    float Xhlslcc_UnusedX_OutlineWidth;
    float Xhlslcc_UnusedX_OneMinusCharacterOutlineWidthScale;
    float Xhlslcc_UnusedX_FixLipOutline;
    float Xhlslcc_UnusedX_OutlineColorIntensity;
    int Xhlslcc_UnusedX_UsingDitherAlpha;
    float Xhlslcc_UnusedX_DitherAlpha;
    float Xhlslcc_UnusedX_DissolveRate;
    vec4 Xhlslcc_UnusedX_DissolveUVSpeed;
    vec4 Xhlslcc_UnusedX_DissolveOutlineColor1;
    vec4 Xhlslcc_UnusedX_DissolveOutlineColor2;
    float Xhlslcc_UnusedX_DissolveDistortionIntensity;
    float Xhlslcc_UnusedX_DissolveOutlineSize1;
    float Xhlslcc_UnusedX_DissolveOutlineSize2;
    float Xhlslcc_UnusedX_DissolveOutlineOffset;
    float Xhlslcc_UnusedX_DissoveDirecMask;
    float Xhlslcc_UnusedX_DissolveMapAdd;
    float Xhlslcc_UnusedX_DissolveUV;
    vec4 Xhlslcc_UnusedX_DissolveOutlineSmoothStep;
    vec4 Xhlslcc_UnusedX_DissolveST;
    vec4 Xhlslcc_UnusedX_DistortionST;
    vec4 Xhlslcc_UnusedX_DissolveMap_ST;
    vec4 Xhlslcc_UnusedX_DissolveComponent;
    vec4 Xhlslcc_UnusedX_DissolveDiretcionXYZ;
    vec4 Xhlslcc_UnusedX_DissolveCenter;
    vec4 Xhlslcc_UnusedX_DissolvePosMaskPos;
    vec4 Xhlslcc_UnusedX_DissolvePosMaskRootOffset;
    float Xhlslcc_UnusedX_DissolvePosMaskWorldON;
    float Xhlslcc_UnusedX_DissolveUseDirection;
    float Xhlslcc_UnusedX_DissolvePosMaskFilpOn;
    float Xhlslcc_UnusedX_DissolvePosMaskOn;
    float Xhlslcc_UnusedX_DissolvePosMaskGlobalOn;
    float Xhlslcc_UnusedX_DissoveON;
    float Xhlslcc_UnusedX_RimEdge;
    float Xhlslcc_UnusedX_RimFeatherWidth;
    float Xhlslcc_UnusedX_RimLightMode;
    vec4 Xhlslcc_UnusedX_RimColor;
    vec4 Xhlslcc_UnusedX_RimOffset;
    vec4 Xhlslcc_UnusedX_RimColor0;
    float Xhlslcc_UnusedX_Rimintensity;
    float Xhlslcc_UnusedX_RimWidth;
    float Xhlslcc_UnusedX_RimWidth0;
    float Xhlslcc_UnusedX_CustomColor;
    vec4 Xhlslcc_UnusedX_CustomColor0;
    vec4 Xhlslcc_UnusedX_CustomColor1;
    vec4 Xhlslcc_UnusedX_CustomColor2;
    vec4 Xhlslcc_UnusedX_CustomColor3;
    vec4 Xhlslcc_UnusedX_CustomColor4;
    vec4 Xhlslcc_UnusedX_CustomColor5;
    vec4 Xhlslcc_UnusedX_CustomColor6;
    vec4 Xhlslcc_UnusedX_CustomColor7;
    vec4 Xhlslcc_UnusedX_CustomColor8;
    vec4 Xhlslcc_UnusedX_CustomColor9;
    vec4 Xhlslcc_UnusedX_CustomColor10;
    vec4 Xhlslcc_UnusedX_CustomColor11;
    vec4 Xhlslcc_UnusedX_CustomColor12;
    vec4 Xhlslcc_UnusedX_CustomColor13;
    vec4 Xhlslcc_UnusedX_CustomSkinColor;
    vec4 Xhlslcc_UnusedX_CustomSkinColor1;
    vec4 Xhlslcc_UnusedX_CustomSkinLineColor;
    vec4 Xhlslcc_UnusedX_CustomBeardColor;
    vec4 Xhlslcc_UnusedX_CustomBeardColor1;
    vec4 Xhlslcc_UnusedX_CustomEyeBallColor;
    vec4 Xhlslcc_UnusedX_CustomEyeBallColor1;
    vec4 Xhlslcc_UnusedX_CustomEyeBallColor2;
    vec4 Xhlslcc_UnusedX_CustomEyeBaseColor;
    vec4 Xhlslcc_UnusedX_CustomSkinLightColor;
    vec4 Xhlslcc_UnusedX_CustomSkinDarkColor;
    vec4 Xhlslcc_UnusedX_CustomEyeDarkColor;
    vec4 Xhlslcc_UnusedX_CustomHairLightColor;
    vec4 Xhlslcc_UnusedX_CustomHairDarkColor;
    vec4 Xhlslcc_UnusedX_CustomHairLineColor;
    vec4 Xhlslcc_UnusedX_CustomDecorateDarkColor;
    vec4 Xhlslcc_UnusedX_CustomDecorateLightColor;
    vec4 Xhlslcc_UnusedX_CustomFurLightColor;
    vec4 Xhlslcc_UnusedX_CustomFurDarkColor;
    vec4 Xhlslcc_UnusedX_CustomFurInLightColor;
    vec4 Xhlslcc_UnusedX_CustomFurInDarkColor;
    float Xhlslcc_UnusedX_CustomEyeBallColor2Range;
    int _HideCharaParts;
    int _HideNPCParts;
    float Xhlslcc_UnusedX_RimIntensityDark;
    float Xhlslcc_UnusedX_WithFur;
    float Xhlslcc_UnusedX_FresnelColorStrength;
    vec4 Xhlslcc_UnusedX_FresnelColor;
    vec4 Xhlslcc_UnusedX_FresnelBSI;
    float Xhlslcc_UnusedX_EnableAlphaCutoff;
    float Xhlslcc_UnusedX_mBloomIntensity0;
    float Xhlslcc_UnusedX_mBloomIntensity1;
    float Xhlslcc_UnusedX_mBloomIntensity;
    vec4 Xhlslcc_UnusedX_mBloomColor0;
    float Xhlslcc_UnusedX_CustomsizedFace;
    int _UseMaterialValuesLUT;
    int _TestMatIDLUTEnabled;
    vec4 Xhlslcc_UnusedX_InstaceProbeUV;
};
layout(std140, binding = 2) uniform UnityPerMaterialCharacterOnly{
    vec4 Xhlslcc_UnusedX_AddColor;
    vec4 Xhlslcc_UnusedX_EnvColor;
    vec4 Xhlslcc_UnusedX_EmissionTintColor;
    float Xhlslcc_UnusedX_BackShadowRange;
    float _ShadowBoost;
    float _ShadowRamp;
    float _ShadowBoostVal;
    vec4 Xhlslcc_UnusedX_ShadowColor;
    vec4 Xhlslcc_UnusedX_EyeBaseShadowColor;
    float Xhlslcc_UnusedX_EyeShadowAngleMin;
    float Xhlslcc_UnusedX_EyeShadowMaxAngle;
    float Xhlslcc_UnusedX_UseUVChannel2;
    float Xhlslcc_UnusedX_UseSpecialEye;
    vec4 Xhlslcc_UnusedX_SpecialEyeShapeTexture_ST;
    vec4 Xhlslcc_UnusedX_EyeCenter;
    vec4 Xhlslcc_UnusedX_EyeSPColor1;
    vec4 Xhlslcc_UnusedX_EyeSPColor2;
    float Xhlslcc_UnusedX_SpecialEyeIntensity;
    vec4 Xhlslcc_UnusedX_LipLinefixColor;
    float Xhlslcc_UnusedX_LipLineFixThrd;
    float Xhlslcc_UnusedX_LipLineFixStart;
    float Xhlslcc_UnusedX_LipLineFixMax;
    float Xhlslcc_UnusedX_LipLineFixScale;
    float Xhlslcc_UnusedX_LipLineFixSC;
    int _UseOverHeated;
    vec4 Xhlslcc_UnusedX_HeatDir;
    vec4 _HeatColor0;
    vec4 _HeatColor1;
    vec4 _HeatColor2;
    float _HeatedHeight;
    float _HeatedThreshould;
    float _HeatInst;
    float Xhlslcc_UnusedX_ParallaxAlpha;
    float Xhlslcc_UnusedX_ParallaxScale;
    vec4 Xhlslcc_UnusedX_ParallaxMap_ST;
    float Xhlslcc_UnusedX_ShadowIntensity;
    vec4 Xhlslcc_UnusedX_RefractionTexTilingOffset;
    float Xhlslcc_UnusedX_IOR;
    float Xhlslcc_UnusedX_RGBSpread;
    float Xhlslcc_UnusedX_Angle;
    vec4 Xhlslcc_UnusedX_RefractionTintColor;
    float Xhlslcc_UnusedX_DiamondScale;
    vec3 Xhlslcc_UnusedX_OffsetRelativeToCenter;
    vec3 Xhlslcc_UnusedX_EulerAngleOffset;
    vec3 Xhlslcc_UnusedX_FinalOffset;
    vec4 Xhlslcc_UnusedX_RefractionTexTilingOffset_CatHead;
    float Xhlslcc_UnusedX_IOR_CatHead;
    float Xhlslcc_UnusedX_RGBSpread_CatHead;
    float Xhlslcc_UnusedX_Angle_CatHead;
    vec4 Xhlslcc_UnusedX_RefractionTintColor_CatHead;
    float Xhlslcc_UnusedX_DiamondScale_CatHead;
    vec3 Xhlslcc_UnusedX_CenterOffset1;
    vec3 Xhlslcc_UnusedX_OffsetRelativeToCenter1;
    vec3 Xhlslcc_UnusedX_EulerAngleOffset_CatHead;
    vec3 Xhlslcc_UnusedX_FinalOffset_CatHead;
    vec3 Xhlslcc_UnusedX_CatHead_Right;
    vec3 Xhlslcc_UnusedX_CatHead_Up;
    vec3 Xhlslcc_UnusedX_CatHead_Forward;
    vec4 Xhlslcc_UnusedX_RefractionTexTilingOffset_CatHead_Weight;
    vec4 Xhlslcc_UnusedX_RefractionTintColor_CatHead_Weight;
    float Xhlslcc_UnusedX_Angle_CatHead_Weight;
    vec4 Xhlslcc_UnusedX_FinalOffset_CatHead_Weight;
    float Xhlslcc_UnusedX_SpecularIntensity_CatHead;
    float _CharacterToonRampModeCompensation;
    vec4 Xhlslcc_UnusedX_CenterOffset;
    vec4 Xhlslcc_UnusedX_Direction;
    float Xhlslcc_UnusedX_RefIntensity;
    float Xhlslcc_UnusedX_AlphaTestThreshold;
};
layout(location = 0) uniform sampler2D _MainTex;
layout(location = 1) uniform sampler2D _LightMap;
layout(location = 2) uniform sampler2D _DiffuseRampMultiTex;
layout(location = 3) uniform sampler2D _DiffuseCoolRampMultiTex;
layout(location = 4) uniform sampler2D _MaterialValuesPackLUT;
layout(location = 5) uniform sampler2D _MainLightShadowmapTexture;
layout(location = 6) uniform sampler2DShadow hlslcc_zcmp_MainLightShadowmapTexture;
in vec4 vs_TEXCOORD0;
in vec4 vs_COLOR0;
in vec3 vs_TEXCOORD2;
in vec3 vs_TEXCOORD3;
in vec4 vs_TEXCOORD4;
layout(location = 0) out vec4 SV_Target0;
layout(location = 1) out vec4 SV_Target1;
layout(location = 2) out float SV_Target2;
vec3 u_xlat0;
vec3 u_xlat16_0;
vec4 u_xlat1;
vec3 u_xlat16_1;
bvec4 u_xlatb1;
float u_xlat16_2;
uvec4 u_xlatu2;
vec3 u_xlat3;
vec3 u_xlat16_3;
bvec4 u_xlatb3;
vec4 u_xlat4;
vec4 u_xlat16_4;
vec4 u_xlat5;
vec4 u_xlat16_5;
vec4 u_xlat6;
vec4 u_xlat16_6;
vec4 u_xlat7;
vec4 u_xlat16_7;
vec4 u_xlat8;
vec4 u_xlat16_8;
vec4 u_xlat9;
vec2 u_xlat16_9;
vec3 u_xlat10;
vec4 u_xlat11;
vec3 u_xlat12;
vec3 u_xlat16_13;
vec3 u_xlat16_14;
vec3 u_xlat16_15;
vec3 u_xlat16_16;
vec3 u_xlat16_17;
vec3 u_xlat19;
bvec2 u_xlatb19;
vec3 u_xlat16_20;
float u_xlat21;
float u_xlat16_21;
vec3 u_xlat16_31;
vec3 u_xlat16_32;
float u_xlat36;
vec2 u_xlat37;
bool u_xlatb37;
vec2 u_xlat16_38;
vec2 u_xlat39;
vec2 u_xlat16_43;
vec2 u_xlat16_44;
float u_xlat54;
int u_xlati54;
uint u_xlatu54;
bool u_xlatb54;
bool u_xlatb55;
float u_xlat16_56;
float u_xlat16_67;
void main(){
    vec3 debugColor = vec3(0.0, 0.0, 0.0);

    vec4 hlslcc_FragCoord = vec4(gl_FragCoord.xyz, (1.0 / gl_FragCoord.w));
    (u_xlat16_0.xyz = texture(_MainTex, vs_TEXCOORD0.xy).xyz);
    (u_xlat0.xyz = (u_xlat16_0.xyz * _Color.xyz));

    (u_xlat16_1.xy = texture(_LightMap, vs_TEXCOORD0.xy).yw);

    (u_xlat16_2 = (u_xlat16_1.y * 8.0));
    (u_xlat16_2 = floor(u_xlat16_2));
    (u_xlat16_20.x = (u_xlat16_2 * 8.0));
    (u_xlatb54 = (u_xlat16_20.x >= (-u_xlat16_20.x)));

    (u_xlat16_20.xy = ((bool(u_xlatb54)) ? (vec2(8.0, 0.125)) : (vec2(-8.0, -0.125))));
    (u_xlat16_2 = (u_xlat16_20.y * u_xlat16_2));
    (u_xlat16_2 = fract(u_xlat16_2));
    (u_xlat16_2 = (u_xlat16_2 * u_xlat16_20.x));


  //Shadow Atten---------------------------------------------
    (u_xlat19.xyz = (vs_TEXCOORD2.xyz + (-_CascadeShadowSplitSpheres0.xyz)));
    (u_xlat3.xyz = (vs_TEXCOORD2.xyz + (-_CascadeShadowSplitSpheres1.xyz)));
    (u_xlat4.xyz = (vs_TEXCOORD2.xyz + (-_CascadeShadowSplitSpheres2.xyz)));
    (u_xlat5.xyz = (vs_TEXCOORD2.xyz + (-_CascadeShadowSplitSpheres3.xyz)));
    (u_xlat6.x = dot(u_xlat19.xyz, u_xlat19.xyz));
    (u_xlat6.y = dot(u_xlat3.xyz, u_xlat3.xyz));
    (u_xlat6.z = dot(u_xlat4.xyz, u_xlat4.xyz));
    (u_xlat6.w = dot(u_xlat5.xyz, u_xlat5.xyz));
    (u_xlatb3 = lessThan(u_xlat6, _CascadeShadowSplitSphereRadii));
    (u_xlat16_4.x = ((u_xlatb3.x) ? (1.0) : (0.0)));
    (u_xlat16_4.y = ((u_xlatb3.y) ? (1.0) : (0.0)));
    (u_xlat16_4.z = ((u_xlatb3.z) ? (1.0) : (0.0)));
    (u_xlat16_4.w = ((u_xlatb3.w) ? (1.0) : (0.0)));
    (u_xlat16_20.x = ((u_xlatb3.x) ? (-1.0) : (-0.0)));
    (u_xlat16_20.y = ((u_xlatb3.y) ? (-1.0) : (-0.0)));
    (u_xlat16_20.z = ((u_xlatb3.z) ? (-1.0) : (-0.0)));
    (u_xlat16_20.xyz = (u_xlat16_20.xyz + u_xlat16_4.yzw));
    (u_xlat16_4.yzw = max(u_xlat16_20.xyz, vec3(0.0, 0.0, 0.0)));
    (u_xlat16_20.x = dot(u_xlat16_4, vec4(4.0, 3.0, 2.0, 1.0)));
    (u_xlat16_20.x = ((-u_xlat16_20.x) + 4.0));
    (u_xlatu54 = uint(u_xlat16_20.x));
    (u_xlati54 = int((int(u_xlatu54) << 2)));
    (u_xlat19.xyz = (vs_TEXCOORD2.yyy * hlslcc_mtx4x4_MainLightWorldToShadow[(u_xlati54 + 1)].xyz));
    (u_xlat19.xyz = ((hlslcc_mtx4x4_MainLightWorldToShadow[u_xlati54].xyz * vs_TEXCOORD2.xxx) + u_xlat19.xyz));
    (u_xlat19.xyz = ((hlslcc_mtx4x4_MainLightWorldToShadow[(u_xlati54 + 2)].xyz * vs_TEXCOORD2.zzz) + u_xlat19.xyz));
    (u_xlat19.xyz = (u_xlat19.xyz + hlslcc_mtx4x4_MainLightWorldToShadow[(u_xlati54 + 3)].xyz));
    (u_xlat3.xy = ((u_xlat19.xy * _MainLightShadowmapSize.zw) + vec2(0.5, 0.5)));
    (u_xlat3.xy = floor(u_xlat3.xy));
    (u_xlat39.xy = ((u_xlat19.xy * _MainLightShadowmapSize.zw) + (-u_xlat3.xy)));
    (u_xlat16_4 = (u_xlat39.xxyy + vec4(0.5, 1.0, 0.5, 1.0)));
    (u_xlat16_5 = (u_xlat16_4.xxzz * u_xlat16_4.xxzz));
    (u_xlat16_20.xy = (u_xlat16_5.yw * vec2(0.079999998, 0.079999998)));
    (u_xlat16_7.xy = ((u_xlat16_5.xz * vec2(0.5, 0.5)) + (-u_xlat39.xy)));
    (u_xlat16_43.xy = ((-u_xlat39.xy) + vec2(1.0, 1.0)));
    (u_xlat16_8.xy = min(u_xlat39.xy, vec2(0.0, 0.0)));
    (u_xlat16_8.xy = (((-u_xlat16_8.xy) * u_xlat16_8.xy) + u_xlat16_43.xy));
    (u_xlat16_44.xy = max(u_xlat39.xy, vec2(0.0, 0.0)));
    (u_xlat16_8.zw = (((-u_xlat16_44.xy) * u_xlat16_44.xy) + u_xlat16_4.yw));
    (u_xlat16_8 = (u_xlat16_8 + vec4(1.0, 1.0, 1.0, 1.0)));
    (u_xlat16_5.xy = (u_xlat16_7.xy * vec2(0.16, 0.16)));
    (u_xlat16_6.xy = (u_xlat16_43.xy * vec2(0.16, 0.16)));
    (u_xlat16_7.xy = (u_xlat16_8.xy * vec2(0.16, 0.16)));
    (u_xlat16_8.xy = (u_xlat16_8.zw * vec2(0.16, 0.16)));
    (u_xlat16_9.xy = (u_xlat16_4.yw * vec2(0.16, 0.16)));
    (u_xlat16_5.z = u_xlat16_7.x);
    (u_xlat16_5.w = u_xlat16_9.x);
    (u_xlat16_6.z = u_xlat16_8.x);
    (u_xlat16_6.w = u_xlat16_20.x);
    (u_xlat4 = (u_xlat16_5.zwxz + u_xlat16_6.zwxz));
    (u_xlat16_7.z = u_xlat16_5.y);
    (u_xlat16_7.w = u_xlat16_9.y);
    (u_xlat16_8.z = u_xlat16_6.y);
    (u_xlat16_8.w = u_xlat16_20.y);
    (u_xlat10.xyz = (u_xlat16_7.zyw + u_xlat16_8.zyw));
    (u_xlat11.xyz = (u_xlat16_6.xzw / u_xlat4.zwy));
    (u_xlat11.xyz = (u_xlat11.xyz + vec3(-2.5, -0.5, 1.5)));
    (u_xlat12.xyz = (u_xlat16_8.zyw / u_xlat10.xyz));
    (u_xlat12.xyz = (u_xlat12.xyz + vec3(-2.5, -0.5, 1.5)));
    (u_xlat5.xyz = (u_xlat11.yxz * _MainLightShadowmapSize.xxx));
    (u_xlat6.xyz = (u_xlat12.xyz * _MainLightShadowmapSize.yyy));
    (u_xlat5.w = u_xlat6.x);
    (u_xlat7 = ((u_xlat3.xyxy * _MainLightShadowmapSize.xyxy) + u_xlat5.ywxw));
    (u_xlat39.xy = ((u_xlat3.xy * _MainLightShadowmapSize.xy) + u_xlat5.zw));
    (u_xlat6.w = u_xlat5.y);
    (u_xlat5.yw = u_xlat6.yz);
    (u_xlat8 = ((u_xlat3.xyxy * _MainLightShadowmapSize.xyxy) + u_xlat5.xyzy));
    (u_xlat6 = ((u_xlat3.xyxy * _MainLightShadowmapSize.xyxy) + u_xlat6.wywz));
    (u_xlat5 = ((u_xlat3.xyxy * _MainLightShadowmapSize.xyxy) + u_xlat5.xwzw));
    (u_xlat9 = (u_xlat4.zwyz * u_xlat10.xxxy));
    (u_xlat11 = (u_xlat4 * u_xlat10.yyzz));
    (u_xlat54 = (u_xlat4.y * u_xlat10.z));
    vec3 txVec0 = vec3(u_xlat7.xy, u_xlat19.z);
    (u_xlat16_3.x = textureLod(hlslcc_zcmp_MainLightShadowmapTexture, txVec0, 0.0));
    vec3 txVec1 = vec3(u_xlat7.zw, u_xlat19.z);
    (u_xlat16_21 = textureLod(hlslcc_zcmp_MainLightShadowmapTexture, txVec1, 0.0));
    (u_xlat21 = (u_xlat16_21 * u_xlat9.y));
    (u_xlat3.x = ((u_xlat9.x * u_xlat16_3.x) + u_xlat21));
    vec3 txVec2 = vec3(u_xlat39.xy, u_xlat19.z);
    (u_xlat16_21 = textureLod(hlslcc_zcmp_MainLightShadowmapTexture, txVec2, 0.0));
    (u_xlat3.x = ((u_xlat9.z * u_xlat16_21) + u_xlat3.x));
    vec3 txVec3 = vec3(u_xlat6.xy, u_xlat19.z);
    (u_xlat16_21 = textureLod(hlslcc_zcmp_MainLightShadowmapTexture, txVec3, 0.0));
    (u_xlat3.x = ((u_xlat9.w * u_xlat16_21) + u_xlat3.x));
    vec3 txVec4 = vec3(u_xlat8.xy, u_xlat19.z);
    (u_xlat16_21 = textureLod(hlslcc_zcmp_MainLightShadowmapTexture, txVec4, 0.0));
    (u_xlat3.x = ((u_xlat11.x * u_xlat16_21) + u_xlat3.x));
    vec3 txVec5 = vec3(u_xlat8.zw, u_xlat19.z);
    (u_xlat16_21 = textureLod(hlslcc_zcmp_MainLightShadowmapTexture, txVec5, 0.0));
    (u_xlat3.x = ((u_xlat11.y * u_xlat16_21) + u_xlat3.x));
    vec3 txVec6 = vec3(u_xlat6.zw, u_xlat19.z);
    (u_xlat16_21 = textureLod(hlslcc_zcmp_MainLightShadowmapTexture, txVec6, 0.0));
    (u_xlat3.x = ((u_xlat11.z * u_xlat16_21) + u_xlat3.x));
    vec3 txVec7 = vec3(u_xlat5.xy, u_xlat19.z);
    (u_xlat16_21 = textureLod(hlslcc_zcmp_MainLightShadowmapTexture, txVec7, 0.0));
    (u_xlat3.x = ((u_xlat11.w * u_xlat16_21) + u_xlat3.x));
    vec3 txVec8 = vec3(u_xlat5.zw, u_xlat19.z);
    (u_xlat16_21 = textureLod(hlslcc_zcmp_MainLightShadowmapTexture, txVec8, 0.0));
    (u_xlat54 = ((u_xlat54 * u_xlat16_21) + u_xlat3.x));
    (u_xlat16_20.x = ((-u_xlat54) + 1.0));
    (u_xlat16_38.x = ((-_MainLightShadowParams.x) + 1.0));
    (u_xlat16_20.x = ((u_xlat16_20.x * _MainLightShadowParams.x) + u_xlat16_38.x));
    (u_xlat3.xy = (_MainLightShadowmapSize.xy * vec2(4.0, 4.0)));
    (u_xlatb54 = (0.0 >= u_xlat19.z));
    (u_xlatb55 = (u_xlat19.z >= 1.0));
    (u_xlatb54 = (u_xlatb54 || u_xlatb55));
    (u_xlatb3.xy = greaterThanEqual(u_xlat3.xyxx, u_xlat19.xyxx).xy);
    (u_xlatb55 = (u_xlatb3.y || u_xlatb3.x));
    (u_xlat16_38.xy = (((-_MainLightShadowmapSize.xy) * vec2(4.0, 4.0)) + vec2(1.0, 1.0)));
    (u_xlatb19.xy = greaterThanEqual(u_xlat19.xyxx, u_xlat16_38.xyxx).xy);
    (u_xlatb19.x = (u_xlatb19.y || u_xlatb19.x));
    (u_xlatb19.x = (u_xlatb19.x || u_xlatb55));
    (u_xlatb54 = (u_xlatb54 || u_xlatb19.x));
    (u_xlat16_20.x = ((u_xlatb54) ? (1.0) : (u_xlat16_20.x)));
    (u_xlat54 = (_ES_Indoor * _ES_IndoorCharShadowAsCookie));
    (u_xlat16_38.x = (u_xlat16_20.x + -1.0));
    (u_xlat16_38.x = ((u_xlat54 * u_xlat16_38.x) + 1.0));
    (u_xlat16_56 = ((-u_xlat16_20.x) + 1.0));
    (u_xlat16_20.x = ((u_xlat54 * u_xlat16_56) + u_xlat16_20.x));
    (u_xlat16_20.x = ((-u_xlat16_20.x) + 1.0));
    (u_xlat16_20.x = (((-u_xlat16_20.x) * 1.25) + 1.0));
    (u_xlat16_20.x = clamp(u_xlat16_20.x, 0.0, 1.0));
    (u_xlat16_56 = ((-u_xlat16_20.x) + 1.0));
    (u_xlat16_20.x = ((_ES_CharacterShadowFactor * u_xlat16_56) + u_xlat16_20.x));
    //shadow atten-----------------------

    (u_xlat16_56 = (_ES_CharacterDisableLocalMainLight + 1.0));
    (u_xlat16_56 = (u_xlat16_56 + (-abs(_DisableCharacterLocalLight.x))));
    (u_xlatb54 = (0.5 < u_xlat16_56));
    (u_xlat19.xyz = ((bool(u_xlatb54)) ? (_MainLightPosition.xyz) : (_CharacterLocalMainLightPosition.xyz)));
    (u_xlatb54 = (0.5 < _IsMonster));
    (u_xlat16_13.xyz = ((bool(u_xlatb54)) ? (_ES_MonsterLightDir.xyz) : (u_xlat19.xyz)));
    //u_xlat16_13 = lerp(u_xlat16_13, _CustomMainLightDir, _CustomMainLightDir.www)
    (u_xlat16_14.xyz = ((-u_xlat16_13.xyz) + _CustomMainLightDir.xyz));
    (u_xlat16_13.xyz = ((_CustomMainLightDir.www * u_xlat16_14.xyz) + u_xlat16_13.xyz));
    //---
    (u_xlat16_13.xyz = ((bool(u_xlatb54)) ? (_ES_MonsterLightDir.xyz) : (u_xlat16_13.xyz)));
    //u_xlat16_13 = LightDir

//vs_TEXCOORD4=viewDirWS
    (u_xlat16_56 = dot(vs_TEXCOORD4.xyz, vs_TEXCOORD4.xyz));
    (u_xlat16_56 = inversesqrt(u_xlat16_56));
    (u_xlat16_14.xyz = (vec3(u_xlat16_56) * vs_TEXCOORD4.xyz));
//u_xlat16_14 = normalize(viewDirWS)
//-------------------------

//vs_TEXCOORD3 = normalWS
    (u_xlat16_56 = dot(vs_TEXCOORD3.xyz, vs_TEXCOORD3.xyz));
    (u_xlat16_56 = inversesqrt(u_xlat16_56));
    (u_xlat16_15.xyz = (vec3(u_xlat16_56) * vs_TEXCOORD3.xyz));
//u_xlat16_15 = normalize(normalWS)
//-------------------------
    (u_xlat16_56 = (((((gl_FrontFacing) ? (4294967295u) : (0u)) != 0u)) ? (1.0) : (-1.0)));
    (u_xlat16_15.xyz = (vec3(u_xlat16_56) * u_xlat16_15.xyz));


//u_xlat19 = normalVS
    (u_xlat19.xyz = (u_xlat16_15.yyy * hlslcc_mtx4x4unity_MatrixV[1].xyz));
    (u_xlat19.xyz = ((hlslcc_mtx4x4unity_MatrixV[0].xyz * u_xlat16_15.xxx) + u_xlat19.xyz));
    (u_xlat19.xyz = ((hlslcc_mtx4x4unity_MatrixV[2].xyz * u_xlat16_15.zzz) + u_xlat19.xyz));
//u_xlat3 = viewDirVS
    (u_xlat3.xyz = (u_xlat16_14.yyy * hlslcc_mtx4x4unity_MatrixV[1].xyz));
    (u_xlat3.xyz = ((hlslcc_mtx4x4unity_MatrixV[0].xyz * u_xlat16_14.xxx) + u_xlat3.xyz));
    (u_xlat3.xyz = ((hlslcc_mtx4x4unity_MatrixV[2].xyz * u_xlat16_14.zzz) + u_xlat3.xyz));
//-------------------------

//u_xlat16_56 = NdotL
    (u_xlat16_56 = dot(u_xlat16_15.xyz, u_xlat16_13.xyz));
//    debugColor = vec4(u_xlat16_13.xyz, 1.0);

    //todo: rim light---------------------------
    (u_xlat16_13.xyz = (u_xlat3.xyz + (-_RimShadowOffset.xyz)));
    (u_xlat16_67 = dot(u_xlat16_13.xyz, u_xlat16_13.xyz));
    (u_xlat16_67 = inversesqrt(u_xlat16_67));
    (u_xlat16_13.xyz = (vec3(u_xlat16_67) * u_xlat16_13.xyz));

    (u_xlat16_13.x = dot(u_xlat19.xyz, u_xlat16_13.xyz));
    (u_xlat16_13.x = clamp(u_xlat16_13.x, 0.0, 1.0));
    // ----------------------------------------

    //todo: lightTex.y (outline)
    (u_xlat16_31.x = (u_xlat16_1.x + u_xlat16_1.x));
    (u_xlat16_31.x = (u_xlat16_31.x * vs_COLOR0.x));
    //todo:u_xlat16_56 is half lambert
    (u_xlat16_56 = ((u_xlat16_56 * 0.5) + 0.5));
    (u_xlat16_56 = clamp(u_xlat16_56, 0.0, 1.0));
//    halfLambert
    (u_xlat16_56 = dot(vec2(u_xlat16_56), u_xlat16_31.xx));


    //u_xlat54 = shadowAtten
    (u_xlatb54 = (0.5 < _ES_CharacterDisableLocalMainLight));
    (u_xlat19.x = ((-u_xlat16_20.x) + 1.0));
    (u_xlat19.x = ((_CharacterLocalMainLightPosition.w * u_xlat19.x) + u_xlat16_20.x));
    (u_xlat54 = ((u_xlatb54) ? (u_xlat16_20.x) : (u_xlat19.x)));
    //u_xlat54 = shadowAtten

    (u_xlat16_20.x = (u_xlat54 * u_xlat16_56));
    (u_xlat16_20.x = min(u_xlat16_38.x, u_xlat16_20.x));
    (u_xlat16_56 = (u_xlat16_1.x * vs_COLOR0.x));
    (u_xlat16_31.x = max(u_xlat16_20.x, 0.001));
    (u_xlat16_31.x = ((u_xlat16_31.x * 0.85000002) + 0.15000001));

    (u_xlatb1.x = (u_xlat54 < 0.1));
    (u_xlat16_56 = min(u_xlat16_56, 0.80000001));
    (u_xlat16_56 = ((u_xlatb1.x) ? (u_xlat16_56) : (1.0)));
//   u_xlat16_56 = 1.0;
    (u_xlatb1.x = (_ShadowRamp < u_xlat16_20.x));
//    debugColor = vec4(_ShadowRamp.xxx,1.0);

    //todo: u_xlat16_14 ramp uv
    (u_xlat16_20.x = ((u_xlatb1.x) ? (0.99000001) : (u_xlat16_31.x)));
    (u_xlat16_14.x = (u_xlat16_56 * u_xlat16_20.x));

    (u_xlat16_31.x = ((u_xlat16_2 * 2.0) + 1.0));
    (u_xlat16_14.y = (u_xlat16_31.x * 0.0625));
//    debugColor = vec4(u_xlat16_2.xxx, 1.0);
//-----------Ramp-----------------
    (u_xlat16_1.xyz = texture(_DiffuseRampMultiTex, u_xlat16_14.xy).xyz);
    (u_xlat16_3.xyz = texture(_DiffuseCoolRampMultiTex, u_xlat16_14.xy).xyz);
    //debugColor = vec4(u_xlat16_14.xy,0.0, 1.0);

    (u_xlat16_31.x = (_ES_CharacterToonRampMode + (-_CharacterToonRampModeCompensation)));
    (u_xlat16_31.x = clamp(u_xlat16_31.x, 0.0, 1.0));
    (u_xlat16_14.xyz = ((-u_xlat16_1.xyz) + u_xlat16_3.xyz));
//    rampColor
    (u_xlat16_31.xyz = ((u_xlat16_31.xxx * u_xlat16_14.xyz) + u_xlat16_1.xyz));
    //-----------Ramp-----------------
//    debugColor = vec4(u_xlat16_20.xxx, 1.0);

    //纯白
    (u_xlat16_20.x = ((u_xlat16_20.x * u_xlat16_56) + -0.80000001));
    (u_xlat16_20.x = (u_xlat16_20.x * 10.000004));

    //  1-smoothstep(0.0, 1.0, u_xlat16_20.x)
    (u_xlat16_20.x = clamp(u_xlat16_20.x, 0.0, 1.0));
    (u_xlat16_56 = ((u_xlat16_20.x * -2.0) + 3.0));
    (u_xlat16_20.x = (u_xlat16_20.x * u_xlat16_20.x));
    (u_xlat1.x = (((-u_xlat16_56) * u_xlat16_20.x) + 1.0));
    //End

    // debugColor = vec4(_ES_LEVEL_ADJUST_ON.xxx, 1.0);

    (u_xlat1.x = (u_xlat1.x * _NewLocalLightStrength.z));

    (u_xlat16_20.x = roundEven(u_xlat16_2));
    (u_xlatb19.x = (u_xlat16_20.x == 0.0));

    (u_xlat3.xyz = (_CharacterLocalMainLightDark1.xyz + vec3(-1.0, -1.0, -1.0)));
    (u_xlat3.xyz = ((u_xlat1.xxx * u_xlat3.xyz) + vec3(1.0, 1.0, 1.0)));
    //u_xlat3 纯白
    (u_xlat3.xyz = (u_xlat3.xyz * u_xlat16_31.xyz));


    (u_xlat10.xyz = (_CharacterLocalMainLightDark.xyz + vec3(-1.0, -1.0, -1.0)));
    (u_xlat1.xzw = ((u_xlat1.xxx * u_xlat10.xyz) + vec3(1.0, 1.0, 1.0)));
    //u_xlat1.xzw 纯白
    (u_xlat1.xzw = (u_xlat1.xzw * u_xlat16_31.xyz));

//    todo:
    (u_xlat16_31.xyz = ((u_xlatb19.x) ? (u_xlat3.xyz) : (u_xlat1.xzw)));

    (u_xlatb1.x = (0.5 < _ES_LEVEL_ADJUST_ON));
//    debugColor = vec4(u_xlat16_31.xyz, 1.0);
    //u_xlat16_20.x=diffuseMask
    (u_xlat16_20.x = dot(u_xlat16_31.xyz, vec3(1.0, 1.0, 1.0)));
    (u_xlatb37 = (2.9000001 < u_xlat16_20.x));
    (u_xlat16_20.x = ((u_xlatb19.x) ? (0.0) : (1.0)));

    // levelHightLightColor = lerp(levelSkinLightColor, levelHightLightColor * 2, isSkin);
    (u_xlat16_14.xyz = (_ES_LevelSkinLightColor.www * _ES_LevelSkinLightColor.xyz));
    (u_xlat16_14.xyz = (u_xlat16_14.xyz + u_xlat16_14.xyz));

// debugColor = u_xlat16_14.xyz;

    (u_xlat16_16.xyz = (_ES_LevelHighLightColor.www * _ES_LevelHighLightColor.xyz));
    (u_xlat16_16.xyz = ((u_xlat16_16.xyz * vec3(2.0, 2.0, 2.0)) + (-u_xlat16_14.xyz)));
    (u_xlat16_14.xyz = ((u_xlat16_20.xxx * u_xlat16_16.xyz) + u_xlat16_14.xyz));


    //levelShadowColor = lerp(levelSkinShadowColor, levelShadowColor * 2, isSkin);
    (u_xlat16_16.xyz = (_ES_LevelSkinShadowColor.www * _ES_LevelSkinShadowColor.xyz));
    (u_xlat16_16.xyz = (u_xlat16_16.xyz + u_xlat16_16.xyz));
    (u_xlat16_17.xyz = (_ES_LevelShadowColor.www * _ES_LevelShadowColor.xyz));
    (u_xlat16_17.xyz = ((u_xlat16_17.xyz * vec3(2.0, 2.0, 2.0)) + (-u_xlat16_16.xyz)));
    (u_xlat16_16.xyz = ((u_xlat16_20.xxx * u_xlat16_17.xyz) + u_xlat16_16.xyz));


//todo:rampDiffuse
    (u_xlat16_17.xyz = (u_xlat16_31.xyz + (-vec3(vec3(_ES_LevelMid, _ES_LevelMid, _ES_LevelMid)))));
    (u_xlat16_20.xz = ((-vec2(_ES_LevelMid, _ES_LevelShadow)) + vec2(_ES_LevelHighLight, _ES_LevelMid)));
    (u_xlat16_17.xyz = (u_xlat16_17.xyz / u_xlat16_20.xxx));
    (u_xlat16_17.xyz = ((u_xlat16_17.xyz * vec3(0.5, 0.5, 0.5)) + vec3(0.5, 0.5, 0.5)));
    (u_xlat16_17.xyz = clamp(u_xlat16_17.xyz, 0.0, 1.0));

    (u_xlat16_14.xyz = (u_xlat16_14.xyz * u_xlat16_17.xyz));

    //finalColor u_xlat16_14
//todo:rampDiffuse2
    (u_xlat16_17.xyz = ((-u_xlat16_31.xyz) + vec3(vec3(_ES_LevelMid, _ES_LevelMid, _ES_LevelMid))));
    (u_xlat16_17.xyz = (u_xlat16_17.xyz / u_xlat16_20.zzz));
    (u_xlat16_17.xyz = (((-u_xlat16_17.xyz) * vec3(0.5, 0.5, 0.5)) + vec3(0.5, 0.5, 0.5)));
    (u_xlat16_17.xyz = clamp(u_xlat16_17.xyz, 0.0, 1.0));
    (u_xlat16_16.xyz = (u_xlat16_16.xyz * u_xlat16_17.xyz));
    //u_xlat16_16=levelShadowColor
    //

//    u_xlatb37==true
    (u_xlat16_14.xyz = ((bool(u_xlatb37)) ? (u_xlat16_14.xyz) : (u_xlat16_16.xyz)));
    (u_xlat16_31.xyz = ((u_xlatb1.x) ? (u_xlat16_14.xyz) : (u_xlat16_31.xyz)));


//u_xlat16_31 = levelShadowColor

    (u_xlatb1.x = (0.5 < _ShadowBoost));
    //u_xlatb1.x == 0
    //u_xlat54 = shadowAtten
    //u_xlat16_20.x = smoothstep(0.0, 1.0, u_xlat54 * 6.66)
    (u_xlat16_20.x = (u_xlat54 * 6.6666665));
    (u_xlat16_20.x = clamp(u_xlat16_20.x, 0.0, 1.0));
    (u_xlat16_56 = ((u_xlat16_20.x * -2.0) + 3.0));
    (u_xlat16_20.x = (u_xlat16_20.x * u_xlat16_20.x));
    (u_xlat16_20.x = (u_xlat16_20.x * u_xlat16_56));
//-----
    (u_xlat16_56 = (_ShadowBoostVal + 1.0));
    (u_xlat16_14.x = ((-u_xlat16_56) + 1.0));
    (u_xlat16_20.x = ((u_xlat16_20.x * u_xlat16_14.x) + u_xlat16_56));
    (u_xlat16_14.xyz = (u_xlat16_20.xxx * u_xlat16_31.xyz));
    (u_xlat16_31.xyz = ((u_xlatb1.x) ? (u_xlat16_14.xyz) : (u_xlat16_31.xyz)));
    (u_xlat16_14.xyz = (u_xlat0.xyz * u_xlat16_31.xyz));

//FinalColor:u_xlat16_14
//vs_TEXCOORD2 = positionWS
    (u_xlat1.xyz = (vs_TEXCOORD2.xyz + (-_NewLocalLightCharCenter.xyz)));
    (u_xlat54 = dot(u_xlat1.xyz, u_xlat1.xyz));
    (u_xlat54 = inversesqrt(u_xlat54));
    (u_xlat1.xyz = (vec3(u_xlat54) * u_xlat1.xyz));
    (u_xlat54 = dot(u_xlat1.xyz, _NewLocalLightDir.xyz));
    (u_xlat1.x = dot(u_xlat16_15.xyz, _NewLocalLightDir.xyz));
    (u_xlat16_20.x = (u_xlat1.x + 0.5));
    (u_xlat16_20.x = (u_xlat16_20.x * 0.66666669));
    (u_xlat16_20.x = clamp(u_xlat16_20.x, 0.0, 1.0));
    (u_xlat16_56 = ((u_xlat16_20.x * -2.0) + 3.0));
    (u_xlat16_20.x = (u_xlat16_20.x * u_xlat16_20.x));
    (u_xlat16_20.x = (u_xlat16_20.x * u_xlat16_56));
    (u_xlat16_56 = ((u_xlat54 * 0.5) + 0.5));
    (u_xlat54 = ((-_CharacterLocalMainLightColor1.w) + 1.0));
    (u_xlat54 = (u_xlat16_20.x * u_xlat54));
    (u_xlat54 = ((_CharacterLocalMainLightColor1.w * u_xlat16_56) + u_xlat54));
    (u_xlat1.xy = (vec2(u_xlat54) * _NewLocalLightStrength.xy));
    (u_xlat54 = (u_xlat16_38.x * u_xlat1.x));
    (u_xlatb1.xzw = lessThan(u_xlat16_14.xxyz, vec4(0.5, 0.0, 0.5, 0.5)).xzw);
    (u_xlat16_15.xyz = (u_xlat16_14.xyz + u_xlat16_14.xyz));
    (u_xlat16_15.xyz = (u_xlat16_15.xyz * _CharacterLocalMainLightColor1.xyz));
    (u_xlat16_16.xyz = (((-u_xlat16_31.xyz) * u_xlat0.xyz) + vec3(1.0, 1.0, 1.0)));
    (u_xlat16_16.xyz = (u_xlat16_16.xyz + u_xlat16_16.xyz));
    (u_xlat16_17.xyz = ((-_CharacterLocalMainLightColor1.xyz) + vec3(1.0, 1.0, 1.0)));
    (u_xlat16_16.xyz = (((-u_xlat16_16.xyz) * u_xlat16_17.xyz) + vec3(1.0, 1.0, 1.0)));
    {
        vec3 hlslcc_movcTemp = u_xlat16_15;
        (hlslcc_movcTemp.x = ((u_xlatb1.x) ? (u_xlat16_15.x) : (u_xlat16_16.x)));
        (hlslcc_movcTemp.y = ((u_xlatb1.z) ? (u_xlat16_15.y) : (u_xlat16_16.y)));
        (hlslcc_movcTemp.z = ((u_xlatb1.w) ? (u_xlat16_15.z) : (u_xlat16_16.z)));
        (u_xlat16_15 = hlslcc_movcTemp);
    }
    //u_xlat54.xxx==0

    (u_xlat16_31.xyz = (((-u_xlat16_31.xyz) * u_xlat0.xyz) + u_xlat16_15.xyz));
    (u_xlat16_31.xyz = ((vec3(u_xlat54) * u_xlat16_31.xyz) + u_xlat16_14.xyz));
    //_CharacterLocalMainLightColor2.xyz == 0
    (u_xlat1.xyz = (u_xlat1.yyy * _CharacterLocalMainLightColor2.xyz));
    (u_xlat1.xyz = ((u_xlat1.xyz * u_xlat16_38.xxx) + u_xlat16_31.xyz));

    (u_xlati54 = ((-_TestMatIDLUTEnabled) + 1));
    (u_xlati54 = (u_xlati54 * _UseMaterialValuesLUT));
    if ((u_xlati54 != 0))
    {
        (u_xlatu2.x = uint(int(u_xlat16_2)));
        (u_xlatu2.y = 5u);
        (u_xlatu2.z = 0u);
        (u_xlatu2.w = 6u);
        (u_xlat3.xyz = texelFetch(_MaterialValuesPackLUT, ivec2(u_xlatu2.xy), int(u_xlatu2.z)).xyz);
        (u_xlat10.xy = texelFetch(_MaterialValuesPackLUT, ivec2(u_xlatu2.xw), int(u_xlatu2.z)).xy);
        (u_xlat16_31.xyz = u_xlat3.xyz);
        (u_xlat16_14.xy = u_xlat10.xy);
    }
    else
    {
        (u_xlat16_31.xyz = _RimShadowColor0.xyz);
        (u_xlat16_14.xy = vec2(_RimShadowWidth0, _RimShadowFeather0));
    }
    (u_xlat16_15.xyz = (_ES_RimShadowColor.www * _ES_RimShadowColor.xyz));
    (u_xlat16_31.xyz = (u_xlat16_31.xyz * u_xlat16_15.xyz));


//rimLight
    (u_xlat16_13.x = ((-u_xlat16_13.x) + 1.0));
    (u_xlat16_13.x = max(u_xlat16_13.x, 0.001));
    (u_xlat16_13.x = log2(u_xlat16_13.x));
    (u_xlat16_13.x = (u_xlat16_13.x * _RimShadowCt));
    (u_xlat16_13.x = exp2(u_xlat16_13.x));
    (u_xlat16_13.x = (u_xlat16_13.x * u_xlat16_14.x));
    (u_xlat16_13.x = clamp(u_xlat16_13.x, 0.0, 1.0));
    //smoothstep(u_xlat16_14.y,1,u_xlat16_13.x)
    (u_xlat16_14.x = ((-u_xlat16_14.y) + 1.0));
    (u_xlat16_13.x = ((-u_xlat16_14.y) + u_xlat16_13.x));
    (u_xlat16_14.x = (1.0 / u_xlat16_14.x));
    (u_xlat16_13.x = (u_xlat16_13.x * u_xlat16_14.x));
    (u_xlat16_13.x = clamp(u_xlat16_13.x, 0.0, 1.0));
    (u_xlat16_14.x = ((u_xlat16_13.x * -2.0) + 3.0));
    (u_xlat16_13.x = (u_xlat16_13.x * u_xlat16_13.x));
    (u_xlat16_13.x = (u_xlat16_13.x * u_xlat16_14.x));
   (u_xlat16_13.x = (u_xlat16_13.x * _RimShadowIntensity));
    (u_xlat16_13.x = (u_xlat16_13.x * _ES_RimShadowIntensity));
    (u_xlat16_13.x = (u_xlat16_13.x * 0.25));

    // lerp(1,u_xlat16_31*2,u_xlat16_13);
    (u_xlat16_31.xyz = ((u_xlat16_31.xyz * vec3(2.0, 2.0, 2.0)) + vec3(-1.0, -1.0, -1.0)));
    (u_xlat16_13.xyz = ((u_xlat16_13.xxx * u_xlat16_31.xyz) + vec3(1.0, 1.0, 1.0)));
//u_xlat16_13 = rimColor
//todo:

    //u_xlat16_13.xyz 纯白
    (u_xlat16_13.xyz = (u_xlat1.xyz * u_xlat16_13.xyz));

    (u_xlatb54 = (_UseOverHeated == 1));
    (u_xlat1.x = (vs_TEXCOORD2.y + (-_CharaWorldSpaceOffset.y)));
    (u_xlat16_67 = max(_HeatedHeight, 0.0099999998));
    (u_xlat19.x = (1.0 / u_xlat16_67));
    (u_xlat1.x = (u_xlat19.x * u_xlat1.x));
    (u_xlat1.x = clamp(u_xlat1.x, 0.0, 1.0));
    (u_xlat19.x = ((u_xlat1.x * -2.0) + 3.0));
    (u_xlat1.x = (u_xlat1.x * u_xlat1.x));
    (u_xlat1.x = (((-u_xlat19.x) * u_xlat1.x) + 1.0));
    (u_xlat16_67 = ((-_HeatedThreshould) + 1.0));
    (u_xlat16_14.x = (u_xlat1.x + -1.0));
    (u_xlat16_32.x = (1.0 / (-_HeatedThreshould)));
    (u_xlat16_14.x = (u_xlat16_32.x * u_xlat16_14.x));
    (u_xlat16_14.x = clamp(u_xlat16_14.x, 0.0, 1.0));
    (u_xlat16_32.x = ((u_xlat16_14.x * -2.0) + 3.0));
    (u_xlat16_14.x = (u_xlat16_14.x * u_xlat16_14.x));
    (u_xlat16_14.x = (u_xlat16_14.x * u_xlat16_32.x));
    (u_xlat16_32.x = (((-_HeatedThreshould) * 2.0) + 1.0));
    (u_xlat16_32.x = ((-u_xlat16_67) + u_xlat16_32.x));
    (u_xlat16_67 = (u_xlat1.x + (-u_xlat16_67)));
    (u_xlat16_32.x = (1.0 / u_xlat16_32.x));
    (u_xlat16_67 = (u_xlat16_67 * u_xlat16_32.x));
    (u_xlat16_67 = clamp(u_xlat16_67, 0.0, 1.0));
    (u_xlat16_32.x = ((u_xlat16_67 * -2.0) + 3.0));
    (u_xlat16_67 = (u_xlat16_67 * u_xlat16_67));
    (u_xlat16_67 = (u_xlat16_67 * u_xlat16_32.x));
    (u_xlat16_32.xyz = ((-_HeatColor0.xyz) + _HeatColor1.xyz));
    (u_xlat16_14.xyz = ((u_xlat16_14.xxx * u_xlat16_32.xyz) + _HeatColor0.xyz));
    (u_xlat16_15.xyz = ((-u_xlat16_14.xyz) + _HeatColor2.xyz));
    (u_xlat16_14.xyz = ((vec3(u_xlat16_67) * u_xlat16_15.xyz) + u_xlat16_14.xyz));
    (u_xlat16_14.xyz = (u_xlat1.xxx * u_xlat16_14.xyz));
    (u_xlat16_14.xyz = ((u_xlat16_14.xyz * vec3(vec3(_HeatInst, _HeatInst, _HeatInst))) + u_xlat16_13.xyz));
//    todo:
    (SV_Target0.xyz = ((bool(u_xlatb54)) ? (u_xlat16_14.xyz) : (u_xlat16_13.xyz)));

    (u_xlat54 = dot(vec3(1.0, 1.0, 1.0), abs(vs_TEXCOORD3.xyz)));
    (u_xlat1.xy = (vs_TEXCOORD3.xy / vec2(u_xlat54)));
    (u_xlatb54 = (0.0 >= vs_TEXCOORD3.z));
    (u_xlat37.xy = ((-abs(u_xlat1.yx)) + vec2(1.0, 1.0)));
    (u_xlatb3.xy = greaterThanEqual(u_xlat1.xyxx, vec4(0.0, 0.0, 0.0, 0.0)).xy);
    (u_xlat3.x = ((u_xlatb3.x) ? (1.0) : (-1.0)));
    (u_xlat3.y = ((u_xlatb3.y) ? (1.0) : (-1.0)));
    (u_xlat37.xy = (u_xlat37.xy * u_xlat3.xy));
    (u_xlat1.xy = ((bool(u_xlatb54)) ? (u_xlat37.xy) : (u_xlat1.xy)));
    (u_xlat1.xy = ((u_xlat1.xy * vec2(0.5, 0.5)) + vec2(0.5, 0.5)));
    (u_xlat16_13.x = ((u_xlat0.z * 127.0) + 128.0));
    (u_xlat36 = trunc(u_xlat16_13.x));
    (u_xlat1.z = (u_xlat36 * 0.0039215689));
    (SV_Target0.w = u_xlat0.x);
    (u_xlat1.w = u_xlat0.y);
    (SV_Target1 = u_xlat1);

    SV_Target0 = vec4(debugColor,1);
    (SV_Target2 = hlslcc_FragCoord.z);
    return;
}
