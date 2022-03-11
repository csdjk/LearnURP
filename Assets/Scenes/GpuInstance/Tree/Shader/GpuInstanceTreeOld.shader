Shader "lcl/GPUInstance/TreeOld"
{
    Properties
    {
        _BaseMap ("Texture", 2D) = "white" { }
        _BaseColor ("Color", Color) = (1, 1, 1, 1)
        _LambertFactor ("Lambert Factor", Range(0.0, 1.0)) = 0.5
        _Cutoff ("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

        _BumpMap ("Normal Map", 2D) = "bump" { }
        _BumpScale ("Normal Scale", Float) = 1.0

        _OcclusionStrength ("AO Strength", Range(0.0, 1.0)) = 1.0
        // _OcclusionMap ("Occlusion", 2D) = "white" { }

    
        _ShadowColor ("Shadow Color", Color) = (0.7, 0.7, 0.7)
        _ShadowIntensity ("Shadow Intensity", Range(0, 1)) = 0
        

        [NoScaleOffset]_MaskTex ("Mask Texture(R-AO,G-Thickness)", 2D) = "white" { }
        
        [Header(Scatter)]
        [HDR]_ScatterColor ("Scatter Color（散射基础色）", Color) = (1, 1, 1, 1)
        _FrontScatterIntensity ("Front Scatter Intensity（正面散射强度）", Range(0, 1)) = 0
        _ScatterDistortion ("Scatter Distortion（散射扭曲程度）", Range(0, 1)) = 1.0
        _ScatterPower ("Scatter Power（散射强度）", Range(0, 10)) = 1.0
        _ScatterScale ("Scatter Scale（散射比例）", Range(0, 1)) = 1.0

        // _FresnelScale ("Fresnel Scale", Range(0, 10)) = 1.0
        // _FresnelColor ("Fresnel Color", Color) = (1, 1, 1, 1)

        [Header(Wind)]
        _NoiseTex ("NoiseMap", 2D) = "white" { }
        _WindDir ("Wind Direction", Vector) = (0.5, 0.05, 0.5, 0)
        _WindSize ("Wind Wave Size", Range(5, 50)) = 15
        _TreeSwaySpeed ("Tree Sway Speed", Range(0, 10)) = 1
        _TreeSwayDisp ("Tree Sway Displacement", Range(0, 1)) = 0.3
        _TreeLeavesDisp ("Branches Displacement", Range(0, 0.5)) = 0.3
    }
    SubShader
    {
        Tags { "RenderType" = "TransparentCutout" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True" "Queue" = "AlphaTest" }
        LOD 600
        Pass
        {
            Tags { "LightMode" = "UniversalForward" }

            Blend One Zero, One Zero

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            // GPU Instancing
            #pragma multi_compile_instancing
            // #pragma instancing_options procedural:setup

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            // #pragma enable_d3d11_debug_symbols

            #pragma shader_feature _NORMALMAP
            // #pragma shader_feature _ALPHATEST_ON
            // #pragma shader_feature _ALPHAPREMULTIPLY_ON
            // #pragma shader_feature _EMISSION
            // #pragma shader_feature _METALLICSPECGLOSSMAP
            // #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            // #pragma shader_feature _OCCLUSIONMAP

            // #pragma shader_feature _SPECULARHIGHLIGHTS_OFF
            // #pragma shader_feature _ENVIRONMENTREFLECTIONS_OFF
            // #pragma shader_feature _SPECULAR_SETUP
            // #pragma shader_feature _RECEIVE_SHADOWS_OFF
            
            struct appdata
            {
                float4 positionOS : POSITION;
                float4 color : COLOR;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv : TEXCOORD0;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float4 tangentWS : TEXCOORD2;
                float3 bitangentWS : TEXCOORD3;
                float3 positionWS : TEXCOORD4;
                float3 viewDirWS : TEXCOORD5;
                half4 fogFactorAndVertexLight : TEXCOORD6; // x: fogFactor, yzw: vertex light
                DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 7);

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct TreeInfo
            {
                float4x4 localToWorld;
                float4 texParams;
            };
            StructuredBuffer<TreeInfo> _InstanceInfoBuffer;

            TEXTURE2D(_NoiseTex);
            SAMPLER(sampler_NoiseTex);
            
            // TEXTURE2D(_BumpMap);
            // SAMPLER(sampler_BumpMap);

            TEXTURE2D(_MaskTex);
            SAMPLER(sampler_MaskTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                half _Cutoff;
                half _LambertFactor;
                half4 _BaseColor;
                half _BumpScale;

                half4 _SpecColor;
                half4 _EmissionColor;
                half _Smoothness;
                half _Metallic;
                half _OcclusionStrength;

                // -----Wind-----
                float4 _WindDir;
                float _WindSize;
                float _TreeSwaySpeed;
                float _TreeSwayDisp;
                float _TreeLeavesDisp;
                // ---------------

                //
                // float _ShadowThreshold;
                float4 _ShadowColor;
                // float4 _ShadowSmoothness;
                float _ShadowIntensity;

                // -----散射-----
                half3 _ScatterColor;
                float _ScatterDistortion;
                float _ScatterPower;
                float _ScatterScale;
                float _FrontScatterIntensity;
                // ---------------
                float _FresnelScale;
                half3 _FresnelColor;
            CBUFFER_END

            float3 ApplyWind(appdata input, v2f output, float windSpeed)
            {
                float3 windDir = float3(0.05, 0.1, 0);
                half2 windStr = _Time.y * (float3(windDir.xz, 0.0) * windSpeed).xy + output.positionWS.xz;
                half4 noiseWorld = SAMPLE_TEXTURE2D_LOD(_NoiseTex, sampler_NoiseTex, windStr * 0.015, 0);
                float c = clamp(input.positionOS.z - 0.0, 0, 204.0);
                return windDir * (noiseWorld + noiseWorld) * c;
            }

            float4 ApplyWind1(float4 positionOS, float3 vertexColor)
            {
                float2 windSize = positionOS.xz / _WindSize;
                float2 noiseUV = (positionOS.xz - _Time.y) / 30;
                half noiseValue = SAMPLE_TEXTURE2D_LOD(_NoiseTex, sampler_NoiseTex, noiseUV, 0).r;
                
                positionOS.xz += sin(_Time.zz * _TreeSwaySpeed + windSize) * (positionOS.y / 10) * _WindDir.xz * noiseValue * _TreeSwayDisp;

                positionOS.y += cos(_Time.w * _TreeSwaySpeed + _WindDir.x + windSize.y) * vertexColor.r * noiseValue * _TreeLeavesDisp;
                return positionOS;
            }
            
            v2f vert(appdata input, uint instanceID : SV_InstanceID)
            {
                v2f output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float4 positionOS = input.positionOS;
                float3 normalOS = input.normalOS;

                TreeInfo treeInfo = _InstanceInfoBuffer[instanceID];

                positionOS = ApplyWind1(positionOS, input.color.rgb);

                //从本地坐标转换到世界坐标
                float4 positionWS = mul(treeInfo.localToWorld, positionOS);
                positionWS /= positionWS.w;


                output.uv = input.uv;
                output.positionWS = positionWS;
                output.viewDirWS = GetCameraPositionWS() - positionWS;
                output.normalWS = mul(treeInfo.localToWorld, float4(normalOS, 0)).xyz;
                // output.tangentWS = TransformObjectToWorld(input.tangentOS.xyz);
                output.tangentWS = mul(treeInfo.localToWorld, float4(input.tangentOS.xyz, 0.0));
                real sign = input.tangentOS.w * GetOddNegativeScale();
                output.bitangentWS = sign * cross(output.normalWS.xyz, output.tangentWS.xyz);
                output.positionCS = TransformWorldToHClip(positionWS);

                // Wind
                // output.positionCS.xyz += ApplyWind(input, output, _WindSpeed);

                return output;
            }


            half3 GetNormal(float2 uv, TEXTURE2D_PARAM(bumpMap, sampler_bumpMap), half scale = 1.0h)
            {
                half4 n = SAMPLE_TEXTURE2D(bumpMap, sampler_bumpMap, uv);
                #if BUMP_SCALE_NOT_SUPPORTED
                    return UnpackNormal(n);
                #else
                    return UnpackNormalScale(n, scale);
                #endif
            }

            // 计算色阶
            float CalculateRamp(float threshold, float value, float smoothness)
            {
                threshold = saturate(1 - threshold);
                half minValue = saturate(threshold - smoothness);
                half maxValue = saturate(threshold + smoothness);
                return smoothstep(minValue, maxValue, value);
            }
            // 计算SSS
            inline float SubsurfaceScattering(float3 V, float3 L, float3 N, float distortion, float power, float scale)
            {
                // float3 H = normalize(L + N * distortion);
                float3 H = L + N * distortion;
                float I = pow(saturate(dot(V, -H)), power) * scale;
                return I;
            }
         
            half4 frag(v2f input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
              
                half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
                clip(color.a - _Cutoff);

                float2 uv = input.uv;
                float3 positionWS = input.positionWS;
                float3 viewDirWS = normalize(input.viewDirWS);
                // light
                float4 shadowCoords = TransformWorldToShadowCoord(positionWS);
                Light mainLight = GetMainLight(shadowCoords);
                half3 lightDir = mainLight.direction;
                half3 halfDir = normalize(lightDir + viewDirWS);


                half4 mask = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, uv);
                half ao = LerpWhiteTo(mask.r, _OcclusionStrength);
                half thickness = 1 - mask.g;

                // normal
                float3 normalTS = GetNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
                float3 normalWS = TransformTangentToWorld(normalTS, half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz));
                normalWS = normalize(normalWS);


                half shadow = lerp(1, mainLight.shadowAttenuation, _ShadowIntensity);

                float NdotL = dot(normalWS, lightDir);
                float NdotV = dot(normalWS, viewDirWS);
                //Lembert Diffuse
                half halfLambert = NdotL * _LambertFactor + _LambertFactor;


                // _Metallic = (max(max(_SpecColor.r, _SpecColor.g), _SpecColor.b));
                // float oneMinusReflectivity = 1 - _Metallic;
                // _SpecColor.rgb = color.rgb * _Metallic;
                // color.rgb *= oneMinusReflectivity;
                // half3 specular = mainLight.color * pow(max(0, dot(normalWS, halfDir)), _Smoothness * 100) * _SpecColor;
                
                
                // 色阶
                // float ramp = CalculateRamp(_ShadowThreshold, halfLambert, _ShadowSmoothness);
                // float3 diffuse = lerp(_ShadowColor, _BaseColor.xyz, ramp) * _BaseColor.xyz * color.rgb * mainLight.color * ao;

                // 次表面散射
                float3 sssBack = SubsurfaceScattering(viewDirWS, lightDir, normalWS, _ScatterDistortion, _ScatterPower, _ScatterScale) * _ScatterColor * thickness;
                float3 sssFont = SubsurfaceScattering(viewDirWS, -lightDir, normalWS, _ScatterDistortion, _ScatterPower, _ScatterScale) * _ScatterColor * thickness;
                float3 sss = saturate(sssFont * _FrontScatterIntensity + sssBack);

                //分层
                float BandedStep = 4;
                float BandedNL = floor(halfLambert * BandedStep) / BandedStep;
                float3 ramp = BandedNL * halfLambert;
                float3 colorLambert = lerp(_ShadowColor, _BaseColor.xyz, ramp);

                float3 rimCol = _FresnelScale * pow(1 - saturate(NdotV), 5) * _FresnelColor;

                half4 resColor = 1;
                resColor.rgb = color.rgb * _BaseColor.rgb * mainLight.color * ao * halfLambert;
                // resColor.rgb = color.rgb *  mainLight.color * ao * colorLambert;
                resColor.rgb += sss;

                // resColor.rgb += specular;
                
                // resColor.rgb *= shadow;

                return resColor;
            }
            ENDHLSL

        }

        pass
        {
            Tags { "LightMode" = "ShadowCaster" }
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            struct appdata
            {
                float4 positionOS : POSITION;
                float4 color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct v2f
            {
                float4 positionCS : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            TEXTURE2D(_NoiseTex);
            SAMPLER(sampler_NoiseTex);

            CBUFFER_START(UnityPerMaterial)
                // -----Wind-----
                float4 _WindDir;
                float _WindSize;
                float _TreeSwaySpeed;
                float _TreeSwayDisp;
                float _TreeLeavesDisp;
                // ---------------
            CBUFFER_END

            struct TreeInfo
            {
                float4x4 localToWorld;
                float4 texParams;
            };
            StructuredBuffer<TreeInfo> _InstanceInfoBuffer;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 ApplyWind1(float4 positionOS, float3 vertexColor)
            {
                float2 windSize = positionOS.xz / _WindSize;
                float2 noiseUV = (positionOS.xz - _Time.y) / 30;
                half noiseValue = SAMPLE_TEXTURE2D_LOD(_NoiseTex, sampler_NoiseTex, noiseUV, 0).r;
                
                positionOS.xz += sin(_Time.zz * _TreeSwaySpeed + windSize) * (positionOS.y / 10) * _WindDir.xz * noiseValue * _TreeSwayDisp;

                positionOS.y += cos(_Time.w * _TreeSwaySpeed + _WindDir.x + windSize.y) * vertexColor.r * noiseValue * _TreeLeavesDisp;
                return positionOS;
            }
            v2f vert(appdata input, uint instanceID : SV_InstanceID)
            {
                v2f output;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float4 positionOS = input.positionOS;

                TreeInfo treeInfo = _InstanceInfoBuffer[instanceID];

                positionOS = ApplyWind1(positionOS, input.color.rgb);

                float4 positionWS = mul(treeInfo.localToWorld, positionOS);
                positionWS /= positionWS.w;

                output.positionCS = TransformWorldToHClip(positionWS);
                return output;
            }
            float4 frag(v2f i) : SV_Target
            {
                return 0;
            }
            ENDHLSL

        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
