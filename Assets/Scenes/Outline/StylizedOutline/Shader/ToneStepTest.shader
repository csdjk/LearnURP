Shader "LcL/NPR/ToneStepTest"
{
    Properties
    {
        _BaseMap ("Texture", 2D) = "white" {}
        _BaseColor ("Colour", Color) = (1, 1, 1, 1)
        _Cutoff ("Alpha Cutoff", Float) = 0.5

        _DistNoiseMap ("扭曲NoiseMap", 2D) = "white" {}
        _DistNoiseTiling ("DistNoiseTiling", Range(0,100)) = 1
        _DistNoiseSpeed ("DistNoiseSpeed", Vector) = (1,1,0,0)
        _DistNoiseIntensity ("DistNoiseIntensity", Range(0, 1)) = 0.1

        _StepNoiseMap ("NoiseMap", 2D) = "white" {}
        _StepNoiseIntensity ("StepNoiseIntensity", Range(0, 1)) = 0.1
        [IntRange] _RampStep("交界段数 RampStep", Range(1,10)) = 1
        _RampStart("RampStart", Range(0, 1)) = 0.5
        _RampSize("RampSize", Range(0, 1)) = 0.5
        _RampSmooth("RampSmooth", Range(0.01, 0.5)) = 0.01
        _DarkColor("DarkColor", Color) = (0.0, 0.0, 0.0, 1)
        _LightColor("LightColor", Color) = (1.0, 1.0, 1.0, 1)
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline"
        }

        //        Stencil
        //        {
        //            Ref 1
        //            Comp Always
        //            Pass Replace
        //        }

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Assets/Shaders/Libraries/Node.hlsl"

        CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            float4 _BaseColor;
            float _Cutoff;
            float4 _StepNoiseMap_ST;
            float _StepNoiseIntensity;
            float _DistNoiseTiling;
            float3 _DistNoiseSpeed;
            float _DistNoiseIntensity;

            float _RampStart;
            float _RampSize;
            float _RampStep;
            float _RampSmooth;
            float4 _DarkColor;
            float4 _LightColor;
        CBUFFER_END

        Texture2D _StepNoiseMap;
        SamplerState sampler_StepNoiseMap;
        Texture2D _DistNoiseMap;
        SamplerState sampler_DistNoiseMap;


        ENDHLSL

        Pass
        {
            Tags
            {
                "LightMode"="UniversalForward"
            }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalOS : NORMAL;
                float4 color : COLOR;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS: TEXCOORD1;
                float3 positionWS : TEXCOORD2;
                float4 color : COLOR;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            Varyings vert(Attributes input)
            {
                Varyings output;

                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = positionInputs.positionCS;
                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                output.color = input.color;
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                output.positionWS = positionInputs.positionWS;
                return output;
            }


            half4 frag(Varyings input) : SV_Target
            {
                float3 normalWS = normalize(input.normalWS);
                Light light = GetMainLight();

                float2 noise_uv = TriplanarFlowUV(input.positionWS, normalWS, _DistNoiseTiling,_DistNoiseSpeed,0);

                float distNoise = SAMPLE_TEXTURE2D(_DistNoiseMap, sampler_DistNoiseMap, noise_uv).r * 2 - 1;
                distNoise = distNoise * _DistNoiseIntensity;

                float2 uv = input.uv + distNoise;
                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
                // return baseMap;

                half stepNoise = SAMPLE_TEXTURE2D(_StepNoiseMap, sampler_StepNoiseMap, (uv) * _StepNoiseMap_ST.xy).r * 2 - 1;
                normalWS += stepNoise * _StepNoiseIntensity;
                normalWS = normalize(normalWS);

                float NdotL = dot(normalWS, light.direction) * 0.5 + 0.5;

                float diff = inverseLerp(_RampStart, _RampStart + _RampSize, NdotL);

                float ramp = RampStep(diff, _RampStep, _RampSmooth);

                float4 rampColor = lerp(_DarkColor, _LightColor, ramp);
                // return rampColor;

                return rampColor * baseMap;
            }
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            ZWrite On
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment
            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
            ENDHLSL
        }
    }
    CustomEditor "LcLShaderEditor.LcLShaderGUI"
}
