#version 450
uniform vec3 _WorldSpaceCameraPos;
uniform vec4 hlslcc_mtx4x4_NonJitteredViewProjMatrix[4];
uniform vec4 _MainTex_ST;
uniform float _InflateScale;
uniform float _Width;
layout(std140, binding = 0) uniform UnityPerDraw{
  vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
  vec4 hlslcc_mtx4x4unity_WorldToObject[4];
  vec4 Xhlslcc_UnusedXhlslcc_mtx4x4unity_MatrixMV[4];
  vec4 Xhlslcc_UnusedXhlslcc_mtx4x4unity_MatrixMVP[4];
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
in vec4 in_POSITION0;
in vec2 in_TEXCOORD0;
in vec3 in_NORMAL0;
in vec4 in_COLOR0;
out vec2 vs_TEXCOORD0;
out vec3 vs_TEXCOORD1;
out vec3 vs_TEXCOORD2;
vec3 u_xlat0;
vec4 u_xlat1;
float u_xlat2;
float u_xlat6;


//获取Scale
vec3 getModelScale() {
    vec3 scale;
    scale.x = length(hlslcc_mtx4x4unity_ObjectToWorld[0].xyz);
    scale.y = length(hlslcc_mtx4x4unity_ObjectToWorld[1].xyz);
    scale.z = length(hlslcc_mtx4x4unity_ObjectToWorld[2].xyz);
    return scale;
}
//获取center
vec3 getModelCenterWorld() {
    return hlslcc_mtx4x4unity_ObjectToWorld[3].xyz;
}

void main(){
  (u_xlat0.xyz = (in_POSITION0.yyy * hlslcc_mtx4x4unity_ObjectToWorld[1].xyz));
  (u_xlat0.xyz = ((hlslcc_mtx4x4unity_ObjectToWorld[0].xyz * in_POSITION0.xxx) + u_xlat0.xyz));
  (u_xlat0.xyz = ((hlslcc_mtx4x4unity_ObjectToWorld[2].xyz * in_POSITION0.zzz) + u_xlat0.xyz));
  (u_xlat0.xyz = (u_xlat0.xyz + hlslcc_mtx4x4unity_ObjectToWorld[3].xyz));
  (u_xlat0.xyz = ((-u_xlat0.xyz) + _WorldSpaceCameraPos.xyz));
  (u_xlat0.x = dot(u_xlat0.xyz, u_xlat0.xyz));
  (u_xlat0.x = sqrt(u_xlat0.x));
  (u_xlat2 = (in_COLOR0.x * _InflateScale));
  (u_xlat0.x = ((u_xlat2 * u_xlat0.x) + in_POSITION0.y));
  (u_xlat0.xyz = (u_xlat0.xxx * hlslcc_mtx4x4unity_ObjectToWorld[1].xyz));
  (u_xlat1.xy = ((in_NORMAL0.xz * vec2(_Width)) + in_POSITION0.xz));
  (u_xlat0.xyz = ((hlslcc_mtx4x4unity_ObjectToWorld[0].xyz * u_xlat1.xxx) + u_xlat0.xyz));
  (u_xlat0.xyz = ((hlslcc_mtx4x4unity_ObjectToWorld[2].xyz * u_xlat1.yyy) + u_xlat0.xyz));
  (u_xlat0.xyz = (u_xlat0.xyz + hlslcc_mtx4x4unity_ObjectToWorld[3].xyz));
  (u_xlat1 = (u_xlat0.yyyy * hlslcc_mtx4x4_NonJitteredViewProjMatrix[1]));
  (u_xlat1 = ((hlslcc_mtx4x4_NonJitteredViewProjMatrix[0] * u_xlat0.xxxx) + u_xlat1));
  (u_xlat1 = ((hlslcc_mtx4x4_NonJitteredViewProjMatrix[2] * u_xlat0.zzzz) + u_xlat1));
  (vs_TEXCOORD2.xyz = u_xlat0.xyz);
  (gl_Position = (u_xlat1 + hlslcc_mtx4x4_NonJitteredViewProjMatrix[3]));

  (vs_TEXCOORD0.xy = ((in_TEXCOORD0.xy * _MainTex_ST.xy) + _MainTex_ST.zw));

vs_TEXCOORD2.xyz = getModelScale();

  (u_xlat0.x = dot(in_NORMAL0.xyz, hlslcc_mtx4x4unity_WorldToObject[0].xyz));
  (u_xlat0.y = dot(in_NORMAL0.xyz, hlslcc_mtx4x4unity_WorldToObject[1].xyz));
  (u_xlat0.z = dot(in_NORMAL0.xyz, hlslcc_mtx4x4unity_WorldToObject[2].xyz));
  (u_xlat6 = dot(u_xlat0.xyz, u_xlat0.xyz));
  (u_xlat6 = max(u_xlat6, 0.0));
  (u_xlat6 = inversesqrt(u_xlat6));
  (vs_TEXCOORD1.xyz = (vec3(u_xlat6) * u_xlat0.xyz));
  return ;
}
