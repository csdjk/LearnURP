#version 450
uniform vec3 _WorldSpaceCameraPos;
uniform vec4 _ProjectionParams;
layout(std140, binding = 3) uniform UnityPerDraw{
  vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
  vec4 hlslcc_mtx4x4unity_WorldToObject[4];
  vec4 Xhlslcc_UnusedXhlslcc_mtx4x4unity_MatrixMV[4];
  vec4 hlslcc_mtx4x4unity_MatrixMVP[4];
  vec4 Xhlslcc_UnusedXunity_WorldTransformParams;
  vec4 Xhlslcc_UnusedXunity_RenderingLayer;
  vec4 Xhlslcc_UnusedXunity_LightData;
  vec4 Xhlslcc_UnusedXunity_LightIndices[2];
  vec4 Xhlslcc_UnusedXunity_ProbesOcclusion;
  vec4 Xhlslcc_UnusedXunity_SpecCube0_HDR;
  vec4 Xhlslcc_UnusedXunity_SpecCube1_HDR;
  vec4 Xhlslcc_UnusedXunity_LightmapST;
  vec4 Xhlslcc_UnusedXunity_DynamicLightmapST;
  vec4 Xhlslcc_UnusedXunity_SHAr;
  vec4 Xhlslcc_UnusedXunity_SHAg;
  vec4 Xhlslcc_UnusedXunity_SHAb;
  vec4 Xhlslcc_UnusedXunity_SHBr;
  vec4 Xhlslcc_UnusedXunity_SHBg;
  vec4 Xhlslcc_UnusedXunity_SHBb;
  vec4 Xhlslcc_UnusedXunity_SHC;
  vec4 Xhlslcc_UnusedXhlslcc_mtx4x4unity_MatrixPreviousM[4];
  vec4 Xhlslcc_UnusedXhlslcc_mtx4x4unity_MatrixPreviousMI[4];
  vec4 Xhlslcc_UnusedXunity_MotionVectorsParams;
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
in vec4 in_POSITION0;
in vec3 in_NORMAL0;
in vec4 in_TANGENT0;
in vec2 in_TEXCOORD0;
in vec2 in_TEXCOORD1;
in vec4 in_COLOR0;
out vec4 vs_TEXCOORD0;
out vec3 vs_TEXCOORD16;
out vec4 vs_COLOR0;
out vec4 vs_TEXCOORD1;
out vec3 vs_TEXCOORD2;
out vec3 vs_TEXCOORD3;
out vec4 vs_TEXCOORD4;
out vec3 vs_TEXCOORD5;
out vec3 vs_TEXCOORD8;
out vec3 vs_POSITION1;
vec4 u_xlat0;
vec2 u_xlat16_0;
vec4 u_xlat1;
ivec2 u_xlati1;
bool u_xlatb1;
float u_xlat2;
vec3 u_xlat4;
int u_xlati4;
bvec2 u_xlatb7;
float u_xlat10;
void main(){
  (u_xlat16_0.xy = (in_COLOR0.yx * vec2(256.0, 256.0)));
  (u_xlati1.xy = ivec2(u_xlat16_0.xy));
  (u_xlati1.xy = ivec2(uvec2((uint(u_xlati1.x) & uint(_ShowPartID)), (uint(u_xlati1.y) & uint(_ShowPartID)))));
  (u_xlatb7.xy = lessThan(ivec4(0, 0, 0, 0), ivec4(_HideCharaParts, _HideNPCParts, _HideCharaParts, _HideNPCParts)).xy);
  (u_xlati4 = ((u_xlatb7.y) ? (u_xlati1.y) : (1)));
  (u_xlati1.x = ((u_xlatb7.x) ? (u_xlati1.x) : (u_xlati4)));
  (u_xlatb1 = (0 < u_xlati1.x));
  (u_xlat0 = (in_POSITION0.yyyy * hlslcc_mtx4x4unity_MatrixMVP[1]));
  (u_xlat0 = ((hlslcc_mtx4x4unity_MatrixMVP[0] * in_POSITION0.xxxx) + u_xlat0));
  (u_xlat0 = ((hlslcc_mtx4x4unity_MatrixMVP[2] * in_POSITION0.zzzz) + u_xlat0));
  (u_xlat0 = (u_xlat0 + hlslcc_mtx4x4unity_MatrixMVP[3]));
  (gl_Position = ((bool(u_xlatb1)) ? (u_xlat0) : (vec4(-99.0, -99.0, -99.0, 1.0))));

//vs_TEXCOORD0 = uv
  (u_xlat1.xy = ((in_TEXCOORD0.xy * _MainTex_ST.xy) + _MainTex_ST.zw));
  (u_xlat1.zw = in_TEXCOORD1.xy);
  (vs_TEXCOORD0 = u_xlat1);
//-----------------------

  (vs_TEXCOORD16.xyz = vec3(0.0, 0.0, 0.0));
  (vs_COLOR0 = in_COLOR0);

//vs_TEXCOORD1 = screenUV
  (u_xlat1.x = (u_xlat0.y * _ProjectionParams.x));
  (u_xlat1.w = (u_xlat1.x * 0.5));
  (u_xlat1.xz = (u_xlat0.xw * vec2(0.5, 0.5)));
  (vs_TEXCOORD1.zw = u_xlat0.zw);
  (vs_TEXCOORD1.xy = (u_xlat1.zz + u_xlat1.xw));
//-----------------------

//vs_TEXCOORD2 = positionWS
  (u_xlat1.xyz = (in_POSITION0.yyy * hlslcc_mtx4x4unity_ObjectToWorld[1].xyz));
  (u_xlat1.xyz = ((hlslcc_mtx4x4unity_ObjectToWorld[0].xyz * in_POSITION0.xxx) + u_xlat1.xyz));
  (u_xlat1.xyz = ((hlslcc_mtx4x4unity_ObjectToWorld[2].xyz * in_POSITION0.zzz) + u_xlat1.xyz));
  (u_xlat1.xyz = (u_xlat1.xyz + hlslcc_mtx4x4unity_ObjectToWorld[3].xyz));
  (vs_TEXCOORD2.xyz = u_xlat1.xyz);
//-----------------------

//vs_TEXCOORD4 = viewDirWS
  (u_xlat1.xyz = ((-u_xlat1.xyz) + _WorldSpaceCameraPos.xyz));
  (vs_TEXCOORD4.xyz = u_xlat1.xyz);
//-----------------------

//vs_TEXCOORD3 = normalWS
  (u_xlat1.x = dot(in_NORMAL0.xyz, hlslcc_mtx4x4unity_WorldToObject[0].xyz));
  (u_xlat1.y = dot(in_NORMAL0.xyz, hlslcc_mtx4x4unity_WorldToObject[1].xyz));
  (u_xlat1.z = dot(in_NORMAL0.xyz, hlslcc_mtx4x4unity_WorldToObject[2].xyz));
  (vs_TEXCOORD3.xyz = u_xlat1.xyz);
//-----------------------

  (vs_TEXCOORD4.w = 1.0);

//vs_TEXCOORD5 = tangentWS
  (u_xlat1.xyz = (in_TANGENT0.yyy * hlslcc_mtx4x4unity_ObjectToWorld[1].xyz));
  (u_xlat1.xyz = ((hlslcc_mtx4x4unity_ObjectToWorld[0].xyz * in_TANGENT0.xxx) + u_xlat1.xyz));
  (u_xlat1.xyz = ((hlslcc_mtx4x4unity_ObjectToWorld[2].xyz * in_TANGENT0.zzz) + u_xlat1.xyz));
  (vs_TEXCOORD5.xyz = u_xlat1.xyz);
//-----------------------

  (u_xlat1.x = dot(in_NORMAL0.xyz, in_POSITION0.xyz));
  (u_xlat4.xyz = (in_POSITION0.xyz + vec3(0.0, 0.5, 0.0)));
  (u_xlat2 = dot(in_NORMAL0.xyz, u_xlat4.xyz));
  (u_xlat1.x = ((-u_xlat1.x) + u_xlat2));
  (u_xlat1.xyz = (((-in_NORMAL0.xyz) * u_xlat1.xxx) + u_xlat4.xyz));
  (u_xlat1.xyz = (u_xlat1.xyz + (-in_POSITION0.xyz)));

  (u_xlat10 = dot(u_xlat1.xyz, u_xlat1.xyz));
  (u_xlat10 = inversesqrt(u_xlat10));
  (u_xlat1.xyz = (vec3(u_xlat10) * u_xlat1.xyz));
  (vs_TEXCOORD8.xyz = u_xlat1.xyz);

  (vs_POSITION1.xyz = in_POSITION0.xyz);
  return ;
}
