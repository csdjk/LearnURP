#version 450
vec4 ImmCB_0[4];
uniform vec4 _ScaledScreenParams;
uniform vec4 hlslcc_mtx4x4unity_MatrixInvP[4];
uniform int _DITHER_FADE_IN;
uniform float _OneMinusGlobalMainIntensity;
uniform float _ES_EP_EffectParticleTop;
uniform float _ES_EP_EffectParticleBottom;
uniform float _ES_EP_EffectParticle;
uniform float _ES_EffectIntensityScale;
uniform float _GlobalOneMinusAvatarIntensity;
uniform float _GlobalOneMinusAvatarIntensityEnable;
uniform float _OneMinusGlobalMainIntensityEnable;
layout(std140, binding = 0) uniform VolumetricFog{
  vec4 Xhlslcc_UnusedX_FogPhaseParams;
  vec4 _SliceZParams;
  vec4 Xhlslcc_UnusedX_FogCutoffParams;
  vec4 Xhlslcc_UnusedX_FogFadeParams;
  int Xhlslcc_UnusedX_FrameIndexMod9;
  vec4 Xhlslcc_UnusedX_TemporalOffset;
  vec4 Xhlslcc_UnusedX_FogAmbientColor;
  vec4 Xhlslcc_UnusedX_FogDimensions;
  int _VolumetricFogEnable;
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
layout(location = 0) uniform sampler3D _FogTex;
layout(location = 1) uniform sampler2D _MainTex;
layout(location = 2) uniform sampler2D _MaskTex;
in vec4 vs_COLOR0;
in vec4 vs_TEXCOORD0;
in vec2 vs_texcoord4;
in vec4 vs_TEXCOORD5;
layout(location = 0) out vec4 SV_TARGET0;
vec2 u_xlat0;
vec4 u_xlat16_0;
ivec2 u_xlati0;
uvec2 u_xlatu0;
bool u_xlatb0;
vec4 u_xlat1;
vec4 u_xlat16_1;
vec4 u_xlat10_1;
int u_xlati1;
bvec2 u_xlatb1;
float u_xlat16_2;
vec4 u_xlat16_3;
vec3 u_xlat4;
bvec2 u_xlatb4;
bool u_xlatb5;
float u_xlat6;
vec3 u_xlat16_8;
vec3 u_xlat10;
float u_xlat11;
float u_xlat16_14;
float u_xlat17;
void main(){
  (ImmCB_0[0] = vec4(1.0, 0.0, 0.0, 0.0));
  (ImmCB_0[1] = vec4(0.0, 1.0, 0.0, 0.0));
  (ImmCB_0[2] = vec4(0.0, 0.0, 1.0, 0.0));
  (ImmCB_0[3] = vec4(0.0, 0.0, 0.0, 1.0));
  (u_xlatb0 = (vec4(0.0, 0.0, 0.0, 0.0) != vec4(_Dither_On)));
  if (u_xlatb0)
  {
    (u_xlatb0 = (_DitherAlpha < 0.94999999));
    if (u_xlatb0)
    {
      (u_xlat0.xy = (vs_TEXCOORD5.yx / vs_TEXCOORD5.ww));
      (u_xlat0.xy = (u_xlat0.xy * _ScaledScreenParams.yx));
      (u_xlatu0.xy = uvec2(u_xlat0.xy));
      (u_xlati0.xy = ivec2(uvec2((u_xlatu0.x & 3u), (u_xlatu0.y & 3u))));
      (u_xlat1.x = dot(vec4(1.0, 13.0, 4.0, 16.0), ImmCB_0[u_xlati0.y]));
      (u_xlat1.y = dot(vec4(9.0, 5.0, 12.0, 8.0), ImmCB_0[u_xlati0.y]));
      (u_xlat1.z = dot(vec4(3.0, 15.0, 2.0, 14.0), ImmCB_0[u_xlati0.y]));
      (u_xlat1.w = dot(vec4(11.0, 7.0, 10.0, 6.0), ImmCB_0[u_xlati0.y]));
      (u_xlat0.x = dot(u_xlat1, ImmCB_0[u_xlati0.x]));
      (u_xlat6 = ((-u_xlat0.x) + 17.0));
      (u_xlat0.x = (((_DITHER_FADE_IN != 0)) ? (u_xlat6) : (u_xlat0.x)));
      (u_xlat0.x = ((_DitherAlpha * 17.0) + (-u_xlat0.x)));
      (u_xlat0.x = (u_xlat0.x + -0.0099999998));
    }
    else
    {
      (u_xlat0.x = 1.0);
    }
    (u_xlat0.x = min(u_xlat0.x, 1.0));
    (u_xlat16_0.x = u_xlat0.x);
  }
  else
  {
    (u_xlat16_0.x = 1.0);
  }
  (u_xlat16_2 = (u_xlat16_0.x + 1.0));
  (u_xlat16_2 = floor(u_xlat16_2));
  (u_xlat16_2 = max(u_xlat16_2, 0.0));
  (u_xlati1 = int(u_xlat16_2));
  if ((u_xlati1 == 0))
  {
    discard;
  }
  (u_xlat16_0 = texture(_MainTex, vs_TEXCOORD0.xy));
  (u_xlatb1.x = (_MASKCHANEL == 0.0));
  if (u_xlatb1.x)
  {
    (u_xlat16_1.xyz = texture(_MaskTex, vs_TEXCOORD0.zw).xyz);
    (u_xlat16_2 = dot(u_xlat16_1.xyz, _MaskChannel.xyz));
    (u_xlat16_2 = (u_xlat16_2 + _MaskUVoffset.z));
    (u_xlat16_2 = ((u_xlat16_2 * vs_texcoord4.x) + _MaskSpeed.z));
    (u_xlat16_8.x = ((-_MaskSpeed.w) + 1.0));
    (u_xlat16_2 = ((-u_xlat16_8.x) + u_xlat16_2));
    (u_xlat16_8.x = ((-u_xlat16_8.x) + _MaskSpeed.w));
    (u_xlat16_8.x = (1.0 / u_xlat16_8.x));
    (u_xlat16_2 = (u_xlat16_8.x * u_xlat16_2));
    (u_xlat16_2 = clamp(u_xlat16_2, 0.0, 1.0));
  }
  else
  {
    (u_xlat16_8.x = (vs_TEXCOORD0.z + _MaskSpeed.z));
    (u_xlat16_14 = ((-_MaskSpeed.w) + 1.0));
    (u_xlat16_8.x = ((-u_xlat16_14) + u_xlat16_8.x));
    (u_xlat16_14 = ((-u_xlat16_14) + _MaskSpeed.w));
    (u_xlat16_14 = (1.0 / u_xlat16_14));
    (u_xlat16_8.x = (u_xlat16_14 * u_xlat16_8.x));
    (u_xlat16_8.x = clamp(u_xlat16_8.x, 0.0, 1.0));
    (u_xlatb1.xy = equal(vec4(_MASKCHANEL), vec4(1.0, 2.0, 0.0, 0.0)).xy);
    (u_xlat16_14 = ((u_xlatb1.y) ? (1.0) : (0.0)));
    (u_xlat16_2 = ((u_xlatb1.x) ? (u_xlat16_8.x) : (u_xlat16_14)));
  }
  (u_xlat16_1 = (u_xlat16_0 * vs_COLOR0));
  (u_xlat16_1.w = u_xlat16_1.w);
  (u_xlat16_1.w = clamp(u_xlat16_1.w, 0.0, 1.0));
  (u_xlat16_8.xyz = (u_xlat16_0.xyz + _MainChannel.www));
  (u_xlat16_8.xyz = clamp(u_xlat16_8.xyz, 0.0, 1.0));
  (u_xlat16_3.x = dot(u_xlat16_0.xyz, _MainChannel.xyz));
  (u_xlat16_3.w = (u_xlat16_3.x * vs_COLOR0.w));
  (u_xlat16_3.w = clamp(u_xlat16_3.w, 0.0, 1.0));
  (u_xlat16_3.xyz = (u_xlat16_8.xyz * vs_COLOR0.xyz));
  (u_xlatb4.xy = equal(ivec4(_CL), ivec4(1, 2, 0, 0)).xy);
  (u_xlat16_8.x = dot(_MainChannelRGB, u_xlat16_0));
  (u_xlat16_8.x = clamp(u_xlat16_8.x, 0.0, 1.0));
  (u_xlat16_14 = dot(_MainChannel, u_xlat16_0));
  (u_xlat16_0.w = (u_xlat16_14 * vs_COLOR0.w));
  (u_xlat16_0.w = clamp(u_xlat16_0.w, 0.0, 1.0));
  (u_xlat16_0.xyz = (u_xlat16_8.xxx * vs_COLOR0.xyz));
  (u_xlat16_0 = ((u_xlatb4.y) ? (u_xlat16_0) : (vs_COLOR0)));
  (u_xlat16_0 = ((u_xlatb4.x) ? (u_xlat16_3) : (u_xlat16_0)));
  (u_xlat16_0 = (((_CL != 0)) ? (u_xlat16_0) : (u_xlat16_1)));
  (u_xlat16_2 = (u_xlat16_2 * u_xlat16_0.w));
  (u_xlat1.xyz = (vs_TEXCOORD5.xyz / vs_TEXCOORD5.www));
  (u_xlat16_8.xy = ((u_xlat1.xy * vec2(2.0, 2.0)) + vec2(-1.0, -1.0)));
  (u_xlat4.xy = (u_xlat16_8.yy * hlslcc_mtx4x4unity_MatrixInvP[1].zw));
  (u_xlat4.xy = ((hlslcc_mtx4x4unity_MatrixInvP[0].zw * u_xlat16_8.xx) + u_xlat4.xy));
  (u_xlat4.xy = ((hlslcc_mtx4x4unity_MatrixInvP[2].zw * u_xlat1.zz) + u_xlat4.xy));
  (u_xlat4.xy = (u_xlat4.xy + hlslcc_mtx4x4unity_MatrixInvP[3].zw));
  (u_xlat4.x = ((-u_xlat4.x) / u_xlat4.y));
  (u_xlat4.x = ((u_xlat4.x * _SliceZParams.x) + _SliceZParams.y));
  (u_xlat4.x = max(u_xlat4.x, 9.9999997e-05));
  (u_xlat4.x = log2(u_xlat4.x));
  (u_xlat1.w = (u_xlat4.x * _SliceZParams.z));
  (u_xlat10_1 = textureLod(_FogTex, u_xlat1.xyw, 0.0));
  (u_xlat16_8.xyz = ((u_xlat16_0.xyz * u_xlat10_1.www) + u_xlat10_1.xyz));
  (u_xlat16_3.x = float(_VolumetricFogEnable));
  (u_xlat16_8.xyz = ((-u_xlat16_0.xyz) + u_xlat16_8.xyz));
  (u_xlat16_8.xyz = (u_xlat16_8.xyz * u_xlat16_3.xxx));
  (u_xlat4.xyz = ((vec3(vec3(_VFogInst, _VFogInst, _VFogInst)) * u_xlat16_8.xyz) + u_xlat16_0.xyz));
  (u_xlat16_8.x = ((-_OneMinusOpacityDitherScale) + 1.0));
  (u_xlat16_2 = (u_xlat16_8.x * u_xlat16_2));
  (u_xlat16_8.x = (((-_GlobalOneMinusAvatarIntensityEnable) * _GlobalOneMinusAvatarIntensity) + 1.0));
  (u_xlat16_8.xyz = (u_xlat16_8.xxx * u_xlat4.xyz));
  (u_xlat16_3.x = (((-_OneMinusGlobalMainIntensityEnable) * _OneMinusGlobalMainIntensity) + 1.0));
  (u_xlat16_8.xyz = (u_xlat16_8.xyz * u_xlat16_3.xxx));
  (u_xlat16_8.xyz = (u_xlat16_8.xyz * vec3(vec3(_ES_EffectIntensityScale, _ES_EffectIntensityScale, _ES_EffectIntensityScale))));
  (u_xlat16_3.x = max(u_xlat16_8.y, u_xlat16_8.x));
  (u_xlat16_3.x = max(u_xlat16_8.z, u_xlat16_3.x));
  (u_xlat16_3.x = (u_xlat16_2 * u_xlat16_3.x));
  (u_xlat4.x = max(u_xlat16_3.x, 0.0099999998));
  (u_xlat10.xyz = (u_xlat16_8.xyz / u_xlat4.xxx));
  (u_xlatb5 = (_ES_EP_EffectParticleBottom < u_xlat4.x));
  (u_xlat11 = ((-_ES_EP_EffectParticleBottom) + _ES_EP_EffectParticleTop));
  (u_xlat17 = (u_xlat4.x + (-_ES_EP_EffectParticleBottom)));
  (u_xlat11 = (1.0 / u_xlat11));
  (u_xlat11 = (u_xlat11 * u_xlat17));
  (u_xlat11 = clamp(u_xlat11, 0.0, 1.0));
  (u_xlat17 = ((u_xlat11 * -2.0) + 3.0));
  (u_xlat11 = (u_xlat11 * u_xlat11));
  (u_xlat11 = (u_xlat11 * u_xlat17));
  (u_xlat16_8.x = ((-_ES_EP_EffectParticleBottom) + _ES_EP_EffectParticleTop));
  (u_xlat16_8.x = ((u_xlat11 * u_xlat16_8.x) + _ES_EP_EffectParticleBottom));
  (u_xlat11 = ((-u_xlat4.x) + u_xlat16_8.x));
  (u_xlat11 = ((_ES_EP_EffectParticle * u_xlat11) + u_xlat4.x));
  (u_xlat4.x = ((u_xlatb5) ? (u_xlat11) : (u_xlat4.x)));
  (u_xlat4.xyz = (u_xlat4.xxx * u_xlat10.xyz));
  (SV_TARGET0.xyz = u_xlat4.xyz);
  (SV_TARGET0.w = u_xlat16_2);
  return ;
}
