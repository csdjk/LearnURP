Shader "LcL/ToonSky"
{
    Properties
    {
        [Foldout()]_Cloud ("Cloud", float) = 0
        _Cloud01Color ("Cloud01 Color", Color) = (1.00, 1.00, 1.00, 1.00)
        [NoScaleOffset]_Cloud01Tex ("Cloud01Tex", 2D) = "white" { }
        _CloudTex01UV1Coord ("CloudTex01 UV1 Coord", Vector) = (8.00, 5.00, -1.55, -1.32)
        _CloudTex01UV2Coord ("CloudTex01 UV2 Coord", Vector) = (8.00, 5.00, 0.00, 0.00)

        _Cloud02Color ("Cloud02 Color", Color) = (1.00, 1.00, 1.00, 1.00)
        [NoScaleOffset] _Cloud02Tex ("Cloud02Tex", 2D) = "white" { }
        _CloudTex02UV1Coord ("CloudTex02 UV1 Coord", Vector) = (4.00, 3.00, -0.31, 0.97)
        _CloudTex02UV2Coord ("CloudTex02 UV2 Coord", Vector) = (2.00, 2.00, 0.00, 0.00)
        _Cloud02Multipler ("Cloud02 Multipler", Range(0, 10)) = 2.97
        _Cloud02Offset ("Cloud02 Offset", Range(0, 1)) = 0.05

        _AllCloudsAlpha ("All Clouds Alpha", Range(0, 1)) = 1.00
        _CloudMultiplyer ("Cloud Multiplyer", Range(0, 10)) = 2.35
        [FoldoutEnd] _CloudOffset ("Cloud Offset", Range(0, 1)) = 0.05

        [Foldout()]_ColorPaletteFoldout ("Color Palette Foldout", float) = 1
        _ColorPalette ("ColorPalette", 2D) = "white" { }
        // _ColorPalette_ST ("Color Palette ST", Vector) = (10.00, 10.00, 0.00, 0.00)
        _ColorPalletteSpeed ("Color Pallette Speed", Range(0, 10)) = 2.29
        [FoldoutEnd]_Desaturate ("Desaturate", Range(0, 1)) = 1.00

        [Foldout()]_TintColor ("Tint Color", float) = 1
        [NoScaleOffset] _TintColorTex ("TintColorTex", 2D) = "white" { }
        _TintColorTexScale ("Tint Color Tex Scale", Range(0, 1)) = 0.662
        _TintColorTexUV1Coord ("Tint Color Tex UV1 Coord", Vector) = (2.00, 2.00, 1.77, -0.02)
        [FoldoutEnd]_TintColorTexUV2Coord ("Tint Color Tex UV2 Coord", Vector) = (1.00, 1.00, 0.00, 0.00)


        [Foldout()]_StarFoldout ("Star", float) = 1
        [NoScaleOffset]_StarTex ("StarTex", 2D) = "white" { }
        _StarTexUV1Coord ("Star Tex UV1 Coord", Vector) = (50.00, 30.00, 0.00, 0.00)
        _StarTexUV2Coord ("Star Tex UV2 Coord", Vector) = (50.00, 30.00, 0.00, 0.00)
        _StarBrightness1 ("Star Brightness 1", Range(0, 10)) = 1.21
        _StarBrightness2 ("Star Brightness 2", Range(0, 10)) = 4.49
        _StarDepth ("Star Depth", Range(0, 100)) = 15.00
        _StarNoiseTiling ("Star Noise Tiling", Vector) = (20.00, 20.00, 0.00, 0.00)
        [FoldoutEnd]_StarScintillationSpeed ("Star Scintillation Speed", Range(0, 1)) = 0.10

        [Foldout()]_FlowFoldout ("Flow", float) = 1
        [NoScaleOffset]_FlowTex ("FlowTex", 2D) = "white" { }
        _FlowSpeed ("Flow Speed", Range(0, 1)) = 0.025
        [FoldoutEnd]_FlowStrength ("Flow Strength", Range(0, 1)) = 0.10


        [Foldout()]_ParticleFoldout ("Particle", float) = 1
        _ES_EP_EffectParticle ("ES EP Effect Particle", Range(0, 1)) = 0.00
        _ES_EP_EffectParticleBottom ("ES EP Effect Particle Bottom", Range(0, 1)) = 0.00
        _ES_EP_EffectParticleTop ("ES EP Effect Particle Top", Range(0, 10)) = 10.00
        [FoldoutEnd]_ES_EffectIntensityScale ("ES Effect Intensity Scale", Range(0, 10)) = 1.00

        _GradientOffset ("Gradient Offset", Range(-10, 10)) = -5.43
        _GradientRange ("Gradient Range", Range(0, 10)) = 7.56

        [Foldout()]_NoiseFoldout ("Noise", float) = 1
        _PerlinNoisePosOffset ("Perlin Noise Pos Offset", Vector) = (216.52, 10.63, 10.00)
        _NoiseSpeed ("Noise Speed", Range(0, 1)) = 0.00
        _PerlinNoiseMultiply ("Perlin Noise Multiply", Range(0, 10)) = 1.79
        _PerlinNoiseOffset ("Perlin Noise Offset", Range(0, 1)) = 0.00
        [FoldoutEnd]_PerlinNoiseScale ("Perlin Noise Scale", Range(-0.1, 0.1)) = -0.005


        _GlobalOneMinusAvatarIntensity ("Global One Minus Avatar Intensity", Range(0, 1)) = 0.00
        _GlobalOneMinusAvatarIntensityEnable ("Global One Minus Avatar Intensity Enable", Range(0, 1)) = 0.00
        _OneMinusGlobalMainIntensity ("One Minus Global Main Intensity", Range(0, 1)) = 0.00
        _OneMinusGlobalMainIntensityEnable ("One Minus Global Main Intensity Enable", Range(0, 1)) = 0.00

        _OffsetFactor ("Offset Factor", Range(-50, 50)) = 0.0
        _OffsetUnits ("Offset Units", Range(-50, 50)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType" = "Background" "RenderPipeline" = "UniversalPipeline" "Queue"="Background" }

        Offset [_OffsetFactor], [_OffsetUnits]

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        CBUFFER_START(UnityPerMaterial)
            // float4 _Time;
            float _OneMinusGlobalMainIntensity;
            float _ES_EP_EffectParticleTop;
            float _ES_EP_EffectParticleBottom;
            float _ES_EP_EffectParticle;
            float _ES_EffectIntensityScale;
            float _GlobalOneMinusAvatarIntensity;
            float _GlobalOneMinusAvatarIntensityEnable;
            float _OneMinusGlobalMainIntensityEnable;
            float4 _Cloud01Color;
            float4 _CloudTex01UV1Coord;
            float4 _CloudTex01UV2Coord;
            float _GradientRange;
            float _GradientOffset;
            float _CloudOffset;
            float _CloudMultiplyer;
            float4 _Cloud02Color;
            float4 _CloudTex02UV1Coord;
            float4 _CloudTex02UV2Coord;
            float _Cloud02Offset;
            float _Cloud02Multipler;
            float4 _ColorPalette_ST;
            float _ColorPalletteSpeed;
            float _AllCloudsAlpha;
            float _PerlinNoiseScale;
            float _PerlinNoiseOffset;
            float _PerlinNoiseMultiply;
            float3 _PerlinNoisePosOffset;
            float _Desaturate;
            float _NoiseSpeed;
            float4 _TintColorTexUV2Coord;
            float4 _TintColorTexUV1Coord;
            float _TintColorTexScale;
            float4 _StarTexUV1Coord;
            float _StarDepth;
            float4 _StarTexUV2Coord;
            float4 _StarNoiseTiling;
            float _StarScintillationSpeed;
            float _StarBrightness1;
            float _StarBrightness2;
            float _FlowSpeed;
            float _FlowStrength;
        CBUFFER_END
        ENDHLSL

        Pass
        {
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float4 color : COLOR;
                float4 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 uv : TEXCOORD0;
                float4 uv1 : TEXCOORD1;
                float4 uv2 : TEXCOORD2;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float4 color : COLOR;
                float4 uv : TEXCOORD0;
                float4 uv1 : TEXCOORD1;
                float4 uv2 : TEXCOORD2;
                float3 tangentWS : TEXCOORD3;
                float3 positionWS : TEXCOORD4;
                float3 normalWS : TEXCOORD5;
            };

            TEXTURE2D(_Cloud01Tex);
            SAMPLER(sampler_Cloud01Tex);
            TEXTURE2D(_Cloud02Tex);
            SAMPLER(sampler_Cloud02Tex);
            TEXTURE2D(_ColorPalette);
            SAMPLER(sampler_ColorPalette);
            TEXTURE2D(_TintColorTex);
            SAMPLER(sampler_TintColorTex);
            TEXTURE2D(_StarTex);
            SAMPLER(sampler_StarTex);
            TEXTURE2D(_FlowTex);
            SAMPLER(sampler_FlowTex);

            Varyings vert(Attributes input)
            {
                Varyings output;

                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = positionInputs.positionCS;

                output.uv = input.uv;
                output.uv1 = input.uv1;
                output.uv2 = input.uv2;
                output.color = input.color;

                float3 viewDirWS = normalize(GetWorldSpaceViewDir(positionInputs.positionWS));

                output.positionWS = positionInputs.positionWS;
                VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS.xyz, input.tangentOS);
                float3 normalWS = normalize(normalInputs.normalWS);
                float3 tangentWS = normalize(normalInputs.tangentWS);

                float3 u_xlat0 = normalWS;
                float3 u_xlat1 = tangentWS;
                float4 u_xlat2 = 0;
                float4 u_xlat3 = 0;
                float u_xlat18;
                float3 u_xlat4 = viewDirWS;

                (u_xlat2.xyz = (u_xlat0.zxy * u_xlat1.yxz));
                (u_xlat2.xyz = ((u_xlat0.yzx * u_xlat1.xzy) + (-u_xlat2.xyz)));
                (u_xlat18 = (input.tangentOS.w * unity_WorldTransformParams.w));
                (u_xlat2.xyz = (u_xlat18 * u_xlat2.yxz));
                (u_xlat3.y = u_xlat2.x);
                (u_xlat3.z = u_xlat0.y);



                (u_xlat3.x = u_xlat1.y);
                (u_xlat3.xyz = (u_xlat3.xyz * u_xlat4.yyy));

                (u_xlat1.y = u_xlat2.z);
                (u_xlat2.z = u_xlat0.x);
                (u_xlat2.x = u_xlat1.z);
                (u_xlat2.xyz = ((u_xlat2.xyz * u_xlat4.xxx) + u_xlat3.xyz));
                (u_xlat1.z = u_xlat0.z);

                output.tangentWS = ((u_xlat1.xyz * u_xlat4.zzz) + u_xlat2.xyz);

                output.normalWS = normalWS;
                return output;
            }


            float PerlinNoise(float3 positionWS, float3 normalWS)
            {
                float4 u_xlat0, u_xlat1, u_xlat2, u_xlat3, u_xlat4, u_xlat5;
                float4 u_xlat7, u_xlat8, u_xlat9, u_xlat14, u_xlat15;

                u_xlat0 = positionWS.xyzx + _PerlinNoisePosOffset.xyzx;
                u_xlat1 = u_xlat0 * _PerlinNoiseScale;
                u_xlat1 = floor(u_xlat1);
                u_xlat2 = u_xlat1.zwzw + float4(0.0, 1.0, 1.0, 1.0);
                u_xlat2.z = dot(u_xlat2.zw, float2(127.1, 311.70001));
                u_xlat2.x = dot(u_xlat2.xy, float2(127.1, 311.70001));
                u_xlat2.xy = sin(u_xlat2.xz);
                u_xlat2.xy = u_xlat2.xy * float2(43758.547, 43758.547);
                u_xlat2.xy = frac(u_xlat2.xy);

                u_xlat2.x = u_xlat2.x * 2.0 + - 1.0;
                u_xlat9.x = u_xlat2.y * 2.0 + - 1.0;

                u_xlat3 = u_xlat0 * _PerlinNoiseScale - u_xlat1;
                u_xlat4 = u_xlat3.zwzw + float4(-0.0, -1.0, -1.0, -1.0);
                u_xlat0.x = dot(u_xlat9.xx, u_xlat4.zw);
                u_xlat14.x = dot(u_xlat2.xx, u_xlat4.xy);
                u_xlat0.x = -u_xlat14.x + u_xlat0.x;
                u_xlat2 = u_xlat3 * u_xlat3;
                u_xlat4 = -u_xlat3 * float4(2.0, 2.0, 2.0, 2.0) + float4(3.0, 3.0, 3.0, 3.0);
                u_xlat2 = u_xlat2 * u_xlat4;
                u_xlat0.x = u_xlat2.z * u_xlat0.x + u_xlat14.x;
                u_xlat4 = u_xlat1 + float4(1.0, 1.0, 1.0, 0.0);

                u_xlat14.x = dot(u_xlat4.zw, float2(127.1, 311.70001));
                u_xlat4.x = dot(u_xlat4.xy, float2(127.1, 311.70001));
                u_xlat4.x = sin(u_xlat4.x);
                u_xlat4.x = u_xlat4.x * 43758.547;
                u_xlat4.x = frac(u_xlat4.x);
                u_xlat4.x = u_xlat4.x * 2.0 + - 1.0;

                u_xlat14.x = sin(u_xlat14.x);
                u_xlat14.x = u_xlat14.x * 43758.547;
                u_xlat14.x = frac(u_xlat14.x);
                u_xlat14.x = u_xlat14.x * 2.0 + - 1.0;

                u_xlat5 = u_xlat3 + float4(-1.0, -1.0, -1.0, -0.0);
                u_xlat14.x = dot(u_xlat14.xx, u_xlat5.zw);
                u_xlat4.x = dot(u_xlat4.xx, u_xlat5.xy);
                u_xlat15.x = dot(u_xlat1.zw, float2(127.1, 311.70001));
                u_xlat15.x = sin(u_xlat15.x);
                u_xlat15.x = u_xlat15.x * 43758.547;
                u_xlat15.x = frac(u_xlat15.x);
                u_xlat15.x = u_xlat15.x * 2.0 + - 1.0;
                u_xlat15.x = dot(u_xlat15.xx, u_xlat3.zw);
                u_xlat14.x = u_xlat14.x + - u_xlat15.x;
                u_xlat14.x = u_xlat2.z * u_xlat14.x + u_xlat15.x;
                u_xlat0.x = -u_xlat14.x + u_xlat0.x;
                u_xlat0.x = u_xlat2.w * u_xlat0.x + u_xlat14.x;

                u_xlat0.x = u_xlat0.x * abs(normalWS.y);
                u_xlat14.x = dot(u_xlat1.xy, float2(127.1, 311.70001));
                u_xlat1 = u_xlat1.xyxy + float4(1.0, 0.0, 0.0, 1.0);
                u_xlat14.x = sin(u_xlat14.x);
                u_xlat14.x = u_xlat14.x * 43758.547;
                u_xlat14.x = frac(u_xlat14.x);
                u_xlat14.x = u_xlat14.x * 2.0 + - 1.0;
                u_xlat14.x = dot(u_xlat14.xx, u_xlat3.xy);
                u_xlat3 = u_xlat3.xyxy + float4(-1.0, -0.0, -0.0, -1.0);
                u_xlat1.x = dot(u_xlat1.xy, float2(127.1, 311.70001));
                u_xlat1.y = dot(u_xlat1.zw, float2(127.1, 311.70001));
                u_xlat1.xy = sin(u_xlat1.xy);
                u_xlat1.xy = u_xlat1.xy * float2(43758.547, 43758.547);
                u_xlat1.xy = frac(u_xlat1.xy);
                u_xlat8.x = u_xlat1.y * 2.0 + - 1.0;
                u_xlat8.x = dot(u_xlat8.xx, u_xlat3.zw);
                u_xlat1.x = u_xlat1.x * 2.0 + - 1.0;
                u_xlat1.x = dot(u_xlat1.xx, u_xlat3.xy);
                u_xlat1.x = -u_xlat14.x + u_xlat1.x;
                u_xlat14.x = u_xlat2.x * u_xlat1.x + u_xlat14.x;
                u_xlat1.x = -u_xlat8.x + u_xlat4.x;
                u_xlat1.x = u_xlat2.x * u_xlat1.x + u_xlat8.x;
                u_xlat1.x = -u_xlat14.x + u_xlat1.x;
                u_xlat14.x = u_xlat2.y * u_xlat1.x + u_xlat14.x;
                u_xlat0.x = u_xlat14.x * abs(normalWS.z) + u_xlat0.x;
                u_xlat1.xy = u_xlat0.yw * _PerlinNoiseScale;
                u_xlat1.xy = floor(u_xlat1.xy);
                u_xlat15.xy = u_xlat1.xy + float2(1.0, 1.0);
                u_xlat14.x = dot(u_xlat15.xy, float2(127.1, 311.70001));
                u_xlat14.x = sin(u_xlat14.x);
                u_xlat14.x = u_xlat14.x * 43758.547;
                u_xlat14.x = frac(u_xlat14.x);
                u_xlat14.x = u_xlat14.x * 2.0 + - 1.0;
                u_xlat7.xz = u_xlat0.yw * _PerlinNoiseScale - u_xlat1.xy;
                u_xlat15.xy = u_xlat7.xz + float2(-1.0, -1.0);
                u_xlat14.x = dot(u_xlat14.xx, u_xlat15.xy);
                u_xlat2 = u_xlat1.xyxy + float4(1.0, 0.0, 0.0, 1.0);
                u_xlat1.x = dot(u_xlat1.xy, float2(127.1, 311.70001));
                u_xlat1.x = sin(u_xlat1.x);
                u_xlat1.x = u_xlat1.x * 43758.547;
                u_xlat1.x = frac(u_xlat1.x);
                u_xlat1.x = u_xlat1.x * 2.0 + - 1.0;
                u_xlat1.x = dot(u_xlat1.xx, u_xlat7.xz);
                u_xlat8.x = dot(u_xlat2.zw, float2(127.1, 311.70001));
                u_xlat8.y = dot(u_xlat2.xy, float2(127.1, 311.70001));
                u_xlat8.xy = sin(u_xlat8.xy);
                u_xlat8.xy = u_xlat8.xy * float2(43758.547, 43758.547);
                u_xlat8.xy = frac(u_xlat8.xy);
                u_xlat15.x = u_xlat8.y * 2.0 + - 1.0;
                u_xlat8.x = u_xlat8.x * 2.0 + - 1.0;
                u_xlat2 = u_xlat7.xzxz + float4(-1.0, -0.0, -0.0, -1.0);
                u_xlat8.x = dot(u_xlat8.xx, u_xlat2.zw);
                u_xlat15.x = dot(u_xlat15.xx, u_xlat2.xy);
                u_xlat15.x = -u_xlat1.x + u_xlat15.x;
                u_xlat14.x = u_xlat14.x + - u_xlat8.x;
                u_xlat2.xy = u_xlat7.xz * u_xlat7.xz;
                u_xlat7.xz = -u_xlat7.xz * float2(2.0, 2.0) + float2(3.0, 3.0);
                u_xlat7.xz = u_xlat7.xz * u_xlat2.xy;
                u_xlat14.x = u_xlat7.x * u_xlat14.x + u_xlat8.x;
                u_xlat7.x = u_xlat7.x * u_xlat15.x + u_xlat1.x;
                u_xlat14.x = -u_xlat7.x + u_xlat14.x;
                u_xlat7.x = u_xlat7.z * u_xlat14.x + u_xlat7.x;
                u_xlat0.x = u_xlat7.x * abs(normalWS.x) + u_xlat0.x;
                u_xlat0.x = u_xlat0.x * _PerlinNoiseMultiply;
                u_xlat0.x = u_xlat0.x * 0.5 + _PerlinNoiseOffset;
                u_xlat0.x = u_xlat0.x + 0.5;
                u_xlat0.x = clamp(u_xlat0.x, 0.0, 1.0);

                return u_xlat0.x;
            }


            half4 frag(Varyings input) : SV_Target
            {
                float perlinNoise = PerlinNoise(input.positionWS, input.normalWS);
                float4 color = 0;
                float4 vs_TEXCOORD0 = input.uv;
                float4 vs_TEXCOORD1 = input.uv1;
                float4 vs_TEXCOORD2 = input.uv2;
                float3 vs_TEXCOORD4 = input.tangentWS;
                float3 vs_TEXCOORD6 = input.normalWS;
                float3 vs_TEXCOORD7 = input.positionWS;

                float4 u_xlat0 = input.positionWS.xyzx + _PerlinNoisePosOffset.xyzx;
                u_xlat0.x = perlinNoise;

                float4 u_xlat1, u_xlat2, u_xlat3, u_xlat7, u_xlat9, u_xlat14, u_xlat15, u_xlat16_1, u_xlat16_6,
                u_xlat16_9, u_xlat16_13, u_xlat16_14, u_xlat16_15, u_xlat16_21
                , u_xlat21;
                float u_xlat16_7, u_xlat22;
                float u_xlat16_27;

                u_xlat7.x = _Time.y * _FlowSpeed + 0.5;
                u_xlat7.x = frac(u_xlat7.x);
                u_xlat7.x = u_xlat7.x * _FlowStrength;

                u_xlat14.xy = vs_TEXCOORD1.xy * _CloudTex02UV2Coord.xy + _CloudTex02UV2Coord.zw;
                u_xlat16_1.xy = SAMPLE_TEXTURE2D(_FlowTex, sampler_FlowTex, u_xlat14.xy).xy;
                u_xlat1.xy = u_xlat16_1.xy * float2(2.0, 2.0) + float2(-1.0, -1.0);
                u_xlat15.xy = u_xlat1.xy * u_xlat7.xx + u_xlat14.xy;
                u_xlat16_15 = SAMPLE_TEXTURE2D(_Cloud02Tex, sampler_Cloud02Tex, u_xlat15.xy).x;

                u_xlat22 = _Time.y * _FlowSpeed;
                u_xlat22 = frac(u_xlat22);
                u_xlat2.x = u_xlat22 * _FlowStrength;
                u_xlat22 = u_xlat22 * 2.0 + - 1.0;
                u_xlat14.xy = u_xlat1.xy * u_xlat2.xx + u_xlat14.xy;
                u_xlat16_14 = SAMPLE_TEXTURE2D(_Cloud02Tex, sampler_Cloud02Tex, u_xlat14.xy).x;
                u_xlat21 = -u_xlat16_14 + u_xlat16_15;
                u_xlat14.x = abs(u_xlat22) * u_xlat21 + u_xlat16_14;
                u_xlat1.xy = vs_TEXCOORD0.xy * _CloudTex02UV1Coord.xy + _CloudTex02UV1Coord.zw;
                u_xlat16_9.xy = SAMPLE_TEXTURE2D(_FlowTex, sampler_FlowTex, u_xlat1.xy).xy;
                u_xlat9.xy = u_xlat16_9.xy * float2(2.0, 2.0) + float2(-1.0, -1.0);
                u_xlat3.xy = u_xlat9.xy * u_xlat7.xx + u_xlat1.xy;
                u_xlat1.xy = u_xlat9.xy * u_xlat2.xx + u_xlat1.xy;
                u_xlat16_21 = SAMPLE_TEXTURE2D(_Cloud02Tex, sampler_Cloud02Tex, u_xlat1.xy).x;
                u_xlat16_1.x = SAMPLE_TEXTURE2D(_Cloud02Tex, sampler_Cloud02Tex, u_xlat3.xy).x;
                u_xlat1.x = -u_xlat16_21 + u_xlat16_1.x;
                u_xlat21 = abs(u_xlat22) * u_xlat1.x + u_xlat16_21;
                u_xlat16_6.x = -u_xlat21 + u_xlat14.x;
                u_xlat14.x = _GradientOffset +_GradientRange;
                u_xlat14.x = vs_TEXCOORD0.y * - _GradientRange + u_xlat14.x;
                u_xlat14.x = clamp(u_xlat14.x, 0.0, 1.0);
                u_xlat1.x = vs_TEXCOORD0.y * _GradientRange + _GradientOffset;
                u_xlat1.x = clamp(u_xlat1.x, 0.0, 1.0);
                u_xlat16_13.x = u_xlat14.x + - u_xlat1.x;
                u_xlat16_13.x = u_xlat14.x * u_xlat16_13.x + u_xlat1.x;
                u_xlat16_6.x = u_xlat16_13.x * u_xlat16_6.x + u_xlat21;
                u_xlat14.x = u_xlat16_6.x + _Cloud02Offset;
                u_xlat14.x = u_xlat14.x * _Cloud02Multipler;
                u_xlat14.x = max(u_xlat14.x, 0.0);
                u_xlat14.x = min(u_xlat14.x, 2.0);
                u_xlat1.xy = vs_TEXCOORD1.xy * _CloudTex01UV2Coord.xy + _CloudTex01UV2Coord.zw;
                u_xlat16_9.xy = SAMPLE_TEXTURE2D(_FlowTex, sampler_FlowTex, u_xlat1.xy).xy;
                u_xlat9.xy = u_xlat16_9.xy * float2(2.0, 2.0) + float2(-1.0, -1.0);
                u_xlat3.xy = u_xlat9.xy * u_xlat7.xx + u_xlat1.xy;
                u_xlat1.xy = u_xlat9.xy * u_xlat2.xx + u_xlat1.xy;
                u_xlat16_21 = SAMPLE_TEXTURE2D(_Cloud01Tex, sampler_Cloud01Tex, u_xlat1.xy).x;
                u_xlat16_1.x = SAMPLE_TEXTURE2D(_Cloud01Tex, sampler_Cloud01Tex, u_xlat3.xy).x;
                u_xlat1.x = -u_xlat16_21 + u_xlat16_1.x;
                u_xlat21 = abs(u_xlat22) * u_xlat1.x + u_xlat16_21;
                u_xlat1.xy = vs_TEXCOORD0.xy * _CloudTex01UV1Coord.xy + _CloudTex01UV1Coord.zw;
                u_xlat16_9.xy = SAMPLE_TEXTURE2D(_FlowTex, sampler_FlowTex, u_xlat1.xy).xy;
                u_xlat9.xy = u_xlat16_9.xy * float2(2.0, 2.0) + float2(-1.0, -1.0);
                u_xlat3.xy = u_xlat9.xy * u_xlat7.xx + u_xlat1.xy;
                u_xlat1.xy = u_xlat9.xy * u_xlat2.xx + u_xlat1.xy;
                u_xlat16_7 = SAMPLE_TEXTURE2D(_Cloud01Tex, sampler_Cloud01Tex, u_xlat1.xy).x;
                u_xlat16_1.x = SAMPLE_TEXTURE2D(_Cloud01Tex, sampler_Cloud01Tex, u_xlat3.xy).x;
                u_xlat1.x = -u_xlat16_7 + u_xlat16_1.x;
                u_xlat7.x = abs(u_xlat22) * u_xlat1.x + u_xlat16_7;
                u_xlat16_6.x = -u_xlat7.x + u_xlat21;
                u_xlat16_6.x = u_xlat16_13.x * u_xlat16_6.x + u_xlat7.x;
                u_xlat7.x = u_xlat16_6.x + _CloudOffset;
                u_xlat7.x = u_xlat7.x * _CloudMultiplyer;
                u_xlat7.x = max(u_xlat7.x, 0.0);
                u_xlat7.x = min(u_xlat7.x, 2.0);

                u_xlat1 = u_xlat7.xxxx * _Cloud01Color;
                u_xlat2 = u_xlat14.xxxx * _Cloud02Color - u_xlat1;
                u_xlat0 = u_xlat0.xxxx * u_xlat2 + u_xlat1;

                // ================================  ================================
                float4 u_xlat16_0, u_xlat16_2, u_xlat16_22, u_xlat16_8, u_xlat8;

                u_xlat1.xy = vs_TEXCOORD1.xy * _TintColorTexUV2Coord.xy + _TintColorTexUV2Coord.zw;
                u_xlat1.z = _Time.y * _NoiseSpeed + u_xlat1.y;
                u_xlat16_1.xyz = SAMPLE_TEXTURE2D(_TintColorTex, sampler_TintColorTex, u_xlat1.xz).xyz;
                u_xlat2.xy = vs_TEXCOORD0.xy * _TintColorTexUV1Coord.xy + _TintColorTexUV1Coord.zw;
                u_xlat2.z = _Time.y * _NoiseSpeed + u_xlat2.y;
                u_xlat16_2.xyz = SAMPLE_TEXTURE2D(_TintColorTex, sampler_TintColorTex, u_xlat2.xz).xyz;
                u_xlat1.xyz = u_xlat16_1.xyz + - u_xlat16_2.xyz;
                u_xlat1.xyz = u_xlat16_13.xxx * u_xlat1.xyz + u_xlat16_2.xyz;
                u_xlat1.xyz = clamp(u_xlat1.xyz, 0.0, 1.0);
                u_xlat22 = dot(u_xlat1.xyz, float3(0.29899999, 0.58700001, 0.114));
                u_xlat1.xyz = -u_xlat22.xxx + u_xlat1.xyz;
                u_xlat1.xyz = _TintColorTexScale * u_xlat1.xyz + u_xlat22;
                u_xlat0.xyz = u_xlat0.xyz * u_xlat1.xyz;
                u_xlat16_0 = (u_xlat0 * (_AllCloudsAlpha));
                u_xlat1.x = dot(u_xlat16_0.xyz, float3(0.29899999, 0.58700001, 0.114));
                u_xlat16_6.x = (u_xlat1.x + - 0.039999999);
                u_xlat16_6.x = (u_xlat16_6.x * 10.0);
                u_xlat16_6.x = clamp(u_xlat16_6.x, 0.0, 1.0);
                u_xlat1.xy = ((vs_TEXCOORD1.xy * _StarTexUV2Coord.xy) + _StarTexUV2Coord.zw);

                u_xlat15.xy = (vs_TEXCOORD4.xy * (_StarDepth));
                // color.xyz = vs_TEXCOORD7.xyz;

                u_xlat2.xy = ((u_xlat1.xy * float2(0.40000001, 0.40000001)) + u_xlat15.xy);
                u_xlat16_1.x = SAMPLE_TEXTURE2D(_StarTex, sampler_StarTex, u_xlat1.xy).x;
                u_xlat16_8 = SAMPLE_TEXTURE2D(_StarTex, sampler_StarTex, u_xlat2.xy).y;
                u_xlat2.xy = ((vs_TEXCOORD0.xy * _StarTexUV1Coord.xy) + _StarTexUV1Coord.zw);
                u_xlat15.xy = ((u_xlat2.xy * float2(0.40000001, 0.40000001)) + u_xlat15.xy);
                u_xlat16_2.x = SAMPLE_TEXTURE2D(_StarTex, sampler_StarTex, u_xlat2.xy).x;
                u_xlat16_15 = SAMPLE_TEXTURE2D(_StarTex, sampler_StarTex, u_xlat15.xy).y;
                u_xlat8.x = ((-u_xlat16_15) + u_xlat16_8);
                u_xlat1.y = ((u_xlat16_13.x * u_xlat8.x) + u_xlat16_15);
                u_xlat1.x = (u_xlat16_1.x + (-u_xlat16_2.x));
                u_xlat1.x = ((u_xlat16_13.x * u_xlat1.x) + u_xlat16_2.x);
                u_xlat1.xy = (u_xlat1.xy * float2(_StarBrightness1, _StarBrightness2));
                u_xlat1.x = ((u_xlat1.x * u_xlat16_6.x) + u_xlat1.y);
                u_xlat8.xy = (vs_TEXCOORD2.xy * _StarNoiseTiling.xy);
                u_xlat22 = (_Time.y * _StarScintillationSpeed);
                u_xlat2 = ((u_xlat22) * float4(0.40000001, 0.2, 0.1, 0.5));
                u_xlat8.xy = ((u_xlat8.xy * float2(2.0, 2.0)) + u_xlat2.zw);
                u_xlat2.xy = ((vs_TEXCOORD2.xy * _StarNoiseTiling.xy) + u_xlat2.xy);
                u_xlat16_22 = SAMPLE_TEXTURE2D(_StarTex, sampler_StarTex, u_xlat2.xy).z;
                u_xlat16_8 = SAMPLE_TEXTURE2D(_StarTex, sampler_StarTex, u_xlat8.xy).z;
                u_xlat8.x = (u_xlat16_8 * u_xlat16_22);
                u_xlat16_6.x = (u_xlat8.x * 3.0);
                u_xlat16_6.x = clamp(u_xlat16_6.x, 0.0, 1.0);
                u_xlat16_6.x = (u_xlat1.x * u_xlat16_6.x);
                u_xlat1.yz = ((vs_TEXCOORD1.xy * _ColorPalette_ST.xy) + _ColorPalette_ST.zw);
                u_xlat1.x = ((_Time.y * _ColorPalletteSpeed) + u_xlat1.y);
                u_xlat16_1.xyz = SAMPLE_TEXTURE2D(_ColorPalette, sampler_ColorPalette, u_xlat1.xz).xyz;
                u_xlat2.yz = ((vs_TEXCOORD0.xy * _ColorPalette_ST.xy) + _ColorPalette_ST.zw);
                u_xlat2.x = ((_Time.y * _ColorPalletteSpeed) + u_xlat2.y);

                u_xlat16_2.xyz = SAMPLE_TEXTURE2D(_ColorPalette, sampler_ColorPalette, u_xlat2.xz).xyz;
                // color.rgb = u_xlat16_2.xyz;
                u_xlat1.xyz = (u_xlat16_1.xyz + (-u_xlat16_2.xyz));
                u_xlat1.xyz = ((u_xlat16_13.xxx * u_xlat1.xyz) + u_xlat16_2.xyz);
                // color.xyz = u_xlat16_2.xyz;

                u_xlat16_13.xyz = ((-u_xlat1.xyz) + float3(1.0, 1.0, 1.0));
                u_xlat16_13.xyz = (((_Desaturate) * u_xlat16_13.xyz) + u_xlat1.xyz);
                u_xlat16_6.xyz = ((u_xlat16_6.xxx * u_xlat16_13.xyz) + u_xlat16_0.xyz);

                color.w = u_xlat16_0.w;
                u_xlat16_27 = (((-_GlobalOneMinusAvatarIntensityEnable) * _GlobalOneMinusAvatarIntensity) + 1.0);
                u_xlat16_6.xyz = ((u_xlat16_27) * u_xlat16_6.xyz);
                u_xlat16_27 = (((-_OneMinusGlobalMainIntensityEnable) * _OneMinusGlobalMainIntensity) + 1.0);
                u_xlat16_6.xyz = ((u_xlat16_27) * u_xlat16_6.xyz);
                u_xlat16_6.xyz = (u_xlat16_6.xyz * _ES_EffectIntensityScale);
                u_xlat16_27 = max(u_xlat16_6.y, u_xlat16_6.x);
                u_xlat16_27 = max(u_xlat16_6.z, u_xlat16_27);
                u_xlat1.x = max(u_xlat16_27, 0.0099999998);
                u_xlat8.x = (u_xlat1.x + (-_ES_EP_EffectParticleBottom));
                u_xlat15.x = ((-_ES_EP_EffectParticleBottom) + _ES_EP_EffectParticleTop);
                u_xlat15.x = (1.0 / u_xlat15.x);
                u_xlat8.x = (u_xlat15.x * u_xlat8.x);
                u_xlat8.x = clamp(u_xlat8.x, 0.0, 1.0);
                u_xlat15.x = ((u_xlat8.x * - 2.0) + 3.0);
                u_xlat8.x = (u_xlat8.x * u_xlat8.x);
                u_xlat8.x = (u_xlat8.x * u_xlat15.x);
                u_xlat16_27 = ((-_ES_EP_EffectParticleBottom) + _ES_EP_EffectParticleTop);
                u_xlat16_27 = ((u_xlat8.x * u_xlat16_27) + _ES_EP_EffectParticleBottom);
                u_xlat8.x = ((-u_xlat1.x) + u_xlat16_27);
                u_xlat8.x = ((_ES_EP_EffectParticle * u_xlat8.x) + u_xlat1.x);
                u_xlat8.x = ((_ES_EP_EffectParticleBottom < u_xlat1.x) ? (u_xlat8.x) : (u_xlat1.x));
                //u_xlat1.yz bug
                // color.xyz = u_xlat16_6.xyz;

                u_xlat1.xzw = (u_xlat16_6.xyz / u_xlat1.xxx);
                u_xlat1.xyz = (u_xlat8.xxx * u_xlat1.xzw);
                color.rgb = u_xlat1.xyz;
                return color;
            }
            ENDHLSL
        }
    }
    CustomEditor "LcLShaderEditor.LcLShaderGUI"
}
