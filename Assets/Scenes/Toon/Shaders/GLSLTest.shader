Shader "LcL/GLSLTest2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _BaseMap ("Texture", 2D) = "white" { }
        [Gamma]_Color ("Colour", Color) = (1, 1, 1, 1)
        _BackColor ("Back Colour", Color) = (1, 1, 1, 1)
        _Test0 ("Test", Float) = 0
        _Test1 ("Test1", Float) = 0
        _Test2 ("Test2", Float) = 0

        _OffsetFactor ("Offset Factor", Range(0, 200)) = 0
        _OffsetUnits ("Offset Units", Range(0, 200)) = 0
        [Toggle(_SWITCH)] _SWITCH ("Toggle", float) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            float4 _Color;
            float4 _BackColor;
            float _Test0;
            float _Test1;
            float _Test2;


            float _OutlineWidth;
            float _OutlineOffset;
            float _OutlineScale;
            float _OutlineExtdStart;
            float _OutlineExtdMax;
            float _OutlineColorIntensity;
            float _ES_OutLineDarkenVal;
            float _ES_OutLineLightedVal;
        CBUFFER_END
        ENDHLSL

        Pass
        {
            Tags { "LightMode" = "UniversalForward" }
            Offset [_OffsetFactor], [_OffsetUnits]

            HLSLPROGRAM
            #pragma shader_feature _SWITCH
            #pragma vertex vert
            #pragma fragment frag

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
                float3 viewDirWS : TEXCOORD1;
                float4 screenUV : TEXCOORD2;
                float3 positionWS : TEXCOORD3;
                float3 normalWS : TEXCOORD4;
                float3 tangentWS : TEXCOORD5;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            float4 _BaseMap_TexelSize;

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _MainTex_TexelSize;

            Varyings vert(Attributes input)
            {
                Varyings output;

                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionWS = positionInputs.positionWS;
                // output.positionCS = positionInputs.positionCS;
                output.uv = input.uv;

                // output.color = input.color;
                output.viewDirWS = GetWorldSpaceViewDir(positionInputs.positionWS);

                // output.screenUV = ComputeScreenPos(output.positionCS);

                VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                output.normalWS = normalInputs.normalWS;

                // output.tangentWS = TransformWorldToViewDir(TransformObjectToWorldDir(input.tangentOS), true);


                // float3 normalDir = normalize(input.normalOS);
                // float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, normalDir);


                output.positionCS = positionInputs.positionCS;
                return output;
            }
            #pragma enable_d3d11_debug_symbols
            half4 frag(Varyings input, half facing : VFACE) : SV_Target
            {
                float4 color = 0;
                color.rgb = normalize(input.normalWS);
                // float2 uv = input.positionCS.xy / _ScaledScreenParams.xy;

                // float3 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
                // float4 uv = float4(_Test, 1, 0,0);

                // half4 baseMap = LOAD_TEXTURE2D(_BaseMap, float2(_Test, 0));
                // half4 baseMap2 = LOAD_TEXTURE2D(_BaseMap, float2(_Test, 1));
                // return baseMap * baseMap2;

                // color.r = smoothstep(_Test0, 1, baseMap.r);
                // color.r = smoothstep(_Test0 - _Test1, _Test0 + _Test1, _Color.r);
                // color.r = smoothstep(_Test0 - _Test1, _Test0 + _Test1, _Color.r*_Test2);

                // float temp = _Test1 + _Test1;
                // color.r = smoothstep(0, 1, 2*(_Color.r - _Test1));
                // float temp = smoothstep(0, 1, baseMap.r);


                // half value = lerp(_Test0,_Test1,_Test2);
                // color.r = lerp(1 - _Test0, 1, _Test1);

                // color = normalize(input.viewDirWS);

                // color = (facing > 0) ? 1.0 : - 1.0;

                // color = PositivePow(baseMap, 5.2);
                // color = pow(baseMap, _Test0);


                // color.r = SampleSceneDepth(uv);
                // color.r = Linear01Depth(color.r, _ZBufferParams);


                // color = length(input.normalWS);


                // color = smoothstep(_OutlineExtdStart, _OutlineExtdMax, _Test0);
                // color = smoothstep(_OutlineExtdStart, _OutlineExtdMax, _Test0);


                // color = (_Color.rgb < float3(0.5, 0.5, 0.5)) ? _Test0 : _Test1;


                // color = facing > 0 ? _Color : _BackColor;


                // float4 baseMap = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
                // float2 uv = _MainTex_TexelSize.zw * input.uv;
                // float2 uv = float2(0,7);

                // int2 uv = floor(_MainTex_TexelSize.zw * input.uv);
                // float4 baseMap = LOAD_TEXTURE2D(_MainTex, uv);

                // if (uv.y == 1)
                // {
                //     baseMap.r *= 10;
                // }
                return color;
            }
            ENDHLSL
        }
    }
}
