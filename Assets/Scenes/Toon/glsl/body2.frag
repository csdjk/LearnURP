#version 450
uniform vec4 _MainLightPosition;
uniform vec4 _MainLightColor;
uniform vec2 _DisableCharacterLocalLight;
uniform vec4 _CharacterLocalMainLightPosition;
uniform vec4 _CharacterLocalMainLightColor;
uniform vec4 _CharacterLocalMainLightColor1;
uniform vec4 _NewLocalLightDir;
uniform vec4 _NewLocalLightCharCenter;
uniform vec4 _NewLocalLightStrength;
uniform vec3 _WorldSpaceCameraPos;
uniform vec4 _ProjectionParams;
uniform vec4 _ZBufferParams;
uniform vec4 _CustomMainLightDir;
uniform vec3 _ES_MonsterLightDir;
uniform float _OneMinusGlobalMainIntensity;
uniform float _ES_Indoor;
uniform float _ES_TransitionRate;
uniform vec4 hlslcc_mtx4x4_ES_GlobalRotMatrix[4];
uniform float _ES_CharacterDisableLocalMainLight;
uniform vec4 _ES_AddColor;
uniform vec4 _ES_SPColor;
uniform float _ES_SPIntensity;
uniform float _ES_CharacterShadowFactor;
uniform float _ES_HeightLerpTop;
uniform float _ES_HeightLerpBottom;
uniform vec4 _ES_HeightLerpTopColor;
uniform vec4 _ES_HeightLerpMiddleColor;
uniform vec4 _ES_HeightLerpBottomColor;
uniform vec2 _ES_RimLightOffset;
uniform float _ES_RimLightWidth;
uniform float _ES_RimLightIntensity;
uniform float _ES_RimLightAddMode;
uniform vec4 _ES_RimLightColor;
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
    float _RimEdgeSoftness0;
    float _RimType0;
    float _RimDark0;
    vec3 Xhlslcc_UnusedX_RimShadowColor;
    float Xhlslcc_UnusedX_RimShadowCt;
    float Xhlslcc_UnusedX_RimShadowIntensity;
    float Xhlslcc_UnusedX_RimShadowWidth;
    float Xhlslcc_UnusedX_RimShadowFeather;
    vec4 Xhlslcc_UnusedX_RimShadowColor0;
    float Xhlslcc_UnusedX_RimShadowWidth0;
    float Xhlslcc_UnusedX_RimShadowFeather0;
    vec3 Xhlslcc_UnusedX_RimShadowOffset;
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
    int _UsingDitherAlpha;
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
    float _RimEdge;
    float Xhlslcc_UnusedX_RimFeatherWidth;
    float _RimLightMode;
    vec4 Xhlslcc_UnusedX_RimColor;
    vec4 Xhlslcc_UnusedX_RimOffset;
    vec4 _RimColor0;
    float _Rimintensity;
    float _RimWidth;
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
layout(location = 0) uniform sampler2D _MainTex;
layout(location = 1) uniform sampler2D _LightMap;
layout(location = 2) uniform sampler2D _MaterialValuesPackLUT;
layout(location = 3) uniform sampler2D _ScreenSpaceShadowmapTexture;
layout(location = 4) uniform sampler2D _ES_GradientAtlas;
layout(location = 5) uniform sampler2D _GBufferA;
layout(location = 6) uniform sampler2D _DepthBufferOrCopy;
in vec4 vs_TEXCOORD0;
in vec4 vs_TEXCOORD1;
in vec3 vs_TEXCOORD2;
in vec3 vs_TEXCOORD3;
in vec4 vs_TEXCOORD4;
layout(location = 0) out vec4 SV_Target0;
vec4 u_xlat0;
vec4 u_xlat16_0;
uvec4 u_xlatu0;
bool u_xlatb0;
vec3 u_xlat10_1;
vec3 u_xlat2;
vec4 u_xlat16_2;
uvec4 u_xlatu2;
vec3 u_xlat3;
vec4 u_xlat16_3;
uvec4 u_xlatu3;
vec4 u_xlat4;
vec3 u_xlat16_5;
vec4 u_xlat16_6;
vec3 u_xlat16_7;
vec3 u_xlat16_8;
vec3 u_xlat9;
uvec4 u_xlatu9;
vec3 u_xlat10;
vec3 u_xlat16_11;
vec3 u_xlat16_12;
float u_xlat13;
vec3 u_xlat15;
float u_xlat16_16;
vec3 u_xlat16_18;
vec3 u_xlat16_19;
float u_xlat16_20;
vec2 u_xlat26;
float u_xlat10_26;
bool u_xlatb26;
float u_xlat28;
float u_xlat16_31;
float u_xlat16_32;
vec2 u_xlat16_33;
float u_xlat39;
int u_xlati39;
bool u_xlatb39;
float u_xlat40;
bool u_xlatb40;
float u_xlat41;
float u_xlat16_44;
float u_xlat16_45;
float u_xlat16_46;
float u_xlat16_47;
void main(){
    vec3 debugColor = vec3(0.0, 0.0, 0.0);

    (u_xlat0.xy = (vs_TEXCOORD1.xy / vs_TEXCOORD1.ww));
//
    (u_xlat10_1.xyz = texture(_GBufferA, u_xlat0.xy).xyz);
    (u_xlat16_2 = texture(_LightMap, vs_TEXCOORD0.xy));
    (u_xlat16_3 = texture(_MainTex, vs_TEXCOORD0.xy));

    (u_xlat4 = (u_xlat16_3 * _Color));
    //----tag:ramp level--------------------
    (u_xlat16_5.x = (u_xlat16_2.w * 8.0));
    (u_xlat16_5.x = floor(u_xlat16_5.x));
    (u_xlat16_18.x = (u_xlat16_5.x * 8.0));
    (u_xlatb26 = (u_xlat16_18.x >= (-u_xlat16_18.x)));
    (u_xlat16_18.xy = ((bool(u_xlatb26)) ? (vec2(8.0, 0.125)) : (vec2(-8.0, -0.125))));
    (u_xlat16_5.x = (u_xlat16_18.y * u_xlat16_5.x));
    (u_xlat16_5.x = fract(u_xlat16_5.x));
    (u_xlat16_5.x = (u_xlat16_5.x * u_xlat16_18.x));
    //----tag:ramp level--------------------


    (u_xlatb26 = (_ES_Indoor < 0.5));
    //tag:u_xlatb26 = true
    if (u_xlatb26)
    {
        (u_xlat3.xyz = (vs_TEXCOORD1.xyw / vs_TEXCOORD1.www));
        (u_xlat26.xy = (u_xlat3.xy / u_xlat3.zz));
        (u_xlat10_26 = texture(_ScreenSpaceShadowmapTexture, u_xlat26.xy).x);
        //u_xlat26.xy == screenUV
        (u_xlat16_18.x = u_xlat10_26);

    }
    else
    {
        (u_xlat16_18.x = 1.0);
    }

    (u_xlat16_31 = ((-u_xlat16_18.x) + 1.0));
    (u_xlat16_18.x = ((_ES_CharacterShadowFactor * u_xlat16_31) + u_xlat16_18.x));
    (u_xlatb26 = (0.5 < _ES_CharacterDisableLocalMainLight));
    (u_xlat39 = ((-u_xlat16_18.x) + 1.0));
    (u_xlat39 = ((_CharacterLocalMainLightPosition.w * u_xlat39) + u_xlat16_18.x));
    //u_xlat26.x == screenShadow
    (u_xlat26.x = ((u_xlatb26) ? (u_xlat16_18.x) : (u_xlat39)));

    (u_xlat16_18.x = (_ES_CharacterDisableLocalMainLight + 1.0));
    (u_xlat16_18.x = (u_xlat16_18.x + (-abs(_DisableCharacterLocalLight.x))));
    (u_xlatb39 = (0.5 < u_xlat16_18.x));
    //u_xlatb39 = true

    (u_xlat3.xyz = ((bool(u_xlatb39)) ? (_MainLightPosition.xyz) : (_CharacterLocalMainLightPosition.xyz)));
    (u_xlatb40 = (0.5 < _IsMonster));
    //u_xlatb40 = false
    //u_xlat3 = _MainLightPosition
    (u_xlat16_18.xyz = ((bool(u_xlatb40)) ? (_ES_MonsterLightDir.xyz) : (u_xlat3.xyz)));
    (u_xlat16_6.xyz = ((-u_xlat16_18.xyz) + _CustomMainLightDir.xyz));
    (u_xlat16_18.xyz = ((_CustomMainLightDir.www * u_xlat16_6.xyz) + u_xlat16_18.xyz));

    (u_xlat16_18.xyz = ((bool(u_xlatb40)) ? (_ES_MonsterLightDir.xyz) : (u_xlat16_18.xyz)));
    (u_xlat3.xyz = ((bool(u_xlatb39)) ? (_MainLightColor.xyz) : (_CharacterLocalMainLightColor.xyz)));
    //vs_TEXCOORD4.xyz = viewDirWS
    //Normalized viewDirWS
    (u_xlat16_6.x = dot(vs_TEXCOORD4.xyz, vs_TEXCOORD4.xyz));
    (u_xlat16_6.x = inversesqrt(u_xlat16_6.x));
    (u_xlat16_19.xyz = (u_xlat16_6.xxx * vs_TEXCOORD4.xyz));
    //-----------------
    //u_xlat16_18 = _MainLightDir
    //u_xlat16_7.xyz = HalfVector

    (u_xlat16_7.xyz = ((vs_TEXCOORD4.xyz * u_xlat16_6.xxx) + u_xlat16_18.xyz));
    //Normalized HalfVector
    (u_xlat16_6.x = dot(u_xlat16_7.xyz, u_xlat16_7.xyz));
    (u_xlat16_6.x = inversesqrt(u_xlat16_6.x));
    (u_xlat16_7.xyz = (u_xlat16_6.xxx * u_xlat16_7.xyz));
    //-----------------

    //Normalized Normal
    (u_xlat16_6.x = dot(vs_TEXCOORD3.xyz, vs_TEXCOORD3.xyz));
    (u_xlat16_6.x = inversesqrt(u_xlat16_6.x));
    (u_xlat16_8.xyz = (u_xlat16_6.xxx * vs_TEXCOORD3.xyz));
    //-----------------

    (u_xlat16_6.x = (((((gl_FrontFacing) ? (4294967295u) : (0u)) != 0u)) ? (1.0) : (-1.0)));
    (u_xlat16_8.xyz = (u_xlat16_6.xxx * u_xlat16_8.xyz));
    //u_xlat16_6 = NdotV
    (u_xlat16_6.x = dot(u_xlat16_8.xyz, u_xlat16_19.xyz));
    //_TestMatIDLUTEnabled = 0
    //_UseMaterialValuesLUT = 1
    (u_xlati39 = ((-_TestMatIDLUTEnabled) + 1));
    (u_xlati39 = (u_xlati39 * _UseMaterialValuesLUT));
    //tag:u_xlati39 >= 1
    if ((u_xlati39 != 0))
    {
        (u_xlatu9.x = uint(int(u_xlat16_5.x)));
        (u_xlatu9.y = 1u);
        (u_xlatu9.z = 0u);
        (u_xlatu9.w = 0u);
        (u_xlat10.xyz = texelFetch(_MaterialValuesPackLUT, ivec2(u_xlatu9.xw), int(u_xlatu9.w)).xyz);
        (u_xlat9.xyz = texelFetch(_MaterialValuesPackLUT, ivec2(u_xlatu9.xy), int(u_xlatu9.w)).xyz);
        (u_xlat16_11.xyz = u_xlat10.xyz);

        (u_xlat16_32 = u_xlat9.y);
        (u_xlat16_46 = u_xlat9.z);
        (u_xlat16_47 = u_xlat9.x);

        // (u_xlat9.xyz = texelFetch(_MaterialValuesPackLUT, ivec2(u_xlatu9.x,1), int(u_xlatu9.w)).xyz);
        // debugColor = u_xlat9.xxx*0.1;
    }
    else
    {
        (u_xlat16_11.xyz = _SpecularColor0.xyz);
        (u_xlat16_32 = _SpecularRoughness0);
        (u_xlat16_46 = _SpecularIntensity0);
        (u_xlat16_47 = _SpecularShininess0);
    }

    //Specular?
    (u_xlat16_12.xyz = (_ES_SPColor.xyz + vec3(-1.0, -1.0, -1.0)));
    (u_xlat16_12.xyz = ((_ES_SPColor.www * u_xlat16_12.xyz) + vec3(1.0, 1.0, 1.0)));
    (u_xlat16_12.xyz = (u_xlat16_12.xyz * vec3(_ES_SPIntensity)));
    (u_xlat16_11.xyz = (u_xlat16_11.xyz * u_xlat16_12.xyz));

    //u_xlat16_8 = Normal, u_xlat16_7 = HalfVector
    //u_xlat16_7.x = NdotH
    (u_xlat16_7.x = dot(u_xlat16_8.xyz, u_xlat16_7.xyz));
    //Specular pow(x,u_xlat16_47)
    (u_xlat16_7.x = max(u_xlat16_7.x, 0.0099999998));
    (u_xlat16_7.x = log2(u_xlat16_7.x));
    (u_xlat16_7.x = (u_xlat16_7.x * u_xlat16_47));
    (u_xlat16_7.x = exp2(u_xlat16_7.x));
    //-----------------

    //u_xlat16_32 = PackLUT.y = _SpecularRoughness0
    (u_xlat16_32 = max(u_xlat16_32, 0.001));
    //u_xlat16_2 = LightMap, u_xlat16_3 = MainTex, u_xlat4 = Albedo
    //invMaskZ
    (u_xlat16_20 = ((-u_xlat16_2.z) + 1.0));
    //u_xlat16_32 = = PackLUT.x
    //u_xlat16_32 = PackLUT.y = _SpecularRoughness0

    (u_xlat16_33.x = ((-u_xlat16_32) + u_xlat16_20));
    (u_xlat16_32 = (u_xlat16_32 + u_xlat16_20));
    //u_xlat26.x == screenShadow
//    specular = smoothstep(u_xlat16_33, u_xlat16_32, u_xlat26.x * u_xlat16_7.);
    (u_xlat16_32 = ((-u_xlat16_33.x) + u_xlat16_32));
    (u_xlat16_7.x = ((u_xlat26.x * u_xlat16_7.x) + (-u_xlat16_33.x)));
    (u_xlat16_32 = (1.0 / u_xlat16_32));
    (u_xlat16_32 = (u_xlat16_32 * u_xlat16_7.x));
    (u_xlat16_32 = clamp(u_xlat16_32, 0.0, 1.0));
    (u_xlat16_7.x = ((u_xlat16_32 * -2.0) + 3.0));
    (u_xlat16_32 = (u_xlat16_32 * u_xlat16_32));
    (u_xlat16_32 = (u_xlat16_32 * u_xlat16_7.x));
    //-----------------
    //u_xlat16_11 = SpecularColor
    (u_xlat16_7.xyz = (u_xlat16_11.xyz * vec3(u_xlat16_32)));
    //u_xlat16_46 = PackLUT.z = _SpecularIntensity0
    (u_xlat16_7.xyz = (vec3(u_xlat16_46) * u_xlat16_7.xyz));
    //u_xlat16_7 = Specular

    //Emission-----------
    //u_xlat4 = Albedo
    (u_xlatb40 = (_EmissionThreshold < u_xlat4.w));
    //u_xlat16_3 = baseMap
    (u_xlat16_32 = ((u_xlat16_3.w * _Color.w) + (-_EmissionThreshold)));
    (u_xlat16_46 = ((-_EmissionThreshold) + 1.0));
    (u_xlat16_46 = max(u_xlat16_46, 0.001));
    (u_xlat28 = (u_xlat16_32 / u_xlat16_46));
    (u_xlat28 = clamp(u_xlat28, 0.0, 1.0));
    (u_xlat16_32 = ((u_xlatb40) ? (u_xlat28) : (0.0)));
    //u_xlat10_1 = GBufferA, u_xlat4 = Albedo
    //lerp()
    (u_xlat16_11.xyz = ((u_xlat4.xyz * vec3(vec3(_EmissionIntensity, _EmissionIntensity, _EmissionIntensity))) + (-u_xlat10_1.xyz)));
    (u_xlat16_11.xyz = ((vec3(u_xlat16_32) * u_xlat16_11.xyz) + u_xlat10_1.xyz));
    //-----------------

    //Fresnel------------------
    //u_xlat16_6 = NdotV
    (u_xlat16_32 = ((-abs(u_xlat16_6.x)) + 1.0));
    (u_xlat16_32 = (u_xlat16_32 + (-_FresnelBSI.x)));
    (u_xlat16_46 = (1.0 / _FresnelBSI.y));
    (u_xlat16_32 = (u_xlat16_32 * u_xlat16_46));
    (u_xlat16_32 = clamp(u_xlat16_32, 0.0, 1.0));
    (u_xlat16_12.xyz = (vec3(u_xlat16_32) * _FresnelColor.xyz));
    (u_xlat16_12.xyz = (u_xlat16_12.xyz * vec3(vec3(_FresnelColorStrength, _FresnelColorStrength, _FresnelColorStrength))));
    (u_xlat16_12.xyz = max(u_xlat16_12.xyz, vec3(0.0, 0.0, 0.0)));
    // debugColor = u_xlat16_12.xyz;
    //------------------
    //u_xlat16_7 = Specular, u_xlat4 = albedo, u_xlat16_11 = Emission
    (u_xlat16_7.xyz = ((u_xlat16_7.xyz * u_xlat4.xyz) + u_xlat16_11.xyz));
    //u_xlat3 = MainLightColor
    (u_xlat16_7.xyz = ((u_xlat16_7.xyz * u_xlat3.xyz) + u_xlat16_12.xyz));


    (u_xlat16_7.xyz = ((_ES_AddColor.xyz * u_xlat4.xyz) + u_xlat16_7.xyz));

    (u_xlatb40 = (_UsingDitherAlpha < 1));
    //猜测是Depth Rim Light
    if (u_xlatb40)
    {
        (u_xlat16_32 = (u_xlat16_2.x + -1.0));
        (u_xlat16_32 = ((_RimLightMode * u_xlat16_32) + 1.0));
        (u_xlat16_32 = (u_xlat16_32 * _RimWidth));
        //u_xlat16_18.x = NdotL
        (u_xlat16_18.x = dot(u_xlat16_8.xyz, u_xlat16_18.xyz));

        (u_xlat16_31 = (u_xlat16_2.y + u_xlat16_2.y));
        //u_xlat16_19 = viewDirWS
        //u_xlat16_8 = Normal
        (u_xlat16_44 = (u_xlat16_19.x * u_xlat16_8.z));
        (u_xlat16_44 = ((u_xlat16_19.z * u_xlat16_8.x) + (-u_xlat16_44)));
        (u_xlatb40 = (0.0 < u_xlat16_44));
        (u_xlat16_44 = ((u_xlatb40) ? (-1.0) : (1.0)));
        //u_xlat16_44 = sign(viewDirWS.x * Normal.z - viewDirWS.z * Normal.x)
        //u_xlat16_44 根据视角对半mask
//        debugColor = u_xlat16_44.xxx;

        (u_xlat16_18.x = ((u_xlat16_18.x * 0.5) + 0.5));
        (u_xlat16_18.x = clamp(u_xlat16_18.x, 0.0, 1.0));

        (u_xlat16_18.x = dot(u_xlat16_18.xx, vec2(u_xlat16_31)));
        (u_xlat16_18.x = (u_xlat26.x * u_xlat16_18.x));
        (u_xlat40 = textureLod(_DepthBufferOrCopy, u_xlat0.xy, 0.0).x);
        if ((u_xlati39 != 0))
        {
            (u_xlatu2.x = uint(int(u_xlat16_5.x)));
            (u_xlatu2.y = 3u);
            (u_xlatu2.z = 0u);
            (u_xlatu2.w = 0u);
            (u_xlat2.xyz = texelFetch(_MaterialValuesPackLUT, ivec2(u_xlatu2.xy), int(u_xlatu2.w)).xyz);
            (u_xlat16_11.xyz = u_xlat2.xyz);
        }
        else
        {
            (u_xlat16_11.xyz = _RimColor0.xyz);
        }
        (u_xlat16_12.xyz = (_ES_RimLightColor.www * _ES_RimLightColor.xyz));
        (u_xlat16_11.xyz = (u_xlat16_11.xyz * u_xlat16_12.xyz));
        (u_xlat16_11.xyz = (u_xlat16_11.xyz * vec3(vec3(_ES_RimLightIntensity, _ES_RimLightIntensity, _ES_RimLightIntensity))));
        (u_xlat16_12.xyz = (u_xlat16_11.xyz * vec3(0.5, 0.5, 0.5)));
        (u_xlat2.xyz = (vs_TEXCOORD2.xyz + (-_NewLocalLightCharCenter.xyz)));
        (u_xlat41 = dot(u_xlat2.xyz, u_xlat2.xyz));
        (u_xlat41 = inversesqrt(u_xlat41));
        (u_xlat2.xyz = (vec3(u_xlat41) * u_xlat2.xyz));
        (u_xlat2.x = dot(u_xlat2.xyz, _NewLocalLightDir.xyz));
        (u_xlat15.x = dot(u_xlat16_8.xyz, _NewLocalLightDir.xyz));
        (u_xlat16_31 = (u_xlat15.x + 0.5));
        (u_xlat16_31 = (u_xlat16_31 * 0.66666669));
        (u_xlat16_31 = clamp(u_xlat16_31, 0.0, 1.0));
        (u_xlat16_19.x = ((u_xlat16_31 * -2.0) + 3.0));
        (u_xlat16_31 = (u_xlat16_31 * u_xlat16_31));
        (u_xlat16_31 = (u_xlat16_31 * u_xlat16_19.x));
        (u_xlat16_19.x = ((u_xlat2.x * 0.5) + 0.5));
        (u_xlat2.x = ((-_CharacterLocalMainLightColor1.w) + 1.0));
        (u_xlat2.x = (u_xlat16_31 * u_xlat2.x));
        (u_xlat2.x = ((_CharacterLocalMainLightColor1.w * u_xlat16_19.x) + u_xlat2.x));
        (u_xlat2.x = (u_xlat2.x * _NewLocalLightStrength.x));
        (u_xlat2.x = clamp(u_xlat2.x, 0.0, 1.0));
        (u_xlat2.x = (u_xlat2.x * 0.30000001));
        (u_xlat15.xyz = (((-u_xlat16_11.xyz) * vec3(0.5, 0.5, 0.5)) + _CharacterLocalMainLightColor1.xyz));
        (u_xlat2.xyz = ((u_xlat2.xxx * u_xlat15.xyz) + u_xlat16_12.xyz));
    debugColor = u_xlat2.xyz;

        (u_xlat16_18.x = (u_xlat26.x * u_xlat16_18.x));

        //Linear01Depth(u_xlat40)
        (u_xlat26.x = ((_ZBufferParams.x * u_xlat40) + _ZBufferParams.y));
        (u_xlat26.x = (1.0 / u_xlat26.x));

        (u_xlat16_31 = (u_xlat16_32 * _ES_RimLightWidth));

//        debugColor = u_xlat16_31.xxx;

        (u_xlat16_31 = (u_xlat16_44 * u_xlat16_31));
        (u_xlat16_31 = (u_xlat16_31 * 0.0055));
        (u_xlat40 = ((u_xlat26.x * _ProjectionParams.z) + 3.0));
        (u_xlat40 = (u_xlat16_31 / u_xlat40));
        (u_xlat40 = ((_ES_RimLightOffset.x * 0.0099999998) + u_xlat40));
        (u_xlat3.x = (u_xlat0.x + u_xlat40));
        (u_xlat16_16 = ((_ES_RimLightOffset.y * 0.0099999998) + u_xlat0.y));
        (u_xlat3.y = u_xlat16_16);
        (u_xlat0.x = textureLod(_DepthBufferOrCopy, u_xlat3.xy, 0.0).x);
        (u_xlat0.x = ((_ZBufferParams.x * u_xlat0.x) + _ZBufferParams.y));
        (u_xlat0.x = (1.0 / u_xlat0.x));
        (u_xlat16_31 = ((-u_xlat26.x) + u_xlat0.x));
        (u_xlat16_31 = max(u_xlat16_31, 1e-06));
        (u_xlat16_31 = log2(u_xlat16_31));
        (u_xlat16_31 = (u_xlat16_31 * _RimEdge));
        (u_xlat16_31 = exp2(u_xlat16_31));

        if ((u_xlati39 != 0))
        {
            (u_xlatu3.x = uint(int(u_xlat16_5.x)));
            (u_xlatu3.y = 4u);
            (u_xlatu3.z = 0u);
            (u_xlatu3.w = 0u);
            (u_xlat0.xyz = texelFetch(_MaterialValuesPackLUT, ivec2(u_xlatu3.xy), int(u_xlatu3.w)).xyz);
            //边缘光平滑值
            (u_xlat16_44 = u_xlat0.y);
            (u_xlat16_19.xy = u_xlat0.xz);
        }
        else
        {
            (u_xlat16_44 = _RimEdgeSoftness0);
            (u_xlat16_19.xy = vec2(_RimType0, _RimDark0));
        }
        (u_xlat16_18.x = ((u_xlat16_18.x * u_xlat16_19.y) + (-u_xlat16_19.y)));
        (u_xlat16_18.x = (u_xlat16_18.x + 1.0));
        (u_xlat16_6.x = ((-u_xlat16_6.x) + 1.0));
        (u_xlat16_31 = (u_xlat16_31 + -0.81999999));
        (u_xlat16_31 = (u_xlat16_31 * 12.500003));

        (u_xlat16_31 = clamp(u_xlat16_31, 0.0, 1.0));
        (u_xlat16_45 = ((u_xlat16_31 * -2.0) + 3.0));
        (u_xlat16_31 = (u_xlat16_31 * u_xlat16_31));
        (u_xlat16_31 = (u_xlat16_31 * u_xlat16_45));

    // debugColor = u_xlat16_31.xxx;
        (u_xlatb0 = (u_xlat16_44 < u_xlat16_31));
        (u_xlat16_31 = ((u_xlatb0) ? (u_xlat16_31) : (0.0)));
        (u_xlat16_8.xyz = (u_xlat2.xyz * vec3(u_xlat16_31)));
    // debugColor = u_xlat16_8.xyz;

        (u_xlat16_11.xyz = (u_xlat16_8.xyz * vec3(_Rimintensity)));
        (u_xlat16_31 = dot(u_xlat16_11.xyz, vec3(0.212671, 0.71516001, 0.072168998)));
        (u_xlat16_31 = (u_xlat16_6.x * u_xlat16_31));
        (u_xlat16_18.x = (u_xlat16_18.x * u_xlat16_31));
        (u_xlat16_18.x = clamp(u_xlat16_18.x, 0.0, 1.0));
        // lerp(u_xlat16_7.xyz,u_xlat16_8.xyz*_Rimintensity,u_xlat16_18.x)
        (u_xlat16_12.xyz = ((u_xlat16_8.xyz * vec3(_Rimintensity)) + (-u_xlat16_7.xyz)));
        (u_xlat16_12.xyz = ((u_xlat16_18.xxx * u_xlat16_12.xyz) + u_xlat16_7.xyz));
    debugColor =u_xlat16_12.xyz;

        (u_xlat16_11.xyz = ((u_xlat16_11.xyz * vec3(vec3(_ES_RimLightAddMode, _ES_RimLightAddMode, _ES_RimLightAddMode))) + u_xlat16_12.xyz));
        (u_xlat16_31 = max(u_xlat16_6.x, 0.001));
        (u_xlat16_31 = log2(u_xlat16_31));
        (u_xlat16_31 = (u_xlat16_31 * u_xlat16_19.y));
        (u_xlat16_31 = exp2(u_xlat16_31));
        (u_xlat16_31 = (u_xlat16_31 + 1.0));

        (u_xlat16_6.xzw = max(u_xlat16_7.xyz, vec3(0.001, 0.001, 0.001)));
        (u_xlat16_6.xzw = log2(u_xlat16_6.xzw));
        (u_xlat16_6.xzw = (vec3(u_xlat16_31) * u_xlat16_6.xzw));
        (u_xlat16_6.xzw = exp2(u_xlat16_6.xzw));

    // debugColor = u_xlat16_18.xxx;
    // debugColor = u_xlat16_6.xzw;
    // debugColor = u_xlat16_8.xyz * _Rimintensity;
        //u_xlat16_8 = RimLight
        // u_xlat16_18.xyz=lerp(u_xlat16_6.xzw,u_xlat16_8.xyz * _Rimintensity,u_xlat16_18.x)
        (u_xlat16_8.xyz = ((u_xlat16_8.xyz * vec3(_Rimintensity)) + (-u_xlat16_6.xzw)));
        (u_xlat16_18.xyz = ((u_xlat16_18.xxx * u_xlat16_8.xyz) + u_xlat16_6.xzw));
    // debugColor = u_xlat16_11.xyz;

        //u_xlat16_7.xyz = lerp(u_xlat16_18.xyz,u_xlat16_11.xyz,u_xlat16_19.x)
        (u_xlat16_6.xzw = ((-u_xlat16_18.xyz) + u_xlat16_11.xyz));
        (u_xlat16_7.xyz = ((u_xlat16_19.xxx * u_xlat16_6.xzw) + u_xlat16_18.xyz));

    }

    //上下渐变--------------------------
    //1-smoothstep(_CharaWorldSpaceOffset.y,u_xlat16_18.x+_CharaWorldSpaceOffset.y,vs_TEXCOORD2.y)
    (u_xlat0.x = (vs_TEXCOORD2.y + (-_CharaWorldSpaceOffset.y)));
    (u_xlat16_18.x = max(_ES_HeightLerpBottom, 0.001));
    (u_xlat13 = (1.0 / u_xlat16_18.x));
    (u_xlat13 = (u_xlat13 * u_xlat0.x));
    (u_xlat13 = clamp(u_xlat13, 0.0, 1.0));
    (u_xlat26.x = ((u_xlat13 * -2.0) + 3.0));
    (u_xlat13 = (u_xlat13 * u_xlat13));
    (u_xlat13 = (((-u_xlat26.x) * u_xlat13) + 1.0));
    //u_xlat13 = 从上到下渐变mask(0-1)
//    debugColor = vs_TEXCOORD2.yyy;

    //-----------------
    (u_xlat0.x = (u_xlat0.x + (-_ES_HeightLerpTop)));
    (u_xlat0.x = (u_xlat0.x + u_xlat0.x));

    //smoothstep(0,1,u_xlat0.x)
    (u_xlat0.x = clamp(u_xlat0.x, 0.0, 1.0));
    (u_xlat26.x = ((u_xlat0.x * -2.0) + 3.0));
    (u_xlat0.x = (u_xlat0.x * u_xlat0.x));
    (u_xlat40 = (u_xlat0.x * u_xlat26.x));
    //u_xlat40 = 从上到下渐变mask(1-0)

    (u_xlat16_18.x = ((-u_xlat13) + 1.0));
    (u_xlat16_18.x = (((-u_xlat26.x) * u_xlat0.x) + u_xlat16_18.x));


    //u_xlat16_18.x = (1-u_xlat13-u_xlat40)中间部分为1
    //-----------------
    (u_xlat16_18.x = clamp(u_xlat16_18.x, 0.0, 1.0));

    (u_xlat16_6.xyz = (vec3(u_xlat13) * _ES_HeightLerpBottomColor.xyz));
    (u_xlat16_18.xyz = (u_xlat16_18.xxx * _ES_HeightLerpMiddleColor.xyz));
    (u_xlat16_18.xyz = (u_xlat16_18.xyz * _ES_HeightLerpMiddleColor.www));
    (u_xlat16_18.xyz = ((u_xlat16_6.xyz * _ES_HeightLerpBottomColor.www) + u_xlat16_18.xyz));
    (u_xlat16_6.xyz = (vec3(u_xlat40) * _ES_HeightLerpTopColor.xyz));
    (u_xlat16_18.xyz = ((u_xlat16_6.xyz * _ES_HeightLerpTopColor.www) + u_xlat16_18.xyz));
    (u_xlat16_18.xyz = clamp(u_xlat16_18.xyz, 0.0, 1.0));

    (u_xlat16_18.xyz = (u_xlat16_18.xyz * u_xlat16_7.xyz));
    (u_xlat16_18.xyz = (u_xlat16_18.xyz + u_xlat16_18.xyz));
    //上下渐变--------------------------

    //Bloom--------------------------
    if ((u_xlati39 != 0))
    {
        (u_xlatu0.x = uint(int(u_xlat16_5.x)));
        (u_xlatu0.y = 6u);
        (u_xlatu0.z = 0u);
        (u_xlatu0.w = 7u);
        (u_xlat13 = texelFetch(_MaterialValuesPackLUT, ivec2(u_xlatu0.xy), int(u_xlatu0.z)).z);
        (u_xlat0.xzw = texelFetch(_MaterialValuesPackLUT, ivec2(u_xlatu0.xw), int(u_xlatu0.z)).xyz);
        (u_xlat16_6.xyz = u_xlat0.xzw);
        (u_xlat16_5.x = u_xlat13);
    }
    else
    {
        (u_xlat16_6.x = 1.0);
        (u_xlat16_6.y = 1.0);
        (u_xlat16_6.z = 1.0);
        (u_xlat16_5.x = _mBloomIntensity0);
    }
  // color = color * (bloomIntensity * bloomColor + 1);
    (u_xlat16_6.xyz = ((u_xlat16_5.xxx * u_xlat16_6.xyz) + vec3(1.0, 1.0, 1.0)));
    (u_xlat16_5.xyz = (u_xlat16_18.xyz * u_xlat16_6.xyz));
//----
    //u_xlat16_44 = 1;
    (u_xlat16_44 = (((-_GlobalOneMinusAvatarIntensityEnable) * _GlobalOneMinusAvatarIntensity) + 1.0));
    (u_xlat16_5.xyz = (vec3(u_xlat16_44) * u_xlat16_5.xyz));
    (u_xlat16_44 = (((-_OneMinusGlobalMainIntensityEnable) * _OneMinusGlobalMainIntensity) + 1.0));
    (u_xlat16_6.xyz = (vec3(u_xlat16_44) * u_xlat16_5.xyz));

    //后面的计算应该是 Fog
    (u_xlat0.xyz = (vs_TEXCOORD2.xyz + (-_WorldSpaceCameraPos.xyz)));
    (u_xlat0.x = dot(u_xlat0.xyz, u_xlat0.xyz));
    (u_xlat0.x = sqrt(u_xlat0.x));
    (u_xlat16_2.xz = vec2(_ES_FogNear, _ES_FogDensity));
    (u_xlat16_2.yw = vec2(_ES_HeightFogFogNear, _ES_HeightFogDensity));
    (u_xlat16_7.x = _ES_FogFar);
    (u_xlat16_7.y = _ES_HeightFogFogFar);
    (u_xlat16_33.xy = ((-u_xlat16_2.xy) + u_xlat16_7.xy));
    (u_xlat16_33.xy = ((vec2(vec2(_ES_FogCharacterNearFactor, _ES_FogCharacterNearFactor)) * u_xlat16_33.xy) + u_xlat16_2.xy));
    (u_xlat16_8.xy = (u_xlat0.xx + (-u_xlat16_33.xy)));
    (u_xlat16_7.xy = ((-u_xlat16_33.xy) + u_xlat16_7.xy));
    (u_xlat16_7.xy = (u_xlat16_8.xy / u_xlat16_7.xy));
    (u_xlat16_7.xy = clamp(u_xlat16_7.xy, 0.0, 1.0));
    (u_xlat16_7.xy = (u_xlat16_2.zw * u_xlat16_7.xy));
    (u_xlat16_33.xy = (((-u_xlat16_7.xy) * u_xlat16_7.xy) + u_xlat16_7.xy));
    (u_xlat16_0.xy = ((u_xlat16_7.xy * u_xlat16_33.xy) + u_xlat16_7.xy));
    (u_xlat16_45 = dot(vs_TEXCOORD2.xyz, hlslcc_mtx4x4_ES_GlobalRotMatrix[3].xyz));
    (u_xlat16_45 = (u_xlat16_45 + (-hlslcc_mtx4x4_ES_GlobalRotMatrix[3].w)));
    (u_xlatb40 = (0.0 < _ES_HeightFogRange));
    (u_xlat16_7.x = (u_xlat16_45 + (-_ES_HeightFogBaseHeight)));
    (u_xlat16_45 = ((-u_xlat16_45) + _ES_HeightFogBaseHeight));
    (u_xlat16_45 = ((u_xlatb40) ? (u_xlat16_7.x) : (u_xlat16_45)));
    (u_xlat16_7.x = (abs(_ES_HeightFogRange) + 1.0));
    (u_xlat16_45 = max(u_xlat16_45, 0.0));
    (u_xlat16_45 = (u_xlat16_45 / u_xlat16_7.x));
    (u_xlat16_45 = min(u_xlat16_45, 1.0));
    (u_xlat16_45 = ((-u_xlat16_45) + 1.0));
    (u_xlat16_7.x = ((u_xlat16_45 * _ES_HeightFogDensity) + -1.0));
    (u_xlat16_7.x = clamp(u_xlat16_7.x, 0.0, 1.0));
    (u_xlat16_0.z = ((_ES_TransitionRate * 0.125) + _ES_FogColor));
    (u_xlat16_3.xyz = textureLod(_ES_GradientAtlas, u_xlat16_0.xz, 0.0).xyz);
    (u_xlat16_20 = (_ES_FogDensity + -1.0));
    (u_xlat16_20 = clamp(u_xlat16_20, 0.0, 1.0));
    (u_xlat16_33.xy = u_xlat16_0.xy);
    (u_xlat16_33.xy = clamp(u_xlat16_33.xy, 0.0, 1.0));
    (u_xlat16_8.xyz = ((u_xlat16_3.xyz * u_xlat16_33.xxx) + (-u_xlat16_6.xyz)));
    (u_xlat16_8.xyz = ((u_xlat16_33.xxx * u_xlat16_8.xyz) + u_xlat16_6.xyz));
    (u_xlat16_11.xyz = ((u_xlat16_3.xyz * u_xlat16_33.xxx) + u_xlat16_8.xyz));
    (u_xlat16_8.xyz = ((u_xlat16_11.xyz * vec3(u_xlat16_20)) + u_xlat16_8.xyz));
    (u_xlat16_0.w = ((_ES_TransitionRate * 0.125) + _ES_HeightFogColor));
    (u_xlat16_3.xyz = textureLod(_ES_GradientAtlas, u_xlat16_0.yw, 0.0).xyz);
    (u_xlat16_11.xyz = (vec3(u_xlat16_45) * u_xlat16_3.xyz));
    (u_xlat16_12.xyz = ((u_xlat16_11.xyz * u_xlat16_33.yyy) + (-u_xlat16_8.xyz)));
    (u_xlat16_12.xyz = ((u_xlat16_33.yyy * u_xlat16_12.xyz) + u_xlat16_8.xyz));
    (u_xlat16_11.xyz = ((u_xlat16_11.xyz * u_xlat16_33.yyy) + u_xlat16_12.xyz));
    (u_xlat16_7.xyz = ((u_xlat16_11.xyz * u_xlat16_7.xxx) + u_xlat16_12.xyz));
    (u_xlat16_47 = max(u_xlat16_3.z, u_xlat16_3.y));
    (u_xlat16_47 = max(u_xlat16_3.x, u_xlat16_47));
    (u_xlat16_11.xyz = (vec3(u_xlat16_45) * u_xlat16_7.xyz));
    (u_xlat16_11.xyz = ((u_xlat16_11.xyz * u_xlat16_33.yyy) + u_xlat16_8.xyz));
    (u_xlat16_7.xyz = ((-u_xlat16_8.xyz) + u_xlat16_7.xyz));
    (u_xlat16_7.xyz = ((vec3(u_xlat16_45) * u_xlat16_7.xyz) + u_xlat16_8.xyz));
    (u_xlat16_45 = ((_ES_HeightFogAddAjust * (-u_xlat16_47)) + u_xlat16_47));

    (u_xlat16_8.xyz = ((-u_xlat16_7.xyz) + u_xlat16_11.xyz));
    (u_xlat16_7.xyz = ((vec3(u_xlat16_45) * u_xlat16_8.xyz) + u_xlat16_7.xyz));
    (u_xlat16_5.xyz = (((-u_xlat16_5.xyz) * vec3(u_xlat16_44)) + u_xlat16_7.xyz));
    //混合Fog Color(角色展示界面基本上没有fog)

    (u_xlat16_5.xyz = ((vec3(u_xlat16_44) * u_xlat16_5.xyz) + u_xlat16_6.xyz));

//    debugColor =-u_xlat10_1.xyz + u_xlat16_5.xyz;
    //最终颜色
    (SV_Target0.xyz = ((-u_xlat10_1.xyz) + u_xlat16_5.xyz));
    SV_Target0.xyz = debugColor.xyz-u_xlat10_1.xyz;

    (SV_Target0.w = 1.0);
    return ;
}
