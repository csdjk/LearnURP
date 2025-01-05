#version 450
#extension GL_EXT_texture_buffer : require

#define HLSLCC_ENABLE_UNIFORM_BUFFERS 1
#if HLSLCC_ENABLE_UNIFORM_BUFFERS
#define UNITY_UNIFORM
#else
#define UNITY_UNIFORM uniform
#endif
#define UNITY_SUPPORTS_UNIFORM_LOCATION 1
#if UNITY_SUPPORTS_UNIFORM_LOCATION
#define UNITY_LOCATION(x) layout(location = x)
#define UNITY_BINDING(x) layout(binding = x, std140)
#else
#define UNITY_LOCATION(x)
#define UNITY_BINDING(x) layout(std140)
#endif
uniform 	vec4 _ProjectionParams;
uniform 	vec4 hlslcc_mtx4x4glstate_matrix_projection[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixV[4];
uniform 	mediump float _WangQiOn;
UNITY_BINDING(1) uniform UnityPerDraw {
	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
	vec4 hlslcc_mtx4x4unity_WorldToObject[4];
	vec4 unity_LODFade;
	mediump vec4 unity_WorldTransformParams;
	vec4 unity_RenderingLayer;
	vec4 unity_ProbesOcclusion;
	mediump vec4 unity_SpecCube0_HDR;
	vec4 unity_SpecCube0_BoxMax;
	vec4 unity_SpecCube0_BoxMin;
	vec4 unity_SpecCube0_ProbePosition;
	mediump vec4 unity_SHAr;
	mediump vec4 unity_SHAg;
	mediump vec4 unity_SHAb;
	mediump vec4 unity_SHBr;
	mediump vec4 unity_SHBg;
	mediump vec4 unity_SHBb;
	mediump vec4 unity_SHC;
};
UNITY_BINDING(0) uniform UnityPerMaterial {
	mediump float _Screen_Door_Weight;
	mediump float _RenderType;
	mediump float _Particle_;
	mediump float _Rotation;
	mediump float _VertexColor_Ban;
	mediump float _Add_Blend_Mode;
	float _SoftParticleFactor;
	mediump vec4 _Final_VertexColor;
	mediump float _Highlight_Alpha;
	mediump float _Ink_Ignore;
	mediump vec4 _Mesh_Final_VertexColor;
	mediump vec4 _Main_Color;
	mediump vec4 _Main_TilingOffset;
	vec4 _Main_CombinedProps1;
	mediump vec4 _CustomDyeColor;
	vec4 _FlipBook_CombinedProps1;
	mediump vec4 _Distort_TilingOffset;
	vec4 _Distort_CombinedProps1;
	mediump vec4 _Distort_CombinedProps2;
	mediump vec4 _Distort_CombinedProps3;
	mediump float _Dst_Blend;
	mediump float _Blend_Mode;
	mediump vec4 _Blend_Color;
	mediump vec4 _Blend_TilingOffset;
	vec4 _Blend_CombinedProps1;
	mediump vec4 _Fresnel_Color;
	mediump vec4 _Fresnel_CombinedProps1;
	mediump vec4 _Alpha_Fresnel_CombinedProps1;
	mediump vec4 _Alpha_TilingOffset;
	vec4 _Alpha_CombinedProps1;
	mediump float _Alpha_Rotation;
	mediump vec4 _Dissolve_TilingOffset;
	mediump vec4 _Dissolve_EdgeColor;
	mediump vec4 _Dissolve_CombinedProps1;
	mediump vec4 _Dissolve_CombinedProps2;
	mediump float _Effect_Dissolve_Key;
	mediump vec4 _Effect_Dissolve_EdgeColor;
	vec4 _Effect_Dissolve_TilingOffset;
	vec4 _Effect_Dissolve_CombinedProps1;
	vec4 _Effect_Dissolve_CombinedProps2;
	vec4 _Noise_TilingOffset;
	vec4 _Mask_Noise_Speed;
	mediump vec4 _VertexOffset_TilingOffset;
	vec4 _VertexOffset_CombinedProps1;
	mediump vec4 _VertexOffset_CombinedProps2;
	mediump vec4 _WangQiNPCHighLight;
	mediump float _StainingLocalOff;
	mediump float _StippleOn;
	mediump float _StippleAlpha;
};
UNITY_LOCATION(5) uniform highp samplerBuffer unity_SkinPoseBuffer;
in highp vec4 in_POSITION0;
in mediump vec4 in_COLOR0;
in mediump vec4 in_TEXCOORD0;
in mediump vec4 in_TEXCOORD1;
in mediump vec4 in_TEXCOORD2;
in highp vec4 in_BLENDWEIGHTS0;
in highp uvec4 in_BLENDINDICES0;
layout(location = 0) out mediump vec4 vs_TEXCOORD8;
layout(location = 1) out mediump vec4 vs_TEXCOORD1;
layout(location = 2) out mediump vec4 vs_TEXCOORD2;
layout(location = 3) out mediump vec4 vs_TEXCOORD3;
layout(location = 4) out mediump vec4 vs_TEXCOORD6;
vec4 u_xlat0;
mediump vec4 u_xlat16_0;
uvec4 u_xlatu0;
vec4 u_xlat1;
mediump vec4 u_xlat16_1;
vec4 u_xlat2;
uvec4 u_xlatu2;
bool u_xlatb2;
vec4 u_xlat3;
bvec3 u_xlatb3;
vec4 u_xlat4;
uvec4 u_xlatu4;
vec4 u_xlat5;
mediump vec3 u_xlat16_6;
mediump vec3 u_xlat16_7;
mediump vec3 u_xlat16_8;
mediump vec3 u_xlat16_9;
float u_xlat10;
vec3 u_xlat11;
vec2 u_xlat13;
bool u_xlatb13;
float u_xlat14;
mediump float u_xlat16_17;
mediump vec2 u_xlat16_28;
float u_xlat33;
float u_xlat35;
mediump float u_xlat16_39;
void main()
{
    u_xlatu0 = in_BLENDINDICES0 << uvec4(2u, 2u, 2u, 2u);
    u_xlat1 = texelFetch(unity_SkinPoseBuffer, int(u_xlatu0.y));
    u_xlat1 = u_xlat1 * in_BLENDWEIGHTS0.yyyy;
    u_xlat2 = texelFetch(unity_SkinPoseBuffer, int(u_xlatu0.x));
    u_xlat1 = u_xlat2 * in_BLENDWEIGHTS0.xxxx + u_xlat1;
    u_xlat2 = texelFetch(unity_SkinPoseBuffer, int(u_xlatu0.z));
    u_xlat0 = texelFetch(unity_SkinPoseBuffer, int(u_xlatu0.w));
    u_xlat1 = u_xlat2 * in_BLENDWEIGHTS0.zzzz + u_xlat1;
    u_xlat0 = u_xlat0 * in_BLENDWEIGHTS0.wwww + u_xlat1;
    u_xlat1.xyz = in_POSITION0.xyz;
    u_xlat1.w = 1.0;
    u_xlat0.x = dot(u_xlat0, u_xlat1);
    u_xlatu2 =  uvec4(ivec4(bitfieldInsert(int(1),int(in_BLENDINDICES0.x),int(2),int(30)) , bitfieldInsert(int(2),int(in_BLENDINDICES0.x),int(2),int(30)) , bitfieldInsert(int(1),int(in_BLENDINDICES0.y),int(2),int(30)) , bitfieldInsert(int(2),int(in_BLENDINDICES0.y),int(2),int(30)) ));
    u_xlat3 = texelFetch(unity_SkinPoseBuffer, int(u_xlatu2.z));
    u_xlat3 = u_xlat3 * in_BLENDWEIGHTS0.yyyy;
    u_xlat4 = texelFetch(unity_SkinPoseBuffer, int(u_xlatu2.x));
    u_xlat3 = u_xlat4 * in_BLENDWEIGHTS0.xxxx + u_xlat3;
    u_xlatu4 =  uvec4(ivec4(bitfieldInsert(int(1),int(in_BLENDINDICES0.z),int(2),int(30)) , bitfieldInsert(int(2),int(in_BLENDINDICES0.z),int(2),int(30)) , bitfieldInsert(int(1),int(in_BLENDINDICES0.w),int(2),int(30)) , bitfieldInsert(int(2),int(in_BLENDINDICES0.w),int(2),int(30)) ));
    u_xlat5 = texelFetch(unity_SkinPoseBuffer, int(u_xlatu4.x));
    u_xlat3 = u_xlat5 * in_BLENDWEIGHTS0.zzzz + u_xlat3;
    u_xlat5 = texelFetch(unity_SkinPoseBuffer, int(u_xlatu4.z));
    u_xlat3 = u_xlat5 * in_BLENDWEIGHTS0.wwww + u_xlat3;
    u_xlat11.x = dot(u_xlat3, u_xlat1);
    u_xlat11.xyz = u_xlat11.xxx * hlslcc_mtx4x4unity_ObjectToWorld[1].xyz;
    u_xlat0.xyz = hlslcc_mtx4x4unity_ObjectToWorld[0].xyz * u_xlat0.xxx + u_xlat11.xyz;
    u_xlat3 = texelFetch(unity_SkinPoseBuffer, int(u_xlatu2.w));
    u_xlat2 = texelFetch(unity_SkinPoseBuffer, int(u_xlatu2.y));
    u_xlat3 = u_xlat3 * in_BLENDWEIGHTS0.yyyy;
    u_xlat2 = u_xlat2 * in_BLENDWEIGHTS0.xxxx + u_xlat3;
    u_xlat3 = texelFetch(unity_SkinPoseBuffer, int(u_xlatu4.y));
    u_xlat4 = texelFetch(unity_SkinPoseBuffer, int(u_xlatu4.w));
    u_xlat2 = u_xlat3 * in_BLENDWEIGHTS0.zzzz + u_xlat2;
    u_xlat2 = u_xlat4 * in_BLENDWEIGHTS0.wwww + u_xlat2;
    u_xlat33 = dot(u_xlat2, u_xlat1);
    u_xlat0.xyz = hlslcc_mtx4x4unity_ObjectToWorld[2].xyz * vec3(u_xlat33) + u_xlat0.xyz;
    u_xlat0.xyz = u_xlat0.xyz + hlslcc_mtx4x4unity_ObjectToWorld[3].xyz;
    u_xlat1.xyz = u_xlat0.yyy * hlslcc_mtx4x4unity_MatrixV[1].xyz;
    u_xlat0.xyw = hlslcc_mtx4x4unity_MatrixV[0].xyz * u_xlat0.xxx + u_xlat1.xyz;
    u_xlat0.xyz = hlslcc_mtx4x4unity_MatrixV[2].xyz * u_xlat0.zzz + u_xlat0.xyw;
    u_xlat0.xyz = u_xlat0.xyz + hlslcc_mtx4x4unity_MatrixV[3].xyz;
    u_xlat1.x = hlslcc_mtx4x4glstate_matrix_projection[0].z;
    u_xlat1.y = hlslcc_mtx4x4glstate_matrix_projection[1].z;
    u_xlat1.z = hlslcc_mtx4x4glstate_matrix_projection[2].z;
    u_xlat1.w = hlslcc_mtx4x4glstate_matrix_projection[3].z;
    u_xlat0.w = 1.0;
    u_xlat1.z = dot(u_xlat1, u_xlat0);
    u_xlat2.x = hlslcc_mtx4x4glstate_matrix_projection[0].x;
    u_xlat2.y = hlslcc_mtx4x4glstate_matrix_projection[2].x;
    u_xlat2.z = hlslcc_mtx4x4glstate_matrix_projection[3].x;
    u_xlat1.x = dot(u_xlat2.xyz, u_xlat0.xzw);
    u_xlat2.x = hlslcc_mtx4x4glstate_matrix_projection[1].y;
    u_xlat2.y = hlslcc_mtx4x4glstate_matrix_projection[2].y;
    u_xlat2.z = hlslcc_mtx4x4glstate_matrix_projection[3].y;
    u_xlat1.y = dot(u_xlat2.xyz, u_xlat0.yzw);
    u_xlat0.x = hlslcc_mtx4x4glstate_matrix_projection[2].w;
    u_xlat0.y = hlslcc_mtx4x4glstate_matrix_projection[3].w;
    u_xlat1.w = dot(u_xlat0.xy, u_xlat0.zw);
    gl_Position = u_xlat1;
    u_xlat0.xz = u_xlat1.xw * vec2(0.5, 0.5);
    u_xlat11.x = u_xlat1.y * _ProjectionParams.x;
    u_xlat0.w = u_xlat11.x * 0.5;
    u_xlat1.xy = u_xlat0.zz + u_xlat0.xw;
    vs_TEXCOORD6 = u_xlat1;
    u_xlat16_6.xyz = (-in_COLOR0.xyz) + _Mesh_Final_VertexColor.xyz;
    u_xlat16_0.xyz = _Mesh_Final_VertexColor.www * u_xlat16_6.xyz + in_COLOR0.xyz;
    u_xlat16_0.w = in_COLOR0.w;
    u_xlat16_1 = (-u_xlat16_0) + vec4(1.0, 1.0, 1.0, 1.0);
    u_xlat16_0 = vec4(_VertexColor_Ban) * u_xlat16_1 + u_xlat16_0;
    u_xlatb2 = u_xlat16_0.y<u_xlat16_0.z;
    u_xlat1.xy = (bool(u_xlatb2)) ? u_xlat16_0.zy : u_xlat16_0.yz;
    u_xlat1.zw = (bool(u_xlatb2)) ? vec2(-1.0, 0.666666687) : vec2(0.0, -0.333333343);
    u_xlatb2 = u_xlat16_0.x<u_xlat1.x;
    u_xlat13.xy = (bool(u_xlatb2)) ? u_xlat1.yw : u_xlat1.yz;
    u_xlat10 = (u_xlatb2) ? u_xlat16_0.x : u_xlat1.x;
    u_xlat3.x = (u_xlatb2) ? u_xlat1.x : u_xlat16_0.x;
    u_xlat2.x = u_xlat10;
    u_xlat35 = min(u_xlat13.x, u_xlat2.x);
    u_xlat35 = (-u_xlat35) + u_xlat3.x;
    u_xlat14 = u_xlat35 * 6.0 + 9.99999975e-06;
    u_xlat2.x = (-u_xlat13.x) + u_xlat2.x;
    u_xlat2.x = u_xlat2.x / u_xlat14;
    u_xlat2.x = u_xlat2.x + u_xlat13.y;
    u_xlat16_6.x = abs(u_xlat2.x) + _Final_VertexColor.x;
    u_xlat2.xyz = u_xlat16_6.xxx + vec3(1.0, 0.666666687, 0.333333343);
    u_xlat2.xyz = fract(u_xlat2.xyz);
    u_xlat2.xyz = u_xlat2.xyz * vec3(6.0, 6.0, 6.0) + vec3(-3.0, -3.0, -3.0);
    u_xlat2.xyz = abs(u_xlat2.xyz) + vec3(-1.0, -1.0, -1.0);
    u_xlat2.xyz = clamp(u_xlat2.xyz, 0.0, 1.0);
    u_xlat2.xyz = u_xlat2.xyz + vec3(-1.0, -1.0, -1.0);
    u_xlat14 = u_xlat3.x + 9.99999975e-06;
    u_xlat16_6.x = u_xlat3.x * _Final_VertexColor.z;
    u_xlat35 = u_xlat35 / u_xlat14;
    u_xlat16_17 = u_xlat35 * _Final_VertexColor.y;
    u_xlat2.xyz = vec3(u_xlat16_17) * u_xlat2.xyz + vec3(1.0, 1.0, 1.0);
    u_xlat2.xyz = u_xlat2.xyz * u_xlat16_6.xxx;
    u_xlatb3.xyz = lessThan(vec4(2.5, 1.5, 0.5, 0.0), _Final_VertexColor.wwww).xyz;
    u_xlat16_6.xyz = (u_xlatb3.z) ? u_xlat2.xyz : u_xlat16_0.xyz;
    u_xlat16_6.xyz = (u_xlatb3.y) ? _Final_VertexColor.xyz : u_xlat16_6.xyz;
    u_xlat16_39 = dot(u_xlat16_0.xyz, vec3(0.212672904, 0.715152204, 0.0721750036));
    u_xlat16_7.xyz = vec3(u_xlat16_39) * _Final_VertexColor.xyz + (-u_xlat16_0.xyz);
    u_xlat16_39 = _Final_VertexColor.w + -3.0;
    u_xlat16_39 = clamp(u_xlat16_39, 0.0, 1.0);
    u_xlat16_7.xyz = vec3(u_xlat16_39) * u_xlat16_7.xyz + u_xlat16_0.xyz;
    u_xlat16_6.xyz = (u_xlatb3.x) ? u_xlat16_7.xyz : u_xlat16_6.xyz;
    u_xlatb2 = vec4(0.0, 0.0, 0.0, 0.0)!=vec4(_WangQiOn);
    u_xlatb13 = 0.5<_WangQiNPCHighLight.w;
    u_xlatb2 = u_xlatb13 && u_xlatb2;
    vs_TEXCOORD8.xyz = (bool(u_xlatb2)) ? _WangQiNPCHighLight.xyz : u_xlat16_6.xyz;
    u_xlat16_6.x = _Highlight_Alpha * _Highlight_Alpha;
    vs_TEXCOORD8.w = u_xlat16_0.w * u_xlat16_6.x;

    u_xlat2.x = _Rotation * 0.0174532924;
    u_xlat16_6.x = sin(u_xlat2.x);
    u_xlat16_7.x = cos(u_xlat2.x);
    u_xlat16_8.z = u_xlat16_6.x;
    u_xlat16_8.y = u_xlat16_7.x;
    u_xlat16_8.x = (-u_xlat16_6.x);
    u_xlat16_6.xy = in_TEXCOORD0.xy + vec2(-0.5, -0.5);
    u_xlat16_7.x = dot(u_xlat16_6.xy, u_xlat16_8.yz);
    u_xlat16_7.y = dot(u_xlat16_6.xy, u_xlat16_8.xy);
    vs_TEXCOORD1.xy = u_xlat16_7.xy + vec2(0.5, 0.5);

    u_xlat2.xy = in_TEXCOORD0.zw * vec2(vec2(_Particle_, _Particle_));
    vs_TEXCOORD1.zw = u_xlat2.xy;

    u_xlat2.x = _Alpha_Rotation * 0.0174532924;
    u_xlat16_7.x = sin(u_xlat2.x);
    u_xlat16_8.x = cos(u_xlat2.x);
    u_xlat16_9.z = u_xlat16_7.x;
    u_xlat16_9.y = u_xlat16_8.x;
    u_xlat16_9.x = (-u_xlat16_7.x);
    u_xlat16_7.y = dot(u_xlat16_6.xy, u_xlat16_9.xy);
    u_xlat16_7.x = dot(u_xlat16_6.xy, u_xlat16_9.yz);

    vs_TEXCOORD2.xy = u_xlat16_7.xy + vec2(0.5, 0.5);
    u_xlat0 = in_TEXCOORD1 * vec4(vec4(_Particle_, _Particle_, _Particle_, _Particle_));
    vs_TEXCOORD2.zw = u_xlat0.zw;

    u_xlat16_28.x = _Dissolve_CombinedProps1.y;
    u_xlat16_28.y = _Distort_CombinedProps2.x;
    u_xlat2.xy = (-u_xlat16_28.xy) + in_TEXCOORD2.xy;
    u_xlat0.zw = vec2(vec2(_Particle_, _Particle_)) * u_xlat2.xy + u_xlat16_28.xy;
    vs_TEXCOORD3 = u_xlat0;
    return;
}
