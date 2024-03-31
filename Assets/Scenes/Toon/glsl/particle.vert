#version 450
uniform vec4 _Time;
uniform vec4 _ProjectionParams;
uniform vec4 hlslcc_mtx4x4_NonJitteredViewProjMatrix[4];
uniform float _ES_EP_Enable;
uniform float _EyeProtectForceDisable;
layout(std140, binding = 2) uniform UnityPerDraw{
  vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
  vec4 Xhlslcc_UnusedXhlslcc_mtx4x4unity_WorldToObject[4];
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
  vec4 _MainTex_ST;
  vec4 _MainColor;
  vec4 _MainSpeed;
  vec4 _MainChannel;
  vec4 _MainChannelRGB;
  vec4 _MaskChannel;
  vec4 Xhlslcc_UnusedX_NoiseTex_ST;
  vec4 Xhlslcc_UnusedX_NoiseSpeed;
  vec4 Xhlslcc_UnusedX_NoiseSpeedG;
  vec4 _MaskTex_ST;
  vec4 _MaskSpeed;
  vec4 _MaskUVoffset;
  vec4 Xhlslcc_UnusedX_CustomUV;
  float _OneMinusOpacityDitherScale;
  float _Opacity;
  float _CoverBackground;
  float Xhlslcc_UnusedX_SoftNear;
  float Xhlslcc_UnusedX_SoftFar;
  int _CL;
  int _UseNojitterMatrix;
  float Xhlslcc_UnusedX_UsePlayerPos;
  vec3 Xhlslcc_UnusedX_InteractivePos;
  vec3 Xhlslcc_UnusedX_ES_PlayerPos;
  vec4 Xhlslcc_UnusedX_InteractiveColor;
  float Xhlslcc_UnusedX_InteractiveRadius;
  float Xhlslcc_UnusedX_InteractiveBlend;
  float _VFogInst;
  vec4 Xhlslcc_UnusedX_FadeoutParams;
  float _Dither_On;
  float _DitherAlpha;
  float _MASKCHANEL;
};
in vec4 in_POSITION0;
in vec4 in_COLOR0;
in vec4 in_TEXCOORD0;
in vec2 in_TEXCOORD1;
out vec4 vs_COLOR0;
out vec4 vs_TEXCOORD0;
out vec2 vs_texcoord4;
out vec2 vs_TEXCOORD6;
out vec4 vs_TEXCOORD5;
out vec3 vs_TEXCOORD7;
out vec2 vs_TEXCOORD8;
vec4 u_xlat0;
vec4 u_xlat16_0;
bool u_xlatb0;
vec4 u_xlat1;
vec4 u_xlat2;
vec3 u_xlat16_3;
bvec3 u_xlatb4;
vec3 u_xlat5;
int u_xlati5;
bool u_xlatb5;
bool u_xlatb9;
vec2 u_xlat10;
int u_xlati10;
bool u_xlatb10;
vec2 u_xlat11;
void main(){
  (u_xlatb0 = (0.5 < _ES_EP_Enable));
  (u_xlatb5 = (0.5 < _EyeProtectForceDisable));
  (u_xlatb0 = (u_xlatb5 && u_xlatb0));
  (u_xlat5.xyz = (in_POSITION0.yyy * hlslcc_mtx4x4unity_ObjectToWorld[1].xyz));
  (u_xlat5.xyz = ((hlslcc_mtx4x4unity_ObjectToWorld[0].xyz * in_POSITION0.xxx) + u_xlat5.xyz));
  (u_xlat5.xyz = ((hlslcc_mtx4x4unity_ObjectToWorld[2].xyz * in_POSITION0.zzz) + u_xlat5.xyz));
  (u_xlat5.xyz = (u_xlat5.xyz + hlslcc_mtx4x4unity_ObjectToWorld[3].xyz));
  (u_xlat1 = (u_xlat5.yyyy * hlslcc_mtx4x4_NonJitteredViewProjMatrix[1]));
  (u_xlat1 = ((hlslcc_mtx4x4_NonJitteredViewProjMatrix[0] * u_xlat5.xxxx) + u_xlat1));
  (u_xlat1 = ((hlslcc_mtx4x4_NonJitteredViewProjMatrix[2] * u_xlat5.zzzz) + u_xlat1));
  (vs_TEXCOORD7.xyz = u_xlat5.xyz);
  (u_xlat1 = (u_xlat1 + hlslcc_mtx4x4_NonJitteredViewProjMatrix[3]));
  (u_xlatb5 = (_UseNojitterMatrix != 0));
  (u_xlatb10 = (vec4(0.0, 0.0, 0.0, 0.0) != vec4(_Dither_On)));
  (u_xlatb5 = (u_xlatb10 || u_xlatb5));
  (u_xlat2 = (in_POSITION0.yyyy * hlslcc_mtx4x4unity_MatrixMVP[1]));
  (u_xlat2 = ((hlslcc_mtx4x4unity_MatrixMVP[0] * in_POSITION0.xxxx) + u_xlat2));
  (u_xlat2 = ((hlslcc_mtx4x4unity_MatrixMVP[2] * in_POSITION0.zzzz) + u_xlat2));
  (u_xlat2 = (u_xlat2 + hlslcc_mtx4x4unity_MatrixMVP[3]));
  (u_xlat1 = ((bool(u_xlatb5)) ? (u_xlat1) : (u_xlat2)));
  (u_xlati5 = int((((0.0 < u_xlat1.z)) ? (4294967295u) : (0u))));
  (u_xlati10 = int((((u_xlat1.z < 0.0)) ? (4294967295u) : (0u))));
  (u_xlati5 = ((-u_xlati5) + u_xlati10));
  (u_xlat5.x = float(u_xlati5));
  (u_xlat10.xy = (u_xlat1.ww * vec2(0.99989998, -2.0)));
  (u_xlat5.x = (abs(u_xlat10.x) * u_xlat5.x));
  (u_xlatb10 = (0.5 < _CoverBackground));
  (u_xlat5.x = ((u_xlatb10) ? (u_xlat5.x) : (u_xlat1.z)));
  (gl_Position.xyw = u_xlat1.xyw);
  (gl_Position.z = ((u_xlatb0) ? (u_xlat10.y) : (u_xlat5.x)));
  (u_xlat16_0 = (in_COLOR0 * _MainColor));
  (u_xlat16_3.x = (u_xlat16_0.w * _Opacity));
  (vs_COLOR0.xyz = (u_xlat16_0.xyz * _MainSpeed.zzz));
  (vs_COLOR0.w = (u_xlat16_3.x * 10.0));



  (u_xlat0.xy = (_Time.yy * _MainSpeed.xy));
  (u_xlat0.zw = (_Time.yy * _MaskSpeed.xy));


  (u_xlat1.xy = ((-in_TEXCOORD0.xy) + in_TEXCOORD1.xy));
  (u_xlat1.xy = ((_MaskUVoffset.ww * u_xlat1.xy) + in_TEXCOORD0.xy));
  (u_xlat1.xy = ((u_xlat1.xy * _MaskTex_ST.xy) + _MaskTex_ST.zw));
  (u_xlat16_3.xy = ((-in_TEXCOORD0.xy) + _MaskUVoffset.xy));
  (u_xlat16_3.yz = min(abs(u_xlat16_3.xy), vec2(1.0, 1.0)));
  (u_xlat11.x = (u_xlat16_3.z * u_xlat16_3.y));
  (u_xlatb4.xyz = equal(vec4(_MASKCHANEL), vec4(0.0, 1.0, 2.0, 0.0)).xyz);
  //u_xlatb4.x = true
  (u_xlat11.x = ((u_xlatb4.y) ? (u_xlat11.x) : (0.0)));
  (u_xlat11.y = ((u_xlatb4.y) ? (u_xlat16_3.z) : (0.0)));
  (u_xlat1.zw = ((u_xlatb4.x) ? (u_xlat1.xy) : (u_xlat11.xy)));
  (u_xlat1.xy = ((in_TEXCOORD0.xy * _MainTex_ST.xy) + _MainTex_ST.zw));
  (u_xlat0 = (u_xlat0 + u_xlat1));


  (u_xlatb9 = (u_xlatb4.y || u_xlatb4.z));
  (u_xlat1.xy = ((bool(u_xlatb9)) ? (u_xlat0.xy) : (u_xlat1.xy)));
  (vs_TEXCOORD0 = ((u_xlatb4.x) ? (u_xlat0) : (u_xlat1)));


  (u_xlat16_3.x = (u_xlat16_3.z * u_xlat16_3.y));


  (vs_texcoord4.xy = ((u_xlatb4.x) ? (u_xlat16_3.xz) : (vec2(0.0, 0.0))));


  (vs_TEXCOORD6.xy = vec2(0.0, 0.0));
  (u_xlat1.x = (u_xlat2.y * _ProjectionParams.x));
  (u_xlat1.w = (u_xlat1.x * 0.5));
  (u_xlat1.xz = (u_xlat2.xw * vec2(0.5, 0.5)));
  (vs_TEXCOORD5.zw = u_xlat2.zw);
  (vs_TEXCOORD5.xy = (u_xlat1.zz + u_xlat1.xw));
  (vs_TEXCOORD8.xy = in_TEXCOORD0.xy);
  return ;
}
