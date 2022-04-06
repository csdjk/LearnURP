Shader "LcL/Rain"
{
	Properties { }
	SubShader
	{
		Pass
		{
			Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }
			Cull Off  ZTest Always
			// Cull Off ZWrite Off ZTest Always

			HLSLPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			// #pragma enable_d3d11_debug_symbols
			struct a2v
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};
			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 rain_uv : TEXCOORD1;
				float4 scrPos : TEXCOORD2;
				float3 worldPos : TEXCOORD3;
			};

			CBUFFER_START(UnityPerMaterial)
				float4 _FarRainData;
				float4 _NearRainData;

				float4 _RainColor;
				float4 _RainDepthRange;
				float4 _RainDepthStart;


				float _LightExponent;
				float _LightIntensity1;
				float _LightIntensity2;
				float4x4 _DepthCameraMatrixVP;
			CBUFFER_END
			

			TEXTURE2D_X_FLOAT(_CameraDepthTexture);
			SAMPLER(sampler_CameraDepthTexture);

			TEXTURE2D(_SourceTex);
			SAMPLER(sampler_SourceTex);

			TEXTURE2D(_RainTexture);
			SAMPLER(sampler_RainTexture);
			TEXTURE2D(_SceneDepth);
			SAMPLER(sampler_SceneDepth);
			
			TEXTURE2D(_CameraOpaqueTexture);
			SAMPLER(sampler_CameraOpaqueTexture);
			float3 CalculateRainLayer(float2 uv, float sceneViewDepth, float rainDepthRange, float rainDepthStart, float3 layer)
			{
				// r:远处的雨,g:近处的雨,b:雨的深度
				half4 rain = SAMPLE_TEXTURE2D(_RainTexture, sampler_RainTexture, uv);
				float rainDepth = rain.b * _ProjectionParams.z * rainDepthRange + rainDepthStart;
				float mask = saturate(sceneViewDepth - rainDepth);
				return rain * mask * layer;
			}
			
			v2f vert(a2v v)
			{
				v2f o;
				VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
				// float4 worldPos = mul(GetObjectToWorldMatrix(), v.vertex);
				o.vertex = vertexInput.positionCS;
				o.uv = v.uv;
				o.scrPos = ComputeScreenPos(o.vertex);
				// o.worldPos = vertexInput.positionVS.xyz;
				return o;
			}
			inline float DecodeFloatRGBA(float4 enc)
			{
				float4 kDecodeDot = float4(1.0, 1 / 255.0, 1 / 65025.0, 1 / 16581375.0);
				return dot(enc, kDecodeDot);
			}
			half4 frag(v2f i) : SV_Target
			{
				float2 screen_uv = i.scrPos.xy / i.scrPos.w;
				float2 uv = i.uv;

				float2 scale = _FarRainData.xy;
				float2 speed = _FarRainData.zw;

				float2 scaleNear = _NearRainData.xy;
				float2 speedNear = _NearRainData.zw;

				float2 uv1 = uv * scale + speed * _Time.x;
				float2 uv2 = uv * scaleNear + speedNear * _Time.x;

				// float3 worldDir = normalize(i.worldPos - _WorldSpaceCameraPos);
				// float2 NoiseUV = tex2D(DistortionTexture, uv1).xy + tex2D(DistortionTexture, uv2).xy;
				// NoiseUV = NoiseUV * uv.y * 2.0f + float2(1.5f, 0.7f) * uv.xy + float2(0.1f, -0.2f) * _Time;

				// ==================================主摄像机遮挡剔除==================================
				float depth = SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, screen_uv).r;
				float sceneViewDepth = LinearEyeDepth(depth, _ZBufferParams); //摄像机空间的深度
				float rainLayer1 = CalculateRainLayer(uv1, sceneViewDepth, _RainDepthRange.x, _RainDepthStart.x, float3(1, 0, 0)).r;
				float rainLayer2 = CalculateRainLayer(uv2, sceneViewDepth, _RainDepthRange.y, _RainDepthStart.y, float3(0, 1, 0)).g;

				// ==================================高度遮挡剔除==================================
				// // 根据雨的深度还原世界坐标和投影空间坐标
				// half4 rain = SAMPLE_TEXTURE2D(_RainTexture, sampler_RainTexture, uv2);
				// float3 viewPos = i.vertex * rain.b;
				// float3 worldPos = mul(UNITY_MATRIX_I_V, float4(viewPos, 1)).xyz;
				// float4 rainPosCS = mul(_DepthCameraMatrixVP, worldPos);

				// float3 rain_uv = 0;
				// // 转换到NDC空间
				// rainPosCS.xyz = rainPosCS.xyz / rainPosCS.w;
				// rain_uv.xy = rainPosCS.xy * 0.5 + 0.5;
				// #if defined(SHADER_TARGET_GLSL)
				// 	rain_uv.z = rainPosCS.z * 0.5 + 0.5; //[-1, 1]-->[0, 1]
				// #elif defined(UNITY_REVERSED_Z)
				// 	rain_uv.z = 1 - rainPosCS.z;       //[1, 0]-->[0, 1]
				// #endif
				// float rainHeight = rain_uv.z;
				// float sceneHeight = DecodeFloatRGBA(SAMPLE_TEXTURE2D(_SceneDepth, sampler_SceneDepth, rain_uv.xy));
				// float occlusion = rainHeight > sceneHeight ? 0 : 1;

				// occlusion = 1;
				// ==================================Blend Color==================================
				half3 color = (rainLayer1 + rainLayer2) * _RainColor;
				half3 mainColor = SAMPLE_TEXTURE2D(_SourceTex, sampler_SourceTex, screen_uv).rgb;
				// half3 mainColor = SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, screen_uv).rgb;

				float3 finalCol = 1 - (1 - mainColor) * (1 - color);
				// float3 finalCol = mainColor + color;

				return half4(finalCol, 1.f);
			}
			ENDHLSL

		}
	}
	FallBack "Hidden/Universal Render Pipeline/FallbackError"
}