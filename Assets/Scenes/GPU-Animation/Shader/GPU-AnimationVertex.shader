Shader "LcL/GPU-Animation/GPU-AnimationVertex"
{
    Properties
    {
        _BaseMap ("Texture", 2D) = "white" { }
        _BaseColor ("Color", Color) = (1, 1, 1, 1)
        _AnimationTex ("Animation Texture", 2D) = "white" { }
        _AnimationNormalTex ("Animation Normal Texture", 2D) = "white" { }
        _FrameIndex ("Frame Index", Range(0.0, 200)) = 0.0
        _BlendFrameIndex ("Blend Frame Index", Range(0.0, 200)) = 0.0
        _BlendProgress ("Blend Progress", Range(0.0, 1.0)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            float4 _BaseColor;
            float4 _AnimationTex_TexelSize;
            float4 _AnimationNormalTex_TexelSize;
            float _Cutoff;
            // 当前动画第几帧
            int _FrameIndex;
            // 下一个动画在第几帧
            int _BlendFrameIndex;
            // 下一个动画的融合程度
            float _BlendProgress;
        CBUFFER_END


        // UNITY_INSTANCING_BUFFER_START(Props)
        // UNITY_DEFINE_INSTANCED_PROP(float4, _BaseMap_ST)
        // UNITY_DEFINE_INSTANCED_PROP(float4, _BaseColor)
        // UNITY_DEFINE_INSTANCED_PROP(float4, _AnimationTex_TexelSize)
        // UNITY_DEFINE_INSTANCED_PROP(float4, _AnimationNormalTex_TexelSize)
        // UNITY_DEFINE_INSTANCED_PROP(float, _Cutoff)
        // UNITY_DEFINE_INSTANCED_PROP(int, _FrameIndex)
        // UNITY_DEFINE_INSTANCED_PROP(int, _BlendFrameIndex)
        // UNITY_DEFINE_INSTANCED_PROP(float, _BlendProgress)
        // UNITY_INSTANCING_BUFFER_END(Props)

        // #define _BaseMap_ST  UNITY_ACCESS_INSTANCED_PROP(Props, _BaseMap_ST)
        // #define _BaseColor  UNITY_ACCESS_INSTANCED_PROP(Props, _BaseColor)
        // #define _AnimationTex_TexelSize  UNITY_ACCESS_INSTANCED_PROP(Props, _AnimationTex_TexelSize)
        // #define _AnimationNormalTex_TexelSize  UNITY_ACCESS_INSTANCED_PROP(Props, _AnimationNormalTex_TexelSize)
        // #define _Cutoff  UNITY_ACCESS_INSTANCED_PROP(Props, _Cutoff)
        // #define _FrameIndex  UNITY_ACCESS_INSTANCED_PROP(Props, _FrameIndex)
        // #define _BlendFrameIndex  UNITY_ACCESS_INSTANCED_PROP(Props, _BlendFrameIndex)
        // #define _BlendProgress  UNITY_ACCESS_INSTANCED_PROP(Props, _BlendProgress)

        TEXTURE2D(_AnimationTex);
        SAMPLER(sampler_AnimationTex);
        TEXTURE2D(_AnimationNormalTex);
        SAMPLER(sampler_AnimationNormalTex);

        void TransformAnimation(uint vertexIndex, inout float4 positionOS, inout float3 normalOS,
        inout float4 tangentOS)
        {
            positionOS = LOAD_TEXTURE2D_LOD(_AnimationTex, uint2(vertexIndex, _FrameIndex), 0);
            float4 blendPositionOS = LOAD_TEXTURE2D_LOD(_AnimationTex, uint2(vertexIndex, _BlendFrameIndex), 0);

            positionOS.xyz = lerp(positionOS.xyz, blendPositionOS.xyz, _BlendProgress);

            // 采样法线\切线数据
            float4 normalTangentData = LOAD_TEXTURE2D_LOD(_AnimationNormalTex, uint2(vertexIndex, _FrameIndex), 0);
            // 解码法线和切线
            normalOS = UnpackNormalOctQuadEncode(normalTangentData.xy);
            tangentOS = float4(UnpackNormalOctQuadEncode(normalTangentData.zw), positionOS.a);
        }
        ENDHLSL

        Pass
        {
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core@12.1.7/ShaderLibrary/Packing.hlsl"

            struct Attributes
            {
                uint id : SV_VertexID;
                float4 positionOS : POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
                float3 normalWS : NORMAL;
                float3 positionWS : TEXCOORD1;
                float3 tangentWS : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);


            Varyings vert(Attributes input)
            {
                Varyings output;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                float4 positionOS, tangentOS;
                float3 normalOS;
                TransformAnimation(input.id, positionOS, normalOS, tangentOS);


                VertexPositionInputs positionInputs = GetVertexPositionInputs(positionOS.xyz);
                output.positionCS = positionInputs.positionCS;
                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                output.color = input.color;
                output.positionWS = positionInputs.positionWS;

                VertexNormalInputs normalInputs = GetVertexNormalInputs(normalOS, tangentOS);
                output.normalWS = normalInputs.normalWS;
                output.tangentWS = normalInputs.tangentWS;
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);

                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
                half4 color = baseMap * _BaseColor * input.color;

                float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS.xyz);
                Light light = GetMainLight(shadowCoord);
                half3 shading = LightingLambert(light.color, light.direction, input.normalWS) * 0.5 + 0.5;
                return half4(color.rgb * shading * light.shadowAttenuation, color.a);
            }
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On
            ZTest LEqual

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma only_renderers gles gles3 glcore d3d11


            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"

            // Material Keywords
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            // GPU Instancing
            #pragma multi_compile_instancing

            struct AttributesShadow
            {
                uint id : SV_VertexID;
                float4 positionOS : POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };


            Varyings ShadowPassVertexAnim(AttributesShadow input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);

                float4 positionOS, tangentOS;
                float3 normalOS;
                TransformAnimation(input.id, positionOS, normalOS, tangentOS);


                Attributes input2;
                input2.positionOS = positionOS;
                input2.normalOS = normalOS;
                input2.texcoord = input.uv;

                output.positionCS = GetShadowPositionHClip(input2);
                return output;
            }

            #pragma vertex ShadowPassVertexAnim
            #pragma fragment ShadowPassFragment
            ENDHLSL
        }
    }
}
