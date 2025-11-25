Shader "LcL/VAT/VAT3_RBD"
{
    //VAT 3.0 刚体动画着色器
    Properties
    {
        // --- 基础渲染属性 ---
        [Header(Base Properties)]
        _BaseMap ("Base Map (Albedo)", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _Cutoff ("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
        [Toggle(_NORMALMAP)] _UseNormalMap("Enable Normal Map", Float) = 0
        _NormalMap("Normal Map", 2D) = "bump" {}
        _Smoothness("Smoothness", Range(0.0, 1.0)) = 0.5
        _Metallic("Metallic", Range(0.0, 1.0)) = 0.0

        // --- VAT 刚体动画属性 ---
        [Foldout(_VAT_RBD)] _VAT_RBD ("VAT Rigid Body", int) = 0
        [Toggle] _UseColorPovit ("UseColorPovit", Float) = 0
        [Toggle] _EnableAutoPlay ("Enable Auto Play", Float) = 1
        [SingleLine]_PosTex ("Position Texture (RGB)", 2D) = "black" {}
        [SingleLine]_RotTex ("Rotation Texture (RGBA)", 2D) = "black" {}
        [ShowIf(_EnableAutoPlay,0)]_CurrentFrame ("Current Frame", Range(0,128)) = 0
        _TotalFrames ("Total Frames", Float) = 128
        _FPS ("FPS", Float) = 24
        [ShowIf(_UseColorPovit)]_PivotRange ("Pivot Range", Vector) = (0, 0, 0, 0)
        [FoldoutEnd]_PlaySpeed ("Play Speed", Float) = 1.0
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque" "Queue"="Geometry" "RenderPipeline"="UniversalPipeline"
        }

        Pass
        {
            Name "ForwardLit"
            Tags
            {
                "LightMode"="UniversalForward"
            }

            HLSLPROGRAM
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment
            #pragma enable_d3d11_debug_symbols

            #pragma shader_feature_local _NORMALMAP

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                half4 _BaseColor;
                half _Cutoff;
                half _Smoothness;
                half _Metallic;

                float _TotalFrames;
                float _FPS;
                float _PlaySpeed;
                float _CurrentFrame;
                float _EnableAutoPlay;
                float _UseColorPovit;
                float2 _PivotRange;
            CBUFFER_END

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);
            TEXTURE2D(_PosTex);
            SAMPLER(sampler_PosTex);
            TEXTURE2D(_RotTex);
            SAMPLER(sampler_RotTex);
            SAMPLER(sampler_PivotTex);

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1; // VAT采样UV
                float2 uv2 : TEXCOORD2; // 存储piece pivot x,z
                float2 uv3 : TEXCOORD3; // 存储piece pivot y
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                half3 normalWS : TEXCOORD2;
                #ifdef _NORMALMAP
                half3 tangentWS : TEXCOORD3;
                half3 bitangentWS : TEXCOORD4;
                #endif
                //debug
                float2 uv1 : TEXCOORD5;
                float4 color : COLOR;
                float4 positionOS:TEXCOORD6;


                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            // 计算VAT采样UV
            float2 CalculateVATUV(float2 baseUV)
            {
                // 按照原始算法计算帧数和UV偏移
                float fps_divide_fc_01 = frac(_FPS / (_TotalFrames - 0.01) * _Time.y * _PlaySpeed);
                float auto_frame = floor(fps_divide_fc_01 * _TotalFrames) + 1;
                float manual_frame = floor(_CurrentFrame);
                float current_frame = lerp(manual_frame, auto_frame, _EnableAutoPlay);
                float texcoord_y = fmod(current_frame - 1, _TotalFrames) * (1.0 / _TotalFrames);

                float2 UV_VAT = baseUV;
                UV_VAT.y -= texcoord_y;
                return UV_VAT;
            }

            // Houdini四元数解码 (使用压缩编码)
            float4 DecodeHoudiniQuaternion(float4 rotOffset, float maxComponent)
            {
                float w = sqrt(1.0 - pow(rotOffset.x, 2) - pow(rotOffset.y, 2) - pow(rotOffset.z, 2));
                float MaxComponent = floor(maxComponent * 4);

                float4 quat_de = (MaxComponent == 0) * float4(rotOffset.xyz, w)
                    + (MaxComponent == 1) * float4(w, rotOffset.yzx)
                    + (MaxComponent == 2) * float4(rotOffset.x, -w, rotOffset.z, -rotOffset.y)
                    + (MaxComponent == 3) * float4(rotOffset.xy, -w, -rotOffset.z)
                    + (MaxComponent == 4) * float4(rotOffset.xyz, w);

                return normalize(quat_de);
            }

            // 四元数旋转向量
            float3 RotateWithQuaternion(float3 v, float4 q)
            {
                return v + 2.0 * cross(q.xyz, cross(q.xyz, v) + v * q.w);
            }

            // 主VAT变换函数
            void ApplyVATTransform(inout float3 positionOS, inout float3 normalOS, inout float4 tangentOS, Attributes input)
            {
                // 1. 计算VAT采样UV
                float2 UV_VAT = CalculateVATUV(input.uv1);

                // // 2. 采样位置和旋转纹理
                float4 posOffset = SAMPLE_TEXTURE2D_LOD(_PosTex, sampler_PosTex, UV_VAT, 0);
                float4 rotOffset = SAMPLE_TEXTURE2D_LOD(_RotTex, sampler_RotTex, UV_VAT, 0);
                //
                // 3. 解码Houdini四元数
                float4 quat_de = DecodeHoudiniQuaternion(rotOffset, posOffset.w);

                float3 piecePivot = 0;

                if (_UseColorPovit == 1.0)
                {
                    // 4. 从顶点色还原piece pivot位置
                    // float3 pivot = input.color.xyz * (_PivotRange.y - _PivotRange.x) + _PivotRange.x;
                    float3 pivot = lerp(_PivotRange.x, _PivotRange.y, input.color.xyz);
                    piecePivot = float3(-pivot.z, pivot.x, 1.0 - pivot.y);
                }
                else
                {
                    // 4. 从UV2,UV3还原piece pivot位置
                    piecePivot = float3(-input.uv2.x, input.uv3.x, 1.0 - input.uv3.y);

                }

                // // 5. 计算相对于pivot的向量
                float3 pivotVec = positionOS - piecePivot;
                //
                // 6. 应用变换：位置偏移 + 绕pivot旋转
                positionOS = posOffset.xyz + RotateWithQuaternion(pivotVec, quat_de);

                // 7. 旋转法线和切线
                normalOS = normalize(RotateWithQuaternion(normalOS, quat_de));
                tangentOS.xyz = normalize(RotateWithQuaternion(tangentOS.xyz, quat_de));
            }

            Varyings LitPassVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                // 应用VAT变换
                float3 positionOS = input.positionOS.xyz;
                float3 normalOS = input.normalOS;
                float4 tangentOS = input.tangentOS;

                ApplyVATTransform(positionOS, normalOS, tangentOS, input);

                // 计算世界空间变换
                VertexPositionInputs positionInputs = GetVertexPositionInputs(positionOS);
                VertexNormalInputs normalInputs = GetVertexNormalInputs(normalOS, tangentOS);

                output.positionCS = positionInputs.positionCS;
                output.positionWS = positionInputs.positionWS;
                output.normalWS = normalInputs.normalWS;
                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                output.uv1 = input.uv1;
                output.color = input.color;
                output.positionOS = input.positionOS;

                #ifdef _NORMALMAP
                output.tangentWS = normalInputs.tangentWS;
                output.bitangentWS = normalInputs.bitangentWS;
                #endif

                return output;
            }

            half4 LitPassFragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                // 基础颜色采样
                half4 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv) * _BaseColor;

                float3 debug = input.uv1.x;
                return float4(debug,1);
            }
            ENDHLSL
        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "LcLShaderEditor.LcLShaderGUI"
}
