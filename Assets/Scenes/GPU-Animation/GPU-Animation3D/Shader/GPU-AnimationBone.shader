Shader "LcL/GPU-Animation/GPU-AnimationBone"
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
        [Toggle(_INVERSE)] _INVERSE ("矫正Normal", float) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core@12.1.7/ShaderLibrary/Packing.hlsl"
        #include "Assets/Shaders/Libraries/Math.hlsl"
        #pragma shader_feature _ _INVERSE

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

        float4x4 GetBoneMatrixWithWeights(uint4 boneIndexs, float4 boneWeights, uint frame)
        {
            //提取骨骼矩阵
            float4x4 boneMatrix0 = GetBoneMatrix(boneIndexs.x, frame);
            float4x4 boneMatrix1 = GetBoneMatrix(boneIndexs.y, frame);
            float4x4 boneMatrix2 = GetBoneMatrix(boneIndexs.z, frame);
            float4x4 boneMatrix3 = GetBoneMatrix(boneIndexs.w, frame);
            //加权重求和
            return boneMatrix0 * boneWeights.x + boneMatrix1 * boneWeights.y + boneMatrix2 * boneWeights.z + boneMatrix3 * boneWeights.w;
        }


        void TransformBoneAnimation(float4 boneIndexs, float4 boneWeights, inout float4 positionOS, inout float3 normalOS,
        inout float4 tangentOS)
        {
            // int totalFrame = _AnimationTex_TexelSize.w;
            // _FrameIndex = abs(_SinTime.w) * totalFrame;

            //提取当前帧骨骼矩阵
            float4x4 boneMatrix = GetBoneMatrixWithWeights(boneIndexs, boneWeights, _FrameIndex);

            //混合下一个动画
            if(_Blend)
            {
                //提取下一个动画的第一帧骨骼矩阵
                float4x4 boneMatrixBlend = GetBoneMatrixWithWeights(boneIndexs, boneWeights, _BlendFrameIndex);
                boneMatrix = lerp(boneMatrix, boneMatrixBlend, _BlendProgress);
            }

            //转换坐标的本质流程: 模型空间 -> 世界空间 -> 骨骼空间 -> 世界空间 -> 模型空间
            positionOS = mul(boneMatrix, positionOS);


            // 法线
            #if defined(_INVERSE)
                // float3x3 boneMatrixIT = InverseTransposeMatrix((float3x3)boneMatrix);
                float3x3 boneMatrixIT0 = InverseTransposeMatrix((float3x3)boneMatrix0);
                float3x3 boneMatrixIT1 = InverseTransposeMatrix((float3x3)boneMatrix1);
                float3x3 boneMatrixIT2 = InverseTransposeMatrix((float3x3)boneMatrix2);
                float3x3 boneMatrixIT3 = InverseTransposeMatrix((float3x3)boneMatrix3);
                float3x3 boneMatrixIT = boneMatrixIT0 * boneWeight.x + boneMatrixIT1 * boneWeight.y + boneMatrixIT2 * boneWeight.z + boneMatrixIT3 * boneWeight.w;
                normalOS = mul(boneMatrixIT, normalOS);
            #else
                normalOS = mul(boneMatrix, float4(normalOS, 0));
            #endif

            // 切线
            tangentOS.xyz = mul((float3x3)boneMatrix, tangentOS.xyz);
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

                TransformBoneAnimation(input.boneIndexs, input.boneWeights, input.positionOS, input.normalOS,
                input.tangentOS);

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
                float4 positionOS : POSITION;
                float4 color : COLOR;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv : TEXCOORD0;
                float4 boneIndex : TEXCOORD1;
                float4 boneWeight : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            Varyings ShadowPassVertexBone(AttributesShadow input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);

                TransformBoneAnimation(input.boneIndex, input.boneWeight, input.positionOS, input.normalOS,
                input.tangentOS);

                Attributes input2;
                input2.positionOS = input.positionOS;
                input2.normalOS = input.normalOS;
                input2.texcoord = input.uv;

                output.positionCS = GetShadowPositionHClip(input2);
                return output;
            }

            #pragma vertex ShadowPassVertexBone
            #pragma fragment ShadowPassFragment
            ENDHLSL
        }
    }
}
