// Example Shader for Universal RP
// Written by @Cyanilux
// https://cyangamedev.wordpress.com/urp-shader-code/
Shader "Custom/LitShaderExample"
{
	Properties
	{
		_BaseMap ("Base Texture", 2D) = "white" { }
		_BaseColor ("Example Colour", Color) = (0, 0.66, 0.73, 1)
		_Smoothness ("Smoothness", Float) = 0.5

		[Toggle(_ALPHATEST_ON)] _EnableAlphaTest ("Enable Alpha Cutoff", Float) = 0.0
		_Cutoff ("Alpha Cutoff", Float) = 0.5

		[Toggle(_NORMALMAP)] _EnableBumpMap ("Enable Normal/Bump Map", Float) = 0.0
		_BumpMap ("Normal/Bump Texture", 2D) = "bump" { }
		_BumpScale ("Bump Scale", Float) = 1

		[Toggle(_EMISSION)] _EnableEmission ("Enable Emission", Float) = 0.0
		_EmissionMap ("Emission Texture", 2D) = "white" { }
		_EmissionColor ("Emission Colour", Color) = (0, 0, 0, 0)

		[Head(Ripple)]
		_FlowMap ("Flow Texture", 2D) = "black" { }

		_RippleMap ("Ripple Texture", 2D) = "white" { }
		_RippleSpeed ("Ripple Speed", Float) = 4
		_RippleTilling ("Ripple Tilling", Float) = 4
		_NoiseSpped ("Noise Speed", Float) = 4
		_RippleStrength ("Ripple Strength", Range(0, 1)) = 1
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
		
		HLSLINCLUDE
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

		CBUFFER_START(UnityPerMaterial)
			float4 _BaseMap_ST;
			float4 _BaseColor;
			float _BumpScale;
			float4 _EmissionColor;
			float _Smoothness;
			float _Cutoff;
		CBUFFER_END
		ENDHLSL

		Pass
		{
			Name "Example"
			Tags { "LightMode" = "UniversalForward" }
			
			HLSLPROGRAM

			// Required to compile gles 2.0 with standard SRP library
			// All shaders must be compiled with HLSLcc and currently only gles is not using HLSLcc by default
			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x gles

			//#pragma target 4.5 // https://docs.unity3d.com/Manual/SL-ShaderCompileTargets.html

			#pragma vertex vert
			#pragma fragment frag
			
			// Material Keywords
			#pragma shader_feature _NORMALMAP
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

			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 color : COLOR;
				float2 uv : TEXCOORD0;
				float2 lightmapUV : TEXCOORD1;
			};
			TEXTURE2D(_RippleMap);            SAMPLER(sampler_RippleMap);
			TEXTURE2D(_FlowMap);            SAMPLER(sampler_FlowMap);
			
			float _RippleSpeed;
			float _RippleTilling;
			float _NoiseSpped;
			float _RippleStrength;

			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float4 color : COLOR;
				float2 uv : TEXCOORD0;
				DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);
				
				#ifdef REQUIRES_WORLD_SPACE_POS_INTERPOLATOR
					float3 positionWS : TEXCOORD2;
				#endif

				float3 normalWS : TEXCOORD3;
				#ifdef _NORMALMAP
					float4 tangentWS : TEXCOORD4;
				#endif

				float3 viewDirWS : TEXCOORD5;
				half4 fogFactorAndVertexLight : TEXCOORD6; // x: fogFactor, yzw: vertex light

				#ifdef REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
					float4 shadowCoord : TEXCOORD7;
				#endif
			};

			// Automatically defined with SurfaceInput.hlsl
			//TEXTURE2D(_BaseMap);
			//SAMPLER(sampler_BaseMap);
			
			#if SHADER_LIBRARY_VERSION_MAJOR < 9
				// This function was added in URP v9.x.x versions, if we want to support URP versions before, we need to handle it instead.
				// Computes the world space view direction (pointing towards the viewer).
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
				OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);

				OUT.color = IN.color;

				#ifdef REQUIRES_WORLD_SPACE_POS_INTERPOLATOR
					OUT.positionWS = positionInputs.positionWS;
				#endif

				OUT.viewDirWS = GetWorldSpaceViewDir(positionInputs.positionWS);

				VertexNormalInputs normalInputs = GetVertexNormalInputs(IN.normalOS, IN.tangentOS);
				OUT.normalWS = normalInputs.normalWS;
				#ifdef _NORMALMAP
					real sign = IN.tangentOS.w * GetOddNegativeScale();
					OUT.tangentWS = half4(normalInputs.tangentWS.xyz, sign);
				#endif

				half3 vertexLight = VertexLighting(positionInputs.positionWS, normalInputs.normalWS);
				half fogFactor = ComputeFogFactor(positionInputs.positionCS.z);

				OUT.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

				OUTPUT_LIGHTMAP_UV(IN.lightmapUV, unity_LightmapST, OUT.lightmapUV);
				OUTPUT_SH(OUT.normalWS.xyz, OUT.vertexSH);

				#ifdef REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
					OUT.shadowCoord = GetShadowCoord(positionInputs);
				#endif

				return OUT;
			}
			
			InputData InitializeInputData(Varyings IN, half3 normalTS)
			{
				InputData inputData = (InputData)0;

				#if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
					inputData.positionWS = IN.positionWS;
				#endif
				
				half3 viewDirWS = SafeNormalize(IN.viewDirWS);
				#ifdef _NORMALMAP
					float sgn = IN.tangentWS.w; // should be either +1 or -1
					float3 bitangent = sgn * cross(IN.normalWS.xyz, IN.tangentWS.xyz);
					inputData.normalWS = TransformTangentToWorld(normalTS, half3x3(IN.tangentWS.xyz, bitangent.xyz, IN.normalWS.xyz));
				#else
					inputData.normalWS = IN.normalWS;
				#endif

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

			// Ripple
			float2 Unity_Flipbook_float(float2 UV, float Width, float Height, float Tile, float2 Invert)
			{
				Tile = fmod(Tile, Width * Height);
				float2 tileCount = float2(1.0, 1.0) / float2(Width, Height);
				float tileY = abs(Invert.y * Height - (floor(Tile * tileCount.x) + Invert.y * 1));
				float tileX = abs(Invert.x * Width - ((Tile - Width * floor(Tile * tileCount.x)) + Invert.x * 1));
				return(UV + float2(tileX, tileY)) * tileCount;
			}
			float3 Unity_NormalBlend_float(float3 A, float3 B)
			{
				return normalize(float3(A.rg + B.rg, A.b * B.b));
			}
			inline float2 unity_voronoi_noise_randomVector(float2 UV, float offset)
			{
				float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
				UV = frac(sin(mul(UV, m)) * 46839.32);
				return float2(sin(UV.y * + offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5);
			}

			void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
			{
				float2 g = floor(UV * CellDensity);
				float2 f = frac(UV * CellDensity);
				float t = 8.0;
				float3 res = float3(8.0, 0.0, 0.0);

				for (int y = -1; y <= 1; y++)
				{
					for (int x = -1; x <= 1; x++)
					{
						float2 lattice = float2(x, y);
						float2 offset = unity_voronoi_noise_randomVector(lattice + g, AngleOffset);
						float d = distance(lattice + offset, f);
						if (d < res.x)
						{
							res = float3(d, offset.x, offset.y);
							Out = res.x;
							Cells = res.y;
						}
					}
				}
			}
			// void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
			// {
			// 	Out = {precision}3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
			// }

			half3 CalculateRipple(float2 ripple_uv, float strength)
			{
				float tile = round(_Time.x * _RippleSpeed);
				float2 flip_uv = Unity_Flipbook_float(frac(ripple_uv), 4, 4, tile, float2(0, 1));
				half3 rippleNormal = SampleNormal(flip_uv, TEXTURE2D_ARGS(_RippleMap, sampler_RippleMap), strength);
				return rippleNormal;
			}

			SurfaceData InitializeSurfaceData(Varyings IN)
			{
				SurfaceData surfaceData = (SurfaceData)0;
				// Note, we can just use SurfaceData surfaceData; here and not set it.
				// However we then need to ensure all values in the struct are set before returning.
				// By casting 0 to SurfaceData, we automatically set all the contents to 0.
				
				half4 albedoAlpha = SampleAlbedoAlpha(IN.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
				surfaceData.alpha = Alpha(albedoAlpha.a, _BaseColor, _Cutoff);
				surfaceData.albedo = albedoAlpha.rgb * _BaseColor.rgb * IN.color.rgb;

				// For the sake of simplicity I'm not supporting the metallic/specular map or occlusion map
				// for an example of that see : https://github.com/Unity-Technologies/Graphics/blob/master/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl
				
				surfaceData.smoothness = 0.5;
				surfaceData.normalTS = SampleNormal(IN.uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
				surfaceData.emission = SampleEmission(IN.uv, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap));
				surfaceData.occlusion = 1;


				float offset = _Time.x * 10;
				float tilling = 8;
				float uv2 = IN.uv * tilling + offset;
				half3 waterNormal = SampleNormal(uv2, TEXTURE2D_ARGS(_FlowMap, sampler_FlowMap), 1);



				// voronoi noise
				float angle = _Time.x * _NoiseSpped;
				float strength, cell;
				Unity_Voronoi_float(IN.uv, angle, 6, strength, cell);
				strength *= _RippleStrength;
				// surfaceData.albedo = strength;
				// strength = 1;
				// Ripple
				float2 ripple_uv = IN.uv * _RippleTilling;
				float2 ripple_uv2 = IN.uv * _RippleTilling * 0.5 + 0.3;
				half3 rippleNormal = Unity_NormalBlend_float(CalculateRipple(ripple_uv, strength), CalculateRipple(ripple_uv2, strength));

				surfaceData.normalTS = Unity_NormalBlend_float(rippleNormal, surfaceData.normalTS);

				return surfaceData;
			}
			
			half4 frag(Varyings IN) : SV_Target
			{
				SurfaceData surfaceData = InitializeSurfaceData(IN);
				InputData inputData = InitializeInputData(IN, surfaceData.normalTS);
				
				// In URP v10+ versions we could use this :
				// half4 color = UniversalFragmentPBR(inputData, surfaceData);

				// But for other versions, we need to use this instead.
				// We could also avoid using the SurfaceData struct completely, but it helps to organise things.
				half4 color = UniversalFragmentPBR(inputData, surfaceData.albedo, surfaceData.metallic,
				surfaceData.specular, surfaceData.smoothness, surfaceData.occlusion,
				surfaceData.emission, surfaceData.alpha);
				
				color.rgb = MixFog(color.rgb, inputData.fogCoord);

				// color.a = OutputAlpha(color.a);
				// Not sure if this is important really. It's implemented as :
				// saturate(outputAlpha + _DrawObjectPassData.a);
				// Where _DrawObjectPassData.a is 1 for opaque objects and 0 for alpha blended.
				// But it was added in URP v8, and versions before just didn't have it.
				// We could still saturate the alpha to ensure it doesn't go outside the 0-1 range though :
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

			// Note if we want to do any vertex displacment, we'll need to change the vertex function :
			/*
			//  e.g.
			#pragma vertex vert

			Varyings vert(Attributes input) {
				Varyings output;
				UNITY_SETUP_INSTANCE_ID(input);

				// Example Displacement
				input.positionOS += float4(0, _SinTime.y, 0, 0);

				output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
				output.positionCS = GetShadowPositionHClip(input);
				return output;
				}*/

				// Using the ShadowCasterPass means we also need _BaseMap, _BaseColor and _Cutoff shader properties.
				// Also including them in cbuffer, with the exception of _BaseMap as it's a texture.

				ENDHLSL

			}

			// Similarly, we should have a DepthOnly pass.
			// UsePass "Universal Render Pipeline/Lit/DepthOnly"
			// Again, since the cbuffer is different it'll break batching with the SRP Batcher.

			// The DepthOnly pass is very similar to the ShadowCaster but doesn't include the shadow bias offsets.
			// I believe Unity uses this pass when rendering the depth of objects in the Scene View.
			// But for the Game View / actual camera Depth Texture it renders fine without it.
			// It's possible that it could be used in Forward Renderer features though, so we should probably still include it.
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
				
				//#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
				// Note, the Lit shader that URP provides uses this, but it also handles the cbuffer which we already have.
				// We could change the shader to use their cbuffer, but we can also just do this :
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
				#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
				#include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"

				// Again, using the DepthOnlyPass means we also need _BaseMap, _BaseColor and _Cutoff shader properties.
				// Also including them in cbuffer, with the exception of _BaseMap as it's a texture.

				ENDHLSL

			}

			// URP also has a "Meta" pass, used when baking lightmaps.
			// UsePass "Universal Render Pipeline/Lit/Meta"
			// While this still breaks the SRP Batcher, I'm curious as to whether it matters.
			// The Meta pass is only used for lightmap baking, so surely is only used in editor?
			// Anyway, if you want to write your own meta pass look at the shaders URP provides for examples
			// https://github.com/Unity-Technologies/Graphics/tree/master/com.unity.render-pipelines.universal/Shaders

		}
	}