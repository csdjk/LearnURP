Shader "LcL/Cloud/ToonCloud"
{
    Properties
    {
        _BaseColor ("Color", Color) = (1, 1, 1, 1)
        _BaseColor2 ("Color2", Color) = (0.5, 0.5, 0.5, 1)
        _Cutoff ("Alpha Cutoff", Float) = 0.5

        _CameraOffset ("Camera Offset", Vector) = (0,1,-1,0)

        _NoiseTex ("Noise", 2D) = "white" { }
        _Seed ("Seed", Range(0,100)) = 0.0
        _Amplitude ("Move Amplitude", Range(0,1)) = 0.2
        _Speed ("Move Speed", Range(0,10)) = 1.0
        _Frequency ("Move Frequency", Range(0,10)) = 1.0

        _ScaleAmplitude ("Scale Amplitude", Range(0,1)) = 0.3
        _ScaleSpeed ("Scale Speed", Range(0,1)) = 0.8
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" "RenderPipeline" = "UniversalPipeline" }

        HLSLINCLUDE
        #pragma target 3.5

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            float4 _BaseColor;
            float4 _BaseColor2;
            float _Cutoff;

            float _Amplitude;
            float _Speed;
            float _Frequency;
            float _Seed;

            float _ScaleAmplitude;
            float _ScaleSpeed;

            float3 _CameraOffset;
        CBUFFER_END
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

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Assets/Shaders/Libraries/Node.hlsl"

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

            // 改为2D噪声纹理
            TEXTURE2D(_NoiseTex);
            SAMPLER(sampler_NoiseTex);

            // 简单 hash -> 0..1
            static float hash1(float n)
            {
                return frac(sin(n) * 43758.5453123);
            }

            Varyings vert(Attributes input)
            {
                Varyings output;

                // 从顶点色 R 通道读取 ID（0..255）
                float id = floor(input.color.r * 255.0 + 0.5);

                // 为每个组生成固定的 baseCoord（二维）
                float baseX = hash1(id * 12.9898 + _Seed);
                float baseY = hash1(id * 78.233 + _Seed + 17.0);
                float2 baseCoord = float2(baseX, baseY); // 在 0..1 内

                // 时间推进，沿噪声纹理移动
                float t = _Time.y * _Speed;
                float2 travel = float2(t * 0.05 * _Frequency, t * 0.06 * _Frequency);

                // 采样位置（在 0..1 空间中循环）
                float2 samplePos = frac(baseCoord + travel);

                // 从 2D 噪声纹理采样（取 R 通道）
                float3 n = SAMPLE_TEXTURE2D_LOD(_NoiseTex, sampler_NoiseTex, samplePos, 0).rgb;

                // 将噪声映射到 -1..1 并乘振幅
                float3 offset = (n - 0.5) * 2.0 * _Amplitude;

                // 添加随机缩放
                // 为缩放生成不同的随机种子和采样坐标
                float scaleBaseX = hash1(id * 54.321 + _Seed + 100.0);
                float scaleBaseY = hash1(id * 19.876 + _Seed + 200.0);
                float2 scaleBaseCoord = float2(scaleBaseX, scaleBaseY);

                // 缩放的时间偏移（可以与位移使用不同的速度）
                float scaleT = _Time.y * _ScaleSpeed;
                float2 scaleTravel = float2(scaleT * 0.03, scaleT * 0.04);
                float2 scaleSamplePos = frac(scaleBaseCoord + scaleTravel);

                // 采样缩放噪声
                float scaleNoise = SAMPLE_TEXTURE2D_LOD(_NoiseTex, sampler_NoiseTex, scaleSamplePos, 0).r;

                // 将缩放噪声映射到合适的范围 (例如 0.7 到 1.3)
                float scale = 1.0 + (scaleNoise - 0.5) * _ScaleAmplitude;

                // 应用缩放和位移
                input.positionOS.xyz = input.positionOS.xyz * scale + offset;

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

                float3 N = normalize(input.normalWS);
                float3 V = GetWorldSpaceViewDir(input.positionWS);

                float NdotV = saturate(dot(N, V));
                NdotV = SmoothValue(0.4,0.01,NdotV);


                float3 offsetView = normalize(V + _CameraOffset.xyz);
                float NdotV2 = saturate(dot(N, offsetView));
                NdotV2 = SmoothValue(0.5,0.1,NdotV2);

                half4 color = lerp(_BaseColor2, _BaseColor, NdotV2) * NdotV;

                return color;
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

            // Material Keywords
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }

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
}
