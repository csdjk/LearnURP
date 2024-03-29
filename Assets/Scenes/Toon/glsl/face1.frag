#version 450
uniform vec4 _MainLightColor;
uniform vec2 _DisableCharacterLocalLight;
uniform vec4 _CharacterLocalMainLightPosition;
uniform vec4 _CharacterLocalMainLightColor;
uniform vec4 _CharacterLocalMainLightColor1;
uniform vec4 _CharacterLocalMainLightColor2;
uniform vec4 _CharacterLocalMainLightDark1;
uniform vec4 _NewLocalLightDir;
uniform vec4 _NewLocalLightCharCenter;
uniform vec4 _NewLocalLightStrength;
uniform vec4 _Time;
uniform vec3 _WorldSpaceCameraPos;
uniform vec4 hlslcc_mtx4x4unity_MatrixV[4];
uniform vec4 hlslcc_mtx4x4_MainLightWorldToShadow[20];
uniform vec4 _CascadeShadowSplitSpheres0;
uniform vec4 _CascadeShadowSplitSpheres1;
uniform vec4 _CascadeShadowSplitSpheres2;
uniform vec4 _CascadeShadowSplitSpheres3;
uniform vec4 _CascadeShadowSplitSphereRadii;
uniform vec4 _MainLightShadowParams;
uniform vec4 _MainLightShadowmapSize;
uniform float _OneMinusGlobalMainIntensity;
uniform float _ES_TransitionRate;
uniform float _ES_LEVEL_ADJUST_ON;
uniform vec4 hlslcc_mtx4x4_ES_GlobalRotMatrix[4];
uniform float _ES_CharacterDisableLocalMainLight;

