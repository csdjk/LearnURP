Shader "lcl/Lightning"
{
	Properties
	{
		_BaseMap ("Example Texture", 2D) = "white" { }
		_BaseColor ("Example Colour", Color) = (1, 1, 1, 1)
	}
	SubShader
	{
		Tags { "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" }

		// Blend One OneMinusSrcAlpha
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off
		Lighting Off
		ZWrite Off
		
		HLSLINCLUDE
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
		
		CBUFFER_START(UnityPerMaterial)
			float4 _BaseMap_ST;
			float4 _BaseColor;
		CBUFFER_END
		ENDHLSL

		Pass
		{
			Name "Example"
			Tags { "LightMode" = "UniversalForward" }
			
			HLSLPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			
			struct Attributes
			{
				float4 positionOS : POSITION;
				float2 uv : TEXCOORD0;
				float4 color : COLOR;
				float4 tangent : TANGENT;
			};
			
			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 color : COLOR;
			};
			
			TEXTURE2D(_BaseMap);
			SAMPLER(sampler_BaseMap);
			
			Varyings vert(Attributes IN)
			{
				Varyings OUT;
				
				VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS.xyz);
				OUT.positionCS = positionInputs.positionCS;
				OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
				OUT.color = IN.color;
				return OUT;
			}
			
			half4 frag(Varyings IN) : SV_Target
			{
				half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv);
				half4 finalColor = baseMap * _BaseColor;
				// finalColor.a = baseMap.a * 0.1;
				finalColor.a *= finalColor.a;

				float dis = 1 - length(IN.uv.x - 0.5);
				finalColor.a *= dis * IN.color.a;
				finalColor.a = saturate(finalColor.a);
				return finalColor;
			}
			ENDHLSL

		}
	}
}