// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Dodjoy/Effect/Mask Additive" {
Properties {
	_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
	_MainTex ("Particle Texture", 2D) = "white" {}
	_MaskTex ("Masked Texture", 2D) = "gray" {}
	_UVSpeed ("UV Speed", Vector) = (0, 0, 0, 0)
}

Category {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
	Blend SrcAlpha One
	AlphaTest Greater .01
	ColorMask RGB
	Cull Off Lighting Off ZWrite Off Fog { Color (0,0,0,0) }
	BindChannels {
		Bind "Color", color
		Bind "Vertex", vertex
		Bind "TexCoord", texcoord
	}

	// ---- Fragment program cards
	SubShader {
		Pass {

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			//#pragma multi_compile_particles

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			sampler2D _MaskTex;
			fixed4 _TintColor;
			float2 _UVSpeed;

			struct appdata_t {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
			};

			struct v2f {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
			};

			float4 _MainTex_ST;
			float4 _MaskTex_ST;

			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.texcoord = v.texcoord*_MainTex_ST.xy + _UVSpeed * _Time.y;
				o.texcoord1 = TRANSFORM_TEX(v.texcoord1,_MaskTex);
				return o;
			}

			fixed4 frag (v2f i) : COLOR
			{
				float4 col = 2.0f * i.color * _TintColor * tex2D(_MainTex, i.texcoord);
				col.a *= tex2D(_MaskTex, i.texcoord1).a;
				return col;
			}
			ENDCG
		}
	}
}
}
