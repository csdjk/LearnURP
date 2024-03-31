#version 450
uniform vec3 _WorldSpaceCameraPos;
uniform vec4 _ProjectionParams;
uniform vec4 hlslcc_mtx4x4_NonJitteredViewProjMatrix[4];
layout(std140, binding = 0) uniform UnityPerDraw{
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
in vec3 in_NORMAL0;
in vec4 in_COLOR0;
out vec3 vs_TEXCOORD3;
out vec3 vs_TEXCOORD2;
out vec2 vs_TEXCOORD1;
out vec4 vs_TEXCOORD0;
out vec4 vs_TEXCOORD4;
vec4 u_xlat0;
vec4 u_xlat1;
float u_xlat6;

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
vec3 getEulerAngles() {
    mat3 rotationMatrix;
    rotationMatrix[0] = hlslcc_mtx4x4unity_ObjectToWorld[0].xyz;
    rotationMatrix[1] = hlslcc_mtx4x4unity_ObjectToWorld[1].xyz;
    rotationMatrix[2] = hlslcc_mtx4x4unity_ObjectToWorld[2].xyz;

    vec3 scale = getModelScale();
    rotationMatrix[0] /= scale.x;
    rotationMatrix[1] /= scale.y;
    rotationMatrix[2] /= scale.z;

    float sy = sqrt(rotationMatrix[0].x * rotationMatrix[0].x +  rotationMatrix[1].x * rotationMatrix[1].x);

    bool singular = sy < 1e-6;

    float x, y, z;
    if (!singular) {
        x = atan(rotationMatrix[2].y / rotationMatrix[2].z);
        y = atan(-rotationMatrix[2].x / sy);
        z = atan(rotationMatrix[1].x / rotationMatrix[0].x);
    } else {
        x = atan(-rotationMatrix[1].z / rotationMatrix[1].y);
        y = atan(-rotationMatrix[2].x / sy);
        z = 0;
    }
    return vec3(x, y, z);
}

void main(){
    vec3 angles = radians(vec3(0.0, 0.0, 0.0));
    // 平移模型
    vec3 translation = vec3(0.0, 0.0, 0.0);
    // 缩放模型
    vec3 scale = vec3(1.0, 1.0, 1.0);
    vec4 rotatedPosition = ApplyTransformations(in_POSITION0, angles, translation, scale);


  (u_xlat0.xyz = (rotatedPosition.yyy * hlslcc_mtx4x4unity_ObjectToWorld[1].xyz));
  (u_xlat0.xyz = ((hlslcc_mtx4x4unity_ObjectToWorld[0].xyz * rotatedPosition.xxx) + u_xlat0.xyz));
  (u_xlat0.xyz = ((hlslcc_mtx4x4unity_ObjectToWorld[2].xyz * rotatedPosition.zzz) + u_xlat0.xyz));
  (u_xlat0.xyz = (u_xlat0.xyz + hlslcc_mtx4x4unity_ObjectToWorld[3].xyz));

  (u_xlat1 = (u_xlat0.yyyy * hlslcc_mtx4x4_NonJitteredViewProjMatrix[1]));
  (u_xlat1 = ((hlslcc_mtx4x4_NonJitteredViewProjMatrix[0] * u_xlat0.xxxx) + u_xlat1));
  (u_xlat1 = ((hlslcc_mtx4x4_NonJitteredViewProjMatrix[2] * u_xlat0.zzzz) + u_xlat1));

  //vs_TEXCOORD3 = viewDirWS
  (vs_TEXCOORD3.xyz = ((-u_xlat0.xyz) + _WorldSpaceCameraPos.xyz));

  (gl_Position = (u_xlat1 + hlslcc_mtx4x4_NonJitteredViewProjMatrix[3]));


  (u_xlat0.x = dot(in_NORMAL0.xyz, hlslcc_mtx4x4unity_WorldToObject[0].xyz));
  (u_xlat0.y = dot(in_NORMAL0.xyz, hlslcc_mtx4x4unity_WorldToObject[1].xyz));
  (u_xlat0.z = dot(in_NORMAL0.xyz, hlslcc_mtx4x4unity_WorldToObject[2].xyz));
  (u_xlat6 = dot(u_xlat0.xyz, u_xlat0.xyz));
  (u_xlat6 = max(u_xlat6, 0.0));
  (u_xlat6 = inversesqrt(u_xlat6));
  //vs_TEXCOORD2 = normalWS
  (vs_TEXCOORD2.xyz = (vec3(u_xlat6) * u_xlat0.xyz));

  //vs_TEXCOORD1 = uv
  (vs_TEXCOORD1.xy = in_TEXCOORD0.xy);

  (u_xlat0 = (in_POSITION0.yyyy * hlslcc_mtx4x4unity_MatrixMVP[1]));
  (u_xlat0 = ((hlslcc_mtx4x4unity_MatrixMVP[0] * in_POSITION0.xxxx) + u_xlat0));
  (u_xlat0 = ((hlslcc_mtx4x4unity_MatrixMVP[2] * in_POSITION0.zzzz) + u_xlat0));
  (u_xlat0 = (u_xlat0 + hlslcc_mtx4x4unity_MatrixMVP[3]));
  (u_xlat0.y = (u_xlat0.y * _ProjectionParams.x));
  (u_xlat1.xzw = (u_xlat0.xwy * vec3(0.5, 0.5, 0.5)));
  //vs_TEXCOORD0 = screenPos
  (vs_TEXCOORD0.zw = u_xlat0.zw);
  (vs_TEXCOORD0.xy = (u_xlat1.zz + u_xlat1.xw));
  //vs_TEXCOORD4 = color
  (vs_TEXCOORD4 = in_COLOR0);
  return ;
}
