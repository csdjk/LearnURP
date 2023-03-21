Shader "LightSpaceToon2/ToonBase"
{
    Properties
    {
        [Header(Surface Inputs)]
        [Space(5)]
        [MainTexture]
        _MainTex ("Diffuse Map", 2D) = "white" { }
        _SpecColorTex ("Specular Color Map", 2D) = "white" { }
        _SSSTex ("SSS (RGB)", 2D) = "white" { }
        _ILMTex ("ILM (RGB)", 2D) = "white" { }
        [Space(5)]
        [Header(Toon Surface Inputs)]
        _ShadowShift ("Shadow Shift", Range(-2, 1)) = 1
        _DarkenInnerLine ("Darken Inner Line", Range(0, 1)) = 0.2
        _BrightAddjustment ("Bright Addjustment", Range(0.5, 2)) = 1.0
        [Space(5)]
        [Header(Toon Specular Inputs)]
        _Roughness ("Roughness", Range(0.2, 0.85)) = 0.5
        _SpecEdgeSmoothness ("Specular Edge Smoot", Range(0.1, 1)) = 0.5
        _SpecularPower ("Specular Power", Range(0.01, 2)) = 1
        [Space(5)]
        [Header(Scatter Input)]
        _Distortion ("Distortion", Float) = 0.28
        _Power ("Power", Float) = 1.43
        _Scale ("Scale", Float) = 0.49
        [Space(5)]
        [Header(Tone Mapped)]
        _Exposure (" Tone map Exposure ", Range(0, 1)) = 0.5
        [Header(Render Queue)]
        [Space(8)]
        [IntRange] _QueueOffset ("Queue Offset", Range(-50, 50)) = 0
        [ToggleOff(_RECEIVE_SHADOWS_OFF)] _ReceiveShadowsOff ("Receive Shadows", Float) = 1
        _ShadowRecieveThresholdWeight ("SelfShadow Threshold", Range(0.001, 2)) = 0.25

        //  Needed by the inspector
        [HideInInspector] _Culling ("Culling", Float) = 0.0
        [HideInInspector] _AlphaFromMaskMap ("AlphaFromMaskMap", Float) = 1.0
    }

    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry" }
        LOD 100

        Pass // Toon Shading Pass

        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard SRP library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x

            //  Shader target needs to be 3.0 due to tex2Dlod in the vertex shader or VFACE
            #pragma target 3.0

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            
            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            sampler2D _MainTex;
            sampler2D _SpecColorTex;
            sampler2D _SSSTex;
            sampler2D _ILMTex;

            //  Material Inputs
            CBUFFER_START(UnityPerMaterial)
                half4 _MainTex_ST;
                //  Toon
                half _ShadowShift;
                half _DarkenInnerLine;
                half _SpecEdgeSmoothness;
                half _Roughness;
                half _BrightAddjustment;
                half _SpecularPower;
                half _ShadowRecieveThresholdWeight;
                //  Scatter
                half _Distortion;
                half _Power;
                half _Scale;
                //  Tone Map
                half _Exposure;
            CBUFFER_END

            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment
            
            struct Attributes //appdata

            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 color : COLOR; //Vertex color attribute input.
                float2 texCoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings //v2f

            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
                float3 normalWS : NORMAL;
                float4 vertex : TEXCOORD1;
                float3 viewDirWS : TEXCOORD2;
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    float4 shadowCoord : TEXCOORD3; // compute shadow coord per-vertex for the main light
                #endif
                float4 positionWS : TEXCOORD4;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            //--------------------------------------
            //  Vertex shader

            Varyings LitPassVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                
				VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);

                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                float3 viewDirWS = GetCameraPositionWS() - positionWS;
                output.uv = TRANSFORM_TEX(input.texCoord, _MainTex);
                float3 normalWS = TransformObjectToWorldNormal(input.normalOS);
                output.normalWS = normalWS;
                output.viewDirWS = viewDirWS;
                
                #if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
                    output.positionWS = float4(positionWS, 0);
                #endif

                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.shadowCoord = GetShadowCoord(positionInputs);
                #endif
                
                output.positionCS = TransformWorldToHClip(positionWS);
                output.color = input.color;
                return output;
            }

            //--------------------------------------
            //  shader and functions
            
            #define _PI 3.14159265359
            // Beckmann normal distribution function here for Specualr
            half NDFBeckmann(float roughness, float NdotH)
            {
                float roughnessSqr = max(1e-4f, roughness * roughness);
                float NdotHSqr = NdotH * NdotH;
                return max(0.000001, (1.0 / (_PI * roughnessSqr * NdotHSqr * NdotHSqr)) * exp((NdotHSqr - 1) / (roughnessSqr * NdotHSqr)));
            }
            
            // Fast back scatter distribution function here for virtual back lighting
            half3 LightScatterFunction(half3 surfaceColor, half3 normalWS, half3 viewDir, Light light, half distortion, half power, half scale)
            {
                half3 lightDir = light.direction;
                half3 normal = normalWS;
                half3 H = lightDir + (normal * distortion);
                float VdotH = pow(saturate(dot(viewDir, -H)), power) * scale;
                half3 col = light.color * VdotH;
                return col;
            }
            

            //--------------------------------------
            //  Fragment shader and functions
	
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

            half4 LitPassFragment(Varyings input, half facing : VFACE) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);

                //  Apply lighting
                float4 finCol = 1; //initializing
                
                float4 mainTex = tex2D(_MainTex, input.uv);
                float4 specClorTex = tex2D(_SpecColorTex, input.uv);
                float4 sssTex = tex2D(_SSSTex, input.uv);
                float4 ilmTex = tex2D(_ILMTex, input.uv);
                
                float shadowThreshold = ilmTex.g;
                shadowThreshold *= input.color.r;
                shadowThreshold = 1 - shadowThreshold + _ShadowShift;
                
                float3 normalDir = normalize(input.normalWS);
                float3 viewDirWS = GetWorldSpaceViewDir(input.positionWS.xyz);
                
                #if defined(MAIN_LIGHT_CALCULATE_SHADOWS)
                    float3 positionWS = input.positionWS.xyz;
                #endif

                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    float4 shadowCoord = input.shadowCoord;
                #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
                    float4 shadowCoord = TransformWorldToShadowCoord(positionWS);
                #else
                    float4 shadowCoord = float4(0, 0, 0, 0);
                #endif

                Light mainLight = GetMainLight(shadowCoord);
                float3 halfDir = normalize(viewDirWS + mainLight.direction);
                float NdotL = (dot(normalDir, mainLight.direction));
                float NdotH = max(0, dot(normalDir, halfDir));
                float halfLambertForToon = NdotL * 0.5 + 0.5;
                half atten = mainLight.shadowAttenuation * mainLight.distanceAttenuation;
                
                half3 brightCol = mainTex.rgb * (halfLambertForToon) * _BrightAddjustment;
                half3 shadowCol = mainTex.rgb * sssTex.rgb;
                half3 scatterOut = LightScatterFunction(shadowCol.xyz, normalDir.xyz, viewDirWS, mainLight, _Distortion, _Power, _Scale);
                
                
                halfLambertForToon = saturate(halfLambertForToon);
                half spec = NDFBeckmann(_Roughness, NdotH);
                half SpecularMask = ilmTex.b;
                half SpecularWeight = smoothstep(0.1, _SpecEdgeSmoothness, spec);
                half shadowContrast = step(shadowThreshold * _ShadowRecieveThresholdWeight, NdotL * atten);
                half3 ToonDiffuse = brightCol * shadowContrast;
                half3 mergedDiffuseSpecular = lerp(ToonDiffuse, specClorTex, SpecularWeight * (_SpecularPower * SpecularMask));
                
                finCol.rgb = lerp(shadowCol, mergedDiffuseSpecular, shadowContrast);
                
                finCol.rgb = lerp(finCol.rgb, finCol.rgb + (shadowCol.rgb * shadowCol.rgb), scatterOut.rgb);
                finCol.rgb *= mainLight.color.rgb;
                float DetailLine = ilmTex.a;
                DetailLine = lerp(DetailLine, _DarkenInnerLine, step(DetailLine, _DarkenInnerLine));
                finCol.rgb *= DetailLine;

                //Simple Tone mapping
                finCol.rgb = finCol.rgb / (finCol.rgb + _Exposure);
                return finCol;
            }
            ENDHLSL
        }
        
        
        Pass //Shadow Caster Pass

        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On
            ZTest LEqual
            Cull Off

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 2.0

            #pragma multi_compile_instancing
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            
            ENDHLSL
        }
    }
    FallBack "Hidden/InternalErrorShader"
}