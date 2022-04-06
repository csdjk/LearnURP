Shader "Hidden/DodRain1"
{
	Properties
	{
		// _SourceTex ("Texture", 2D) = "white" { }
		// _Color ("Color", Color) = (1, 1, 1, 1)
	}
	SubShader
	{
		Pass
		{
			Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }
			Cull Off ZWrite Off ZTest Always

			HLSLPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			//传入顶点着色器的数据
			struct a2v
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};
			//传入片元着色器的数据
			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 rain_uv : TEXCOORD1;
				float4 scrPos : TEXCOORD2;
				float3 worldPos : TEXCOORD3;
			};
			

			CBUFFER_START(UnityPerMaterial)
				// 	float4 _Color;
				// sampler2D _MainTex;

				float4 _FarRainData;
				float4 _NearRainData;

				float4 _RainColor;
				float2 _LayerDistances;
				float _ForcedLayerDistances;
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
			float CalculateRainLayer(float2 uv, float sceneViewDepth, float rainLayer)
			{
				half4 rain = SAMPLE_TEXTURE2D(_RainTexture, sampler_RainTexture, uv).rgba;
				// r:远处的雨,g:近处的雨,a:雨的深度
				float3 rainDepth = rain.b * _ProjectionParams.z * _ForcedLayerDistances;
				float depthScale = (sceneViewDepth - rainDepth);
				depthScale = smoothstep(0, 20, depthScale);
				return depthScale * lerp(rain.r, rain.g, rainLayer);
			}
		
			//顶点着色器
			v2f vert(a2v v)
			{
				v2f o;
				VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
				o.vertex = vertexInput.positionCS;
				o.uv = v.uv;
				o.scrPos = ComputeScreenPos(o.vertex);
				o.worldPos = vertexInput.positionWS.xyz;
				return o;
			}

			//片元着色器
			half4 frag(v2f i) : SV_Target
			{
				float2 screen_uv = i.scrPos.xy / i.scrPos.w;
				float2 uv = i.uv;

				float2 scale = _FarRainData.xy;
				float2 speed = _FarRainData.zw;

				float2 scaleNear = _NearRainData.xy;
				float2 speedNear = _NearRainData.zw;


				float depth = SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, screen_uv).r;

				float sceneViewDepth = LinearEyeDepth(depth, _ZBufferParams); //摄像机空间的深度

				// return Linear01Depth(depth, _ZBufferParams);


				float3 worldDir = normalize(i.worldPos - _WorldSpaceCameraPos);

				float2 uv1 = uv * scale + speed * _Time.x;
				float2 uv2 = uv * scaleNear + speedNear * _Time.x;
				

				// r:远处的雨,g:近处的雨,b:雨的深度
				float rainLayer1 = CalculateRainLayer(uv1, sceneViewDepth, 0);
				float rainLayer2 = CalculateRainLayer(uv2, sceneViewDepth, 1);

				// height
				// float2 rain_uv = i.rain_uv.xy / i.rain_uv.w;
				// float3 sceneDepthCol = tex2D(_SceneDepth, rain_uv);
				// float sceneDepth = sceneDepthCol.r * 255 + sceneDepthCol.b;
				// float snowCulling = (i.worldPos.y + 1 - sceneDepth) / 100;
				// snowCulling = smoothstep(-0.08, 0, snowCulling);

				// float3 color = rainCol.b;
				// float3 color = snowCulling * rainCol.r + snowCulling * rainCol.g;
				


				half3 color = rainLayer1 + rainLayer2;
				// half3 mainColor = SAMPLE_TEXTURE2D(_SourceTex, sampler_SourceTex, screen_uv).rgb;

				half3 mainColor = SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, screen_uv).rgb;

				return half4(mainColor+color, 1.f);

				// return half4(color, 1.f);

			}
			ENDHLSL

		}
	}
	FallBack "Hidden/Universal Render Pipeline/FallbackError"
}