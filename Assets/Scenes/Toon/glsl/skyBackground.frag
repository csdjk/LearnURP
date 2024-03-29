#version 450
uniform vec4 _Time;
uniform vec4 _BaseTex_ST;
uniform float _BaseTexInst;
uniform vec4 _Pattern1;
uniform float _Pattern1SpeedX;
uniform float _Pattern1SpeedY;
uniform float _MainDistortion;
uniform float _MaskDistortion;
uniform float _MainSpeedX;
uniform float _MainSpeedY;
uniform float _MaskRangeMin;
uniform float _MaskRangeMax;
uniform float _MainRangeMin;
uniform float _MainRangeMax;
uniform float _ColorRangeMin;
uniform float _ColorRangeMax;
uniform float _ColorRangeTop;
uniform vec4 _Color;
uniform vec4 _Color1;
uniform vec4 _Color2;
uniform vec4 _Color3;
uniform float _SatRangeStar;
uniform float _SatRangeEnd;
uniform vec4 _BaseTexRange;
uniform float _BaseTexSharp;
uniform float _BaseTexMax;
uniform vec4 _BaseTexSpeed;
layout(std140, binding = 0) uniform UnityPerMaterial{
  vec4 Xhlslcc_UnusedX_MainColor;
  vec3 Xhlslcc_UnusedX_EmissionColor;
  vec4 _MainTex_ST;
  float Xhlslcc_UnusedX_EmissionIntensity;
  float Xhlslcc_UnusedX_FillRatio;
  float Xhlslcc_UnusedX_LumiFactor;
  float Xhlslcc_UnusedX_CutOff;
  float _Opacity;
  float Xhlslcc_UnusedX_ReverseU;
  float Xhlslcc_UnusedX_ReverseV;
  float Xhlslcc_UnusedX_TSAspectRatio;
  float Xhlslcc_UnusedX_DistortionIntensity;
  float Xhlslcc_UnusedX_MaxDistance;
  float Xhlslcc_UnusedX_VertexAlpha;
  vec4 Xhlslcc_UnusedX_DistortionTex_ST;
  uint Xhlslcc_UnusedX_UseVertexMask;
  vec4 Xhlslcc_UnusedX_MaskTex_ST;
  vec4 Xhlslcc_UnusedX_MaskChannle;
  vec4 Xhlslcc_UnusedX_TimeScale;
  uint Xhlslcc_UnusedX_LUTMode;
  uint Xhlslcc_UnusedX_LUTRChannle;
  uint Xhlslcc_UnusedX_LUTGChannle;
  uint Xhlslcc_UnusedX_LUTBChannle;
  uint Xhlslcc_UnusedX_LUTCellNum;
  float Xhlslcc_UnusedX_LUTIntensity;
  float Xhlslcc_UnusedX_Dither_On;
  float Xhlslcc_UnusedX_DitherAlpha;
};
layout(location = 0) uniform sampler2D _MainTex;
layout(location = 1) uniform sampler2D _BaseTex;
in vec3 vs_TEXCOORD3;
in vec3 vs_TEXCOORD2;
in vec2 vs_TEXCOORD1;
in vec2 vs_TEXCOORD5;
in vec4 vs_TEXCOORD4;
in vec4 vs_TEXCOORD6;
in vec3 vs_TEXCOORD10;
layout(location = 0) out vec4 SV_Target0;
vec3 u_xlat0;
vec3 u_xlat1;
float u_xlat16_1;
vec4 u_xlat2;
vec3 u_xlat16_3;
vec3 u_xlat16_4;
vec3 u_xlat5;
float u_xlat16_5;
vec2 u_xlat6;
vec3 u_xlat16_8;
vec3 u_xlat16_9;
vec2 u_xlat10;
vec2 u_xlat11;
float u_xlat15;
float u_xlat16_18;
void main(){
    //  vs_TEXCOORD1 = uv;
    //  vs_TEXCOORD2 = normalWS;
    //  vs_TEXCOORD3 = viewDirWS;
    //  vs_TEXCOORD4 = COLOR0;
    //  vs_TEXCOORD5 = uv1;
    //  vs_TEXCOORD6 = screenUV;
    //  vs_TEXCOORD10 = positionWS;
vec3 debugColor = vec3(0.0, 0.0, 0.0);

  (u_xlat0.xy = ((vs_TEXCOORD10.xy * _Pattern1.xy) + _Pattern1.zw));
  (u_xlat0.xy = ((vec2(_Pattern1SpeedX, _Pattern1SpeedY) * _Time.yy) + u_xlat0.xy));
  (u_xlat10.xy = floor(u_xlat0.xy));
  (u_xlat0.xy = fract(u_xlat0.xy));

  (u_xlat1.xy = (u_xlat10.xy + vec2(1.0, 1.0)));
  (u_xlat1.x = dot(u_xlat1.xy, vec2(127.1, 311.70001)));
  (u_xlat1.x = sin(u_xlat1.x));
  (u_xlat1.x = (u_xlat1.x * 4.3758545));
  (u_xlat1.x = fract(u_xlat1.x));
  (u_xlat1.x = ((u_xlat1.x * 2.0) + -1.0));
  (u_xlat6.xy = (u_xlat0.xy + vec2(-1.0, -1.0)));
  (u_xlat1.x = dot(u_xlat1.xx, u_xlat6.xy));
  (u_xlat2 = (u_xlat10.xyxy + vec4(1.0, 0.0, 0.0, 1.0)));
  (u_xlat10.x = dot(u_xlat10.xy, vec2(127.1, 311.70001)));
  (u_xlat10.x = sin(u_xlat10.x));
  (u_xlat10.x = (u_xlat10.x * 4.3758545));
  (u_xlat10.x = fract(u_xlat10.x));
  (u_xlat10.x = ((u_xlat10.x * 2.0) + -1.0));
  (u_xlat10.x = dot(u_xlat10.xx, u_xlat0.xy));


  (u_xlat15 = dot(u_xlat2.zw, vec2(127.1, 311.70001)));
  (u_xlat6.x = dot(u_xlat2.xy, vec2(127.1, 311.70001)));
  (u_xlat6.x = sin(u_xlat6.x));
  (u_xlat6.x = (u_xlat6.x * 4.3758545));
  (u_xlat6.x = fract(u_xlat6.x));
  (u_xlat6.x = ((u_xlat6.x * 2.0) + -1.0));

//----------------------------------------------

// debugColor = u_xlat6.xxx;

  (u_xlat15 = sin(u_xlat15));
  (u_xlat15 = (u_xlat15 * 4.3758545));
  (u_xlat15 = fract(u_xlat15));
  (u_xlat15 = ((u_xlat15 * 2.0) + -1.0));
  (u_xlat2 = (u_xlat0.xyxy + vec4(-1.0, -0.0, -0.0, -1.0)));
  (u_xlat10.y = dot(vec2(u_xlat15), u_xlat2.zw));
  (u_xlat1.y = dot(u_xlat6.xx, u_xlat2.xy));
  (u_xlat1.xy = ((-u_xlat10.yx) + u_xlat1.xy));
  (u_xlat11.xy = (u_xlat0.xy * u_xlat0.xy));
  (u_xlat0.xy = (((-u_xlat0.xy) * vec2(2.0, 2.0)) + vec2(3.0, 3.0)));
  (u_xlat0.xy = (u_xlat0.xy * u_xlat11.xy));
  (u_xlat15 = ((u_xlat0.x * u_xlat1.x) + u_xlat10.y));
  (u_xlat0.x = ((u_xlat0.x * u_xlat1.y) + u_xlat10.x));
  (u_xlat10.x = ((-u_xlat0.x) + u_xlat15));
  (u_xlat0.x = ((u_xlat0.y * u_xlat10.x) + u_xlat0.x));
  (u_xlat0.xy = ((u_xlat0.xx * vec2(_MainDistortion, _MaskDistortion)) + vs_TEXCOORD5.yy));
  (u_xlat16_3.x = (u_xlat0.y + (-_MaskRangeMin)));
  (u_xlat16_8.x = ((-_MaskRangeMin) + _MaskRangeMax));
  (u_xlat16_8.x = (1.0 / u_xlat16_8.x));
  (u_xlat16_3.x = (u_xlat16_8.x * u_xlat16_3.x));
  (u_xlat16_3.x = clamp(u_xlat16_3.x, 0.0, 1.0));
  (u_xlat16_8.x = ((u_xlat16_3.x * -2.0) + 3.0));
  (u_xlat16_3.x = (u_xlat16_3.x * u_xlat16_3.x));
  (u_xlat16_3.x = (u_xlat16_3.x * u_xlat16_8.x));
  (u_xlat16_3.x = (u_xlat16_3.x * vs_TEXCOORD4.w));

// debugColor.xy = vs_TEXCOORD2.xy;
//----------------------------------------------


  (u_xlat0.z = vs_TEXCOORD5.x);
  (u_xlat5.xy = ((u_xlat0.zx * _MainTex_ST.xy) + _MainTex_ST.zw));
  (u_xlat5.xy = ((_Time.yy * vec2(_MainSpeedX, _MainSpeedY)) + u_xlat5.xy));
  (u_xlat16_5 = texture(_MainTex, u_xlat5.xy).x);
  (u_xlat16_8.x = (u_xlat16_5 + -1.0));
  (u_xlat16_3.x = ((u_xlat16_3.x * u_xlat16_8.x) + 1.0));


  (u_xlat5.x = (u_xlat0.x + (-_MainRangeMin)));
  (u_xlat0.xz = (u_xlat0.xx + (-vec2(_ColorRangeMax, _ColorRangeMin))));
  (u_xlat15 = ((-_MainRangeMin) + _MainRangeMax));
  (u_xlat15 = (1.0 / u_xlat15));
  (u_xlat5.x = (u_xlat15 * u_xlat5.x));
  (u_xlat5.x = clamp(u_xlat5.x, 0.0, 1.0));
  (u_xlat15 = ((u_xlat5.x * -2.0) + 3.0));
  (u_xlat5.x = (u_xlat5.x * u_xlat5.x));
  (u_xlat5.x = ((u_xlat15 * u_xlat5.x) + -1.0));
  (u_xlat15 = (vs_TEXCOORD5.y + -0.050000001));
  (u_xlat15 = (u_xlat15 * 6.6666665));
  (u_xlat15 = clamp(u_xlat15, 0.0, 1.0));
  (u_xlat1.x = ((u_xlat15 * -2.0) + 3.0));
  (u_xlat15 = (u_xlat15 * u_xlat15));
  (u_xlat15 = (u_xlat15 * u_xlat1.x));
  (u_xlat5.x = ((u_xlat15 * u_xlat5.x) + 1.0));
// debugColor.xyz = u_xlat5.xxx;

//----------------------------------------------
debugColor.xyz = vs_TEXCOORD10.xyz;

  (u_xlat16_3.x = (u_xlat16_3.x * u_xlat5.x));
  (SV_Target0.w = (u_xlat16_3.x * _Opacity));
  (u_xlat5.xz = ((-vec2(_ColorRangeMax, _ColorRangeMin)) + vec2(_ColorRangeTop, _ColorRangeMax)));
  (u_xlat5.xz = (vec2(1.0, 1.0) / u_xlat5.xz));
  (u_xlat0.xy = (u_xlat5.xz * u_xlat0.xz));
  (u_xlat0.xy = clamp(u_xlat0.xy, 0.0, 1.0));
  (u_xlat10.xy = ((u_xlat0.xy * vec2(-2.0, -2.0)) + vec2(3.0, 3.0)));
  (u_xlat0.xy = (u_xlat0.xy * u_xlat0.xy));
  (u_xlat0.xy = (u_xlat0.xy * u_xlat10.xy));
  (u_xlat16_3.x = (u_xlat0.y * vs_TEXCOORD4.w));
  (u_xlat16_8.xyz = (_Color.xyz + (-_Color1.xyz)));
  (u_xlat16_8.xyz = ((u_xlat0.xxx * u_xlat16_8.xyz) + _Color1.xyz));
  (u_xlat0.xy = (vs_TEXCOORD6.xy / vs_TEXCOORD6.ww));
  (u_xlat0.xy = ((-u_xlat0.xy) + vec2(0.5, 0.5)));
  (u_xlat0.xy = ((-abs(u_xlat0.xy)) + vec2(1.0, 1.0)));
  (u_xlat16_4.x = (u_xlat0.y + 0.1));
  (u_xlat16_4.x = (u_xlat16_4.x * 1.081081));
  (u_xlat16_4.x = clamp(u_xlat16_4.x, 0.0, 1.0));
  (u_xlat16_9.x = ((u_xlat16_4.x * -2.0) + 3.0));
  (u_xlat16_4.x = (u_xlat16_4.x * u_xlat16_4.x));
  (u_xlat16_4.x = (u_xlat16_4.x * u_xlat16_9.x));
  (u_xlat16_4.x = ((u_xlat0.x * u_xlat16_4.x) + (-_SatRangeStar)));
  (u_xlat16_9.x = ((-_SatRangeStar) + _SatRangeEnd));
  (u_xlat16_9.x = (1.0 / u_xlat16_9.x));
  (u_xlat16_4.x = (u_xlat16_9.x * u_xlat16_4.x));
  (u_xlat16_4.x = clamp(u_xlat16_4.x, 0.0, 1.0));
  (u_xlat16_9.x = ((u_xlat16_4.x * -2.0) + 3.0));
  (u_xlat16_4.x = (u_xlat16_4.x * u_xlat16_4.x));
  (u_xlat16_4.x = (u_xlat16_4.x * u_xlat16_9.x));
  (u_xlat16_9.x = dot(vec3(0.30000001, 0.58999997, 0.11), _Color2.xyz));
  (u_xlat16_9.xyz = (u_xlat16_9.xxx + (-_Color2.xyz)));
  (u_xlat16_4.xyz = ((u_xlat16_4.xxx * u_xlat16_9.xyz) + _Color2.xyz));
  (u_xlat16_8.xyz = (u_xlat16_8.xyz + (-u_xlat16_4.xyz)));
  (u_xlat16_3.xyz = ((u_xlat16_3.xxx * u_xlat16_8.xyz) + u_xlat16_4.xyz));
  (u_xlat0.xyz = ((-u_xlat16_3.xyz) + _Color3.xyz));

// debugColor.xyz = vs_TEXCOORD2.xyz;

  (u_xlat15 = dot(vs_TEXCOORD3.xyz, vs_TEXCOORD3.xyz));
  (u_xlat15 = inversesqrt(u_xlat15));
  (u_xlat1.xyz = (vec3(u_xlat15) * vs_TEXCOORD3.xyz));
  (u_xlat15 = dot(vs_TEXCOORD2.xyz, vs_TEXCOORD2.xyz));
  (u_xlat15 = inversesqrt(u_xlat15));
  (u_xlat2.xyz = (vec3(u_xlat15) * vs_TEXCOORD2.xyz));
  (u_xlat15 = dot(u_xlat2.xyz, u_xlat1.xyz));
  (u_xlat1.x = (1.0 / _BaseTexRange.x));
  (u_xlat15 = (u_xlat15 * u_xlat1.x));
  (u_xlat15 = clamp(u_xlat15, 0.0, 1.0));
  (u_xlat1.x = ((u_xlat15 * -2.0) + 3.0));
  (u_xlat15 = (u_xlat15 * u_xlat15));
  (u_xlat15 = (u_xlat15 * u_xlat1.x));
  (u_xlat15 = (u_xlat15 * _BaseTexInst));
  (u_xlat1.xy = ((vs_TEXCOORD1.xy * _BaseTex_ST.xy) + _BaseTex_ST.zw));
  (u_xlat1.xy = ((_BaseTexSpeed.xy * _Time.yy) + u_xlat1.xy));
  (u_xlat16_1 = texture(_BaseTex, u_xlat1.xy).x);
  (u_xlat16_18 = (u_xlat16_1 + (-_BaseTexSharp)));
  (u_xlat16_4.x = ((-_BaseTexSharp) + _BaseTexMax));
  (u_xlat16_4.x = (1.0 / u_xlat16_4.x));
  (u_xlat16_18 = (u_xlat16_18 * u_xlat16_4.x));
  (u_xlat16_18 = clamp(u_xlat16_18, 0.0, 1.0));
  (u_xlat16_4.x = ((u_xlat16_18 * -2.0) + 3.0));
  (u_xlat16_18 = (u_xlat16_18 * u_xlat16_18));
  (u_xlat16_18 = (u_xlat16_18 * u_xlat16_4.x));
  (u_xlat15 = (u_xlat15 * u_xlat16_18));
  (u_xlat0.xyz = ((vec3(u_xlat15) * u_xlat0.xyz) + u_xlat16_3.xyz));
  (SV_Target0.xyz = u_xlat0.xyz);
  SV_Target0.xyz = debugColor;

  SV_Target0.w = 1;

  return ;
}
