#version 450
uniform vec3 _WorldSpaceCameraPos;
uniform vec4 _ProjectionParams;
uniform vec4 _ScreenParams;
uniform vec4 _CenterPos1;
uniform vec4 _CenterPos2;
layout(std140, binding = 1) uniform UnityPerDraw{
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
in vec4 in_POSITION0;
in vec2 in_TEXCOORD0;
in vec2 in_TEXCOORD1;
in vec3 in_NORMAL0;
in vec4 in_COLOR0;
out vec3 vs_TEXCOORD3;
out vec3 vs_TEXCOORD2;
out vec2 vs_TEXCOORD1;
out vec2 vs_TEXCOORD5;
out vec4 vs_TEXCOORD4;
out vec4 vs_TEXCOORD6;
out vec3 vs_TEXCOORD7;
out vec4 vs_TEXCOORD8;
out vec4 vs_TEXCOORD9;
out vec3 vs_TEXCOORD10;
vec4 u_xlat0;
vec4 u_xlat1;
vec4 u_xlat2;
float u_xlat16_3;
vec2 u_xlat4;
bvec2 u_xlatb11;
float u_xlat12;
vec2 u_xlat14;
float u_xlat16;

mat4 RotationMatrix(vec3 angles)
{
    float sinX = sin(angles.x);
    float cosX = cos(angles.x);
    float sinY = sin(angles.y);
    float cosY = cos(angles.y);
    float sinZ = sin(angles.z);
    float cosZ = cos(angles.z);

    return mat4(
        cosY * cosZ, cosZ * sinX * sinY - cosX * sinZ, sinX * sinZ + cosX * cosZ * sinY, 0.0,
        cosY * sinZ, cosX * cosZ + sinX * sinY * sinZ, cosX * sinY * sinZ - cosZ * sinX, 0.0,
        -sinY, cosY * sinX, cosX * cosY, 0.0,
        0.0, 0.0, 0.0, 1.0
    );
}

// 平移变换
mat4 TranslationMatrix(vec3 translation)
{
    return mat4(
        1.0, 0.0, 0.0, translation.x,
        0.0, 1.0, 0.0, translation.y,
        0.0, 0.0, 1.0, translation.z,
        0.0, 0.0, 0.0, 1.0
    );
}

// 缩放变换
mat4 ScaleMatrix(vec3 scale)
{
    return mat4(
        scale.x, 0.0, 0.0, 0.0,
        0.0, scale.y, 0.0, 0.0,
        0.0, 0.0, scale.z, 0.0,
        0.0, 0.0, 0.0, 1.0
    );
}

// 应用所有变换
vec4 ApplyTransformations(vec4 position, vec3 rotationAngles, vec3 translation, vec3 scale)
{
    mat4 rotationMatrix = RotationMatrix(rotationAngles);
    mat4 translationMatrix = TranslationMatrix(translation);
    mat4 scaleMatrix = ScaleMatrix(scale);

    mat4 transformationMatrix = rotationMatrix * scaleMatrix * translationMatrix;

    return transformationMatrix * position;
}

vec3 getModelScale() {
    vec3 scale;
    scale.x = length(hlslcc_mtx4x4unity_ObjectToWorld[0].xyz);
    scale.y = length(hlslcc_mtx4x4unity_ObjectToWorld[1].xyz);
    scale.z = length(hlslcc_mtx4x4unity_ObjectToWorld[2].xyz);
    return scale;
}

vec3 getModelCenterWorld() {
    return hlslcc_mtx4x4unity_ObjectToWorld[3].xyz;
}

void main(){


    // 旋转模型
    // vec3 angles = radians(vec3(0.0, 0.0, 0.0));
    // // 平移模型
    // vec3 translation = vec3(0.0, 0.0, 0.0);
    // // 缩放模型
    // vec3 scale = vec3(1.0, 1.0, 1.0);
    // vec4 rotatedPosition = ApplyTransformations(in_POSITION0, angles, translation, scale);

    // (u_xlat0 = (rotatedPosition.yyyy * hlslcc_mtx4x4unity_MatrixMVP[1]));
    // (u_xlat0 = ((hlslcc_mtx4x4unity_MatrixMVP[0] * rotatedPosition.xxxx) + u_xlat0));
    // (u_xlat0 = ((hlslcc_mtx4x4unity_MatrixMVP[2] * rotatedPosition.zzzz) + u_xlat0));
    // (u_xlat0 = (u_xlat0 + hlslcc_mtx4x4unity_MatrixMVP[3]));

vec3 Scale = getModelScale();

  (u_xlat0 = (in_POSITION0.yyyy * hlslcc_mtx4x4unity_MatrixMVP[1]));
  (u_xlat0 = ((hlslcc_mtx4x4unity_MatrixMVP[0] * in_POSITION0.xxxx) + u_xlat0));
  (u_xlat0 = ((hlslcc_mtx4x4unity_MatrixMVP[2] * in_POSITION0.zzzz) + u_xlat0));
  (u_xlat0 = (u_xlat0 + hlslcc_mtx4x4unity_MatrixMVP[3]));
  (gl_Position = u_xlat0);

//u_xlat1 = vs_TEXCOORD10 = positionWS
  (u_xlat1.xyz = (in_POSITION0.yyy * hlslcc_mtx4x4unity_ObjectToWorld[1].xyz));
  (u_xlat1.xyz = ((hlslcc_mtx4x4unity_ObjectToWorld[0].xyz * in_POSITION0.xxx) + u_xlat1.xyz));
  (u_xlat1.xyz = ((hlslcc_mtx4x4unity_ObjectToWorld[2].xyz * in_POSITION0.zzz) + u_xlat1.xyz));
  (u_xlat1.xyz = (u_xlat1.xyz + hlslcc_mtx4x4unity_ObjectToWorld[3].xyz));
  (vs_TEXCOORD10.xyz = u_xlat1.xyz);
  (vs_TEXCOORD10.xyz = Scale.xyz);

//----------------------------------------------

//vs_TEXCOORD3 = viewDirWS
  (vs_TEXCOORD3.xyz = ((-u_xlat1.xyz) + _WorldSpaceCameraPos.xyz));

//vs_TEXCOORD2 = normalWS
  (u_xlat1.x = dot(in_NORMAL0.xyz, hlslcc_mtx4x4unity_WorldToObject[0].xyz));
  (u_xlat1.y = dot(in_NORMAL0.xyz, hlslcc_mtx4x4unity_WorldToObject[1].xyz));
  (u_xlat1.z = dot(in_NORMAL0.xyz, hlslcc_mtx4x4unity_WorldToObject[2].xyz));
  (u_xlat16 = dot(u_xlat1.xyz, u_xlat1.xyz));
  (u_xlat16 = max(u_xlat16, 0.0));
  (u_xlat16 = inversesqrt(u_xlat16));
  (vs_TEXCOORD2.xyz = (vec3(u_xlat16) * u_xlat1.xyz));
//   vs_TEXCOORD2.xyz =in_NORMAL0.xyz;
//----------------------------------------------

  (vs_TEXCOORD1.xy = in_TEXCOORD0.xy);
  (vs_TEXCOORD5.xy = in_TEXCOORD1.xy);
  (vs_TEXCOORD4 = in_COLOR0);

//vs_TEXCOORD6 = screenUV
  (u_xlat1.x = 0.5);
  (u_xlat1.z = 0.5);
  (u_xlat1.y = _ProjectionParams.x);
  (u_xlat1.xyz = (u_xlat0.xyw * u_xlat1.xyz));
  (u_xlat1.w = (u_xlat1.y * 0.5));
  (vs_TEXCOORD6.xy = (u_xlat1.zz + u_xlat1.xw));
  (vs_TEXCOORD6.zw = u_xlat0.zw);
//----------------------------------------------

//vs_TEXCOORD7 = positionCS
  (vs_TEXCOORD7.xyz = u_xlat0.xyz);

  (u_xlat0 = (_CenterPos2.xzyw * vec4(0.5, 0.5, 0.5, 0.5)));
  (u_xlat1.xy = (u_xlat0.xy + vec2(0.5, 0.5)));
  (u_xlatb11.xy = lessThan(vec4(0.5, 0.5, 0.5, 0.5), u_xlat1.xyxy).xy);
  (u_xlat2.xy = ((-u_xlat1.xy) + vec2(0.5, 0.5)));
  (u_xlat12 = (_ScreenParams.y / _ScreenParams.x));
  (u_xlat16_3 = (u_xlat12 * 1.7777778));
  (u_xlat1.xy = (((-u_xlat2.xy) * vec2(u_xlat16_3)) + u_xlat1.xy));
  (u_xlat0.xy = ((u_xlat0.xy * vec2(u_xlat16_3)) + vec2(0.5, 0.5)));
  (u_xlat2.zw = ((u_xlat0.zw * _ProjectionParams.xx) + vec2(0.5, 0.5)));
  {
    vec4 hlslcc_movcTemp = u_xlat0;
    (hlslcc_movcTemp.z = ((u_xlatb11.x) ? (u_xlat0.x) : (u_xlat1.x)));
    (hlslcc_movcTemp.w = ((u_xlatb11.y) ? (u_xlat0.y) : (u_xlat1.y)));
    (u_xlat0 = hlslcc_movcTemp);
  }
  (u_xlat1 = (_CenterPos1.xzyw * vec4(0.5, 0.5, 0.5, 0.5)));
  (u_xlat4.xy = (u_xlat1.xy + vec2(0.5, 0.5)));
  (u_xlat14.xy = ((-u_xlat4.xy) + vec2(0.5, 0.5)));
  (u_xlat14.x = (((-u_xlat14.x) * u_xlat16_3) + u_xlat4.x));
  (u_xlat14.y = (((-u_xlat14.y) * u_xlat16_3) + 0.5));
  (u_xlat1.xy = ((u_xlat1.xy * vec2(u_xlat16_3)) + vec2(0.5, 0.5)));
  (u_xlat2.xy = ((u_xlat1.zw * _ProjectionParams.xx) + vec2(0.5, 0.5)));
  (vs_TEXCOORD9 = u_xlat2);


  (u_xlatb11.xy = lessThan(vec4(0.5, 0.5, 0.5, 0.5), u_xlat4.xyxy).xy);
  (u_xlat0.x = ((u_xlatb11.x) ? (u_xlat1.x) : (u_xlat14.x)));
  (u_xlat0.y = ((u_xlatb11.y) ? (u_xlat1.y) : (u_xlat14.y)));
  (vs_TEXCOORD8 = u_xlat0);
  return ;
}
