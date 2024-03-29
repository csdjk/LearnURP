#version 450
uniform vec4 _MainLightPosition;
uniform vec4 _MainLightColor;
uniform vec2 _DisableCharacterLocalLight;
uniform vec4 _CharacterLocalMainLightPosition;
uniform vec4 _CharacterLocalMainLightColor;
uniform vec4 _CharacterLocalMainLightColor1;
uniform vec4 _CharacterLocalMainLightColor2;
uniform vec4 _CharacterLocalMainLightDark;
uniform vec4 _CharacterLocalMainLightDark1;
uniform vec4 _NewLocalLightDir;
uniform vec4 _NewLocalLightCharCenter;
uniform vec4 _NewLocalLightStrength;
uniform vec3 _WorldSpaceCameraPos;
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
uniform float _OneMinusGlobalMainIntensity;
uniform float _ES_Indoor;
uniform float _ES_TransitionRate;
uniform float _ES_LEVEL_ADJUST_ON;
uniform vec4 hlslcc_mtx4x4_ES_GlobalRotMatrix[4];
uniform float _ES_CharacterToonRampMode;
uniform float _ES_CharacterDisableLocalMainLight;
uniform vec4 _ES_AddColor;
uniform vec4 _ES_SPColor;
uniform float _ES_SPIntensity;
uniform vec4 _ES_RimShadowColor;
uniform float _ES_RimShadowIntensity;
uniform float _ES_CharacterShadowFactor;
uniform float _ES_HeightLerpTop;
uniform float _ES_HeightLerpBottom;
uniform vec4 _ES_HeightLerpTopColor;
uniform vec4 _ES_HeightLerpMiddleColor;
uniform vec4 _ES_HeightLerpBottomColor;
uniform vec4 _ES_LevelSkinLightColor;
uniform vec4 _ES_LevelSkinShadowColor;
uniform vec4 _ES_LevelHighLightColor;
uniform vec4 _ES_LevelShadowColor;
uniform float _ES_LevelShadow;
uniform float _ES_LevelMid;
uniform float _ES_LevelHighLight;
uniform float _ES_IndoorCharShadowAsCookie;
uniform float _ES_FogColor;
uniform float _ES_FogDensity;
uniform float _ES_FogNear;
uniform float _ES_FogFar;
uniform float _ES_HeightFogColor;
uniform float _ES_HeightFogBaseHeight;
uniform float _ES_HeightFogRange;
uniform float _ES_HeightFogDensity;
uniform float _ES_HeightFogFogNear;
uniform float _ES_HeightFogFogFar;
uniform float _ES_FogCharacterNearFactor;
uniform float _ES_HeightFogAddAjust;
uniform float _GlobalOneMinusAvatarIntensity;
uniform float _GlobalOneMinusAvatarIntensityEnable;
uniform float _OneMinusGlobalMainIntensityEnable;
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
  vec4 _SpecularColor0;
  float _IsMonster;
  float Xhlslcc_UnusedX_AlphaCutoff;
  float Xhlslcc_UnusedX_NormalScale;
  float Xhlslcc_UnusedX_ShadowThreshold;
  float Xhlslcc_UnusedX_ShadowFeather;
  float Xhlslcc_UnusedX_SpecularShininess;
  float _SpecularShininess0;
  float Xhlslcc_UnusedX_SpecularIntensity;
  float _SpecularIntensity0;
  float _SpecularRoughness0;
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
  float _EmissionThreshold;
  float _EmissionIntensity;
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
  float _FresnelColorStrength;
  vec4 _FresnelColor;
  vec4 _FresnelBSI;
  float Xhlslcc_UnusedX_EnableAlphaCutoff;
  float _mBloomIntensity0;
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
  int Xhlslcc_UnusedX_UseOverHeated;
  vec4 Xhlslcc_UnusedX_HeatDir;
  vec4 Xhlslcc_UnusedX_HeatColor0;
  vec4 Xhlslcc_UnusedX_HeatColor1;
  vec4 Xhlslcc_UnusedX_HeatColor2;
  float Xhlslcc_UnusedX_HeatedHeight;
  float Xhlslcc_UnusedX_HeatedThreshould;
  float Xhlslcc_UnusedX_HeatInst;
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
layout(location = 7) uniform sampler2D _ES_GradientAtlas;
in vec4 vs_TEXCOORD0;
in vec4 vs_COLOR0;
in vec3 vs_TEXCOORD2;
in vec3 vs_TEXCOORD3;
in vec4 vs_TEXCOORD4;
layout(location = 0) out vec4 SV_Target0;
vec3 u_xlat0;
vec4 u_xlat16_0;
bool u_xlatb0;
vec4 u_xlat1;
vec4 u_xlat16_1;
int u_xlati1;
uvec4 u_xlatu1;
bool u_xlatb1;
vec3 u_xlat16_2;
vec4 u_xlat3;
bvec4 u_xlatb3;
vec3 u_xlat4;
vec4 u_xlat16_4;
uvec4 u_xlatu4;
vec3 u_xlat5;
vec3 u_xlat16_5;
bvec3 u_xlatb5;
vec3 u_xlat6;
vec3 u_xlat16_6;
vec3 u_xlat16_7;
vec3 u_xlat16_8;
vec3 u_xlat16_9;
vec3 u_xlat16_10;
vec3 u_xlat16_11;
vec3 u_xlat16_12;
vec3 u_xlat16_13;
vec3 u_xlat16_14;
vec3 u_xlat15;
float u_xlat16;
float u_xlat17;
bool u_xlatb17;
vec3 u_xlat16_18;
vec3 u_xlat16_23;
vec3 u_xlat16_24;
float u_xlat32;
vec2 u_xlat33;
float u_xlat16_33;
int u_xlati33;
uint u_xlatu33;
bvec2 u_xlatb33;
vec2 u_xlat16_34;
bool u_xlatb35;
vec2 u_xlat16_39;
vec2 u_xlat16_40;
float u_xlat49;
bool u_xlatb49;
float u_xlat16_50;
bool u_xlatb51;
float u_xlat16_55;
float u_xlat16_56;
float u_xlat16_57;
void main(){
    vec3 debugColor = vec3(0.0, 0.0, 0.0);

  (u_xlat16_0 = texture(_MainTex, vs_TEXCOORD0.xy));
  (u_xlat0.xyz = (u_xlat16_0.xyz * _Color.xyz));

  (u_xlat16_1.xyz = texture(_LightMap, vs_TEXCOORD0.xy).yzw);

  (u_xlat16_2.x = (u_xlat16_1.z * 8.0));
  (u_xlat16_2.x = floor(u_xlat16_2.x));
  (u_xlat16_18.x = (u_xlat16_2.x * 8.0));
  (u_xlatb33.x = (u_xlat16_18.x >= (-u_xlat16_18.x)));

  (u_xlat16_18.xy = ((u_xlatb33.x) ? (vec2(8.0, 0.125)) : (vec2(-8.0, -0.125))));
  (u_xlat16_2.x = (u_xlat16_18.y * u_xlat16_2.x));
  (u_xlat16_2.x = fract(u_xlat16_2.x));
  (u_xlat16_2.x = (u_xlat16_2.x * u_xlat16_18.x));

  //Shadow Atten---------------------------------------------------
  (u_xlat3.xyz = (vs_TEXCOORD2.xyz + (-_CascadeShadowSplitSpheres0.xyz)));
  (u_xlat4.xyz = (vs_TEXCOORD2.xyz + (-_CascadeShadowSplitSpheres1.xyz)));
  (u_xlat5.xyz = (vs_TEXCOORD2.xyz + (-_CascadeShadowSplitSpheres2.xyz)));
  (u_xlat6.xyz = (vs_TEXCOORD2.xyz + (-_CascadeShadowSplitSpheres3.xyz)));
  (u_xlat3.x = dot(u_xlat3.xyz, u_xlat3.xyz));
  (u_xlat3.y = dot(u_xlat4.xyz, u_xlat4.xyz));
  (u_xlat3.z = dot(u_xlat5.xyz, u_xlat5.xyz));
  (u_xlat3.w = dot(u_xlat6.xyz, u_xlat6.xyz));
  (u_xlatb3 = lessThan(u_xlat3, _CascadeShadowSplitSphereRadii));
  (u_xlat16_4.x = ((u_xlatb3.x) ? (1.0) : (0.0)));
  (u_xlat16_4.y = ((u_xlatb3.y) ? (1.0) : (0.0)));
  (u_xlat16_4.z = ((u_xlatb3.z) ? (1.0) : (0.0)));
  (u_xlat16_4.w = ((u_xlatb3.w) ? (1.0) : (0.0)));
  (u_xlat16_18.x = ((u_xlatb3.x) ? (-1.0) : (-0.0)));
  (u_xlat16_18.y = ((u_xlatb3.y) ? (-1.0) : (-0.0)));
  (u_xlat16_18.z = ((u_xlatb3.z) ? (-1.0) : (-0.0)));
  (u_xlat16_18.xyz = (u_xlat16_18.xyz + u_xlat16_4.yzw));
  (u_xlat16_4.yzw = max(u_xlat16_18.xyz, vec3(0.0, 0.0, 0.0)));
  (u_xlat16_18.x = dot(u_xlat16_4, vec4(4.0, 3.0, 2.0, 1.0)));
  (u_xlat16_18.x = ((-u_xlat16_18.x) + 4.0));
  (u_xlatu33 = uint(u_xlat16_18.x));
  (u_xlati33 = int((int(u_xlatu33) << 2)));
  (u_xlat3.xyz = (vs_TEXCOORD2.yyy * hlslcc_mtx4x4_MainLightWorldToShadow[(u_xlati33 + 1)].xyz));
  (u_xlat3.xyz = ((hlslcc_mtx4x4_MainLightWorldToShadow[u_xlati33].xyz * vs_TEXCOORD2.xxx) + u_xlat3.xyz));
  (u_xlat3.xyz = ((hlslcc_mtx4x4_MainLightWorldToShadow[(u_xlati33 + 2)].xyz * vs_TEXCOORD2.zzz) + u_xlat3.xyz));
  (u_xlat3.xyz = (u_xlat3.xyz + hlslcc_mtx4x4_MainLightWorldToShadow[(u_xlati33 + 3)].xyz));
  vec3 txVec0 = vec3(u_xlat3.xy, u_xlat3.z);
  (u_xlat16_33 = textureLod(hlslcc_zcmp_MainLightShadowmapTexture, txVec0, 0.0));
  (u_xlat16_18.x = ((-u_xlat16_33) + 1.0));
  (u_xlat16_34.x = ((-_MainLightShadowParams.x) + 1.0));
  (u_xlat16_18.x = ((u_xlat16_18.x * _MainLightShadowParams.x) + u_xlat16_34.x));
  (u_xlat33.xy = (_MainLightShadowmapSize.xy * vec2(4.0, 4.0)));
  (u_xlatb51 = (0.0 >= u_xlat3.z));
  (u_xlatb35 = (u_xlat3.z >= 1.0));
  (u_xlatb35 = (u_xlatb35 || u_xlatb51));
  (u_xlatb33.xy = greaterThanEqual(u_xlat33.xyxy, u_xlat3.xyxy).xy);
  (u_xlatb33.x = (u_xlatb33.y || u_xlatb33.x));
  (u_xlat16_34.xy = (((-_MainLightShadowmapSize.xy) * vec2(4.0, 4.0)) + vec2(1.0, 1.0)));
  (u_xlatb3.xy = greaterThanEqual(u_xlat3.xyxx, u_xlat16_34.xyxx).xy);
  (u_xlatb49 = (u_xlatb3.y || u_xlatb3.x));
  (u_xlatb33.x = (u_xlatb49 || u_xlatb33.x));
  (u_xlatb33.x = (u_xlatb33.x || u_xlatb35));
  (u_xlat16_18.x = ((u_xlatb33.x) ? (1.0) : (u_xlat16_18.x)));
  (u_xlat33.x = (_ES_Indoor * _ES_IndoorCharShadowAsCookie));
  (u_xlat16_34.x = (u_xlat16_18.x + -1.0));
  (u_xlat16_34.x = ((u_xlat33.x * u_xlat16_34.x) + 1.0));
  (u_xlat16_50 = ((-u_xlat16_18.x) + 1.0));
  (u_xlat16_18.x = ((u_xlat33.x * u_xlat16_50) + u_xlat16_18.x));
  (u_xlat16_18.x = ((-u_xlat16_18.x) + 1.0));
  (u_xlat16_18.x = (((-u_xlat16_18.x) * 1.25) + 1.0));
  (u_xlat16_18.x = clamp(u_xlat16_18.x, 0.0, 1.0));
  (u_xlat16_50 = ((-u_xlat16_18.x) + 1.0));
  (u_xlat16_18.x = ((_ES_CharacterShadowFactor * u_xlat16_50) + u_xlat16_18.x));
  //Shadow Atten---------------------------------------------------

  (u_xlat16_50 = (_ES_CharacterDisableLocalMainLight + 1.0));
  (u_xlat16_50 = (u_xlat16_50 + (-abs(_DisableCharacterLocalLight.x))));
  (u_xlatb33.x = (0.5 < u_xlat16_50));
  (u_xlat3.xyz = ((u_xlatb33.x) ? (_MainLightPosition.xyz) : (_CharacterLocalMainLightPosition.xyz)));
  (u_xlatb49 = (0.5 < _IsMonster));
  (u_xlat16_7.xyz = ((bool(u_xlatb49)) ? (_ES_MonsterLightDir.xyz) : (u_xlat3.xyz)));
  (u_xlat16_8.xyz = ((-u_xlat16_7.xyz) + _CustomMainLightDir.xyz));
  (u_xlat16_7.xyz = ((_CustomMainLightDir.www * u_xlat16_8.xyz) + u_xlat16_7.xyz));
  (u_xlat16_7.xyz = ((bool(u_xlatb49)) ? (_ES_MonsterLightDir.xyz) : (u_xlat16_7.xyz)));
    //u_xlat16_7 = LightDir
  (u_xlat3.xyz = ((u_xlatb33.x) ? (_MainLightColor.xyz) : (_CharacterLocalMainLightColor.xyz)));
    //u_xlat3 = LightColor

//vs_TEXCOORD4=viewDirWS
  (u_xlat16_50 = dot(vs_TEXCOORD4.xyz, vs_TEXCOORD4.xyz));
  (u_xlat16_50 = inversesqrt(u_xlat16_50));
  (u_xlat16_8.xyz = (vec3(u_xlat16_50) * vs_TEXCOORD4.xyz));
//u_xlat16_8 = normalize(viewDirWS)
//-------------------------

//u_xlat16_9 = halfVector
  (u_xlat16_9.xyz = ((vs_TEXCOORD4.xyz * vec3(u_xlat16_50)) + u_xlat16_7.xyz));
  (u_xlat16_50 = dot(u_xlat16_9.xyz, u_xlat16_9.xyz));
  (u_xlat16_50 = inversesqrt(u_xlat16_50));
  (u_xlat16_9.xyz = (vec3(u_xlat16_50) * u_xlat16_9.xyz));
//-------------------------

//vs_TEXCOORD3 = normalWS
  (u_xlat16_50 = dot(vs_TEXCOORD3.xyz, vs_TEXCOORD3.xyz));
  (u_xlat16_50 = inversesqrt(u_xlat16_50));
  (u_xlat16_10.xyz = (vec3(u_xlat16_50) * vs_TEXCOORD3.xyz));
//  u_xlat16_10 = normalWS
//-------------------------

  (u_xlat16_50 = (((((gl_FrontFacing) ? (4294967295u) : (0u)) != 0u)) ? (1.0) : (-1.0)));
  (u_xlat16_10.xyz = (vec3(u_xlat16_50) * u_xlat16_10.xyz));

//u_xlat6 = normalVS
  (u_xlat5.xyz = (u_xlat16_10.yyy * hlslcc_mtx4x4unity_MatrixV[1].xyz));
  (u_xlat5.xyz = ((hlslcc_mtx4x4unity_MatrixV[0].xyz * u_xlat16_10.xxx) + u_xlat5.xyz));
  (u_xlat5.xyz = ((hlslcc_mtx4x4unity_MatrixV[2].xyz * u_xlat16_10.zzz) + u_xlat5.xyz));
  (u_xlat6.xyz = (u_xlat16_8.yyy * hlslcc_mtx4x4unity_MatrixV[1].xyz));
  (u_xlat6.xyz = ((hlslcc_mtx4x4unity_MatrixV[0].xyz * u_xlat16_8.xxx) + u_xlat6.xyz));
  (u_xlat6.xyz = ((hlslcc_mtx4x4unity_MatrixV[2].xyz * u_xlat16_8.zzz) + u_xlat6.xyz));
//-------------------------
//u_xlat16_50 = NdotL
  (u_xlat16_50 = dot(u_xlat16_10.xyz, u_xlat16_7.xyz));
//u_xlat16_7.x = NdotV
  (u_xlat16_7.x = dot(u_xlat16_10.xyz, u_xlat16_8.xyz));


  (u_xlat16_23.xyz = (u_xlat6.xyz + (-_RimShadowOffset.xyz)));
  (u_xlat16_8.x = dot(u_xlat16_23.xyz, u_xlat16_23.xyz));
  (u_xlat16_8.x = inversesqrt(u_xlat16_8.x));
  (u_xlat16_23.xyz = (u_xlat16_23.xyz * u_xlat16_8.xxx));
  (u_xlat16_23.x = dot(u_xlat5.xyz, u_xlat16_23.xyz));
  (u_xlat16_23.x = clamp(u_xlat16_23.x, 0.0, 1.0));
  (u_xlat16_39.x = (u_xlat16_1.x + u_xlat16_1.x));
  (u_xlat16_39.x = (u_xlat16_39.x * vs_COLOR0.x));
  (u_xlat16_50 = ((u_xlat16_50 * 0.5) + 0.5));
  (u_xlat16_50 = clamp(u_xlat16_50, 0.0, 1.0));
//  u_xlat16_50 =  halfLambert
  (u_xlat16_50 = dot(vec2(u_xlat16_50), u_xlat16_39.xx));

    //u_xlat33 = shadowAtten
  (u_xlatb33.x = (0.5 < _ES_CharacterDisableLocalMainLight));
  (u_xlat49 = ((-u_xlat16_18.x) + 1.0));
  (u_xlat49 = ((_CharacterLocalMainLightPosition.w * u_xlat49) + u_xlat16_18.x));
  (u_xlat33.x = ((u_xlatb33.x) ? (u_xlat16_18.x) : (u_xlat49)));
    //u_xlat54 = shadowAtten


  (u_xlat16_18.x = (u_xlat33.x * u_xlat16_50));
  (u_xlat16_18.x = min(u_xlat16_34.x, u_xlat16_18.x));
  (u_xlat16_50 = (u_xlat16_1.x * vs_COLOR0.x));
  (u_xlat16_39.x = max(u_xlat16_18.x, 0.001));
  (u_xlat16_39.x = ((u_xlat16_39.x * 0.85000002) + 0.15000001));


  (u_xlatb1 = (u_xlat33.x < 0.1));
  (u_xlat16_50 = min(u_xlat16_50, 0.80000001));
  (u_xlat16_50 = ((u_xlatb1) ? (u_xlat16_50) : (1.0)));
  (u_xlatb1 = (_ShadowRamp < u_xlat16_18.x));

    //todo: u_xlat16_14 ramp uv
  (u_xlat16_18.x = ((u_xlatb1) ? (0.99000001) : (u_xlat16_39.x)));
  (u_xlat16_8.x = (u_xlat16_50 * u_xlat16_18.x));

  (u_xlat16_39.x = ((u_xlat16_2.x * 2.0) + 1.0));
  (u_xlat16_8.y = (u_xlat16_39.x * 0.0625));
//-----------Ramp-----------------
  (u_xlat16_5.xyz = texture(_DiffuseRampMultiTex, u_xlat16_8.xy).xyz);
  (u_xlat16_6.xyz = texture(_DiffuseCoolRampMultiTex, u_xlat16_8.xy).xyz);

  (u_xlat16_39.x = (_ES_CharacterToonRampMode + (-_CharacterToonRampModeCompensation)));
  (u_xlat16_39.x = clamp(u_xlat16_39.x, 0.0, 1.0));
  (u_xlat16_8.xyz = ((-u_xlat16_5.xyz) + u_xlat16_6.xyz));
//    rampColor
  (u_xlat16_8.xyz = ((u_xlat16_39.xxx * u_xlat16_8.xyz) + u_xlat16_5.xyz));
//----------------------------

  (u_xlat16_18.x = ((u_xlat16_18.x * u_xlat16_50) + -0.80000001));
  (u_xlat16_18.x = (u_xlat16_18.x * 10.000004));
//  1-smoothstep(0.0, 1.0, u_xlat16_20.x)
  (u_xlat16_18.x = clamp(u_xlat16_18.x, 0.0, 1.0));
  (u_xlat16_50 = ((u_xlat16_18.x * -2.0) + 3.0));
  (u_xlat16_18.x = (u_xlat16_18.x * u_xlat16_18.x));
  (u_xlat1.x = (((-u_xlat16_50) * u_xlat16_18.x) + 1.0));


  (u_xlat1.x = (u_xlat1.x * _NewLocalLightStrength.z));
  (u_xlat16_18.x = roundEven(u_xlat16_2.x));
  (u_xlatb49 = (u_xlat16_18.x == 0.0));
  (u_xlat5.xyz = (_CharacterLocalMainLightDark1.xyz + vec3(-1.0, -1.0, -1.0)));
  (u_xlat5.xyz = ((u_xlat1.xxx * u_xlat5.xyz) + vec3(1.0, 1.0, 1.0)));

  (u_xlat5.xyz = (u_xlat5.xyz * u_xlat16_8.xyz));

  (u_xlat6.xyz = (_CharacterLocalMainLightDark.xyz + vec3(-1.0, -1.0, -1.0)));
  (u_xlat6.xyz = ((u_xlat1.xxx * u_xlat6.xyz) + vec3(1.0, 1.0, 1.0)));

  (u_xlat6.xyz = (u_xlat6.xyz * u_xlat16_8.xyz));

  (u_xlat16_8.xyz = ((bool(u_xlatb49)) ? (u_xlat5.xyz) : (u_xlat6.xyz)));

  (u_xlatb1 = (0.5 < _ES_LEVEL_ADJUST_ON));
//u_xlat16_18.x=diffuseMask
  (u_xlat16_18.x = dot(u_xlat16_8.xyz, vec3(1.0, 1.0, 1.0)));
  (u_xlatb51 = (2.9000001 < u_xlat16_18.x));
  (u_xlat16_18.x = ((u_xlatb49) ? (0.0) : (1.0)));

// levelHightLightColor = lerp(levelSkinLightColor, levelHightLightColor * 2, isSkin);
  (u_xlat16_11.xyz = (_ES_LevelSkinLightColor.www * _ES_LevelSkinLightColor.xyz));
  (u_xlat16_11.xyz = (u_xlat16_11.xyz + u_xlat16_11.xyz));
  (u_xlat16_12.xyz = (_ES_LevelHighLightColor.www * _ES_LevelHighLightColor.xyz));
  (u_xlat16_12.xyz = ((u_xlat16_12.xyz * vec3(2.0, 2.0, 2.0)) + (-u_xlat16_11.xyz)));
  (u_xlat16_11.xyz = ((u_xlat16_18.xxx * u_xlat16_12.xyz) + u_xlat16_11.xyz));

//levelShadowColor = lerp(levelSkinShadowColor, levelShadowColor * 2, isSkin);
  (u_xlat16_12.xyz = (_ES_LevelSkinShadowColor.www * _ES_LevelSkinShadowColor.xyz));
  (u_xlat16_12.xyz = (u_xlat16_12.xyz + u_xlat16_12.xyz));
  (u_xlat16_13.xyz = (_ES_LevelShadowColor.www * _ES_LevelShadowColor.xyz));
  (u_xlat16_13.xyz = ((u_xlat16_13.xyz * vec3(2.0, 2.0, 2.0)) + (-u_xlat16_12.xyz)));
  (u_xlat16_12.xyz = ((u_xlat16_18.xxx * u_xlat16_13.xyz) + u_xlat16_12.xyz));

//todo:rampDiffuse
  (u_xlat16_13.xyz = (u_xlat16_8.xyz + (-vec3(vec3(_ES_LevelMid, _ES_LevelMid, _ES_LevelMid)))));
  (u_xlat16_18.xz = ((-vec2(_ES_LevelMid, _ES_LevelShadow)) + vec2(_ES_LevelHighLight, _ES_LevelMid)));
  (u_xlat16_13.xyz = (u_xlat16_13.xyz / u_xlat16_18.xxx));
  (u_xlat16_13.xyz = ((u_xlat16_13.xyz * vec3(0.5, 0.5, 0.5)) + vec3(0.5, 0.5, 0.5)));
  (u_xlat16_13.xyz = clamp(u_xlat16_13.xyz, 0.0, 1.0));
  (u_xlat16_11.xyz = (u_xlat16_11.xyz * u_xlat16_13.xyz));

//todo:rampDiffuse2
  (u_xlat16_13.xyz = ((-u_xlat16_8.xyz) + vec3(vec3(_ES_LevelMid, _ES_LevelMid, _ES_LevelMid))));
  (u_xlat16_13.xyz = (u_xlat16_13.xyz / u_xlat16_18.zzz));
  (u_xlat16_13.xyz = (((-u_xlat16_13.xyz) * vec3(0.5, 0.5, 0.5)) + vec3(0.5, 0.5, 0.5)));
  (u_xlat16_13.xyz = clamp(u_xlat16_13.xyz, 0.0, 1.0));
  (u_xlat16_12.xyz = (u_xlat16_12.xyz * u_xlat16_13.xyz));


  (u_xlat16_11.xyz = ((bool(u_xlatb51)) ? (u_xlat16_11.xyz) : (u_xlat16_12.xyz)));
debugColor = u_xlat16_11.xyz;

  (u_xlat16_8.xyz = ((bool(u_xlatb1)) ? (u_xlat16_11.xyz) : (u_xlat16_8.xyz)));

  (u_xlatb1 = (0.5 < _ShadowBoost));

//u_xlat33.x = shadowAtten
  (u_xlat16_18.x = (u_xlat33.x * 6.6666665));
  (u_xlat16_18.x = clamp(u_xlat16_18.x, 0.0, 1.0));
  (u_xlat16_50 = ((u_xlat16_18.x * -2.0) + 3.0));
  (u_xlat16_18.x = (u_xlat16_18.x * u_xlat16_18.x));
  (u_xlat16_18.x = (u_xlat16_18.x * u_xlat16_50));
  (u_xlat16_50 = (_ShadowBoostVal + 1.0));
  (u_xlat16_39.x = ((-u_xlat16_50) + 1.0));
  (u_xlat16_18.x = ((u_xlat16_18.x * u_xlat16_39.x) + u_xlat16_50));
  (u_xlat16_11.xyz = (u_xlat16_18.xxx * u_xlat16_8.xyz));
  (u_xlat16_8.xyz = ((bool(u_xlatb1)) ? (u_xlat16_11.xyz) : (u_xlat16_8.xyz)));
  (u_xlat16_11.xyz = (u_xlat0.xyz * u_xlat16_8.xyz));

//vs_TEXCOORD2 = positionWS
  (u_xlat5.xyz = (vs_TEXCOORD2.xyz + (-_NewLocalLightCharCenter.xyz)));
  (u_xlat1.x = dot(u_xlat5.xyz, u_xlat5.xyz));
  (u_xlat1.x = inversesqrt(u_xlat1.x));
  (u_xlat5.xyz = (u_xlat1.xxx * u_xlat5.xyz));

  (u_xlat1.x = dot(u_xlat5.xyz, _NewLocalLightDir.xyz));
  (u_xlat49 = dot(u_xlat16_10.xyz, _NewLocalLightDir.xyz));
  (u_xlat16_18.x = (u_xlat49 + 0.5));
  (u_xlat16_18.x = (u_xlat16_18.x * 0.66666669));
  (u_xlat16_18.x = clamp(u_xlat16_18.x, 0.0, 1.0));
  (u_xlat16_50 = ((u_xlat16_18.x * -2.0) + 3.0));
  (u_xlat16_18.x = (u_xlat16_18.x * u_xlat16_18.x));
  (u_xlat16_18.x = (u_xlat16_18.x * u_xlat16_50));
  (u_xlat16_50 = ((u_xlat1.x * 0.5) + 0.5));
  (u_xlat1.x = ((-_CharacterLocalMainLightColor1.w) + 1.0));
  (u_xlat1.x = (u_xlat16_18.x * u_xlat1.x));
  (u_xlat1.x = ((_CharacterLocalMainLightColor1.w * u_xlat16_50) + u_xlat1.x));
  (u_xlat1.xw = (u_xlat1.xx * _NewLocalLightStrength.xy));
  (u_xlat1.x = (u_xlat16_34.x * u_xlat1.x));
  (u_xlatb5.xyz = lessThan(u_xlat16_11.xyzx, vec4(0.5, 0.5, 0.5, 0.0)).xyz);
  (u_xlat16_12.xyz = (u_xlat16_11.xyz + u_xlat16_11.xyz));
  (u_xlat16_12.xyz = (u_xlat16_12.xyz * _CharacterLocalMainLightColor1.xyz));
  (u_xlat16_13.xyz = (((-u_xlat16_8.xyz) * u_xlat0.xyz) + vec3(1.0, 1.0, 1.0)));
  (u_xlat16_13.xyz = (u_xlat16_13.xyz + u_xlat16_13.xyz));
  (u_xlat16_14.xyz = ((-_CharacterLocalMainLightColor1.xyz) + vec3(1.0, 1.0, 1.0)));
  (u_xlat16_13.xyz = (((-u_xlat16_13.xyz) * u_xlat16_14.xyz) + vec3(1.0, 1.0, 1.0)));
  {
    vec3 hlslcc_movcTemp = u_xlat16_12;
    (hlslcc_movcTemp.x = ((u_xlatb5.x) ? (u_xlat16_12.x) : (u_xlat16_13.x)));
    (hlslcc_movcTemp.y = ((u_xlatb5.y) ? (u_xlat16_12.y) : (u_xlat16_13.y)));
    (hlslcc_movcTemp.z = ((u_xlatb5.z) ? (u_xlat16_12.z) : (u_xlat16_13.z)));
    (u_xlat16_12 = hlslcc_movcTemp);
  }
  (u_xlat16_8.xyz = (((-u_xlat16_8.xyz) * u_xlat0.xyz) + u_xlat16_12.xyz));
  (u_xlat16_8.xyz = ((u_xlat1.xxx * u_xlat16_8.xyz) + u_xlat16_11.xyz));
  (u_xlat5.xyz = (u_xlat1.www * _CharacterLocalMainLightColor2.xyz));
  (u_xlat5.xyz = ((u_xlat5.xyz * u_xlat16_34.xxx) + u_xlat16_8.xyz));

  (u_xlati1 = ((-_TestMatIDLUTEnabled) + 1));
  (u_xlati1 = (u_xlati1 * _UseMaterialValuesLUT));
  if ((u_xlati1 != 0))
  {
    (u_xlatu4.x = uint(int(u_xlat16_2.x)));
    (u_xlatu4.y = 5u);
    (u_xlatu4.z = 0u);
    (u_xlatu4.w = 6u);
    (u_xlat6.xyz = texelFetch(_MaterialValuesPackLUT, ivec2(u_xlatu4.xy), int(u_xlatu4.z)).xyz);
    (u_xlat15.xy = texelFetch(_MaterialValuesPackLUT, ivec2(u_xlatu4.xw), int(u_xlatu4.z)).xy);
    (u_xlat16_18.xyz = u_xlat6.xyz);
    (u_xlat16_39.xy = u_xlat15.xy);
  }
  else
  {
    (u_xlat16_18.xyz = _RimShadowColor0.xyz);
    (u_xlat16_39.xy = vec2(_RimShadowWidth0, _RimShadowFeather0));
  }
  (u_xlat16_8.xyz = (_ES_RimShadowColor.www * _ES_RimShadowColor.xyz));
  (u_xlat16_18.xyz = (u_xlat16_18.xyz * u_xlat16_8.xyz));

//rimLight
  (u_xlat16_23.x = ((-u_xlat16_23.x) + 1.0));
  (u_xlat16_23.x = max(u_xlat16_23.x, 0.001));
  (u_xlat16_23.x = log2(u_xlat16_23.x));
  (u_xlat16_23.x = (u_xlat16_23.x * _RimShadowCt));
  (u_xlat16_23.x = exp2(u_xlat16_23.x));
  (u_xlat16_23.x = (u_xlat16_23.x * u_xlat16_39.x));
  (u_xlat16_23.x = clamp(u_xlat16_23.x, 0.0, 1.0));
  (u_xlat16_39.x = ((-u_xlat16_39.y) + 1.0));
  (u_xlat16_23.x = ((-u_xlat16_39.y) + u_xlat16_23.x));
  (u_xlat16_39.x = (1.0 / u_xlat16_39.x));
  (u_xlat16_23.x = (u_xlat16_39.x * u_xlat16_23.x));
  (u_xlat16_23.x = clamp(u_xlat16_23.x, 0.0, 1.0));
  (u_xlat16_39.x = ((u_xlat16_23.x * -2.0) + 3.0));
  (u_xlat16_23.x = (u_xlat16_23.x * u_xlat16_23.x));
  (u_xlat16_23.x = (u_xlat16_23.x * u_xlat16_39.x));
  (u_xlat16_23.x = (u_xlat16_23.x * _RimShadowIntensity));
  (u_xlat16_23.x = (u_xlat16_23.x * _ES_RimShadowIntensity));
  (u_xlat16_23.x = (u_xlat16_23.x * 0.25));
  (u_xlat16_18.xyz = ((u_xlat16_18.xyz * vec3(2.0, 2.0, 2.0)) + vec3(-1.0, -1.0, -1.0)));
  (u_xlat16_18.xyz = ((u_xlat16_23.xxx * u_xlat16_18.xyz) + vec3(1.0, 1.0, 1.0)));
//todo:

  if ((u_xlati1 != 0))
  {
    (u_xlatu4.x = uint(int(u_xlat16_2.x)));
    (u_xlatu4.y = 1u);
    (u_xlatu4.z = 0u);
    (u_xlatu4.w = 0u);
    (u_xlat6.xyz = texelFetch(_MaterialValuesPackLUT, ivec2(u_xlatu4.xw), int(u_xlatu4.w)).xyz);
    (u_xlat15.xyz = texelFetch(_MaterialValuesPackLUT, ivec2(u_xlatu4.xy), int(u_xlatu4.w)).xyz);
    (u_xlat16_23.xyz = u_xlat6.xyz);
    (u_xlat16_8.xyz = u_xlat15.yzx);
  }
  else
  {
    (u_xlat16_23.xyz = _SpecularColor0.xyz);
    (u_xlat16_8.xy = vec2(_SpecularRoughness0, _SpecularIntensity0));
    (u_xlat16_8.z = _SpecularShininess0);
  }

  (u_xlat16_11.xyz = (_ES_SPColor.xyz + vec3(-1.0, -1.0, -1.0)));
  (u_xlat16_11.xyz = ((_ES_SPColor.www * u_xlat16_11.xyz) + vec3(1.0, 1.0, 1.0)));
  (u_xlat16_11.xyz = (u_xlat16_11.xyz * vec3(_ES_SPIntensity)));
  (u_xlat16_23.xyz = (u_xlat16_23.xyz * u_xlat16_11.xyz));

//u_xlat16_10 = normalWS,u_xlat16_9 = H
//u_xlat16_56 = NdotH
  (u_xlat16_56 = dot(u_xlat16_10.xyz, u_xlat16_9.xyz));
//Specular pow(x,u_xlat16_8.z)
  (u_xlat16_56 = max(u_xlat16_56, 0.0099999998));
  (u_xlat16_56 = log2(u_xlat16_56));
  (u_xlat16_40.x = (u_xlat16_56 * u_xlat16_8.z));
  (u_xlat16_40.x = exp2(u_xlat16_40.x));
//----------------------------------------

  (u_xlat16_8.x = max(u_xlat16_8.x, 0.001));
  (u_xlat16_56 = ((-u_xlat16_1.y) + 1.0));
  (u_xlat16_9.x = ((-u_xlat16_8.x) + u_xlat16_56));
  (u_xlat16_8.x = (u_xlat16_8.x + u_xlat16_56));
//    specular = smoothstep(u_xlat16_9, u_xlat16_8, u_xlat33.x * u_xlat16_40.x);
  (u_xlat16_8.x = ((-u_xlat16_9.x) + u_xlat16_8.x));
  (u_xlat16_40.x = ((u_xlat33.x * u_xlat16_40.x) + (-u_xlat16_9.x)));
  (u_xlat16_8.x = (1.0 / u_xlat16_8.x));
  (u_xlat16_8.x = (u_xlat16_8.x * u_xlat16_40.x));
  (u_xlat16_8.x = clamp(u_xlat16_8.x, 0.0, 1.0));
  (u_xlat16_40.x = ((u_xlat16_8.x * -2.0) + 3.0));
  (u_xlat16_8.x = (u_xlat16_8.x * u_xlat16_8.x));
  (u_xlat16_8.x = (u_xlat16_8.x * u_xlat16_40.x));
//----------------------------------------
//u_xlat16_23 = SpecularColor

  (u_xlat16_23.xyz = (u_xlat16_23.xyz * u_xlat16_8.xxx));
  (u_xlat16_23.xyz = (u_xlat16_8.yyy * u_xlat16_23.xyz));
  //u_xlat0 = albedo
  (u_xlat16_23.xyz = (u_xlat0.xyz * u_xlat16_23.xyz));
    //Emission-----------
  (u_xlatb17 = (_EmissionThreshold < u_xlat16_0.w));
  (u_xlat16_8.x = (u_xlat16_0.w + (-_EmissionThreshold)));
  (u_xlat16_24.x = ((-_EmissionThreshold) + 1.0));
  (u_xlat16_24.x = max(u_xlat16_24.x, 0.001));
  (u_xlat33.x = (u_xlat16_8.x / u_xlat16_24.x));
  (u_xlat33.x = clamp(u_xlat33.x, 0.0, 1.0));
  (u_xlat16_8.x = ((u_xlatb17) ? (u_xlat33.x) : (0.0)));
  //lerp()
  (u_xlat16_24.xyz = ((u_xlat0.xyz * vec3(vec3(_EmissionIntensity, _EmissionIntensity, _EmissionIntensity))) + (-u_xlat5.xyz)));
  (u_xlat16_8.xyz = ((u_xlat16_8.xxx * u_xlat16_24.xyz) + u_xlat5.xyz));
  //---------------------

  //Fresnel------------------
  //u_xlat16_7 = NdotV
  (u_xlat16_7.x = ((-abs(u_xlat16_7.x)) + 1.0));
  (u_xlat16_7.x = (u_xlat16_7.x + (-_FresnelBSI.x)));
  (u_xlat16_56 = (1.0 / _FresnelBSI.y));
  (u_xlat16_7.x = (u_xlat16_7.x * u_xlat16_56));
  (u_xlat16_7.x = clamp(u_xlat16_7.x, 0.0, 1.0));
  (u_xlat16_9.xyz = (u_xlat16_7.xxx * _FresnelColor.xyz));
  (u_xlat16_9.xyz = (u_xlat16_9.xyz * vec3(vec3(_FresnelColorStrength, _FresnelColorStrength, _FresnelColorStrength))));
  (u_xlat16_9.xyz = max(u_xlat16_9.xyz, vec3(0.0, 0.0, 0.0)));

   //------------------
//u_xlat16_8 = Emission, u_xlat16_23 = Specular, u_xlat16_18 = rimColor
  (u_xlat16_18.xyz = ((u_xlat16_8.xyz * u_xlat16_18.xyz) + u_xlat16_23.xyz));
//u_xlat3 = LightColor, u_xlat16_9 = Fresnel
  (u_xlat16_18.xyz = ((u_xlat16_18.xyz * u_xlat3.xyz) + u_xlat16_9.xyz));
// color = ((Emission*rimShadow)+Specular) * LightColor + Fresnel

  (u_xlat16_18.xyz = ((_ES_AddColor.xyz * u_xlat0.xyz) + u_xlat16_18.xyz));
  (u_xlat0.x = (vs_TEXCOORD2.y + (-_CharaWorldSpaceOffset.y)));
  (u_xlat16_7.x = max(_ES_HeightLerpBottom, 0.001));
  (u_xlat16 = (1.0 / u_xlat16_7.x));
  (u_xlat16 = (u_xlat16 * u_xlat0.x));
  (u_xlat16 = clamp(u_xlat16, 0.0, 1.0));
  (u_xlat32 = ((u_xlat16 * -2.0) + 3.0));
  (u_xlat16 = (u_xlat16 * u_xlat16));
  (u_xlat16 = (((-u_xlat32) * u_xlat16) + 1.0));
  (u_xlat0.x = (u_xlat0.x + (-_ES_HeightLerpTop)));
  (u_xlat0.x = (u_xlat0.x + u_xlat0.x));
  (u_xlat0.x = clamp(u_xlat0.x, 0.0, 1.0));
  (u_xlat32 = ((u_xlat0.x * -2.0) + 3.0));
  (u_xlat0.x = (u_xlat0.x * u_xlat0.x));
  (u_xlat17 = (u_xlat0.x * u_xlat32));
  (u_xlat16_7.x = ((-u_xlat16) + 1.0));
  (u_xlat16_7.x = (((-u_xlat32) * u_xlat0.x) + u_xlat16_7.x));
  (u_xlat16_7.x = clamp(u_xlat16_7.x, 0.0, 1.0));
  (u_xlat16_23.xyz = (vec3(u_xlat16) * _ES_HeightLerpBottomColor.xyz));
  (u_xlat16_8.xyz = (u_xlat16_7.xxx * _ES_HeightLerpMiddleColor.xyz));
  (u_xlat16_8.xyz = (u_xlat16_8.xyz * _ES_HeightLerpMiddleColor.www));
  (u_xlat16_7.xyz = ((u_xlat16_23.xyz * _ES_HeightLerpBottomColor.www) + u_xlat16_8.xyz));
  (u_xlat16_8.xyz = (vec3(u_xlat17) * _ES_HeightLerpTopColor.xyz));
  (u_xlat16_7.xyz = ((u_xlat16_8.xyz * _ES_HeightLerpTopColor.www) + u_xlat16_7.xyz));
  (u_xlat16_7.xyz = clamp(u_xlat16_7.xyz, 0.0, 1.0));
  (u_xlat16_18.xyz = (u_xlat16_18.xyz * u_xlat16_7.xyz));
  (u_xlat16_18.xyz = (u_xlat16_18.xyz + u_xlat16_18.xyz));
  if ((u_xlati1 != 0))
  {
    (u_xlatu1.x = uint(int(u_xlat16_2.x)));
    (u_xlatu1.y = 6u);
    (u_xlatu1.z = 0u);
    (u_xlatu1.w = 7u);
    (u_xlat0.x = texelFetch(_MaterialValuesPackLUT, ivec2(u_xlatu1.xy), int(u_xlatu1.z)).z);
    (u_xlat1.xyz = texelFetch(_MaterialValuesPackLUT, ivec2(u_xlatu1.xw), int(u_xlatu1.z)).xyz);
    (u_xlat16_7.xyz = u_xlat1.xyz);
    (u_xlat16_2.x = u_xlat0.x);
  }
  else
  {
    (u_xlat16_7.x = 1.0);
    (u_xlat16_7.y = 1.0);
    (u_xlat16_7.z = 1.0);
    (u_xlat16_2.x = _mBloomIntensity0);
  }
  // color = color * (bloomIntensity * bloomColor + 1);
  (u_xlat16_7.xyz = ((u_xlat16_2.xxx * u_xlat16_7.xyz) + vec3(1.0, 1.0, 1.0)));
  (u_xlat16_2.xyz = (u_xlat16_18.xyz * u_xlat16_7.xyz));

// debugColor = u_xlat16_2.xyz;
//
  (u_xlat16_50 = (((-_GlobalOneMinusAvatarIntensityEnable) * _GlobalOneMinusAvatarIntensity) + 1.0));
  (u_xlat16_2.xyz = (vec3(u_xlat16_50) * u_xlat16_2.xyz));
  (u_xlat16_50 = (((-_OneMinusGlobalMainIntensityEnable) * _OneMinusGlobalMainIntensity) + 1.0));
  (u_xlat16_7.xyz = (vec3(u_xlat16_50) * u_xlat16_2.xyz));


  //fog
  (u_xlat0.xyz = (vs_TEXCOORD2.xyz + (-_WorldSpaceCameraPos.xyz)));
  (u_xlat0.x = dot(u_xlat0.xyz, u_xlat0.xyz));
  (u_xlat0.x = sqrt(u_xlat0.x));
  (u_xlat16_1.xz = vec2(_ES_FogNear, _ES_FogDensity));
  (u_xlat16_1.yw = vec2(_ES_HeightFogFogNear, _ES_HeightFogDensity));
  (u_xlat16_8.x = _ES_FogFar);
  (u_xlat16_8.y = _ES_HeightFogFogFar);
  (u_xlat16_40.xy = ((-u_xlat16_1.xy) + u_xlat16_8.xy));
  (u_xlat16_40.xy = ((vec2(vec2(_ES_FogCharacterNearFactor, _ES_FogCharacterNearFactor)) * u_xlat16_40.xy) + u_xlat16_1.xy));
  (u_xlat16_9.xy = (u_xlat0.xx + (-u_xlat16_40.xy)));
  (u_xlat16_8.xy = ((-u_xlat16_40.xy) + u_xlat16_8.xy));
  (u_xlat16_8.xy = (u_xlat16_9.xy / u_xlat16_8.xy));
  (u_xlat16_8.xy = clamp(u_xlat16_8.xy, 0.0, 1.0));
  (u_xlat16_8.xy = (u_xlat16_1.zw * u_xlat16_8.xy));
  (u_xlat16_40.xy = (((-u_xlat16_8.xy) * u_xlat16_8.xy) + u_xlat16_8.xy));
  (u_xlat16_1.xy = ((u_xlat16_8.xy * u_xlat16_40.xy) + u_xlat16_8.xy));
  (u_xlat16_55 = dot(vs_TEXCOORD2.xyz, hlslcc_mtx4x4_ES_GlobalRotMatrix[3].xyz));
  (u_xlat16_55 = (u_xlat16_55 + (-hlslcc_mtx4x4_ES_GlobalRotMatrix[3].w)));
  (u_xlatb0 = (0.0 < _ES_HeightFogRange));
  (u_xlat16_8.x = (u_xlat16_55 + (-_ES_HeightFogBaseHeight)));
  (u_xlat16_55 = ((-u_xlat16_55) + _ES_HeightFogBaseHeight));
  (u_xlat16_55 = ((u_xlatb0) ? (u_xlat16_8.x) : (u_xlat16_55)));
  (u_xlat16_8.x = (abs(_ES_HeightFogRange) + 1.0));
  (u_xlat16_55 = max(u_xlat16_55, 0.0));
  (u_xlat16_55 = (u_xlat16_55 / u_xlat16_8.x));
  (u_xlat16_55 = min(u_xlat16_55, 1.0));
  (u_xlat16_55 = ((-u_xlat16_55) + 1.0));
  (u_xlat16_8.x = ((u_xlat16_55 * _ES_HeightFogDensity) + -1.0));
  (u_xlat16_8.x = clamp(u_xlat16_8.x, 0.0, 1.0));
  (u_xlat16_1.z = ((_ES_TransitionRate * 0.125) + _ES_FogColor));
  (u_xlat16_0.xyz = textureLod(_ES_GradientAtlas, u_xlat16_1.xz, 0.0).xyz);
  (u_xlat16_24.x = (_ES_FogDensity + -1.0));
  (u_xlat16_24.x = clamp(u_xlat16_24.x, 0.0, 1.0));
  (u_xlat16_40.xy = u_xlat16_1.xy);
  (u_xlat16_40.xy = clamp(u_xlat16_40.xy, 0.0, 1.0));
  (u_xlat16_9.xyz = ((u_xlat16_0.xyz * u_xlat16_40.xxx) + (-u_xlat16_7.xyz)));
  (u_xlat16_9.xyz = ((u_xlat16_40.xxx * u_xlat16_9.xyz) + u_xlat16_7.xyz));
  (u_xlat16_10.xyz = ((u_xlat16_0.xyz * u_xlat16_40.xxx) + u_xlat16_9.xyz));
  (u_xlat16_9.xyz = ((u_xlat16_10.xyz * u_xlat16_24.xxx) + u_xlat16_9.xyz));
  (u_xlat16_1.w = ((_ES_TransitionRate * 0.125) + _ES_HeightFogColor));
  (u_xlat16_0.xyz = textureLod(_ES_GradientAtlas, u_xlat16_1.yw, 0.0).xyz);
  (u_xlat16_10.xyz = (vec3(u_xlat16_55) * u_xlat16_0.xyz));
  (u_xlat16_11.xyz = ((u_xlat16_10.xyz * u_xlat16_40.yyy) + (-u_xlat16_9.xyz)));
  (u_xlat16_11.xyz = ((u_xlat16_40.yyy * u_xlat16_11.xyz) + u_xlat16_9.xyz));
  (u_xlat16_10.xyz = ((u_xlat16_10.xyz * u_xlat16_40.yyy) + u_xlat16_11.xyz));
  (u_xlat16_8.xyz = ((u_xlat16_10.xyz * u_xlat16_8.xxx) + u_xlat16_11.xyz));
  (u_xlat16_57 = max(u_xlat16_0.z, u_xlat16_0.y));
  (u_xlat16_57 = max(u_xlat16_0.x, u_xlat16_57));
  (u_xlat16_10.xyz = (vec3(u_xlat16_55) * u_xlat16_8.xyz));
  (u_xlat16_10.xyz = ((u_xlat16_10.xyz * u_xlat16_40.yyy) + u_xlat16_9.xyz));
  (u_xlat16_8.xyz = ((-u_xlat16_9.xyz) + u_xlat16_8.xyz));
  (u_xlat16_8.xyz = ((vec3(u_xlat16_55) * u_xlat16_8.xyz) + u_xlat16_9.xyz));
  (u_xlat16_55 = ((_ES_HeightFogAddAjust * (-u_xlat16_57)) + u_xlat16_57));
  (u_xlat16_9.xyz = ((-u_xlat16_8.xyz) + u_xlat16_10.xyz));
  (u_xlat16_8.xyz = ((vec3(u_xlat16_55) * u_xlat16_9.xyz) + u_xlat16_8.xyz));
  (u_xlat16_2.xyz = (((-u_xlat16_2.xyz) * vec3(u_xlat16_50)) + u_xlat16_8.xyz));

// debugColor = u_xlat16_7.xyz;

  (SV_Target0.xyz = ((vec3(u_xlat16_50) * u_xlat16_2.xyz) + u_xlat16_7.xyz));

SV_Target0.xyz=debugColor;
SV_Target0.w = 1;

  (SV_Target0.w = u_xlat16_0.w);
  return ;
}
