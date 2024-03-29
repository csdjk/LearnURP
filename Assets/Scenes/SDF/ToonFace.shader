Shader "lcl/ToonFace"
{
    Properties
    {
        _BaseMap ("Texture", 2D) = "white" { }
        _BaseColor ("Example Colour", Color) = (0, 0.66, 0.73, 1)
        _Cutoff ("Alpha Cutoff", Float) = 0.5

        _FaceShadowTex ("Face Shadow Texture", 2D) = "white" { }
        _FaceLightOffset ("Face Light Offset", Range(0,1)) = 0.5
        _ShadowSmoothness ("Shadow Smoothness", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"
        }
        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Assets/Shaders/Libraries/Node.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                float4 _BaseColor;
                float _Cutoff;
                float _FaceLightOffset;
                float _ShadowSmoothness;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
                float4 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
                float3 normalWS : NORMAL;
                float3 positionWS : TEXCOORD2;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            TEXTURE2D(_FaceShadowTex);
            SAMPLER(sampler_FaceShadowTex);


            Varyings vert(Attributes input)
            {
                Varyings output;
                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = positionInputs.positionCS;
                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                output.color = input.color;
                output.positionWS = positionInputs.positionWS;
                VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS.xyz);
                output.normalWS = normalInputs.normalWS;
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
                half4 color = baseMap * _BaseColor * input.color;
                float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS.xyz);
                Light light = GetMainLight(shadowCoord);
                half3 shading = LightingLambert(light.color, light.direction, input.normalWS);


                float3 L = light.direction;
                float3 forward = GetModelForwardDir();
                float3 left = -GetModelRightDir();

                //L.xz:光源方向在水平面上的投影
                float lightAtten = 1 - (dot(L.xz, forward.xz) * 0.5 + 0.5);
                float filpU = sign(dot(L.xz, left.xz));
                float2 shadow_uv = input.uv * float2(filpU, 1);
                float3 shaodwRamp = SAMPLE_TEXTURE2D(_FaceShadowTex, sampler_FaceShadowTex, shadow_uv).a;
                float faceShadow = SmoothValue(lightAtten + _FaceLightOffset, _ShadowSmoothness, shaodwRamp.r);

                return half4(faceShadow.xxx, 1);

                // return half4(color.rgb * shading * light.shadowAttenuation, color.a);
            }
            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
            ZWrite On
            ZTest LEqual
            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x gles
            //#pragma target 4.5
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }
    }
}
