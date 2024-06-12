Shader "LcL/GPU-Animation/GPU-AnimationBone2D"
{
    Properties
    {
        _BaseMap ("Texture", 2D) = "white" { }
        _BaseColor ("Color", Color) = (1, 1, 1, 1)
        _AnimationTex ("Bone Texture", 2D) = "white" { }
        _FrameIndex ("Frame Index", Int) = 0
        _BlendFrameIndex ("Blend Frame Index", Int) = 0
        _BlendProgress ("Blend Progress", Range(0.0, 1.0)) = 0.0
        [Toggle(_Blend)] _Blend ("Blend", float) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core@12.1.7/ShaderLibrary/Packing.hlsl"
        #include "Assets/Shaders/Libraries/Math.hlsl"

        CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            float4 _BaseColor;
            float4 _AnimationTex_TexelSize;
            float4 _AnimationNormalTex_TexelSize;
            float _Cutoff;
            int _Blend;
            // 当前动画第几帧
            int _FrameIndex;
            // 下一个动画在第几帧
            int _BlendFrameIndex;
            // 下一个动画的融合程度
            float _BlendProgress;
        CBUFFER_END


        TEXTURE2D(_AnimationTex);
        SAMPLER(sampler_AnimationTex);

        float4x4 GetBoneMatrix(uint boneIndex, uint frame)
        {
            uint startIndex = boneIndex * 3;
            float4x4 boneMatrix = 0;
            boneMatrix[0] = LOAD_TEXTURE2D_LOD(_AnimationTex, uint2(startIndex + 0, frame), 0);
            boneMatrix[1] = LOAD_TEXTURE2D_LOD(_AnimationTex, uint2(startIndex + 1, frame), 0);
            boneMatrix[2] = LOAD_TEXTURE2D_LOD(_AnimationTex, uint2(startIndex + 2, frame), 0);
            boneMatrix[3] = float4(0, 0, 0, 1);
            return boneMatrix;
        }


        void TransformBoneAnimation(float4 boneIndexs, float4 boneWeights, inout float4 positionOS)
        {
            //提取当前帧骨骼矩阵
            float4x4 boneMatrix = GetBoneMatrix(boneIndexs.x, _FrameIndex);

            //混合下一个动画
            if (_Blend)
            {
                //提取下一个动画的第一帧骨骼矩阵
                float4x4 boneMatrixBlend = GetBoneMatrix(boneIndexs.x, _BlendFrameIndex);
                boneMatrix = lerp(boneMatrix, boneMatrixBlend, _BlendProgress);
            }

            //转换坐标的本质流程: 模型空间 -> 世界空间 -> 骨骼空间 -> 世界空间 -> 模型空间
            positionOS = mul(boneMatrix, positionOS);
        }
        ENDHLSL

        Pass
        {
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_instancing
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT


            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"


            struct Attributes
            {
                float4 positionOS : POSITION;
                float4 color : COLOR;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv : TEXCOORD0;
                float4 boneIndexs : TEXCOORD1;
                float4 boneWeights : TEXCOORD2;
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
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                TransformBoneAnimation(input.boneIndexs, input.boneWeights, input.positionOS);

                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = positionInputs.positionCS;
                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                output.color = input.color;
                output.positionWS = positionInputs.positionWS;

                VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                output.normalWS = normalInputs.normalWS;
                output.tangentWS = normalInputs.tangentWS;
                return output;
            }


            half4 frag(Varyings input) : SV_Target
            {


                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
                half4 color = baseMap * _BaseColor * input.color;

                float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS.xyz);
                Light light = GetMainLight(shadowCoord);
                half3 shading = LightingLambert(light.color, light.direction, input.normalWS) * 0.5 + 0.5;
                return half4(color.rgb * shading * light.shadowAttenuation, color.a);
            }
            ENDHLSL
        }
    }
}
