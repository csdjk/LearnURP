Shader "lcl/Ice"
{
	Properties
	{
		_BaseMap ("Base Texture", 2D) = "white" { }
		_BaseColor ("Example Colour", Color) = (0, 0.66, 0.73, 1)
		_Smoothness ("Smoothness", Range(0, 1)) = 0.5

		[Toggle(_ALPHATEST_ON)] _EnableAlphaTest ("Enable Alpha Cutoff", Float) = 0.0
		_Cutoff ("Alpha Cutoff", Float) = 0.5

		_EnableBumpMap ("Enable Normal/Bump Map", Float) = 0.0
		_BumpMap ("Normal/Bump Texture", 2D) = "bump" { }
		_BumpScale ("Bump Scale", Float) = 1

		[Toggle(_EMISSION)] _EnableEmission ("Enable Emission", Float) = 0.0
		_EmissionMap ("Emission Texture", 2D) = "white" { }
		_EmissionColor ("Emission Colour", Color) = (0, 0, 0, 0)


		[Header(Ice)]
		_MinMaxHeight ("Min Max Height", Vector) = (0, 1, 1, 1)
		[Enum(X, 1, Y, 2, Z, 3)]_FreezeDirection ("Freeze Direction", Int) = 1
		_IceDistribution ("Ice Distribution", Range(0, 1)) = 0.5
		_IceStrength ("Ice Strength", Range(0, 1)) = 0.5
		_IceSmoothness ("Ice Smoothness", Range(0, 1)) = 0.8

		_IceMap ("Ice Texture", 2D) = "white" { }
		[HDR]_IceColor ("Ice Color", Color) = (1, 1, 1, 1)
		_IceNormalMap ("Ice Normal Texture", 2D) = "bump" { }
		_IceBumpScale ("Ice Bump Scale", Range(0, 10)) = 1
		_RefractionAmount ("Refraction Amount", Range(-1, 1)) = 0
		[HDR]_ScatterColor ("Fresnel Color", Color) = (1, 1, 1, 1)
		_ScaterDistortion ("Scater Distortion", Range(0.0, 1.0)) = 0
		_ScaterPower ("Scater Power", Range(1, 10.0)) = 1
		_ScaterScale ("Scater Scale", Range(0.0, 10.0)) = 1
	}
	SubShader
	{
		Tags { "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent" }
		
		HLSLINCLUDE
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

		CBUFFER_START(UnityPerMaterial)
			float4 _BaseMap_ST;
			float4 _BaseColor;
			float _BumpScale;
			float4 _EmissionColor;
			float _Smoothness;
			float _Cutoff;

			// 冰冻相关参数
			int _FreezeDirection;
			float _IceDistribution;
			float _IceStrength;
			float2 _MinMaxHeight;
			float _IceSmoothness;
			float4 _IceMap_ST;
			float4 _IceColor;
			float _IceBumpScale;
			float _RefractionAmount;
			// 散射相关参数
			float4 _ScatterColor;
			half _ScaterDistortion;
			half _ScaterPower;
			half _ScaterScale;
		CBUFFER_END
		ENDHLSL

		Pass
		{
			Name "Example"
			Tags { "LightMode" = "UniversalForward" }
			
			HLSLPROGRAM

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x gles
			// #pragma enable_d3d11_debug_symbols
			#pragma vertex vert
			#pragma fragment frag
			
			// Material Keywords
			// #pragma shader_feature _NORMALMAP
			#pragma shader_feature _ALPHATEST_ON
			#pragma shader_feature _ALPHAPREMULTIPLY_ON
			#pragma shader_feature _EMISSION
			//#pragma shader_feature _METALLICSPECGLOSSMAP
			//#pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
			//#pragma shader_feature _OCCLUSIONMAP
			//#pragma shader_feature _ _CLEARCOAT _CLEARCOATMAP // URP v10+

			//#pragma shader_feature _SPECULARHIGHLIGHTS_OFF
			//#pragma shader_feature _ENVIRONMENTREFLECTIONS_OFF
			//#pragma shader_feature _SPECULAR_SETUP
			#pragma shader_feature _RECEIVE_SHADOWS_OFF

			// URP Keywords
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile _ _SHADOWS_SOFT
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE

			// Unity defined keywords
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile_fog

			// Includes
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"

			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 color : COLOR;
				float2 uv : TEXCOORD0;
				float2 lightmapUV : TEXCOORD1;
			};

			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float4 color : COLOR;
				float4 uv : TEXCOORD0;
				DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);
				
				float3 positionWS : TEXCOORD2;
				float3 normalWS : TEXCOORD3;
				float4 tangentWS : TEXCOORD4;

				float3 viewDirWS : TEXCOORD5;
				half4 fogFactorAndVertexLight : TEXCOORD6; // x: fogFactor, yzw: vertex light

				#ifdef REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
					float4 shadowCoord : TEXCOORD7;
				#endif

				float4 scrPos : TEXCOORD8;
				float positionHeight : TEXCOORD9;
			};

			TEXTURE2D(_IceMap);
			SAMPLER(sampler_IceMap);

			TEXTURE2D(_IceNormalMap);
			SAMPLER(sampler_IceNormalMap);
			
			#if SHADER_LIBRARY_VERSION_MAJOR < 9
				float3 GetWorldSpaceViewDir(float3 positionWS)
				{
					if (unity_OrthoParams.w == 0)
					{
						// Perspective
						return _WorldSpaceCameraPos - positionWS;
					}
					else
					{
						// Orthographic
						float4x4 viewMat = GetWorldToViewMatrix();
						return viewMat[2].xyz;
					}
				}
			#endif

			Varyings vert(Attributes IN)
			{
				Varyings OUT;

				VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS.xyz);
				OUT.positionCS = positionInputs.positionCS;
				OUT.uv.xy = TRANSFORM_TEX(IN.uv, _BaseMap);
				OUT.color = IN.color;

				OUT.positionWS = positionInputs.positionWS;
				OUT.viewDirWS = GetWorldSpaceViewDir(positionInputs.positionWS);

				VertexNormalInputs normalInputs = GetVertexNormalInputs(IN.normalOS, IN.tangentOS);
				OUT.normalWS = normalInputs.normalWS;
				real sign = IN.tangentOS.w * GetOddNegativeScale();
				OUT.tangentWS = half4(normalInputs.tangentWS.xyz, sign);

				half3 vertexLight = VertexLighting(positionInputs.positionWS, normalInputs.normalWS);
				half fogFactor = ComputeFogFactor(positionInputs.positionCS.z);

				OUT.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

				OUTPUT_LIGHTMAP_UV(IN.lightmapUV, unity_LightmapST, OUT.lightmapUV);
				OUTPUT_SH(OUT.normalWS.xyz, OUT.vertexSH);

				#ifdef REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
					OUT.shadowCoord = GetShadowCoord(positionInputs);
				#endif

				OUT.scrPos = ComputeScreenPos(OUT.positionCS);
				OUT.uv.zw = TRANSFORM_TEX(IN.uv, _IceMap);

				UNITY_BRANCH
				if (_FreezeDirection == 1)
				{
					OUT.positionHeight = IN.positionOS.x;
				}
				else if (_FreezeDirection == 2)
				{
					OUT.positionHeight = IN.positionOS.y;
				}
				else
				{
					OUT.positionHeight = IN.positionOS.z;
				}
				return OUT;
			}
			
			InputData InitializeInputData(Varyings IN, half3 normalTS)
			{
				InputData inputData = (InputData)0;

				inputData.positionWS = IN.positionWS;
				
				half3 viewDirWS = SafeNormalize(IN.viewDirWS);
				float sgn = IN.tangentWS.w;
				float3 bitangent = sgn * cross(IN.normalWS.xyz, IN.tangentWS.xyz);
				inputData.normalWS = TransformTangentToWorld(normalTS, half3x3(IN.tangentWS.xyz, bitangent.xyz, IN.normalWS.xyz));
				

				inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				inputData.viewDirectionWS = viewDirWS;

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					inputData.shadowCoord = IN.shadowCoord;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
				#else
					inputData.shadowCoord = float4(0, 0, 0, 0);
				#endif

				inputData.fogCoord = IN.fogFactorAndVertexLight.x;
				inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
				inputData.bakedGI = SAMPLE_GI(IN.lightmapUV, IN.vertexSH, inputData.normalWS);
				return inputData;
			}
			float3 NormalFromTexture(TEXTURE2D_PARAM(bumpMap, sampler_bumpMap), float2 UV, float offset, float Strength)
			{
				offset = pow(offset, 3) * 0.1;
				float2 offsetU = float2(UV.x + offset, UV.y);
				float2 offsetV = float2(UV.x, UV.y + offset);
				float normalSample = SAMPLE_TEXTURE2D(bumpMap, sampler_bumpMap, UV);
				float uSample = SAMPLE_TEXTURE2D(bumpMap, sampler_bumpMap, offsetU);
				float vSample = SAMPLE_TEXTURE2D(bumpMap, sampler_bumpMap, offsetV);
				float3 va = float3(1, 0, (uSample - normalSample) * Strength);
				float3 vb = float3(0, 1, (vSample - normalSample) * Strength);
				return normalize(cross(va, vb));
			}
			float FresnelEffect(float3 Normal, float3 ViewDir, float Power)
			{
				return pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
			}
			float FresnelEffect(float3 Normal, float3 ViewDir, float Power, float Scale)
			{
				return Scale + (1 - Scale) * pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
			}
			float Remap(float In, float2 InMinMax, float2 OutMinMax)
			{
				return OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
			}
			float SubsurfaceScattering(float3 viewDirWS, float3 lightDir, float3 normalWS, float distortion, float power, float scale)
			{
				float3 H = (lightDir + normalWS * distortion);
				float I = pow(saturate(dot(viewDirWS, -H)), power) * scale;
				return I;
			}
			SurfaceData InitializeSurfaceData(Varyings IN)
			{
				SurfaceData surfaceData = (SurfaceData)0;
				
				half4 albedoAlpha = SampleAlbedoAlpha(IN.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
				surfaceData.alpha = Alpha(albedoAlpha.a, _BaseColor, _Cutoff);
				surfaceData.albedo = albedoAlpha.rgb * _BaseColor.rgb * IN.color.rgb;

				// Ice Shading
				float3 screenPos = IN.scrPos.xyz / IN.scrPos.w;
				half4 iceColor = SAMPLE_TEXTURE2D(_IceMap, sampler_IceMap, IN.uv.zw);

				half3 refractionPos = iceColor.rgb * screenPos + screenPos;
				screenPos = lerp(screenPos, refractionPos, _RefractionAmount);
				float3 screenColor = SampleSceneColor(screenPos.xy);

				// fresnel
				// float fresnel = FresnelEffect(IN.normalWS, IN.viewDirWS, _ScaterPower) * _ScatterColor;
				half3 fresnel = FresnelEffect(IN.normalWS, IN.viewDirWS, _ScaterPower, _ScaterScale) * _ScatterColor;
				// SSS
				half3 customLightDir = normalize(IN.positionWS - GetCameraPositionWS());
				half3 sss = SubsurfaceScattering(IN.viewDirWS, customLightDir, IN.normalWS, _ScaterDistortion, _ScaterPower, _ScaterScale) * _ScatterColor;

				// ice color
				half3 iceFinalColor = (iceColor + screenColor) * _IceColor + sss;
				// half3 iceFinalColor = (iceColor + screenColor) * _IceColor + fresnel;
				iceFinalColor = lerp(surfaceData.albedo, iceFinalColor, _IceStrength);
				


				half2 range = _MinMaxHeight.xy;
				float maxHeight = lerp(range.x, range.y, _IceDistribution) + 0.001;
				half iceHeight = Remap(IN.positionHeight, float2(range.x, maxHeight), float2(0, 1));
				iceHeight = smoothstep(_IceSmoothness, 1, iceHeight);
				// iceHeight = lerp(iceHeight, 1, step(1, _IceDistribution));
				iceHeight = _IceDistribution == 1 ? 0 : iceHeight;

				surfaceData.albedo = lerp(iceFinalColor, surfaceData.albedo, iceHeight);

				// half3 iceNormal = NormalFromTexture(TEXTURE2D_ARGS(_IceMap, sampler_IceMap), IN.uv.zw, 0.5, _IceBumpScale);
				half4 iceNormalValue = SAMPLE_TEXTURE2D(_IceNormalMap, sampler_IceNormalMap, IN.uv.zw);
				half3 iceNormal = UnpackNormalScale(iceNormalValue, _IceBumpScale);

				half3 originNormal = SampleNormal(IN.uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
				// surfaceData.normalTS = BlendNormal(originNormal, iceNormal);
				surfaceData.normalTS = lerp(iceNormal, originNormal, iceHeight);


				surfaceData.emission = SampleEmission(IN.uv, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap));
				surfaceData.occlusion = 1;
				surfaceData.smoothness = lerp(1, _Smoothness, iceHeight);

				// float fresnel = FresnelEffect(IN.normalWS, IN.viewDirWS, 5) * _ScatterColor;
				// surfaceData.albedo = iceHeight;

				return surfaceData;
			}

			half4 frag(Varyings IN) : SV_Target
			{
				SurfaceData surfaceData = InitializeSurfaceData(IN);

				// return half4(surfaceData.albedo,1);
				InputData inputData = InitializeInputData(IN, surfaceData.normalTS);
				
				half4 color = UniversalFragmentPBR(inputData, surfaceData.albedo, surfaceData.metallic,
				surfaceData.specular, surfaceData.smoothness, surfaceData.occlusion,
				surfaceData.emission, surfaceData.alpha);
				
				color.rgb = MixFog(color.rgb, inputData.fogCoord);

				color.a = saturate(color.a);



				return color; // float4(inputData.bakedGI,1);

			}
			ENDHLSL

		}

		// UsePass "Universal Render Pipeline/Lit/ShadowCaster"
		// Note, you can do this, but it will break batching with the SRP Batcher currently due to the CBUFFERs not being the same.
		// So instead, we'll define the pass manually :
		Pass
		{
			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }

			ZWrite On
			ZTest LEqual

			HLSLPROGRAM

			// Required to compile gles 2.0 with standard srp library
			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x gles
			//#pragma target 4.5

			// Material Keywords
			#pragma shader_feature _ALPHATEST_ON
			#pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			// GPU Instancing
			#pragma multi_compile_instancing
			#pragma multi_compile _ DOTS_INSTANCING_ON
			
			#pragma vertex ShadowPassVertex
			#pragma fragment ShadowPassFragment
			
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"

			
			ENDHLSL

		}

		
		Pass
		{
			Name "DepthOnly"
			Tags { "LightMode" = "DepthOnly" }

			ZWrite On
			ColorMask 0

			HLSLPROGRAM

			// Required to compile gles 2.0 with standard srp library
			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x gles
			//#pragma target 4.5

			// Material Keywords
			#pragma shader_feature _ALPHATEST_ON
			#pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			// GPU Instancing
			#pragma multi_compile_instancing
			#pragma multi_compile _ DOTS_INSTANCING_ON
			
			#pragma vertex DepthOnlyVertex
			#pragma fragment DepthOnlyFragment
			
			
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"

			ENDHLSL

		}
	}
}