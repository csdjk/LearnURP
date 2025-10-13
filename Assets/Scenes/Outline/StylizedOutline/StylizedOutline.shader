Shader "LcL/Outline/StylizedOutline"
{
    Properties
    {
        _LineColor ("lineColor", Color) = (1, 1, 1, 1)
        _OutlineWidth ("line width", Range(0, 10)) = 1
        _OutlineMaskWidth ("line mask width", Range(0, 10)) = 0.2

        [SingleLine]_NoiseTex ("Noise", 2D) = "white" { }
        _NoiseTilling ("Noise Tilling(zy:Offset,zw:Clip)", Vector) = (1, 1, 1, 1)
        _OffsetNoiseIntensity ("Offset Noise Intensity", Range(0, 1 )) = 0.1

        _OutlineClipValue ("Clip Value", Range(-1, 1)) = -1
        _ClipNoiseIntensity ("Clip Noise Intensity", Range(0, 1 )) = 0.1
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry"
        }
        LOD 100

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        struct appdata
        {
            float4 positionOS : POSITION;
            float4 color: COLOR;
            float2 uv : TEXCOORD0;
            float3 normal : NORMAL;
            float4 tangent : TANGENT;
        };

        struct v2f
        {
            float4 vertex : SV_POSITION;
            float3 viewWS: TEXCOORD0;
            float3 normalWS: TEXCOORD1;
            float2 uv : TEXCOORD2;
        };

        TEXTURE2D(_NoiseTex);
        SAMPLER(sampler_NoiseTex);
        float4 _MainTex_TexelSize;
        float4 _Color;
        float4 _LineColor;
        float _OutlineWidth;
        float _OutlineMaskWidth;
        float _OutlinePow;

        float4 _NoiseTilling;
        float _OffsetNoiseIntensity;
        float _ClipNoiseIntensity;
        float _OutlineClipValue;

        v2f vert_outline(appdata input, float outlineWidth)
        {
            v2f output;
            VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);

            half noise = (SAMPLE_TEXTURE2D_LOD(_NoiseTex, sampler_NoiseTex, input.uv * _NoiseTilling.xy, 0).r * 2 - 1) * _OffsetNoiseIntensity;

            outlineWidth = (outlineWidth + noise) * 0.01;

            //=============================顶点沿着法线方向扩张=============================
            input.positionOS.xyz += normalize(input.normal) * outlineWidth;
            output.vertex = TransformObjectToHClip(input.positionOS);


            //=============================顶点沿着法线方向扩张（NDC空间）=============================
            // float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, input.normal.xyz);
            // //将法线变换到NDC空间
            // float3 ndcNormal = normalize(TransformWViewToHClip(viewNormal.xyz)) * positionInputs.positionCS.w;
            // //将近裁剪面右上角位置的顶点变换到观察空间
            // float4 nearUpperRight = mul(unity_CameraInvProjection,
            //                             float4(1, 1, UNITY_NEAR_CLIP_VALUE, _ProjectionParams.y));
            //
            // float aspect = abs(nearUpperRight.y / nearUpperRight.x); //求得屏幕宽高比
            // ndcNormal.x *= aspect;
            // positionInputs.positionCS.xy += outlineWidth * ndcNormal.xy;
            // output.vertex = positionInputs.positionCS;

            output.viewWS = GetWorldSpaceViewDir(positionInputs.positionWS);
            output.normalWS = normalize(TransformObjectToWorldNormal(input.normal));
            output.uv = input.uv;
            return output;
        }

        v2f vert_mask(appdata input)
        {
            return vert_outline(input, _OutlineWidth - _OutlineMaskWidth);
        }

        v2f vert_real(appdata input)
        {
            return vert_outline(input, _OutlineWidth);
        }

        half4 frag_outline_mask(v2f input, half facing : VFACE) : SV_Target
        {
            return float4(0, 0, 0, 1);
        }

        half4 frag_simple_color(v2f input, half facing : VFACE) : SV_Target
        {
            half4 noise = (SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, input.uv * _NoiseTilling.zw) * 2 - 1) * _ClipNoiseIntensity;
            clip(noise - _OutlineClipValue);
            return _LineColor;
        }

        /**============================================================================
        // 根据菲涅尔计算轮廓剔除部分描边(部分模型效果不太理想,宽度不一致,没有用多 pass + stencil效果好)
        float ComputeOutlineClipAlpha(float3 normal_ws, float3 view_ws, float outline_pow, float3 noise)
        {
            normal_ws = normalize(normal_ws + noise);
            float NdotV = dot(normal_ws, view_ws);

            NdotV = saturate(NdotV);

            // NdotV = pow(NdotV, outline_pow) * (noise + 1);
            NdotV = pow(NdotV, outline_pow);

            float mask = step(NdotV, 0.5);
            clip(mask - 0.5);
            return mask;
        }
        half4 frag_rim_clip(v2f input, half facing : VFACE) : SV_Target
        {
            float face = facing > 0 ? 1 : -1;

            float3 view_ws = normalize(input.viewWS);
            float3 normal_ws = normalize(input.normalWS) * face;

            view_ws = TransformWorldToViewDir(view_ws, true);
            normal_ws = TransformWorldToViewDir(normal_ws, true);


            half4 noise = (SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, input.uv * _NoiseTilling.xy) * 2 - 1) * _ClipNoiseIntensity;

            // float alpha = ComputeOutlineClipAlpha(normal_ws, view_ws, _OutlinePow, noise);
            return half4(_LineColor.xyz, 1);
        }
        **/


        ENDHLSL

        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            Stencil
            {
                Ref 1
                Comp Always
                Pass Replace
            }
            ColorMask 0
            Cull Front
            ZWrite Off
            ZTest Off

            HLSLPROGRAM
            #pragma vertex vert_mask
            #pragma fragment frag_outline_mask
            ENDHLSL
        }

        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            Stencil
            {
                Ref 1
                Comp NotEqual
                Pass Keep
            }
            Cull Front

            HLSLPROGRAM
            #pragma vertex vert_real
            #pragma fragment frag_simple_color
            ENDHLSL
        }
    }

    CustomEditor "LcLShaderEditor.LcLShaderGUI"
}
