#version 450
uniform vec3 _WorldSpaceCameraPos;
uniform vec4 _ProjectionParams;
uniform float _ES_EP_Enable;
uniform float _EyeProtectForceDisable;
layout(std140, binding = 0) uniform UnityPerDraw{
  vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
  vec4 hlslcc_mtx4x4unity_WorldToObject[4];
  vec4 Xhlslcc_UnusedXhlslcc_mtx4x4unity_MatrixMV[4];
  vec4 hlslcc_mtx4x4unity_MatrixMVP[4];
  vec4 unity_WorldTransformParams;
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
in vec4 in_COLOR0;
in vec3 in_NORMAL0;
in vec4 in_TANGENT0;
in vec4 in_TEXCOORD0;
in vec4 in_TEXCOORD1;
in vec4 in_TEXCOORD2;
out vec4 vs_COLOR0;
out vec4 vs_TEXCOORD0;
out vec4 vs_TEXCOORD1;
out vec4 vs_TEXCOORD2;
out vec4 vs_TEXCOORD3;
out vec3 vs_TEXCOORD4;
out vec3 vs_TEXCOORD5;
out vec3 vs_TEXCOORD6;
out vec3 vs_TEXCOORD7;
vec4 u_xlat0;
bool u_xlatb0;
vec4 u_xlat1;
vec3 u_xlat2;
vec3 u_xlat3;
vec3 u_xlat4;
vec3 u_xlat5;
float u_xlat6;
bool u_xlatb6;
float u_xlat18;

mat4 rotateXYZ(vec3 angles) {
    float sinX = sin(angles.x);
    float cosX = cos(angles.x);
    float sinY = sin(angles.y);
    float cosY = cos(angles.y);
    float sinZ = sin(angles.z);
    float cosZ = cos(angles.z);

    mat4 rotateX = mat4(
        1.0, 0.0, 0.0, 0.0,
        0.0, cosX, -sinX, 0.0,
        0.0, sinX, cosX, 0.0,
        0.0, 0.0, 0.0, 1.0
    );

    mat4 rotateY = mat4(
        cosY, 0.0, sinY, 0.0,
        0.0, 1.0, 0.0, 0.0,
        -sinY, 0.0, cosY, 0.0,
        0.0, 0.0, 0.0, 1.0
    );

    mat4 rotateZ = mat4(
        cosZ, -sinZ, 0.0, 0.0,
        sinZ, cosZ, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0
    );

    return rotateZ * rotateY * rotateX;
}

void main(){
  (u_xlatb0 = (0.5 < _ES_EP_Enable));
  (u_xlatb6 = (0.5 < _EyeProtectForceDisable));
  (u_xlatb0 = (u_xlatb6 && u_xlatb0));

    vec3 angles = radians(vec3(0.0, 0.0, 20.0));

    // 旋转模型
    mat4 rotationMatrix = rotateXYZ(angles);
    vec4 rotatedPosition = rotationMatrix * in_POSITION0;

    (u_xlat1 = (rotatedPosition.yyyy * hlslcc_mtx4x4unity_MatrixMVP[1]));
    (u_xlat1 = ((hlslcc_mtx4x4unity_MatrixMVP[0] * rotatedPosition.xxxx) + u_xlat1));
    (u_xlat1 = ((hlslcc_mtx4x4unity_MatrixMVP[2] * rotatedPosition.zzzz) + u_xlat1));
    (u_xlat1 = (u_xlat1 + hlslcc_mtx4x4unity_MatrixMVP[3]));

//   (u_xlat1 = (in_POSITION0.yyyy * hlslcc_mtx4x4unity_MatrixMVP[1]));
//   (u_xlat1 = ((hlslcc_mtx4x4unity_MatrixMVP[0] * in_POSITION0.xxxx) + u_xlat1));
//   (u_xlat1 = ((hlslcc_mtx4x4unity_MatrixMVP[2] * in_POSITION0.zzzz) + u_xlat1));
//   (u_xlat1 = (u_xlat1 + hlslcc_mtx4x4unity_MatrixMVP[3]));

  (u_xlat6 = (u_xlat1.w * -2.0));
  (gl_Position.z = ((u_xlatb0) ? (u_xlat6) : (u_xlat1.z)));
  (gl_Position.xyw = u_xlat1.xyw);

  (vs_COLOR0 = in_COLOR0);

  (vs_TEXCOORD0 = in_TEXCOORD0);
  (vs_TEXCOORD1 = in_TEXCOORD1);
  (vs_TEXCOORD2 = in_TEXCOORD2);

//vs_TEXCOORD3 = screenUV
  (u_xlat0.x = (u_xlat1.y * _ProjectionParams.x));
  (u_xlat0.w = (u_xlat0.x * 0.5));
  (u_xlat0.xz = (u_xlat1.xw * vec2(0.5, 0.5)));
  (vs_TEXCOORD3.zw = u_xlat1.zw);
  (vs_TEXCOORD3.xy = (u_xlat0.zz + u_xlat0.xw));

//u_xlat0 = normalWS
  (u_xlat0.x = dot(in_NORMAL0.xyz, hlslcc_mtx4x4unity_WorldToObject[0].xyz));
  (u_xlat0.y = dot(in_NORMAL0.xyz, hlslcc_mtx4x4unity_WorldToObject[1].xyz));
  (u_xlat0.z = dot(in_NORMAL0.xyz, hlslcc_mtx4x4unity_WorldToObject[2].xyz));
  (u_xlat18 = dot(u_xlat0.xyz, u_xlat0.xyz));
  (u_xlat18 = max(u_xlat18, 0.0));
  (u_xlat18 = inversesqrt(u_xlat18));
  (u_xlat0.xyz = (vec3(u_xlat18) * u_xlat0.xyz));
  (u_xlat18 = dot(u_xlat0.xyz, u_xlat0.xyz));
  (u_xlat18 = inversesqrt(u_xlat18));
  (u_xlat0.xyz = (vec3(u_xlat18) * u_xlat0.xyz));
//-----------------------------------

//u_xlat1 = tangentWS
  (u_xlat1.xyz = (in_TANGENT0.yyy * hlslcc_mtx4x4unity_ObjectToWorld[1].yzx));
  (u_xlat1.xyz = ((hlslcc_mtx4x4unity_ObjectToWorld[0].yzx * in_TANGENT0.xxx) + u_xlat1.xyz));
  (u_xlat1.xyz = ((hlslcc_mtx4x4unity_ObjectToWorld[2].yzx * in_TANGENT0.zzz) + u_xlat1.xyz));
  (u_xlat18 = dot(u_xlat1.xyz, u_xlat1.xyz));
  (u_xlat18 = max(u_xlat18, 0.0));
  (u_xlat18 = inversesqrt(u_xlat18));
  (u_xlat1.xyz = (vec3(u_xlat18) * u_xlat1.yxz));
//-----------------------------------

//u_xlat0 = normalWS,u_xlat1 = tangentWS

  (u_xlat2.xyz = (u_xlat0.zxy * u_xlat1.yxz));
  (u_xlat2.xyz = ((u_xlat0.yzx * u_xlat1.xzy) + (-u_xlat2.xyz)));
  (u_xlat18 = (in_TANGENT0.w * unity_WorldTransformParams.w));
  (u_xlat2.xyz = (vec3(u_xlat18) * u_xlat2.yxz));
  (u_xlat3.y = u_xlat2.x);
  (u_xlat3.z = u_xlat0.y);

// vs_TEXCOORD4.xyz = u_xlat2.xyz;

  //vs_TEXCOORD7 = positionWS
  (u_xlat4.xyz = (in_POSITION0.yyy * hlslcc_mtx4x4unity_ObjectToWorld[1].xyz));
  (u_xlat4.xyz = ((hlslcc_mtx4x4unity_ObjectToWorld[0].xyz * in_POSITION0.xxx) + u_xlat4.xyz));
  (u_xlat4.xyz = ((hlslcc_mtx4x4unity_ObjectToWorld[2].xyz * in_POSITION0.zzz) + u_xlat4.xyz));
  (u_xlat4.xyz = ((hlslcc_mtx4x4unity_ObjectToWorld[3].xyz * in_POSITION0.www) + u_xlat4.xyz));
  (u_xlat5.xyz = ((-u_xlat4.xyz) + _WorldSpaceCameraPos.xyz));
  (vs_TEXCOORD7.xyz = u_xlat4.xyz);


//-----------------------------------

//u_xlat4 = viewDirWS
  (u_xlat18 = dot(u_xlat5.xyz, u_xlat5.xyz));
  (u_xlat18 = inversesqrt(u_xlat18));
  (u_xlat4.xyz = (vec3(u_xlat18) * u_xlat5.xyz));
//-----------------------------------

  (u_xlat3.x = u_xlat1.y);
  (u_xlat3.xyz = (u_xlat3.xyz * u_xlat4.yyy));

  (u_xlat1.y = u_xlat2.z);
  (u_xlat2.z = u_xlat0.x);
  (u_xlat2.x = u_xlat1.z);
  (u_xlat2.xyz = ((u_xlat2.xyz * u_xlat4.xxx) + u_xlat3.xyz));

  (u_xlat1.z = u_xlat0.z);
//vs_TEXCOORD6 = normalWS
  (vs_TEXCOORD6.xyz = u_xlat0.xyz);
//vs_TEXCOORD4 = ?
  (vs_TEXCOORD4.xyz = ((u_xlat1.xyz * u_xlat4.zzz) + u_xlat2.xyz));
//vs_TEXCOORD5 = viewDirWS
  (vs_TEXCOORD5.xyz = u_xlat4.xyz);
  return ;
}
