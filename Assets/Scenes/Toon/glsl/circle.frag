#version 450
uniform vec4 _Time;
uniform float _MainTexScale;
uniform vec4 _MainColor;
uniform vec4 _MaskTex_ST;
uniform vec2 _MaskSpeed;
uniform float _MaskScale;
uniform float _MaskOffset;
layout(location = 0) uniform sampler2D _MainTex;
layout(location = 1) uniform sampler2D _MaskTex;
in vec2 vs_TEXCOORD0;
in vec3 vs_TEXCOORD2;
layout(location = 0) out vec4 SV_Target0;
vec3 u_xlat0;
float u_xlat16_0;
vec4 u_xlat1;
vec4 u_xlat16_1;
float u_xlat16_2;
float u_xlat16_6;
float u_xlat9;
void main(){
  (u_xlat0.xy = ((vs_TEXCOORD0.xy * _MaskTex_ST.xy) + _MaskTex_ST.zw));
  (u_xlat0.xy = ((_Time.yy * _MaskSpeed.xy) + u_xlat0.xy));

  (u_xlat1.x = u_xlat0.x);
  (u_xlat1.y = ((_Time.y * 0.02) + u_xlat0.y));
  //mask
  (u_xlat16_6 = texture(_MaskTex, u_xlat1.xy).x);


  (u_xlat9 = (_Time.y * 0.02));
  (u_xlat1.y = (-u_xlat9));
  (u_xlat1.x = -0.0);
  (u_xlat0.xy = (u_xlat0.xy + u_xlat1.xy));
  (u_xlat16_0 = texture(_MaskTex, u_xlat0.xy).x);



  (u_xlat16_2 = (u_xlat16_6 + u_xlat16_0));
  (u_xlat0.x = ((u_xlat16_2 * _MaskScale) + _MaskOffset));
  (u_xlat0.x = clamp(u_xlat0.x, 0.0, 1.0));

  (u_xlat16_1 = texture(_MainTex, vs_TEXCOORD0.xy));
  (u_xlat1 = (u_xlat16_1 * _MainColor));

  (SV_Target0.w = (u_xlat0.x * u_xlat1.w));
  (u_xlat0.xyz = (u_xlat1.xyz * vec3(_MainTexScale)));

  SV_Target0.w = 1;
  (SV_Target0.xyz = vs_TEXCOORD2.xyz);


  return ;
}