uniform vec4 _ES_AddColor;
uniform float _ES_CharacterShadowFactor;
uniform float _ES_HeightLerpTop;
uniform float _ES_HeightLerpBottom;
uniform vec4 _ES_HeightLerpTopColor;
uniform vec4 _ES_HeightLerpMiddleColor;
uniform vec4 _ES_HeightLerpBottomColor;
uniform vec4 _ES_LevelSkinLightColor;
uniform vec4 _ES_LevelSkinShadowColor;
uniform float _ES_LevelEyeShadowIntensity;
uniform float _ES_LevelShadow;
uniform float _ES_LevelMid;
uniform float _ES_LevelHighLight;

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
  vec3 _RimShadowColor;
  float _RimShadowCt;
  float _RimShadowIntensity;
  float _RimShadowWidth;
  float _RimShadowFeather;
  vec4 Xhlslcc_UnusedX_RimShadowColor0;
  float Xhlslcc_UnusedX_RimShadowWidth0;
  float Xhlslcc_UnusedX_RimShadowFeather0;
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
  vec4 _EyeShadowColor;
  vec4 Xhlslcc_UnusedX_BrightDiffuseColor;
  vec4 Xhlslcc_UnusedX_ShadowDiffuseColor;
  vec4 Xhlslcc_UnusedX_SpecularColor0;
  float _IsMonster;
  float Xhlslcc_UnusedX_AlphaCutoff;
  float Xhlslcc_UnusedX_NormalScale;
  float Xhlslcc_UnusedX_ShadowThreshold;
  float _ShadowFeather;
  float Xhlslcc_UnusedX_SpecularShininess;
  float Xhlslcc_UnusedX_SpecularShininess0;
  float Xhlslcc_UnusedX_SpecularIntensity;
  float Xhlslcc_UnusedX_SpecularIntensity0;
  float Xhlslcc_UnusedX_SpecularRoughness0;
  float Xhlslcc_UnusedX_SpecularThreshold;
  float Xhlslcc_UnusedX_SpecularShadowOffset;
  float Xhlslcc_UnusedX_SpecularShadowIntensity;
  float _ExMapThreshold;
  float _ExSpecularIntensity;
  float _ExCheekIntensity;
  float _ExShyIntensity;
  float _ExShadowIntensity;
  vec4 _ExCheekColor;
  vec4 _ExShyColor;
  vec4 _ExShadowColor;
  vec4 _ExEyeColor;
  float Xhlslcc_UnusedX_HairBlendWeight;
  float Xhlslcc_UnusedX_HairBlendOffset;
  float _EyeEffectProcs;
  float Xhlslcc_UnusedX_EyeEffectPower;
  vec4 _EyeEffectColor;
  float Xhlslcc_UnusedX_EyeEffectDarken;
  float _EmissionThreshold;
  float _EmissionIntensity;
  float _NoseLinePower;
  vec4 _NoseLineColor;
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
  float _mBloomIntensity;
  vec4 Xhlslcc_UnusedX_mBloomColor0;
  float Xhlslcc_UnusedX_CustomsizedFace;
  vec4 Xhlslcc_UnusedX_InstaceProbeUV;
};
layout(std140, binding = 2) uniform UnityPerMaterialCharacterOnly{
  vec4 Xhlslcc_UnusedX_AddColor;
  vec4 Xhlslcc_UnusedX_EnvColor;
  vec4 Xhlslcc_UnusedX_EmissionTintColor;
  float _BackShadowRange;
  float Xhlslcc_UnusedX_ShadowBoost;
  float Xhlslcc_UnusedX_ShadowRamp;
  float Xhlslcc_UnusedX_ShadowBoostVal;
  vec4 _ShadowColor;
  vec4 _EyeBaseShadowColor;
  float _EyeShadowAngleMin;
  float _EyeShadowMaxAngle;
  float _UseUVChannel2;
  float _UseSpecialEye;
  vec4 _SpecialEyeShapeTexture_ST;
  vec4 _EyeCenter;
  vec4 _EyeSPColor1;
  vec4 _EyeSPColor2;
  float _SpecialEyeIntensity;
  vec4 _LipLinefixColor;
  float _LipLineFixThrd;
  float _LipLineFixStart;
  float _LipLineFixMax;
  float _LipLineFixScale;
  float _LipLineFixSC;
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
  float Xhlslcc_UnusedX_CharacterToonRampModeCompensation;
  vec4 Xhlslcc_UnusedX_CenterOffset;
  vec4 Xhlslcc_UnusedX_Direction;
  float Xhlslcc_UnusedX_RefIntensity;
  float Xhlslcc_UnusedX_AlphaTestThreshold;
};
layout(location = 0) uniform sampler2D _MainTex;
layout(location = 1) uniform sampler2D _SpecialEyeShapeTexture;
layout(location = 2) uniform sampler2D _FaceMap;
layout(location = 3) uniform sampler2D _FaceExpression;
layout(location = 4) uniform sampler2D _MainLightShadowmapTexture;
layout(location = 5) uniform sampler2DShadow hlslcc_zcmp_MainLightShadowmapTexture;
layout(location = 6) uniform sampler2D _ES_GradientAtlas;
in vec4 vs_TEXCOORD0;
in vec4 vs_TEXCOORD1;
in vec4 vs_TEXCOORD3;
in vec4 vs_TEXCOORD4;
in vec3 vs_TEXCOORD5;
in vec3 vs_TEXCOORD6;
layout(location = 0) out vec4 SV_Target0;
layout(location = 1) out vec4 SV_Target1;
layout(location = 2) out float SV_Target2;
vec4 u_xlat16_0;
vec4 u_xlat1;
vec4 u_xlat16_1;
int u_xlati1;
uint u_xlatu1;
bvec4 u_xlatb1;
vec4 u_xlat2;
vec4 u_xlat16_2;
vec3 u_xlat3;
vec3 u_xlat16_3;
bvec3 u_xlatb3;
vec4 u_xlat4;
vec4 u_xlat16_4;
vec4 u_xlat5;
vec3 u_xlat16_5;
vec4 u_xlat6;
vec4 u_xlat16_6;
vec4 u_xlat7;
vec4 u_xlat16_7;
vec4 u_xlat8;
vec4 u_xlat16_8;
vec3 u_xlat9;
bvec2 u_xlatb9;
vec4 u_xlat10;
vec3 u_xlat11;
vec3 u_xlat16_12;
vec3 u_xlat13;
vec3 u_xlat16_14;
vec3 u_xlat16_15;
vec3 u_xlat16_16;
vec3 u_xlat16_17;
vec3 u_xlat16_18;
vec3 u_xlat16_19;
vec3 u_xlat16_20;
vec3 u_xlat16_21;
vec3 u_xlat16_22;
vec3 u_xlat16_23;
vec2 u_xlat16_24;
vec3 u_xlat26;
vec2 u_xlat16_26;
int u_xlati26;
bvec3 u_xlatb26;
float u_xlat28;
float u_xlat16_28;
float u_xlat16_35;
vec3 u_xlat16_37;
vec3 u_xlat16_39;
vec3 u_xlat16_40;
vec3 u_xlat16_42;
float u_xlat50;
vec2 u_xlat51;
bool u_xlatb51;
vec2 u_xlat53;
vec2 u_xlat16_55;
vec2 u_xlat16_56;
float u_xlat16_64;
vec2 u_xlat16_65;
float u_xlat75;
float u_xlat16_75;
bool u_xlatb75;
float u_xlat76;
bool u_xlatb76;
bool u_xlatb78;
float u_xlat84;
float u_xlat16_87;
float u_xlat16_89;
float u_xlat16_91;
void main(){
    vec3 debugColor = vec3(0.0, 0.0, 0.0);

  vec4 hlslcc_FragCoord = vec4(gl_FragCoord.xyz, (1.0 / gl_FragCoord.w));
  (u_xlat16_0 = texture(_MainTex, vs_TEXCOORD0.xy));
  (u_xlat1.xyz = (vs_TEXCOORD3.xyz + (-_CascadeShadowSplitSpheres0.xyz)));
  (u_xlat2.xyz = (vs_TEXCOORD3.xyz + (-_CascadeShadowSplitSpheres1.xyz)));
  (u_xlat3.xyz = (vs_TEXCOORD3.xyz + (-_CascadeShadowSplitSpheres2.xyz)));
  (u_xlat4.xyz = (vs_TEXCOORD3.xyz + (-_CascadeShadowSplitSpheres3.xyz)));
  (u_xlat1.x = dot(u_xlat1.xyz, u_xlat1.xyz));
  (u_xlat1.y = dot(u_xlat2.xyz, u_xlat2.xyz));
  (u_xlat1.z = dot(u_xlat3.xyz, u_xlat3.xyz));
  (u_xlat1.w = dot(u_xlat4.xyz, u_xlat4.xyz));
  (u_xlatb1 = lessThan(u_xlat1, _CascadeShadowSplitSphereRadii));
  (u_xlat16_2.x = ((u_xlatb1.x) ? (1.0) : (0.0)));
  (u_xlat16_2.y = ((u_xlatb1.y) ? (1.0) : (0.0)));
  (u_xlat16_2.z = ((u_xlatb1.z) ? (1.0) : (0.0)));
  (u_xlat16_2.w = ((u_xlatb1.w) ? (1.0) : (0.0)));
  (u_xlat16_5.x = ((u_xlatb1.x) ? (-1.0) : (-0.0)));
  (u_xlat16_5.y = ((u_xlatb1.y) ? (-1.0) : (-0.0)));
  (u_xlat16_5.z = ((u_xlatb1.z) ? (-1.0) : (-0.0)));
  (u_xlat16_5.xyz = (u_xlat16_2.yzw + u_xlat16_5.xyz));
  (u_xlat16_2.yzw = max(u_xlat16_5.xyz, vec3(0.0, 0.0, 0.0)));
  (u_xlat16_5.x = dot(u_xlat16_2, vec4(4.0, 3.0, 2.0, 1.0)));
  (u_xlat16_5.x = ((-u_xlat16_5.x) + 4.0));
  (u_xlatu1 = uint(u_xlat16_5.x));
  (u_xlati1 = int((int(u_xlatu1) << 2)));
  (u_xlat26.xyz = (vs_TEXCOORD3.yyy * hlslcc_mtx4x4_MainLightWorldToShadow[(u_xlati1 + 1)].xyz));
  (u_xlat26.xyz = ((hlslcc_mtx4x4_MainLightWorldToShadow[u_xlati1].xyz * vs_TEXCOORD3.xxx) + u_xlat26.xyz));
  (u_xlat26.xyz = ((hlslcc_mtx4x4_MainLightWorldToShadow[(u_xlati1 + 2)].xyz * vs_TEXCOORD3.zzz) + u_xlat26.xyz));
  (u_xlat1.xyz = (u_xlat26.xyz + hlslcc_mtx4x4_MainLightWorldToShadow[(u_xlati1 + 3)].xyz));
  (u_xlat3.xy = ((u_xlat1.xy * _MainLightShadowmapSize.zw) + vec2(0.5, 0.5)));
  (u_xlat3.xy = floor(u_xlat3.xy));
  (u_xlat53.xy = ((u_xlat1.xy * _MainLightShadowmapSize.zw) + (-u_xlat3.xy)));
  (u_xlat16_2 = (u_xlat53.xxyy + vec4(0.5, 1.0, 0.5, 1.0)));
  (u_xlat16_4 = (u_xlat16_2.xxzz * u_xlat16_2.xxzz));
  (u_xlat16_5.xy = (u_xlat16_4.yw * vec2(0.079999998, 0.079999998)));
  (u_xlat16_55.xy = ((u_xlat16_4.xz * vec2(0.5, 0.5)) + (-u_xlat53.xy)));
  (u_xlat16_6.xy = ((-u_xlat53.xy) + vec2(1.0, 1.0)));
  (u_xlat16_56.xy = min(u_xlat53.xy, vec2(0.0, 0.0)));
  (u_xlat16_56.xy = (((-u_xlat16_56.xy) * u_xlat16_56.xy) + u_xlat16_6.xy));
  (u_xlat16_7.xy = max(u_xlat53.xy, vec2(0.0, 0.0)));
  (u_xlat16_7.xy = (((-u_xlat16_7.xy) * u_xlat16_7.xy) + u_xlat16_2.yw));
  (u_xlat16_56.xy = (u_xlat16_56.xy + vec2(1.0, 1.0)));
  (u_xlat16_7.xy = (u_xlat16_7.xy + vec2(1.0, 1.0)));
  (u_xlat16_4.xy = (u_xlat16_55.xy * vec2(0.16, 0.16)));
  (u_xlat16_8.xy = (u_xlat16_6.xy * vec2(0.16, 0.16)));
  (u_xlat16_6.xy = (u_xlat16_56.xy * vec2(0.16, 0.16)));
  (u_xlat16_7.xy = (u_xlat16_7.xy * vec2(0.16, 0.16)));
  (u_xlat16_55.xy = (u_xlat16_2.yw * vec2(0.16, 0.16)));
  (u_xlat16_4.z = u_xlat16_6.x);
  (u_xlat16_4.w = u_xlat16_55.x);
  (u_xlat16_8.z = u_xlat16_7.x);
  (u_xlat16_8.w = u_xlat16_5.x);
  (u_xlat2 = (u_xlat16_4.zwxz + u_xlat16_8.zwxz));
  (u_xlat16_6.z = u_xlat16_4.y);
  (u_xlat16_6.w = u_xlat16_55.y);
  (u_xlat16_7.z = u_xlat16_8.y);
  (u_xlat16_7.w = u_xlat16_5.y);
  (u_xlat9.xyz = (u_xlat16_6.zyw + u_xlat16_7.zyw));
  (u_xlat10.xyz = (u_xlat16_8.xzw / u_xlat2.zwy));
  (u_xlat10.xyz = (u_xlat10.xyz + vec3(-2.5, -0.5, 1.5)));
  (u_xlat11.xyz = (u_xlat16_7.zyw / u_xlat9.xyz));
  (u_xlat11.xyz = (u_xlat11.xyz + vec3(-2.5, -0.5, 1.5)));
  (u_xlat4.xyz = (u_xlat10.yxz * _MainLightShadowmapSize.xxx));
  (u_xlat5.xyz = (u_xlat11.xyz * _MainLightShadowmapSize.yyy));
  (u_xlat4.w = u_xlat5.x);
  (u_xlat6 = ((u_xlat3.xyxy * _MainLightShadowmapSize.xyxy) + u_xlat4.ywxw));
  (u_xlat53.xy = ((u_xlat3.xy * _MainLightShadowmapSize.xy) + u_xlat4.zw));
  (u_xlat5.w = u_xlat4.y);
  (u_xlat4.yw = u_xlat5.yz);
  (u_xlat7 = ((u_xlat3.xyxy * _MainLightShadowmapSize.xyxy) + u_xlat4.xyzy));
  (u_xlat5 = ((u_xlat3.xyxy * _MainLightShadowmapSize.xyxy) + u_xlat5.wywz));
  (u_xlat4 = ((u_xlat3.xyxy * _MainLightShadowmapSize.xyxy) + u_xlat4.xwzw));
  (u_xlat8 = (u_xlat2.zwyz * u_xlat9.xxxy));
  (u_xlat10 = (u_xlat2 * u_xlat9.yyzz));
  (u_xlat76 = (u_xlat2.y * u_xlat9.z));
  vec3 txVec0 = vec3(u_xlat6.xy, u_xlat1.z);
  (u_xlat16_3.x = textureLod(hlslcc_zcmp_MainLightShadowmapTexture, txVec0, 0.0));
  vec3 txVec1 = vec3(u_xlat6.zw, u_xlat1.z);
  (u_xlat16_28 = textureLod(hlslcc_zcmp_MainLightShadowmapTexture, txVec1, 0.0));
  (u_xlat28 = (u_xlat16_28 * u_xlat8.y));
  (u_xlat3.x = ((u_xlat8.x * u_xlat16_3.x) + u_xlat28));
  vec3 txVec2 = vec3(u_xlat53.xy, u_xlat1.z);
  (u_xlat16_28 = textureLod(hlslcc_zcmp_MainLightShadowmapTexture, txVec2, 0.0));
  (u_xlat3.x = ((u_xlat8.z * u_xlat16_28) + u_xlat3.x));
  vec3 txVec3 = vec3(u_xlat5.xy, u_xlat1.z);
  (u_xlat16_28 = textureLod(hlslcc_zcmp_MainLightShadowmapTexture, txVec3, 0.0));
  (u_xlat3.x = ((u_xlat8.w * u_xlat16_28) + u_xlat3.x));
  vec3 txVec4 = vec3(u_xlat7.xy, u_xlat1.z);
  (u_xlat16_28 = textureLod(hlslcc_zcmp_MainLightShadowmapTexture, txVec4, 0.0));
  (u_xlat3.x = ((u_xlat10.x * u_xlat16_28) + u_xlat3.x));
  vec3 txVec5 = vec3(u_xlat7.zw, u_xlat1.z);
  (u_xlat16_28 = textureLod(hlslcc_zcmp_MainLightShadowmapTexture, txVec5, 0.0));
  (u_xlat3.x = ((u_xlat10.y * u_xlat16_28) + u_xlat3.x));
  vec3 txVec6 = vec3(u_xlat5.zw, u_xlat1.z);
  (u_xlat16_28 = textureLod(hlslcc_zcmp_MainLightShadowmapTexture, txVec6, 0.0));
  (u_xlat3.x = ((u_xlat10.z * u_xlat16_28) + u_xlat3.x));
  vec3 txVec7 = vec3(u_xlat4.xy, u_xlat1.z);
  (u_xlat16_28 = textureLod(hlslcc_zcmp_MainLightShadowmapTexture, txVec7, 0.0));
  (u_xlat3.x = ((u_xlat10.w * u_xlat16_28) + u_xlat3.x));
  vec3 txVec8 = vec3(u_xlat4.zw, u_xlat1.z);
  (u_xlat16_28 = textureLod(hlslcc_zcmp_MainLightShadowmapTexture, txVec8, 0.0));
  (u_xlat76 = ((u_xlat76 * u_xlat16_28) + u_xlat3.x));
  (u_xlat16_12.x = ((-u_xlat76) + 1.0));
  (u_xlat16_37.x = ((-_MainLightShadowParams.x) + 1.0));
  (u_xlat16_12.x = ((u_xlat16_12.x * _MainLightShadowParams.x) + u_xlat16_37.x));
  (u_xlat3.xy = (_MainLightShadowmapSize.xy * vec2(4.0, 4.0)));
  (u_xlatb76 = (0.0 >= u_xlat1.z));
  (u_xlatb51 = (u_xlat1.z >= 1.0));
  (u_xlatb51 = (u_xlatb51 || u_xlatb76));
  (u_xlatb3.xy = greaterThanEqual(u_xlat3.xyxx, u_xlat1.xyxx).xy);
  (u_xlatb76 = (u_xlatb3.y || u_xlatb3.x));
  (u_xlat16_37.xy = (((-_MainLightShadowmapSize.xy) * vec2(4.0, 4.0)) + vec2(1.0, 1.0)));
  (u_xlatb1.xy = greaterThanEqual(u_xlat1.xyxx, u_xlat16_37.xyxx).xy);
  (u_xlatb1.x = (u_xlatb1.y || u_xlatb1.x));
  (u_xlatb1.x = (u_xlatb1.x || u_xlatb76));
  (u_xlatb1.x = (u_xlatb1.x || u_xlatb51));
  (u_xlati26 = int((((u_xlat16_12.x < 0.99000001)) ? (4294967295u) : (0u))));
  (u_xlati1 = ((u_xlatb1.x) ? (0) : (u_xlati26)));
  (u_xlat16_12.x = (((u_xlati1 != 0)) ? (0.0) : (1.0)));
  (u_xlat16_37.x = (((u_xlati1 != 0)) ? (_ES_CharacterShadowFactor) : (0.0)));
  (u_xlat16_12.x = (u_xlat16_37.x + u_xlat16_12.x));
  (u_xlatb1.x = (0.5 < _ES_CharacterDisableLocalMainLight));
  (u_xlat26.x = ((-u_xlat16_12.x) + 1.0));
  (u_xlat26.x = ((_CharacterLocalMainLightPosition.w * u_xlat26.x) + u_xlat16_12.x));
  (u_xlat1.x = ((u_xlatb1.x) ? (u_xlat16_12.x) : (u_xlat26.x)));
    //u_xlat1.x = shadowAtten
  //----------------------------------------------------------


  (u_xlat16_26.xy = texture(_FaceMap, vs_TEXCOORD5.xy).zw);
  (u_xlatb76 = (u_xlat16_26.y < _BackShadowRange));
//   (u_xlat16_12.x = ((-u_xlat16_26.y) + 1.0));
//   (u_xlat16_12.x = ((u_xlatb76) ? (u_xlat16_12.x) : (u_xlat16_26.y)));
  (u_xlat16_12.x = (u_xlat16_26.y));
// debugColor = vs_TEXCOORD5.zzz;

  (u_xlat51.x = texture(_FaceMap, vs_TEXCOORD0.xy).x);
  (u_xlat16_3.xyz = texture(_FaceExpression, vs_TEXCOORD0.xy).xyz);

  (u_xlat16_37.x = (_ES_CharacterDisableLocalMainLight + 1.0));
  (u_xlat16_37.x = (u_xlat16_37.x + (-abs(_DisableCharacterLocalLight.x))));
  (u_xlatb76 = (0.5 < u_xlat16_37.x));
  (u_xlat9.xyz = ((bool(u_xlatb76)) ? (_MainLightColor.xyz) : (_CharacterLocalMainLightColor.xyz)));
  //u_xlat9.xyz = _MainLightColor.xyz;

  //vs_TEXCOORD4 = normalWS
  (u_xlat16_37.x = dot(vs_TEXCOORD4.xyz, vs_TEXCOORD4.xyz));
  (u_xlat16_37.x = inversesqrt(u_xlat16_37.x));
  (u_xlat16_37.xyz = (u_xlat16_37.xxx * vs_TEXCOORD4.xyz));
  //u_xlat16_37.xyz = normalWS

  //u_xlat10.xyz = ViewDir
  (u_xlat10.xyz = ((-vs_TEXCOORD3.xyz) + _WorldSpaceCameraPos.xyz));
  (u_xlat76 = dot(u_xlat10.xyz, u_xlat10.xyz));
  (u_xlat76 = inversesqrt(u_xlat76));
  (u_xlat10.xyz = (vec3(u_xlat76) * u_xlat10.xyz));
  //u_xlat10.xyz = ViewDir

//u_xlat11 = normalVS
  (u_xlat11.xyz = (u_xlat16_37.yyy * hlslcc_mtx4x4unity_MatrixV[1].xyz));
  (u_xlat11.xyz = ((hlslcc_mtx4x4unity_MatrixV[0].xyz * u_xlat16_37.xxx) + u_xlat11.xyz));
  (u_xlat11.xyz = ((hlslcc_mtx4x4unity_MatrixV[2].xyz * u_xlat16_37.zzz) + u_xlat11.xyz));

  (u_xlat13.xyz = (u_xlat10.yyy * hlslcc_mtx4x4unity_MatrixV[1].xyz));
  (u_xlat13.xyz = ((hlslcc_mtx4x4unity_MatrixV[0].xyz * u_xlat10.xxx) + u_xlat13.xyz));
  (u_xlat13.xyz = ((hlslcc_mtx4x4unity_MatrixV[2].xyz * u_xlat10.zzz) + u_xlat13.xyz));
//u_xlat13 = ViewDirVS

  //u_xlat16_14.x = NdotV
  (u_xlat16_14.x = dot(u_xlat16_37.xyz, u_xlat10.xyz));

  (u_xlat16_39.xyz = (u_xlat13.xyz + (-_RimShadowOffset.xyz)));
  (u_xlat16_15.x = dot(u_xlat16_39.xyz, u_xlat16_39.xyz));
  (u_xlat16_15.x = inversesqrt(u_xlat16_15.x));
  (u_xlat16_39.xyz = (u_xlat16_39.xyz * u_xlat16_15.xxx));

  (u_xlat16_39.x = dot(u_xlat11.xyz, u_xlat16_39.xyz));
  (u_xlat16_39.x = clamp(u_xlat16_39.x, 0.0, 1.0));

  //鼻线---------------------------
  (u_xlat16_35 = (u_xlat10.y * 0.5));
  (u_xlat10.y = u_xlat16_35);
  //u_xlat16_37.xyz = normalWS
    //u_xlat16_37.x = NdotV;
  (u_xlat16_37.x = dot(u_xlat10.xyz, u_xlat16_37.xyz));
  (u_xlat16_37.y = (_NoseLinePower * 8.0));
  (u_xlat16_37.xy = max(u_xlat16_37.xy, vec2(0.001, 0.1)));
  //pow(u_xlat16_37.x, u_xlat16_37.y)
  (u_xlat16_37.x = log2(u_xlat16_37.x));
  (u_xlat16_37.x = (u_xlat16_37.x * u_xlat16_37.y));
  (u_xlat16_37.x = exp2(u_xlat16_37.x));
  (u_xlat16_37.x = min(u_xlat16_37.x, 1.0));
//u_xlat16_26.x=_FaceMap.z
  (u_xlat16_37.x = (u_xlat16_26.x * u_xlat16_37.x));
  (u_xlatb26.x = (0.1 < u_xlat16_37.x));
  (u_xlat16_37.x = ((u_xlatb26.x) ? (1.0) : (0.0)));
  //u_xlat16_37.x = 鼻线
  //lerp(u_xlat16_0, _NoseLineColor, u_xlat16_37.x)
  (u_xlat16_15.xyz = ((-u_xlat16_0.xyz) + _NoseLineColor.xyz));
  (u_xlat16_37.xyz = ((u_xlat16_37.xxx * u_xlat16_15.xyz) + u_xlat16_0.xyz));
  //todo:u_xlat16_37
  //---------------------------
// debugColor = u_xlat16_37.xxx;

    //嘴唇线修复?------------------------------
  (u_xlat16_64 = ((-_LipLineFixStart) + _LipLineFixMax));
  (u_xlat16_64 = max(u_xlat16_64, 0.0099999998));
  //vs_TEXCOORD3 = positionWS
  //u_xlat16_15.xyz = ViewDir
  (u_xlat16_15.xyz = (vs_TEXCOORD3.xyz + (-_WorldSpaceCameraPos.xyz)));
  (u_xlat16_89 = dot(u_xlat16_15.xyz, u_xlat16_15.xyz));
  (u_xlat16_89 = sqrt(u_xlat16_89));

  (u_xlatb26.x = (u_xlat16_89 < 2.0));
  (u_xlatb26.z = (5.0 < u_xlat16_89));
  (u_xlat26.x = ((u_xlatb26.x) ? (1.2) : (1.0)));
  (u_xlat26.z = ((u_xlatb26.z) ? (0.80000001) : (1.0)));
  (u_xlatb78 = (u_xlat16_89 < _LipLineFixStart));
  (u_xlat16_89 = (u_xlat16_89 + (-_LipLineFixStart)));
  (u_xlat84 = (u_xlat16_89 / u_xlat16_64));
  (u_xlat84 = clamp(u_xlat84, 0.0, 1.0));
  (u_xlat16_64 = ((u_xlatb78) ? (0.0) : (u_xlat84)));
  (u_xlat16_89 = ((u_xlat26.x * u_xlat26.z) + -1.0));
  (u_xlat16_89 = ((_LipLineFixSC * u_xlat16_89) + 1.0));
  (u_xlat16_89 = (u_xlat16_89 * _LipLineFixScale));
  (u_xlat16_89 = max(u_xlat16_89, 0.0099999998));
  (u_xlat16_89 = (u_xlat16_89 * _LipLineFixThrd));
  (u_xlat16_89 = clamp(u_xlat16_89, 0.0, 1.0));
  (u_xlat16_89 = (u_xlat16_89 + -0.039999999));
  (u_xlat16_89 = ((u_xlat16_64 * u_xlat16_89) + 0.039999999));
  (u_xlatb26.x = (vs_TEXCOORD1.y < 0.94999999));
  (u_xlat16_15.x = ((u_xlatb26.x) ? (vs_TEXCOORD1.y) : (0.0)));
  (u_xlat16_64 = ((-u_xlat16_64) + 1.0));
  (u_xlat16_64 = ((-u_xlat16_64) + u_xlat16_15.x));
  (u_xlatb26.x = (u_xlat16_89 < u_xlat16_64));
  (u_xlat16_64 = ((u_xlatb26.x) ? (0.0) : (1.0)));
  //_LipLinefixColor 0.45881, 0.23419, 0.19947, 1.00

  //u_xlat16_37 = lerp(_LipLinefixColor, u_xlat16_37, u_xlat16_64);
  (u_xlat16_37.xyz = (u_xlat16_37.xyz + (-_LipLinefixColor.xyz)));
  (u_xlat16_37.xyz = ((vec3(u_xlat16_64) * u_xlat16_37.xyz) + _LipLinefixColor.xyz));
//-----------------------------------------

//lerp(_EyeBaseShadowColor, 1, vs_TEXCOORD1.x)
  (u_xlat16_15.xyz = ((-_EyeBaseShadowColor.xyz) + vec3(1.0, 1.0, 1.0)));
  (u_xlat16_15.xyz = ((vs_TEXCOORD1.xxx * u_xlat16_15.xyz) + _EyeBaseShadowColor.xyz));
  (u_xlat16_15.xyz = (u_xlat16_15.xyz * _Color.xyz));
//  u_xlat16_15.xyz = eyeBaseColor
//-----------------------------------------
  (u_xlat16_37.xyz = (u_xlat16_37.xyz * u_xlat16_15.xyz));

    //Emission--------------
  (u_xlatb26.x = (_EmissionThreshold < u_xlat16_0.w));
  (u_xlat16_64 = (u_xlat16_0.w + (-_EmissionThreshold)));
  (u_xlat16_89 = ((-_EmissionThreshold) + 1.0));
  (u_xlat16_89 = max(u_xlat16_89, 0.001));
  (u_xlat16_64 = (u_xlat16_64 / u_xlat16_89));
  (u_xlat16_64 = ((u_xlatb26.x) ? (u_xlat16_64) : (0.0)));
//u_xlat16_64 = emissionFactor
  (u_xlatb26.x = (_EmissionThreshold >= u_xlat16_0.w));
  (u_xlat16_15.x = (u_xlat16_0.w / _EmissionThreshold));
  (u_xlat16_15.x = ((u_xlatb26.x) ? (u_xlat16_15.x) : (1.0)));
  //u_xlat16_15.x = emissionFactor2

//finalColor = finalColor * emissionFactor * _EmissionIntensity.xxx + finalColor;
  (u_xlat16_40.xyz = (u_xlat16_37.xyz * vec3(u_xlat16_64)));
  (u_xlat16_37.xyz = ((u_xlat16_40.xyz * vec3(vec3(_EmissionIntensity, _EmissionIntensity, _EmissionIntensity))) + u_xlat16_37.xyz));
//-------------


  (u_xlat16_14.x = ((-abs(u_xlat16_14.x)) + 1.0));
  (u_xlat16_14.x = (u_xlat16_14.x + (-_FresnelBSI.x)));
  (u_xlat16_64 = (1.0 / _FresnelBSI.y));
  (u_xlat16_14.x = (u_xlat16_64 * u_xlat16_14.x));
  (u_xlat16_14.x = clamp(u_xlat16_14.x, 0.0, 1.0));
  (u_xlat16_40.xyz = (u_xlat16_14.xxx * _FresnelColor.xyz));
  (u_xlat16_40.xyz = (u_xlat16_40.xyz * vec3(vec3(_FresnelColorStrength, _FresnelColorStrength, _FresnelColorStrength))));
  (u_xlat16_40.xyz = max(u_xlat16_40.xyz, vec3(0.0, 0.0, 0.0)));
  (u_xlatb26.xz = lessThan(vec4(0.0, 0.0, 0.1, 0.1), u_xlat51.xxxx).xz);
  (u_xlatb75 = (_ExMapThreshold < u_xlat16_3.x));
  (u_xlat16_14.x = (u_xlat16_3.x + (-_ExMapThreshold)));
  (u_xlat16_64 = ((-_ExMapThreshold) + 1.0));
  (u_xlat16_14.x = (u_xlat16_14.x / u_xlat16_64));
  (u_xlatb78 = (_ExMapThreshold >= u_xlat16_3.x));
  (u_xlat16_64 = (u_xlat16_3.x / _ExMapThreshold));
  (u_xlat16_64 = ((u_xlatb78) ? (u_xlat16_64) : (1.0)));
  (u_xlat3.x = (u_xlat16_14.x * _ExSpecularIntensity));
  (u_xlat3.x = (u_xlat3.x * _ExCheekIntensity));
  (u_xlat16_14.x = ((u_xlatb75) ? (u_xlat3.x) : (0.0)));
  (u_xlat16_16.xyz = ((-_ExShadowColor.xyz) + _ExEyeColor.xyz));
  (u_xlat16_16.xyz = ((u_xlatb26.x) ? (u_xlat16_16.xyz) : (vec3(0.0, 0.0, 0.0))));
  (u_xlat16_16.xyz = (u_xlat16_16.xyz + _ExShadowColor.xyz));
  (u_xlat16_64 = (u_xlat16_64 * _ExCheekIntensity));
  (u_xlat16_17.xyz = (_ExCheekColor.xyz + vec3(-1.0, -1.0, -1.0)));
  (u_xlat16_17.xyz = ((vec3(u_xlat16_64) * u_xlat16_17.xyz) + vec3(1.0, 1.0, 1.0)));
  (u_xlat16_18.xy = (u_xlat16_3.yz * vec2(_ExShyIntensity, _ExShadowIntensity)));
  (u_xlat16_19.xyz = ((-u_xlat16_17.xyz) + _ExShyColor.xyz));
  (u_xlat16_17.xyz = ((u_xlat16_18.xxx * u_xlat16_19.xyz) + u_xlat16_17.xyz));
  (u_xlat16_16.xyz = (u_xlat16_16.xyz + (-u_xlat16_17.xyz)));
  (u_xlat16_16.xyz = ((u_xlat16_18.yyy * u_xlat16_16.xyz) + u_xlat16_17.xyz));
  (u_xlat16_16.xyz = (u_xlat16_14.xxx + u_xlat16_16.xyz));
  (u_xlat16_14.xz = ((u_xlatb26.z) ? (vec2(1.0, 0.0)) : (vec2(0.0, 1.0))));
  //_ShadowFeather = 0.001
  (u_xlat16_91 = (vs_TEXCOORD5.z + (-_ShadowFeather)));
//   (u_xlat16_91 = max(u_xlat16_91, 9.9999997e-05));
  (u_xlat16_17.x = (vs_TEXCOORD5.z + _ShadowFeather));
  (u_xlat16_17.x = min(u_xlat16_17.x, 0.99989998));

    //smoothstep(u_xlat16_91,u_xlat16_17.x,u_xlat16_12)
  (u_xlat16_17.x = ((-u_xlat16_91) + u_xlat16_17.x));
  (u_xlat16_12.x = (u_xlat16_12.x + (-u_xlat16_91)));
  (u_xlat16_91 = (1.0 / u_xlat16_17.x));
  (u_xlat16_12.x = (u_xlat16_12.x * u_xlat16_91));
  (u_xlat16_12.x = clamp(u_xlat16_12.x, 0.0, 1.0));
  (u_xlat16_91 = ((u_xlat16_12.x * -2.0) + 3.0));
  (u_xlat16_12.x = (u_xlat16_12.x * u_xlat16_12.x));
  (u_xlat16_12.x = (u_xlat16_12.x * u_xlat16_91));

// u_xlat16_12 = fase shadow------------------------------

// debugColor = u_xlat16_12.xxx;
//u_xlat51.x = faceMap.x
// _CharacterLocalMainLightPosition 0.38249, 0.43589, -0.81468, 0.00

//u_xlat16_14.xxx = eyeMask

  (u_xlat75 = max(_CharacterLocalMainLightPosition.w, 0.0099999998));
  (u_xlatb26.x = (u_xlat51.x < 0.80000001));
  (u_xlatb26.x = (u_xlatb26.z && u_xlatb26.x));

  (u_xlat16_17.xyz = ((u_xlatb26.x) ? (vec3(1.0, -1.0, 0.5)) : (vec3(0.0, -0.0, 0.0))));
  (u_xlat16_91 = (u_xlat16_14.x + u_xlat16_17.y));
  (u_xlat16_91 = (u_xlat16_91 + u_xlat16_17.z));
    //u_xlat16_91 = eye
  //vs_TEXCOORD3 = positionWS

  (u_xlat16_42.x = (_EyeShadowAngleMin + -0.36000001));
  (u_xlat26.x = ((-u_xlat16_42.x) + _EyeShadowMaxAngle));
  (u_xlat51.x = ((-u_xlat16_42.x) + vs_TEXCOORD3.w));
  (u_xlat26.x = (1.0 / u_xlat26.x));
  (u_xlat26.x = (u_xlat26.x * u_xlat51.x));
  (u_xlat26.x = clamp(u_xlat26.x, 0.0, 1.0));
  (u_xlat51.x = ((u_xlat26.x * -2.0) + 3.0));
  (u_xlat26.x = (u_xlat26.x * u_xlat26.x));
  (u_xlat26.x = (u_xlat26.x * u_xlat51.x));

// debugColor = u_xlat16_91.xxx;
//  eye = lerp(1, u_xlat26.x * u_xlat16_91, u_xlat16_91);
  (u_xlat16_42.x = ((u_xlat16_91 * u_xlat26.x) + -1.0));
  (u_xlat16_91 = ((u_xlat16_91 * u_xlat16_42.x) + 1.0));
// _EyeShadowColor 0.78741, 0.72036, 0.71313, 1.00 64 float4
// _ShadowColor 0.9774, 0.73162, 0.65174, 1.00 64 float4

// u_xlat16_42 = lerp(_ShadowColor.xyz, _EyeShadowColor.xyz, eyeMask.xxx);
  (u_xlat16_42.xyz = (_EyeShadowColor.xyz + (-_ShadowColor.xyz)));
  (u_xlat16_42.xyz = ((u_xlat16_14.xxx * u_xlat16_42.xyz) + _ShadowColor.xyz));
//lerp(1, _CharacterLocalMainLightDark1, _NewLocalLightStrength.z)
  (u_xlat26.xyz = (_CharacterLocalMainLightDark1.xyz + vec3(-1.0, -1.0, -1.0)));
  (u_xlat26.xyz = ((_NewLocalLightStrength.zzz * u_xlat26.xyz) + vec3(1.0, 1.0, 1.0)));
//u_xlat3.xyz = eyeShadowColor
  (u_xlat3.xyz = (u_xlat26.xyz * u_xlat16_42.xyz));

  (u_xlat16_12.x = (u_xlat1.x * u_xlat16_12.x));
    //u_xlat1.xxx = shadowAtten
  //u_xlat16_12.x= faceShadow

    //u_xlat16_91 = eyeShadow
  (u_xlat16_18.x = (u_xlat16_91 * u_xlat16_12.x));
  (u_xlat16_42.xyz = (((-u_xlat16_42.xyz) * u_xlat26.xyz) + vec3(1.0, 1.0, 1.0)));
  (u_xlat16_42.xyz = ((u_xlat16_18.xxx * u_xlat16_42.xyz) + u_xlat3.xyz));
  //u_xlat16_42=darkColor
  (u_xlatb1.x = (0.5 < _ES_LEVEL_ADJUST_ON));

  (u_xlat16_18.xyz = (_ES_LevelSkinLightColor.www * _ES_LevelSkinLightColor.xyz));
  (u_xlat16_19.xyz = (u_xlat16_18.xyz + u_xlat16_18.xyz));
  //u_xlat16_19 = levelSkinLightColor2
  (u_xlat16_20.xyz = (_ES_LevelSkinShadowColor.www * _ES_LevelSkinShadowColor.xyz));
  (u_xlat16_21.xyz = (u_xlat16_20.xyz + u_xlat16_20.xyz));
    //u_xlat16_21.xyz=levelSkinShadowColor2
  (u_xlat16_22.xyz = ((u_xlat16_18.xyz * vec3(2.0, 2.0, 2.0)) + (-u_xlat16_21.xyz)));
  (u_xlat16_22.xyz = ((vec3(u_xlat16_91) * u_xlat16_22.xyz) + u_xlat16_21.xyz));
  (u_xlat16_22.xyz = (u_xlat16_22.xyz + vec3(-1.0, -1.0, -1.0)));
  (u_xlat16_22.xyz = ((vec3(_ES_LevelEyeShadowIntensity) * u_xlat16_22.xyz) + vec3(1.0, 1.0, 1.0)));
  //u_xlat16_22.xyz=skinColor

  (u_xlatb75 = (u_xlat16_12.x >= u_xlat75));
  (u_xlat16_23.xyz = (u_xlat16_42.xyz + (-vec3(vec3(_ES_LevelMid, _ES_LevelMid, _ES_LevelMid)))));
  (u_xlat16_24.xy = ((-vec2(_ES_LevelMid, _ES_LevelShadow)) + vec2(_ES_LevelHighLight, _ES_LevelMid)));
  (u_xlat16_23.xyz = (u_xlat16_23.xyz / u_xlat16_24.xxx));
  (u_xlat16_23.xyz = ((u_xlat16_23.xyz * vec3(0.5, 0.5, 0.5)) + vec3(0.5, 0.5, 0.5)));
  (u_xlat16_23.xyz = clamp(u_xlat16_23.xyz, 0.0, 1.0));
  //float3 diffuseColor = lerp(levelSkinLightColor2, skinColor, eyeMask.x) * rampDiffuse;
  (u_xlat16_18.xyz = (((-u_xlat16_18.xyz) * vec3(2.0, 2.0, 2.0)) + u_xlat16_22.xyz));
  (u_xlat16_18.xyz = ((u_xlat16_14.xxx * u_xlat16_18.xyz) + u_xlat16_19.xyz));
//
  (u_xlat16_18.xyz = (u_xlat16_18.xyz * u_xlat16_23.xyz));
  //u_xlat16_18=diffuseColor

// debugColor = u_xlat16_18.xyz;

  (u_xlat16_19.xyz = ((-u_xlat16_42.xyz) + vec3(vec3(_ES_LevelMid, _ES_LevelMid, _ES_LevelMid))));
  (u_xlat16_19.xyz = (u_xlat16_19.xyz / u_xlat16_24.yyy));
  (u_xlat16_19.xyz = (((-u_xlat16_19.xyz) * vec3(0.5, 0.5, 0.5)) + vec3(0.5, 0.5, 0.5)));
  (u_xlat16_19.xyz = clamp(u_xlat16_19.xyz, 0.0, 1.0));
  //float3 diffuseColor2 = lerp(levelSkinShadowColor2, skinColor, eyeMask.x) * rampDiffuse;
  (u_xlat16_20.xyz = (((-u_xlat16_20.xyz) * vec3(2.0, 2.0, 2.0)) + u_xlat16_22.xyz));
  (u_xlat16_20.xyz = ((u_xlat16_14.xxx * u_xlat16_20.xyz) + u_xlat16_21.xyz));
  (u_xlat16_19.xyz = (u_xlat16_19.xyz * u_xlat16_20.xyz));
  //---------------------
//
  (u_xlat16_18.xyz = ((bool(u_xlatb75)) ? (u_xlat16_18.xyz) : (u_xlat16_19.xyz)));
  (u_xlat16_42.xyz = ((u_xlatb1.x) ? (u_xlat16_18.xyz) : (u_xlat16_42.xyz)));
  //u_xlat16_37 = blend _Emission
  (u_xlat16_42.xyz = (u_xlat16_37.xyz * u_xlat16_42.xyz));
//
// debugColor = u_xlat16_42.xyz;

  (u_xlat16_12.x = dot(u_xlat16_42.xyz, vec3(0.30000001, 0.58999997, 0.11)));
  (u_xlat16_91 = (u_xlat16_17.x * _EyeEffectProcs));
  (u_xlat16_91 = clamp(u_xlat16_91, 0.0, 1.0));
  (u_xlat16_18.xyz = (u_xlat16_12.xxx * _EyeEffectColor.xyz));
  (u_xlat16_19.xyz = ((u_xlat16_12.xxx * _EyeEffectColor.xyz) + (-u_xlat16_42.xyz)));
  (u_xlat16_19.xyz = ((vec3(u_xlat16_91) * u_xlat16_19.xyz) + u_xlat16_42.xyz));
  (u_xlat16_18.xyz = ((u_xlat16_18.xyz * u_xlat16_12.xxx) + u_xlat16_19.xyz));
  (u_xlat16_12.x = ((u_xlat16_12.x * 0.5) + 1.0));
  (u_xlat16_18.xyz = ((u_xlat16_18.xyz * u_xlat16_12.xxx) + (-u_xlat16_42.xyz)));
  (u_xlat16_42.xyz = ((vec3(u_xlat16_91) * u_xlat16_18.xyz) + u_xlat16_42.xyz));
  (u_xlat16_42.xyz = clamp(u_xlat16_42.xyz, 0.0, 1.0));
  //_UseSpecialEye = 0
  (u_xlatb75 = (0.5 < _UseSpecialEye));
  if (u_xlatb75)
  {
    (u_xlat1.xy = ((vs_TEXCOORD0.yx * _SpecialEyeShapeTexture_ST.yx) + _SpecialEyeShapeTexture_ST.wz));
    (u_xlat51.xy = (_Time.yy * _EyeCenter.zw));
    (u_xlat1.xy = (u_xlat1.xy + (-_EyeCenter.yx)));
    (u_xlat3.x = sin(u_xlat51.x));
    (u_xlat10.x = cos(u_xlat51.x));
    (u_xlat3.xy = (u_xlat1.xy * u_xlat3.xx));
    (u_xlat11.x = ((u_xlat1.y * u_xlat10.x) + (-u_xlat3.x)));
    (u_xlat11.y = ((u_xlat1.x * u_xlat10.x) + u_xlat3.y));
    (u_xlat3.xy = (u_xlat11.xy + _EyeCenter.xy));
    (u_xlat10.x = sin(u_xlat51.y));
    (u_xlat11.x = cos(u_xlat51.y));
    (u_xlat51.xy = (u_xlat1.xy * u_xlat10.xx));
    (u_xlat10.x = ((u_xlat1.y * u_xlat11.x) + (-u_xlat51.x)));
    (u_xlat10.y = ((u_xlat1.x * u_xlat11.x) + u_xlat51.y));
    (u_xlat1.xy = (u_xlat10.xy + _EyeCenter.xy));
    (u_xlat16_75 = texture(_SpecialEyeShapeTexture, u_xlat3.xy).x);
    (u_xlat16_1.x = texture(_SpecialEyeShapeTexture, u_xlat1.xy).y);
    (u_xlat16_12.x = (u_xlat16_17.x * u_xlat16_1.x));
    (u_xlat16_18.xyz = ((-u_xlat16_42.xyz) + _EyeSPColor2.xyz));
    (u_xlat16_18.xyz = ((u_xlat16_12.xxx * u_xlat16_18.xyz) + u_xlat16_42.xyz));
    (u_xlat16_12.x = (u_xlat16_17.x * u_xlat16_75));
    (u_xlat16_19.xyz = ((-u_xlat16_18.xyz) + _EyeSPColor1.xyz));
    (u_xlat16_18.xyz = ((u_xlat16_12.xxx * u_xlat16_19.xyz) + u_xlat16_18.xyz));
    (u_xlat16_12.x = (u_xlat16_14.x + u_xlat16_17.x));
    (u_xlat16_14.x = (_SpecialEyeIntensity + -1.0));
    (u_xlat16_12.x = ((u_xlat16_12.x * u_xlat16_14.x) + 1.0));
    (u_xlat16_42.xyz = (u_xlat16_12.xxx * u_xlat16_18.xyz));
  }
  (u_xlat16_75 = texture(_FaceMap, vs_TEXCOORD6.xy).w);

  (u_xlat16_18.xy = (vs_TEXCOORD6.zz + vec2(-0.1, 0.1)));
  (u_xlat16_18.xy = clamp(u_xlat16_18.xy, 0.0, 1.0));
  (u_xlat1.x = ((-u_xlat16_18.x) + u_xlat16_18.y));
  (u_xlat75 = (u_xlat16_75 + (-u_xlat16_18.x)));
  (u_xlat1.x = (1.0 / u_xlat1.x));
  (u_xlat75 = (u_xlat75 * u_xlat1.x));
  (u_xlat75 = clamp(u_xlat75, 0.0, 1.0));
  (u_xlat1.x = ((u_xlat75 * -2.0) + 3.0));
  (u_xlat75 = (u_xlat75 * u_xlat75));
  (u_xlat75 = (u_xlat75 * u_xlat1.x));

  (u_xlat1.xyz = (vs_TEXCOORD3.xyz + (-_NewLocalLightCharCenter.xyz)));
  (u_xlat76 = dot(u_xlat1.xyz, u_xlat1.xyz));
  (u_xlat76 = inversesqrt(u_xlat76));
  (u_xlat1.xyz = (vec3(u_xlat76) * u_xlat1.xyz));
  (u_xlat1.x = dot(u_xlat1.xyz, _NewLocalLightDir.xyz));
  (u_xlat16_12.x = ((u_xlat1.x * 0.5) + 0.5));
  (u_xlat1.x = ((-_CharacterLocalMainLightColor1.w) + 1.0));
  (u_xlat75 = (u_xlat75 * u_xlat1.x));
  (u_xlat75 = (u_xlat75 * 0.94999999));
  (u_xlat75 = ((_CharacterLocalMainLightColor1.w * u_xlat16_12.x) + u_xlat75));

  (u_xlat1.xy = (vec2(u_xlat75) * _NewLocalLightStrength.xy));
  (u_xlatb3.xyz = lessThan(u_xlat16_42.xyzx, vec4(0.5, 0.5, 0.5, 0.0)).xyz);

  (u_xlat16_18.xyz = (u_xlat16_42.xyz + u_xlat16_42.xyz));
  (u_xlat16_18.xyz = (u_xlat16_18.xyz * _CharacterLocalMainLightColor1.xyz));
  (u_xlat16_19.xyz = ((-u_xlat16_42.xyz) + vec3(1.0, 1.0, 1.0)));
  (u_xlat16_19.xyz = (u_xlat16_19.xyz + u_xlat16_19.xyz));
  (u_xlat16_20.xyz = ((-_CharacterLocalMainLightColor1.xyz) + vec3(1.0, 1.0, 1.0)));
  (u_xlat16_19.xyz = (((-u_xlat16_19.xyz) * u_xlat16_20.xyz) + vec3(1.0, 1.0, 1.0)));
  {
    vec3 hlslcc_movcTemp = u_xlat16_18;
    (hlslcc_movcTemp.x = ((u_xlatb3.x) ? (u_xlat16_18.x) : (u_xlat16_19.x)));
    (hlslcc_movcTemp.y = ((u_xlatb3.y) ? (u_xlat16_18.y) : (u_xlat16_19.y)));
    (hlslcc_movcTemp.z = ((u_xlatb3.z) ? (u_xlat16_18.z) : (u_xlat16_19.z)));
    (u_xlat16_18 = hlslcc_movcTemp);
  }
  (u_xlat16_18.xyz = ((-u_xlat16_42.xyz) + u_xlat16_18.xyz));
  (u_xlat16_42.xyz = ((u_xlat1.xxx * u_xlat16_18.xyz) + u_xlat16_42.xyz));


  (u_xlat75 = (u_xlat16_14.z * u_xlat1.y));
  (u_xlat1.xyz = ((vec3(u_xlat75) * _CharacterLocalMainLightColor2.xyz) + u_xlat16_42.xyz));

  (u_xlatb75 = (0.5 < vs_TEXCOORD0.x));
  (u_xlat16_12.x = ((-vs_TEXCOORD0.x) + 1.0));
  (u_xlat16_18.x = ((u_xlatb75) ? (u_xlat16_12.x) : (vs_TEXCOORD0.x)));
  (u_xlat16_18.y = vs_TEXCOORD0.y);
  (u_xlat16_75 = texture(_FaceMap, u_xlat16_18.xy).w);

  (u_xlat16_12.x = ((-u_xlat16_39.x) + 1.0));
  (u_xlat16_12.x = max(u_xlat16_12.x, 0.001));
  (u_xlat16_12.x = log2(u_xlat16_12.x));
  (u_xlat16_12.x = (u_xlat16_12.x * _RimShadowCt));
  (u_xlat16_12.x = exp2(u_xlat16_12.x));
  (u_xlat16_12.x = (u_xlat16_12.x * _RimShadowWidth));
  (u_xlat16_12.x = clamp(u_xlat16_12.x, 0.0, 1.0));
  (u_xlat16_14.x = ((-_RimShadowFeather) + 1.0));
  (u_xlat16_12.x = (u_xlat16_12.x + (-_RimShadowFeather)));
  (u_xlat16_14.x = (1.0 / u_xlat16_14.x));
  (u_xlat16_12.x = (u_xlat16_12.x * u_xlat16_14.x));
  (u_xlat16_12.x = clamp(u_xlat16_12.x, 0.0, 1.0));
  (u_xlat16_14.x = ((u_xlat16_12.x * -2.0) + 3.0));
  (u_xlat16_12.x = (u_xlat16_12.x * u_xlat16_12.x));
  (u_xlat16_12.x = (u_xlat16_12.x * u_xlat16_14.x));
  (u_xlat16_14.xyz = ((-_RimShadowColor.xyz) + vec3(1.0, 1.0, 1.0)));
  (u_xlat16_14.xyz = (u_xlat16_12.xxx * u_xlat16_14.xyz));
  (u_xlat16_14.xyz = (u_xlat16_14.xyz * vec3(_RimShadowIntensity)));
  (u_xlat16_12.x = ((-u_xlat16_75) + 1.0));

  (u_xlat16_14.xyz = ((u_xlat16_12.xxx * (-u_xlat16_14.xyz)) + vec3(1.0, 1.0, 1.0)));
  (u_xlat16_16.xyz = (u_xlat16_16.xyz * u_xlat1.xyz));
  (u_xlat16_16.xyz = (u_xlat9.xyz * u_xlat16_16.xyz));
  (u_xlat16_12.x = ((u_xlat16_17.x * (-_mBloomIntensity0)) + _mBloomIntensity0));
  (u_xlat16_17.xyz = (u_xlat16_37.xyz * u_xlat16_12.xxx));
  (u_xlat16_14.xyz = ((u_xlat16_16.xyz * u_xlat16_14.xyz) + u_xlat16_17.xyz));

  (u_xlat16_14.xyz = (u_xlat16_40.xyz + u_xlat16_14.xyz));
  (u_xlat16_14.xyz = ((_ES_AddColor.xyz * u_xlat16_37.xyz) + u_xlat16_14.xyz));
  (u_xlatb75 = (_EmissionThreshold < u_xlat16_15.x));
  (u_xlat16_12.x = (u_xlat16_15.x + (-_EmissionThreshold)));
  (u_xlat1.x = (u_xlat16_12.x / u_xlat16_89));
  (u_xlat1.x = clamp(u_xlat1.x, 0.0, 1.0));
  (u_xlat16_12.x = ((u_xlatb75) ? (u_xlat1.x) : (0.0)));
  (u_xlat16_37.xyz = ((u_xlat16_37.xyz * vec3(vec3(_EmissionIntensity, _EmissionIntensity, _EmissionIntensity))) + (-u_xlat16_14.xyz)));
  (u_xlat16_12.xyz = ((u_xlat16_12.xxx * u_xlat16_37.xyz) + u_xlat16_14.xyz));
  (u_xlat75 = (vs_TEXCOORD3.y + (-_CharaWorldSpaceOffset.y)));

  (u_xlat16_87 = max(_ES_HeightLerpBottom, 0.001));
  (u_xlat1.x = (1.0 / u_xlat16_87));
  (u_xlat1.x = (u_xlat75 * u_xlat1.x));
  (u_xlat1.x = clamp(u_xlat1.x, 0.0, 1.0));
  (u_xlat26.x = ((u_xlat1.x * -2.0) + 3.0));
  (u_xlat1.x = (u_xlat1.x * u_xlat1.x));
  (u_xlat1.x = (((-u_xlat26.x) * u_xlat1.x) + 1.0));
  (u_xlat75 = (u_xlat75 + (-_ES_HeightLerpTop)));
  (u_xlat75 = (u_xlat75 + u_xlat75));
  (u_xlat75 = clamp(u_xlat75, 0.0, 1.0));
  (u_xlat26.x = ((u_xlat75 * -2.0) + 3.0));
  (u_xlat75 = (u_xlat75 * u_xlat75));
  (u_xlat51.x = (u_xlat75 * u_xlat26.x));
  (u_xlat16_87 = ((-u_xlat1.x) + 1.0));
  (u_xlat16_87 = (((-u_xlat26.x) * u_xlat75) + u_xlat16_87));
  (u_xlat16_87 = clamp(u_xlat16_87, 0.0, 1.0));
  (u_xlat16_14.xyz = (u_xlat1.xxx * _ES_HeightLerpBottomColor.xyz));
  (u_xlat16_15.xyz = (vec3(u_xlat16_87) * _ES_HeightLerpMiddleColor.xyz));
  (u_xlat16_15.xyz = (u_xlat16_15.xyz * _ES_HeightLerpMiddleColor.www));
  (u_xlat16_14.xyz = ((u_xlat16_14.xyz * _ES_HeightLerpBottomColor.www) + u_xlat16_15.xyz));
  (u_xlat16_15.xyz = (u_xlat51.xxx * _ES_HeightLerpTopColor.xyz));
  (u_xlat16_14.xyz = ((u_xlat16_15.xyz * _ES_HeightLerpTopColor.www) + u_xlat16_14.xyz));
  (u_xlat16_14.xyz = clamp(u_xlat16_14.xyz, 0.0, 1.0));

  (u_xlat16_12.xyz = (u_xlat16_12.xyz * u_xlat16_14.xyz));
  (u_xlat16_12.xyz = (u_xlat16_12.xyz + u_xlat16_12.xyz));
debugColor = u_xlat16_12.xyz;

  //u_xlat16_87 = 1
  (u_xlat16_87 = (_mBloomIntensity + 1.0));
  (u_xlat16_12.xyz = (vec3(u_xlat16_87) * u_xlat16_12.xyz));
  (u_xlat16_87 = (((-_GlobalOneMinusAvatarIntensityEnable) * _GlobalOneMinusAvatarIntensity) + 1.0));
  (u_xlat16_12.xyz = (vec3(u_xlat16_87) * u_xlat16_12.xyz));
  (u_xlat16_87 = (((-_OneMinusGlobalMainIntensityEnable) * _OneMinusGlobalMainIntensity) + 1.0));
  //u_xlat16_87 = 1

  (u_xlat16_14.xyz = (vec3(u_xlat16_87) * u_xlat16_12.xyz));


  //Fog---------------------------------------------------
  (u_xlat1.xyz = (vs_TEXCOORD3.xyz + (-_WorldSpaceCameraPos.xyz)));
  (u_xlat75 = dot(u_xlat1.xyz, u_xlat1.xyz));
  (u_xlat75 = sqrt(u_xlat75));
  (u_xlat16_1.xz = vec2(_ES_FogNear, _ES_FogDensity));
  (u_xlat16_1.yw = vec2(_ES_HeightFogFogNear, _ES_HeightFogDensity));
  (u_xlat16_15.x = _ES_FogFar);
  (u_xlat16_15.y = _ES_HeightFogFogFar);
  (u_xlat16_65.xy = ((-u_xlat16_1.xy) + u_xlat16_15.xy));
  (u_xlat16_65.xy = ((vec2(vec2(_ES_FogCharacterNearFactor, _ES_FogCharacterNearFactor)) * u_xlat16_65.xy) + u_xlat16_1.xy));
  (u_xlat16_16.xy = (vec2(u_xlat75) + (-u_xlat16_65.xy)));
  (u_xlat16_15.xy = ((-u_xlat16_65.xy) + u_xlat16_15.xy));
  (u_xlat16_15.xy = (u_xlat16_16.xy / u_xlat16_15.xy));
  (u_xlat16_15.xy = clamp(u_xlat16_15.xy, 0.0, 1.0));
  (u_xlat16_15.xy = (u_xlat16_1.zw * u_xlat16_15.xy));
  (u_xlat16_65.xy = (((-u_xlat16_15.xy) * u_xlat16_15.xy) + u_xlat16_15.xy));
  (u_xlat16_1.xy = ((u_xlat16_15.xy * u_xlat16_65.xy) + u_xlat16_15.xy));
  (u_xlat16_89 = dot(vs_TEXCOORD3.xyz, hlslcc_mtx4x4_ES_GlobalRotMatrix[3].xyz));
  (u_xlat16_89 = (u_xlat16_89 + (-hlslcc_mtx4x4_ES_GlobalRotMatrix[3].w)));
  (u_xlatb75 = (0.0 < _ES_HeightFogRange));
  (u_xlat16_15.x = (u_xlat16_89 + (-_ES_HeightFogBaseHeight)));
  (u_xlat16_89 = ((-u_xlat16_89) + _ES_HeightFogBaseHeight));
  (u_xlat16_89 = ((u_xlatb75) ? (u_xlat16_15.x) : (u_xlat16_89)));
  (u_xlat16_15.x = (abs(_ES_HeightFogRange) + 1.0));
  (u_xlat16_89 = max(u_xlat16_89, 0.0));
  (u_xlat16_89 = (u_xlat16_89 / u_xlat16_15.x));
  (u_xlat16_89 = min(u_xlat16_89, 1.0));
  (u_xlat16_89 = ((-u_xlat16_89) + 1.0));
  (u_xlat16_15.x = ((u_xlat16_89 * _ES_HeightFogDensity) + -1.0));
  (u_xlat16_15.x = clamp(u_xlat16_15.x, 0.0, 1.0));
  (u_xlat16_1.z = ((_ES_TransitionRate * 0.125) + _ES_FogColor));
  (u_xlat16_3.xyz = textureLod(_ES_GradientAtlas, u_xlat16_1.xz, 0.0).xyz);
  (u_xlat16_40.x = (_ES_FogDensity + -1.0));
  (u_xlat16_40.x = clamp(u_xlat16_40.x, 0.0, 1.0));
  (u_xlat16_65.xy = u_xlat16_1.xy);
  (u_xlat16_65.xy = clamp(u_xlat16_65.xy, 0.0, 1.0));
  (u_xlat16_16.xyz = ((u_xlat16_3.xyz * u_xlat16_65.xxx) + (-u_xlat16_14.xyz)));
  (u_xlat16_16.xyz = ((u_xlat16_65.xxx * u_xlat16_16.xyz) + u_xlat16_14.xyz));
  (u_xlat16_17.xyz = ((u_xlat16_3.xyz * u_xlat16_65.xxx) + u_xlat16_16.xyz));
  (u_xlat16_16.xyz = ((u_xlat16_17.xyz * u_xlat16_40.xxx) + u_xlat16_16.xyz));
  (u_xlat16_1.w = ((_ES_TransitionRate * 0.125) + _ES_HeightFogColor));
  (u_xlat16_3.xyz = textureLod(_ES_GradientAtlas, u_xlat16_1.yw, 0.0).xyz);
  (u_xlat16_17.xyz = (vec3(u_xlat16_89) * u_xlat16_3.xyz));
  (u_xlat16_18.xyz = ((u_xlat16_17.xyz * u_xlat16_65.yyy) + (-u_xlat16_16.xyz)));
  (u_xlat16_18.xyz = ((u_xlat16_65.yyy * u_xlat16_18.xyz) + u_xlat16_16.xyz));
  (u_xlat16_17.xyz = ((u_xlat16_17.xyz * u_xlat16_65.yyy) + u_xlat16_18.xyz));
  (u_xlat16_15.xyz = ((u_xlat16_17.xyz * u_xlat16_15.xxx) + u_xlat16_18.xyz));
  (u_xlat16_91 = max(u_xlat16_3.z, u_xlat16_3.y));
  (u_xlat16_91 = max(u_xlat16_3.x, u_xlat16_91));
  (u_xlat16_17.xyz = (vec3(u_xlat16_89) * u_xlat16_15.xyz));
  (u_xlat16_17.xyz = ((u_xlat16_17.xyz * u_xlat16_65.yyy) + u_xlat16_16.xyz));
  (u_xlat16_15.xyz = ((-u_xlat16_16.xyz) + u_xlat16_15.xyz));
  (u_xlat16_15.xyz = ((vec3(u_xlat16_89) * u_xlat16_15.xyz) + u_xlat16_16.xyz));
  (u_xlat16_89 = ((_ES_HeightFogAddAjust * (-u_xlat16_91)) + u_xlat16_91));
  (u_xlat16_16.xyz = ((-u_xlat16_15.xyz) + u_xlat16_17.xyz));
  (u_xlat16_15.xyz = ((vec3(u_xlat16_89) * u_xlat16_16.xyz) + u_xlat16_15.xyz));
  (u_xlat16_12.xyz = (((-u_xlat16_12.xyz) * vec3(u_xlat16_87)) + u_xlat16_15.xyz));
//--------------------------------------------------------------------------------------------

  //final color------------------------------------------------------------------
  (SV_Target0.xyz = ((vec3(u_xlat16_87) * u_xlat16_12.xyz) + u_xlat16_14.xyz));
SV_Target0.xyz = debugColor;

  (u_xlat75 = dot(vec3(1.0, 1.0, 1.0), abs(vs_TEXCOORD4.xyz)));
  (u_xlat3.xy = (vs_TEXCOORD4.xy / vec2(u_xlat75)));
  (u_xlatb75 = (0.0 >= vs_TEXCOORD4.z));
  (u_xlat53.xy = ((-abs(u_xlat3.yx)) + vec2(1.0, 1.0)));
  (u_xlatb9.xy = greaterThanEqual(u_xlat3.xyxx, vec4(0.0, 0.0, 0.0, 0.0)).xy);
  (u_xlat9.x = ((u_xlatb9.x) ? (1.0) : (-1.0)));
  (u_xlat9.y = ((u_xlatb9.y) ? (1.0) : (-1.0)));
  (u_xlat53.xy = (u_xlat53.xy * u_xlat9.xy));
  (u_xlat3.xy = ((bool(u_xlatb75)) ? (u_xlat53.xy) : (u_xlat3.xy)));
  (u_xlat1.xy = ((u_xlat3.xy * vec2(0.5, 0.5)) + vec2(0.5, 0.5)));
  (u_xlat16_12.x = ((u_xlat16_0.z * 127.0) + 128.0));
  (u_xlat50 = trunc(u_xlat16_12.x));
  (u_xlat1.z = (u_xlat50 * 0.0039215689));
  (SV_Target0.w = u_xlat16_0.x);
  (u_xlat1.w = u_xlat16_0.y);
  (SV_Target1 = u_xlat1);
  (SV_Target2 = hlslcc_FragCoord.z);
  return ;
}
