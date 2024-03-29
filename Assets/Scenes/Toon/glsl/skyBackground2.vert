#version 450
uniform vec4 _MainTex_ST;
layout(std140, binding = 0) uniform UnityPerDraw{
  vec4 Xhlslcc_UnusedXhlslcc_mtx4x4unity_ObjectToWorld[4];
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
in vec4 in_POSITION0;
in vec2 in_TEXCOORD0;
out vec2 vs_TEXCOORD0;
vec4 u_xlat0;


vec3 getModelScale() {
    vec3 scale;
    scale.x = length(Xhlslcc_UnusedXhlslcc_mtx4x4unity_ObjectToWorld[0].xyz);
    scale.y = length(Xhlslcc_UnusedXhlslcc_mtx4x4unity_ObjectToWorld[1].xyz);
    scale.z = length(Xhlslcc_UnusedXhlslcc_mtx4x4unity_ObjectToWorld[2].xyz);
    return scale;
}

vec3 getModelCenterWorld() {
    return Xhlslcc_UnusedXhlslcc_mtx4x4unity_ObjectToWorld[3].xyz;
}



void main(){
  (vs_TEXCOORD0.xy = ((in_TEXCOORD0.xy * _MainTex_ST.xy) + _MainTex_ST.zw));
  (u_xlat0 = (in_POSITION0.yyyy * hlslcc_mtx4x4unity_MatrixMVP[1]));
  (u_xlat0 = ((hlslcc_mtx4x4unity_MatrixMVP[0] * in_POSITION0.xxxx) + u_xlat0));
  (u_xlat0 = ((hlslcc_mtx4x4unity_MatrixMVP[2] * in_POSITION0.zzzz) + u_xlat0));
  (gl_Position = (u_xlat0 + hlslcc_mtx4x4unity_MatrixMVP[3]));

    vec3 scale = getModelScale();
  vs_TEXCOORD0.xy = scale.xy;
  return ;
}
