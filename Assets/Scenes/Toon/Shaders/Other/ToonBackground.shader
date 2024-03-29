Shader "LcL/ToonBackground"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" { }
        _Opacity ("Opacity", Range(0, 1)) = 1
        _BaseMap ("Base Texture", 2D) = "black" { }
        _BaseTexInst ("Base Texture Instance", Range(0, 1)) = 0
        _BaseTexMax ("Base Texture Max", Range(0, 1)) = 1
        _BaseTexRange ("Base Texture Range", Vector) = (0, 0, 0, 0)
        _BaseTexSharp ("Base Texture Sharp", Range(0, 1)) = 0.01
        _BaseTexSpeed ("Base Texture Speed", Vector) = (0, 0, 0, 0)
        _Color ("Color", Color) = (0.27525, 0.5211, 1, 1)
        _Color1 ("Color 1", Color) = (0.41663, 0.59025, 0.97867, 1)
        _Color2 ("Color 2", Color) = (0.86613, 0.95413, 1, 1)
        _Color3 ("Color 3", Color) = (1, 1, 1, 1)
        _ColorRangeMax ("Color Range Max", Range(0, 1)) = 0.225
        _ColorRangeMin ("Color Range Min", Range(0, 1)) = 0.1
        _ColorRangeTop ("Color Range Top", Range(0, 1)) = 0.4
        _MainDistortion ("Main Distortion", Range(0, 1)) = 0.111
        _MainRangeMax ("Main Range Max", Range(0, 1)) = 0.05
        _MainRangeMin ("Main Range Min", Range(0, 1)) = 0.75
        _MainSpeedX ("Main Speed X", Float) = 0.003
        _MainSpeedY ("Main Speed Y", Float) = -0.005
        _MaskDistortion ("Mask Distortion", Range(0, 1)) = 0.1
        _MaskRangeMax ("Mask Range Max", Range(0, 1)) = 0.4
        _MaskRangeMin ("Mask Range Min", Range(0, 1)) = 0.05
        _Pattern1 ("Pattern 1", Vector) = (0.61, 0.94, 0, 0)
        _Pattern1SpeedX ("Pattern 1 Speed X", Float) = -0.05
        _Pattern1SpeedY ("Pattern 1 Speed Y", Float) = -0.02
        _SatRangeEnd ("Saturation Range End", Range(0, 1)) = 0.8
        _SatRangeStar ("Saturation Range Start", Range(0, 1)) = 0.3

        _CenterPos1 ("Center Position 1", Vector) = (-0.09, 0.65, -0.75, 0.45)
        _CenterPos2 ("Center Position 2", Vector) = (0.235, 0.575, 0.625, 0.65)
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent" }

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            float4 _MainTex_ST;
            float4 _BaseTexRange;
            float4 _BaseTexSpeed;
            float4 _BaseTex_ST;
            float4 _Color;
            float4 _Color1;
            float4 _Color2;
            float4 _Color3;

            float _BaseTexInst;
            float _BaseTexMax;
            float _BaseTexSharp;

            float _ColorRangeMax;
            float _ColorRangeMin;
            float _ColorRangeTop;
            float _MainDistortion;
            float _MainRangeMax;
            float _MainRangeMin;
            float _MainSpeedX;
            float _MainSpeedY;
            float _MaskDistortion;
            float _MaskRangeMax;
            float _MaskRangeMin;
            float4 _Pattern1;
            float _Pattern1SpeedX;
            float _Pattern1SpeedY;
            float _SatRangeEnd;
            float _SatRangeStar;

            float _Opacity;
        CBUFFER_END
        ENDHLSL

        Pass
        {
            Tags { "LightMode" = "UniversalForward" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float4 color : COLOR;
                float4 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
                float3 viewDirWS : TEXCOORD3;
                float3 normalWS : TEXCOORD4;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            Varyings vert(Attributes input)
            {
                Varyings output;

                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = positionInputs.positionCS;
                output.uv = input.uv;
                output.uv1 = input.uv1;
                output.color = input.color;


                VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS.xyz);
                output.normalWS = normalize(normalInputs.normalWS);
                // output.normalWS = input.normalOS;
                output.viewDirWS = GetWorldSpaceViewDir(positionInputs.positionWS);
                output.positionWS = positionInputs.positionWS;

                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                float2 screenUV = input.positionCS.xy / _ScaledScreenParams.xy;
                float2 vs_TEXCOORD1 = input.uv;
                float3 vs_TEXCOORD2 = input.normalWS;
                float3 vs_TEXCOORD3 = input.viewDirWS;
                float4 vs_TEXCOORD4 = input.color;
                float2 vs_TEXCOORD5 = input.uv1;
                float3 vs_TEXCOORD10 = input.positionWS;

                float4 finalColor = float4(0, 0, 0, 1);

                float4 u_xlat0;
                float4 u_xlat1;
                float4 u_xlat2;
                float4 u_xlat6;
                float4 u_xlat10;
                float u_xlat15;


                u_xlat0.xy = vs_TEXCOORD10.xy * _Pattern1.xy + _Pattern1.zw;
                u_xlat0.xy = float2(_Pattern1SpeedX, _Pattern1SpeedY) * _Time.yy + u_xlat0.xy;
                u_xlat10.xy = floor(u_xlat0.xy);
                u_xlat0.xy = frac(u_xlat0.xy);

                u_xlat1.xy = u_xlat10.xy + float2(1.0, 1.0);
                u_xlat1.x = dot(u_xlat1.xy, float2(127.1, 311.70001));
                u_xlat1.x = sin(u_xlat1.x);
                u_xlat1.x = u_xlat1.x * 4.3758545;
                u_xlat1.x = frac(u_xlat1.x);
                u_xlat1.x = u_xlat1.x * 2.0 - 1.0;
                u_xlat6.xy = u_xlat0.xy + float2(-1.0, -1.0);
                u_xlat1.x = dot(u_xlat1.xx, u_xlat6.xy);
                u_xlat2 = u_xlat10.xyxy + float4(1.0, 0.0, 0.0, 1.0);
                u_xlat10.x = dot(u_xlat10.xy, float2(127.1, 311.70001));
                u_xlat10.x = sin(u_xlat10.x);
                u_xlat10.x = u_xlat10.x * 4.3758545;
                u_xlat10.x = frac(u_xlat10.x);
                u_xlat10.x = u_xlat10.x * 2.0 - 1.0;
                u_xlat10.x = dot(u_xlat10.xx, u_xlat0.xy);

                u_xlat15 = dot(u_xlat2.zw, float2(127.1, 311.70001));
                u_xlat6.x = dot(u_xlat2.xy, float2(127.1, 311.70001));
                u_xlat6.x = sin(u_xlat6.x);
                u_xlat6.x = u_xlat6.x * 4.3758545;
                u_xlat6.x = frac(u_xlat6.x);
                u_xlat6.x = u_xlat6.x * 2.0 - 1.0;

                //----------------------------------------------

                float4 u_xlat11;
                float4 u_xlat16_3;
                float4 u_xlat16_8;

                u_xlat15 = sin(u_xlat15);
                u_xlat15 = u_xlat15 * 4.3758545;
                u_xlat15 = frac(u_xlat15);
                u_xlat15 = u_xlat15 * 2.0 - 1.0;
                u_xlat2 = u_xlat0.xyxy + float4(-1.0, 0.0, 0.0, -1.0);
                u_xlat10.y = dot(u_xlat15, u_xlat2.zw);
                u_xlat1.y = dot(u_xlat6.xx, u_xlat2.xy);
                u_xlat1.xy = -u_xlat10.yx + u_xlat1.xy;
                u_xlat11.xy = u_xlat0.xy * u_xlat0.xy;
                u_xlat0.xy = -u_xlat0.xy * float2(2.0, 2.0) + float2(3.0, 3.0);
                u_xlat0.xy = u_xlat0.xy * u_xlat11.xy;
                u_xlat15 = u_xlat0.x * u_xlat1.x + u_xlat10.y;
                u_xlat0.x = u_xlat0.x * u_xlat1.y + u_xlat10.x;
                u_xlat10.x = -u_xlat0.x + u_xlat15;
                u_xlat0.x = u_xlat0.y * u_xlat10.x + u_xlat0.x;
                u_xlat0.xy = u_xlat0.xx * float2(_MainDistortion, _MaskDistortion) + vs_TEXCOORD5.yy;
                u_xlat16_3.x = u_xlat0.y - _MaskRangeMin;
                u_xlat16_8.x = -_MaskRangeMin + _MaskRangeMax;
                u_xlat16_8.x = 1.0 / u_xlat16_8.x;
                u_xlat16_3.x = u_xlat16_8.x * u_xlat16_3.x;
                u_xlat16_3.x = clamp(u_xlat16_3.x, 0.0, 1.0);
                u_xlat16_8.x = u_xlat16_3.x * - 2.0 + 3.0;
                u_xlat16_3.x = u_xlat16_3.x * u_xlat16_3.x;
                u_xlat16_3.x = u_xlat16_3.x * u_xlat16_8.x;
                u_xlat16_3.x = u_xlat16_3.x * vs_TEXCOORD4.w;


                //----------------------------------------------
                float4 u_xlat5;
                float u_xlat16_5;

                u_xlat0.z = vs_TEXCOORD5.x;
                u_xlat5.xy = u_xlat0.zx * _MainTex_ST.xy + _MainTex_ST.zw;
                u_xlat5.xy = _Time.yy * float2(_MainSpeedX, _MainSpeedY) + u_xlat5.xy;
                u_xlat16_5 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, u_xlat5.xy).x;
                u_xlat16_8.x = u_xlat16_5 - 1.0;
                u_xlat16_3.x = u_xlat16_3.x * u_xlat16_8.x + 1.0;

                u_xlat5.x = u_xlat0.x - _MainRangeMin;
                u_xlat0.xz = u_xlat0.xx - float2(_ColorRangeMax, _ColorRangeMin);
                u_xlat15 = -_MainRangeMin + _MainRangeMax;
                u_xlat15 = 1.0 / u_xlat15;
                u_xlat5.x = u_xlat15 * u_xlat5.x;
                u_xlat5.x = clamp(u_xlat5.x, 0.0, 1.0);
                u_xlat15 = u_xlat5.x * - 2.0 + 3.0;
                u_xlat5.x = u_xlat5.x * u_xlat5.x;
                u_xlat5.x = u_xlat15 * u_xlat5.x - 1.0;
                u_xlat15 = vs_TEXCOORD5.y - 0.050000001;
                u_xlat15 = u_xlat15 * 6.6666665;
                u_xlat15 = clamp(u_xlat15, 0.0, 1.0);
                u_xlat1.x = u_xlat15 * - 2.0 + 3.0;
                u_xlat15 = u_xlat15 * u_xlat15;
                u_xlat15 = u_xlat15 * u_xlat1.x;

                // finalColor.rgb = vs_TEXCOORD1.yyy;

                u_xlat5.x = u_xlat15 * u_xlat5.x + 1.0;

                //----------------------------------------------
                float4 u_xlat16_4;
                float4 u_xlat16_9;
                float4 u_xlat16_1;
                float4 u_xlat16_18;

                u_xlat16_3.x *= u_xlat5.x;

                finalColor.w = u_xlat16_3.x * _Opacity;
                u_xlat5.xz = -float2(_ColorRangeMax, _ColorRangeMin) + float2(_ColorRangeTop, _ColorRangeMax);
                u_xlat5.xz = float2(1.0, 1.0) / u_xlat5.xz;
                u_xlat0.xy = u_xlat5.xz * u_xlat0.xz;
                u_xlat0.xy = clamp(u_xlat0.xy, 0.0, 1.0);
                u_xlat10.xy = u_xlat0.xy * float2(-2.0, -2.0) + float2(3.0, 3.0);
                u_xlat0.xy = u_xlat0.xy * u_xlat0.xy;
                u_xlat0.xy = u_xlat0.xy * u_xlat10.xy;
                u_xlat16_3.x = u_xlat0.y * vs_TEXCOORD4.w;
                u_xlat16_8.xyz = _Color.xyz - _Color1.xyz;
                u_xlat16_8.xyz = u_xlat0.xxx * u_xlat16_8.xyz + _Color1.xyz;
                u_xlat0.xy = screenUV;
                u_xlat0.xy = -u_xlat0.xy + float2(0.5, 0.5);
                u_xlat0.xy = -abs(u_xlat0.xy) + float2(1.0, 1.0);
                u_xlat16_4.x = u_xlat0.y + 0.1;
                u_xlat16_4.x *= 1.081081;
                u_xlat16_4.x = clamp(u_xlat16_4.x, 0.0, 1.0);
                u_xlat16_9.x = u_xlat16_4.x * - 2.0 + 3.0;
                u_xlat16_4.x *= u_xlat16_4.x;
                u_xlat16_4.x *= u_xlat16_9.x;
                u_xlat16_4.x = u_xlat0.x * u_xlat16_4.x - _SatRangeStar;
                u_xlat16_9.x = -_SatRangeStar + _SatRangeEnd;
                u_xlat16_9.x = 1.0 / u_xlat16_9.x;
                u_xlat16_4.x = u_xlat16_9.x * u_xlat16_4.x;
                u_xlat16_4.x = clamp(u_xlat16_4.x, 0.0, 1.0);
                u_xlat16_9.x = u_xlat16_4.x * - 2.0 + 3.0;
                u_xlat16_4.x *= u_xlat16_4.x;
                u_xlat16_4.x *= u_xlat16_9.x;
                u_xlat16_9.x = dot(float3(0.30000001, 0.58999997, 0.11), _Color2.xyz);
                u_xlat16_9.xyz = u_xlat16_9.xxx - _Color2.xyz;
                u_xlat16_4.xyz = u_xlat16_4.xxx * u_xlat16_9.xyz + _Color2.xyz;
                u_xlat16_8.xyz = u_xlat16_8.xyz - u_xlat16_4.xyz;
                u_xlat16_3.xyz = u_xlat16_3.xxx * u_xlat16_8.xyz + u_xlat16_4.xyz;
                u_xlat0.xyz = -u_xlat16_3.xyz + _Color3.xyz;

                // ================================  ================================


                u_xlat15.x = dot(vs_TEXCOORD3.xyz, vs_TEXCOORD3.xyz);
                u_xlat15.x = rsqrt(u_xlat15.x);
                u_xlat1.xyz = u_xlat15.xxx * vs_TEXCOORD3.xyz;
                u_xlat15.x = dot(vs_TEXCOORD2.xyz, vs_TEXCOORD2.xyz);
                u_xlat15.x = rsqrt(u_xlat15.x);
                u_xlat2.xyz = u_xlat15.xxx * vs_TEXCOORD2.xyz;
                u_xlat15.x = dot(u_xlat2.xyz, u_xlat1.xyz);
                u_xlat1.x = 1.0 / _BaseTexRange.x;
                u_xlat15.x *= u_xlat1.x;
                u_xlat15.x = clamp(u_xlat15.x, 0.0, 1.0);
                u_xlat1.x = u_xlat15.x * - 2.0 + 3.0;
                u_xlat15.x *= u_xlat15.x;
                u_xlat15.x *= u_xlat1.x;
                u_xlat15.x *= _BaseTexInst;
                u_xlat1.xy = vs_TEXCOORD1.xy * _BaseTex_ST.xy + _BaseTex_ST.zw;
                u_xlat1.xy = _BaseTexSpeed.xy * _Time.yy + u_xlat1.xy;
                u_xlat16_1.x = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap, u_xlat1.xy).x;
                u_xlat16_18.x = u_xlat16_1.x - _BaseTexSharp;
                u_xlat16_4.x = -_BaseTexSharp + _BaseTexMax;
                u_xlat16_4.x = 1.0 / u_xlat16_4.x;
                u_xlat16_18.x *= u_xlat16_4.x;
                u_xlat16_18.x = clamp(u_xlat16_18.x, 0.0, 1.0);
                u_xlat16_4.x = u_xlat16_18.x * - 2.0 + 3.0;
                u_xlat16_18.x *= u_xlat16_18.x;
                u_xlat16_18.x *= u_xlat16_4.x;
                u_xlat15.x *= u_xlat16_18.x;
                u_xlat0.xyz = u_xlat15.xxx * u_xlat0.xyz + u_xlat16_3.xyz;
                finalColor.xyz = u_xlat0.xyz;

                // finalColor.w = 1;


                return finalColor;
            }
            ENDHLSL
        }
    }
    CustomEditor "LcLShaderEditor.LcLShaderGUI"
}
