Shader "LcL/SimpleURP_VAT_RigidBody"
{
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
        [Header(VAT)]
        _PosTex ("Position Texture (RGB)", 2D) = "black" {}
        _RotTex ("Rotation Texture (RGBA)", 2D) = "black" {}
        _AnimLen ("Animation Length (Total Frames)", Float) = 1
        _CurrentFrame ("Current Frame", Range(0,128)) = 0
        _TotalFrames ("Animation Length (Frames)", Float) = 128
        _Speed ("Animation Speed", Float) = 1.0
        _BoundsMin ("Bounds Min (Position)", Vector) = (-1, -1, -1, 0)
        _BoundsMax ("Bounds Max (Position)", Vector) = (1, 1, 1, 0)
        _PivotBoundsMin("Pivot Bounds Min", Float) = 0
        _PivotBoundsMax("Pivot Bounds Max", Float) = 1
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

            // 开启法线贴图的关键字
            #pragma shader_feature_local _NORMALMAP

            // URP Core Includes
            // #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            //================================================================================
            // 属性和CBUFFER
            //================================================================================
            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                half4 _BaseColor;
                half _Cutoff;
                half _Smoothness;
                half _Metallic;

                float _AnimLen;
                float _Speed;
                float _TotalFrames;
                float _CurrentFrame;
                float4 _BoundsMin;
                float4 _BoundsMax;
                float _PivotBoundsMin;
                float _PivotBoundsMax;
            CBUFFER_END

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);
            TEXTURE2D(_PosTex);
            SAMPLER(sampler_PosTex);
            TEXTURE2D(_RotTex);
            SAMPLER(sampler_RotTex);

            //================================================================================
            // 输入/输出结构体
            //================================================================================
            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1; // .x 存储顶点ID, .y 存储 piece ID
                float4 color : COLOR; // .rgb 存储枢轴点(pivot)在包围盒中的归一化位置
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                half3 normalWS : TEXCOORD2;
                half3 tangentWS : TEXCOORD3;
                half3 bitangentWS : TEXCOORD4;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            // Houdini的Z-up右手坐标系 -> Unity的Y-up左手坐标系
            float3 VAT_ConvertSpace(float3 v)
            {
                return v.xzy * float3(-1, 1, 1);
            }

            // 使用单位四元数旋转一个三维向量
            float3 VAT_RotateVector(float3 v, float4 q)
            {
                return v + cross(2 * q.xyz, cross(q.xyz, v) + q.w * v);
            }

            // 球面线性插值函数 - 用于四元数平滑插值
            float4 slerp(float4 q1, float4 q2, float t)
            {
                // 确保四元数已归一化
                q1 = normalize(q1);
                q2 = normalize(q2);

                // 计算点积
                float dot_product = dot(q1, q2);

                // 如果点积为负，翻转一个四元数以确保最短路径插值
                if (dot_product < 0.0)
                {
                    q2 = -q2;
                    dot_product = -dot_product;
                }

                // 如果四元数非常接近，使用线性插值避免数值不稳定
                if (dot_product > 0.9995)
                {
                    return normalize(lerp(q1, q2, t));
                }

                // 计算角度
                float theta_0 = acos(abs(dot_product));
                float theta = theta_0 * t;
                float sin_theta_0 = sin(theta_0);
                float sin_theta = sin(theta);

                // 计算插值系数
                float s0 = cos(theta) - dot_product * sin_theta / sin_theta_0;
                float s1 = sin_theta / sin_theta_0;

                // 执行球面线性插值
                return normalize(s0 * q1 + s1 * q2);
            }

            //================================================================================
            // 核心 VAT 算法
            //================================================================================
            void ApplyVAT(inout float3 positionOS, inout float3 normalOS, inout float4 tangentOS, float2 uv1, float3 color)
            {
                // 1. 计算当前动画帧和插值系数
                // _Time.y * _Speed 得到总的流逝帧数
                // fmod(..., _AnimLen) 实现循环播放
                float totalElapsedFrames = _Time.y * _Speed;
                float currentFrame = floor(fmod(totalElapsedFrames, _AnimLen));
                float nextFrame = floor(fmod(currentFrame + 1.0, _AnimLen));
                float interp = frac(totalElapsedFrames);

                // 2. 计算采样UV
                // uv1.y (piece ID) 决定V方向的偏移，uv1.x (vertex ID) 决定U方向
                // 每一帧的数据在V方向上是连续的
                float v_step = 1.0 / _AnimLen;
                float2 uv_current = float2(uv1.x, (currentFrame + 0.5) * v_step);
                float2 uv_next = float2(uv1.x, (nextFrame + 0.5) * v_step);

                // 3. 采样位置和旋转数据
                float4 posDataCurrent = SAMPLE_TEXTURE2D_LOD(_PosTex, sampler_PosTex, uv_current, 0);
                float4 rotDataCurrent = SAMPLE_TEXTURE2D_LOD(_RotTex, sampler_RotTex, uv_current, 0);

                float4 posDataNext = SAMPLE_TEXTURE2D_LOD(_PosTex, sampler_PosTex, uv_next, 0);
                float4 rotDataNext = SAMPLE_TEXTURE2D_LOD(_RotTex, sampler_RotTex, uv_next, 0);

                // 4. 解码数据

                // 从包围盒范围解码位置偏移
                float3 posOffsetCurrent = lerp(_BoundsMin.xyz, _BoundsMax.xyz, posDataCurrent.xyz);
                float3 posOffsetNext = lerp(_BoundsMin.xyz, _BoundsMax.xyz, posDataNext.xyz);
                float3 posOffset = lerp(posOffsetCurrent, posOffsetNext, interp);
                posOffset = VAT_ConvertSpace(posOffset);

                // 从顶点颜色解码枢轴点(pivot)
                float3 pivot = lerp(_PivotBoundsMin, _PivotBoundsMax, color.rgb);
                pivot = VAT_ConvertSpace(pivot);

                // 解码旋转四元数 (从 0-1 范围映射到 -1-1 范围)
                float4 rotCurrent = rotDataCurrent * 2.0 - 1.0;
                float4 rotNext = rotDataNext * 2.0 - 1.0;
                // 球面线性插值得到平滑的旋转
                float4 rot = slerp(rotCurrent, rotNext, interp);

                // 坐标系转换
                rot = float4(-rot.x, rot.z, rot.y, rot.w);
                rot = normalize(rot);

                // 5. 应用变换


                positionOS = VAT_RotateVector(positionOS - pivot, rot) + pivot + posOffset;
                normalOS = VAT_RotateVector(normalOS, rot);
                tangentOS.xyz = VAT_RotateVector(tangentOS.xyz, rot);
            }

            //================================================================================
            // 顶点着色器
            //================================================================================
            Varyings LitPassVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float3 positionOS = input.positionOS.xyz;
                float3 normalOS = input.normalOS;
                float4 tangentOS = input.tangentOS;

                // 应用VAT变换
                ApplyVAT(positionOS, normalOS, tangentOS, input.uv1, input.color.rgb);

                // 计算世界空间位置和法线
                VertexPositionInputs positionInputs = GetVertexPositionInputs(positionOS);
                VertexNormalInputs normalInputs = GetVertexNormalInputs(normalOS, tangentOS);

                output.positionWS = positionInputs.positionWS;
                output.positionCS = positionInputs.positionCS;
                output.normalWS = normalInputs.normalWS;
                output.tangentWS = normalInputs.tangentWS;
                output.bitangentWS = normalInputs.bitangentWS;
                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                output.color = input.color;

                return output;
            }

            //================================================================================
            // 片元着色器
            //================================================================================
            half4 LitPassFragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                //
                // // 基础纹理和颜色
                // half4 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv) * _BaseColor;
                // clip(albedo.a - _Cutoff);
                //
                // // 法线贴图
                // #if defined(_NORMALMAP)
                // half3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, input.uv));
                // input.normalWS = TransformTangentToWorld(normalTS, half3x3(input.tangentWS, input.bitangentWS, input.normalWS));
                // #endif
                // input.normalWS = normalize(input.normalWS);
                //
                // // 构建表面数据
                // SurfaceData surfaceData;
                // ZERO_INITIALIZE(SurfaceData, surfaceData);
                // surfaceData.albedo = albedo.rgb;
                // surfaceData.metallic = _Metallic;
                // surfaceData.smoothness = _Smoothness;
                // surfaceData.normalTS = float3(0, 0, 1); // 使用世界空间法线，所以切线空间法线是默认值
                // surfaceData.emission = 0;
                // surfaceData.occlusion = 1;
                // surfaceData.alpha = albedo.a;
                //
                // // 构建光照输入
                // InputData inputData;
                // inputData.positionWS = input.positionWS;
                // inputData.normalWS = input.normalWS;
                // inputData.viewDirectionWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
                // inputData.shadowCoord = GetShadowCoord(GetVertexPositionInputs(input.positionWS));
                //
                // // URP光照计算
                // half4 color = UniversalFragmentPBR(inputData, surfaceData);
                // color.rgb = MixFog(color.rgb, inputData.fogCoord);

                return input.color;
            }
            ENDHLSL
        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
}
