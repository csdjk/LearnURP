Shader "LcL/VAT/VAT2_RBD"
{
    //VAT 2.0 刚体动画着色器

    Properties
    {
        _BaseMap ("BaseMap", 2D) = "white" { }
        _BaseColor ("Color", Color) = (1, 1, 1, 1)
        _Cutoff ("Alpha Cutoff", Float) = 0.5

        [Foldout(_VAT_RBD)] _VAT_RBD ("VAT-2.0 Rigid Body", int) = 0
        [SingleLine]_PosTex("Pos Texture", 2D) = "black" {}
        [SingleLine]_RotTex("Rot Texture", 2D) = "black" {}
        _PosRange("Pos Range", Vector) = (0,0,0,0)
        _PivRange("Pivot Range", Vector) = (0,0,0,0)
        _TotalFrame("Total Frame", float) = 128

        _CurrentFrame ("Current Frame", Range(0,200)) = 0
        [FoldoutEnd]_Speed("Animation Speed", float) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque" "Queue" = "Geometry" "RenderPipeline" = "UniversalPipeline"
        }

        HLSLINCLUDE
        #pragma target 3.5

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        // 从 VATHelper.hlsl 提取的函数
        // -------------------------------------------------------------------

        // 使用单位四元数旋转向量
        float3 VAT_RotateVector(float3 v, float4 q)
        {
            return v + cross(2 * q.xyz, cross(q.xyz, v) + q.w * v);
        }

        // 坐标系转换 (右手Z-up -> 左手Y-up)
        float3 VAT_ConvertSpace(float3 v)
        {
            return v.xzy * float3(-1, 1, 1);
        }

        // 为给定顶点计算纹理采样点
        int3 VAT_GetSamplePoint(Texture2D map, float2 uv, float current, float total)
        {
            uint t_w, t_h;
            map.GetDimensions(t_w, t_h);

            int frame = clamp(current, 0, total - 1);
            // 假设每一帧的数据在纹理中垂直堆叠
            int stride = t_h / total;

            // 返回整数坐标以供 Load 函数使用
            return int3(uv.x * t_w, uv.y * t_h - frame * stride, 0);
        }
        // -------------------------------------------------------------------

        CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            float4 _BaseColor;
            float _Cutoff;
            float _CurrentFrame;
            float _TotalFrame;
            float _Speed;
            float4 _PosRange;
            float4 _PivRange;
        CBUFFER_END

        TEXTURE2D(_PosTex);
        TEXTURE2D(_RotTex);
        SAMPLER(sampler_PosTex);

        struct Attributes
        {
            float4 positionOS : POSITION;
            float2 uv : TEXCOORD0;
            float4 color : COLOR;
            float4 normalOS : NORMAL;
            float2 uv1 : TEXCOORD1; // uv1.x = vertex id
        };

        // 将顶点动画逻辑提取到一个函数中，以便在多个Pass中复用
        void ApplyVAT(inout float3 positionOS, inout float3 normalOS, float2 uv1, float3 color)
        {
            float animTime = _Time.y * _Speed;
            float currentFrame = fmod(animTime, _TotalFrame);

            int3 samplePoint = VAT_GetSamplePoint(_PosTex, uv1, _CurrentFrame, _TotalFrame);

            float4 p = _PosTex.Load(samplePoint);
            float4 r = _RotTex.Load(samplePoint);

            // 解码位置偏移
            float3 offs = VAT_ConvertSpace(lerp(_PosRange.x, _PosRange.y, p.xyz));

            // 从顶点颜色解码Pivot
            float3 pivot = VAT_ConvertSpace(lerp(_PivRange.x, _PivRange.y, color));

            // 解码旋转四元数
            float4 rot = (r * 2 - 1).xzyw * float4(-1, 1, 1, 1);

            // 计算最终位置和法线
            positionOS = VAT_RotateVector(positionOS - pivot, rot) + pivot + offs;
            normalOS = VAT_RotateVector(normalOS, rot);
        }
        ENDHLSL

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

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

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

            Varyings vert(Attributes input)
            {
                Varyings output;

                float3 positionOS = input.positionOS.xyz;
                float3 normalOS = input.normalOS.xyz;
                ApplyVAT(positionOS, normalOS, input.uv1, input.color.rgb);

                VertexPositionInputs positionInputs = GetVertexPositionInputs(positionOS);
                output.positionCS = positionInputs.positionCS;

                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                output.color = input.color;

                output.positionWS = positionInputs.positionWS;

                VertexNormalInputs normalInputs = GetVertexNormalInputs(normalOS);
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

                return half4(color.rgb , color.a);

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
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

            struct VertexInput
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float4 color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct VertexOutput
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            VertexOutput ShadowPassVertex(VertexInput input)
            {
                VertexOutput output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                float3 positionOS = input.positionOS.xyz;
                float3 normalOS = input.normalOS.xyz;
                ApplyVAT(positionOS, normalOS, input.uv1, input.color.rgb);

                output.positionCS = TransformObjectToHClip(positionOS);
                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                return output;
            }

            half4 ShadowPassFragment(VertexOutput input) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(input);

                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
                half alpha = baseMap.a * _BaseColor.a;
                clip(alpha - _Cutoff);
                return 0;
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

            HLSLPROGRAM
            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

            struct VertexInput
            {
                float4 position : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float4 color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            Varyings DepthOnlyVertex(VertexInput input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                float3 positionOS = input.position.xyz;
                float3 normalOS = float3(0, 0, 1); // 法线在深度通道中不重要
                ApplyVAT(positionOS, normalOS, input.uv1, input.color.rgb);

                output.positionCS = TransformObjectToHClip(positionOS);
                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                return output;
            }

            half4 DepthOnlyFragment(Varyings input) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(input);

                half4 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
                clip(albedo.a - _Cutoff);
                return 0;
            }
            ENDHLSL
        }
    }
    CustomEditor "LcLShaderEditor.LcLShaderGUI"

}
