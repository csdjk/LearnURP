Shader "Custom/UnlitShaderExample"
{
    Properties
    {
        _BaseMap ("Example Texture", 2D) = "white" {}
        _BaseColor ("Example Colour", Color) = (0, 0.66, 0.73, 1)
        _RotationAngle ("Rotation Angle", Range(0,3.14)) = 0
        _NoiseTex ("Noise Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline"
        }

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Assets/Shaders/Libraries/Hash.hlsl"

        CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            float4 _BaseColor;
            float _RotationAngle;
        CBUFFER_END

        TEXTURE2D(_NoiseTex);
        SAMPLER(sampler_NoiseTex);
        ENDHLSL

        Pass
        {
            Name "Example"
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
                float4 color : COLOR;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
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
                return output;
            }

            float DegreeToRadian(float degree)
            {
                return degree * 3.14159 / 180.0;
            }

            float2 RotateUV(float2 uv, float angle, float2 center = float2(0.5, 0.5))
            {
                angle = DegreeToRadian(angle);
                float s, c;
                sincos(angle, s, c);

                // Translate point back to origin
                uv -= center;

                // Rotate point
                float xnew = uv.x * c - uv.y * s;
                float ynew = uv.x * s + uv.y * c;

                // Translate point back
                uv = float2(xnew, ynew) + center;
                return uv;
            }

            float2 TransformUV(float2 uv, float rotation, float scale, float2 offset,
                               float2 center = float2(0.5, 0.5))
            {
                // Rotate UV
                uv = RotateUV(uv, rotation, center);

                // Scale UV
                uv *= scale;

                // Translate UV
                uv += offset;

                return uv;
            }

            float3 noise23(float2 p)
            {
                float a = dot(float3(127.099998, 312.700012, 74.699997), p.yxx);
                float b = dot(float3(270, 183, 246), p.yxx);
                float c = dot(float3(113.5, 271.899994, 127.599998), p.xyy);
                return frac(sin(float3(a, b, c)) * 43758.5453);
            }

            float2 RandomTransformUV(float2 uv, float2 rotationRange, float2 scaleRange, float2 seed = float2(0, 0))
            {
                // float angle = UNITY_SAMPLE_TEX2D(_NoiseTex, uv).r * 2.0 * 3.14159;
                float3 noise = noise23(seed);
                float randomRotation = lerp(rotationRange.x, rotationRange.y, frac(noise.z * 16));
                float randomScale = lerp(scaleRange.x, scaleRange.y, noise.z);
                // Rotate, Scale and Translate UV
                uv = TransformUV(uv, randomRotation, randomScale, noise.xy);

                return uv;
            }


            half4 frag(Varyings input) : SV_Target
            {
                float2 uv = input.uv - float2(0.5, 0.5);
                float dit = 1 - length(uv);
                // float angle = _Time.x * dit * _RotationAngle;
                float angle = _Time.x * _RotationAngle;

                // float3 noise = noise23(input.uv);
                // return half4(noise, 1);
                float3 noise = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, input.uv) * 15;
                noise = round(noise);

                float2 rotatedUV = RandomTransformUV(input.uv, float2(0, 360), float2(0.8, 1.2),noise);
                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, rotatedUV);
                return baseMap * _BaseColor * input.color;
            }
            ENDHLSL
        }
    }
}
