Shader "Hidden/DodRain"
{
	
	SubShader
	{
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 uvP : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float4 vertexP : TEXCOORD3;
				float4 vertex : SV_POSITION;
			};


			float4 _UVData;
			float2 _LayerDistances;
			float _ForcedLayerDistances;
			float4 _RainColor;
			float _LightExponent;
			float _LightIntensity1;
			float _LightIntensity2;
			

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.vertexP = v.vertex;
				o.uv = v.uv;
				o.uvP = ComputeScreenPos(o.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				return o;
			}
			
			sampler2D _MainTex;
			sampler2D _RainTexture;
			sampler2D _CameraDepthTexture;

			sampler3D _VolumeScatter;
			float _CameraFarOverMaxFar;
			float _NearOverFarClip;

			

			half3 InjectedLight(half linear01Depth, half2 screenuv)
			{
				half z = linear01Depth * _CameraFarOverMaxFar;
				z = (z - _NearOverFarClip) / (1 - _NearOverFarClip);
				if (z < 0.0)
					return half4(0, 0, 0, 1);

				half3 uvw = half3(screenuv.x, screenuv.y, z);
				return tex3D(_VolumeScatter, uvw).rgb;
			}

			float4 CalculateRainLayer(float2 screenUV, float sceneViewDepth, float3 worldDir, float2 layerUV, float2 layerDistances, float forcedDistance, float mip)
			{
				float2 rainAndDepth = tex2D(_RainTexture, layerUV).gb;
				float layerDistance = rainAndDepth.g * layerDistances.y + layerDistances.x;

				if (forcedDistance >= 0.f)
					layerDistance = forcedDistance;

				float depthScale = saturate((sceneViewDepth - layerDistance) * 2.f);


				float3 lightAtDepth = InjectedLight(saturate(layerDistance * _ProjectionParams.w), screenUV);
				lightAtDepth = pow(lightAtDepth * _LightIntensity1, _LightExponent) * _LightIntensity2;

				float4 output;
				output.a = rainAndDepth.r * depthScale ;
				output.rgb = lightAtDepth * output.a;
				return output;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float2 screenUV = i.uvP.xy / i.uvP.w;
				float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screenUV);
				float linearViewDepth = _ProjectionParams.z * Linear01Depth(depth);
				float3 worldDir = normalize(i.worldPos - _WorldSpaceCameraPos);

				float2 uv = i.uv * _UVData.xy + _UVData.zw * _Time.x;
				
				float4 rain = CalculateRainLayer(screenUV, linearViewDepth, worldDir, uv, _LayerDistances, _ForcedLayerDistances, 0);
				
				float3 rainRGB = (_RainColor * rain.a);
				rainRGB += rain.rgb;
				float3 color = rainRGB;


				// r
				// color = tex2D(_RainTexture, uv).r;

				
				float3 mainColor = tex2D(_MainTex, screenUV).rgb;
				return float4(mainColor + color, 1.f);
			}
			ENDCG

		}
	}
}
