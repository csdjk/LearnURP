Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        // 描边强度
        _OutlinePower ("line power", Range(0, 0.2)) = 0.05
        // 描边颜色
        _LineColor ("lineColor", Color) = (1, 1, 1, 1)

        _OffsetFactor ("Offset Factor", Range(0, 200)) = 0
        _OffsetUnits ("Offset Units", Range(0, 200)) = 0
        [Toggle(_USE_SMOOTH_NORMAL_ON)] _USE_SMOOTH_NORMAL ("Use Smooth Normal", float) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Front
            ZWrite Off
            Offset [_OffsetFactor], [_OffsetUnits]

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _USE_SMOOTH_NORMAL_ON

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };
            //顶点着色器输出结构体
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormalDir : COLOR0;
                float3 worldPos : COLOR1;
            };
            
            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float4 _Color;
            //描边强度
            float _OutlinePower;
            //描边颜色
            float4 _LineColor;

            v2f vert(appdata v)
            {
                v2f o;
                //顶点沿着法线方向扩张
                #ifdef _USE_SMOOTH_NORMAL_ON
                    // 使用平滑的法线计算
                    v.vertex.xyz += normalize(v.tangent.xyz) * _OutlinePower;
                #else
                    // 使用自带的法线计算
                    v.vertex.xyz += normalize(v.normal) * _OutlinePower * 0.7;
                #endif
                o.vertex = UnityObjectToClipPos(v.vertex);

                // 如果需要使描边线不随Camera距离变大而跟着变小，就需要变换到ndc空间
                // float3 normalDir =  normalize(v.normal.xyz);
                // float4 pos = UnityObjectToClipPos(v.vertex);
                // float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, normalDir);
                // float3 ndcNormal = normalize(TransformViewToProjection(viewNormal.xyz)) * pos.w;//将法线变换到NDC空间
                // pos.xy += _OutlinePower * ndcNormal.xy;
                // o.vertex = pos;
                return o;
            }
            fixed4 frag(v2f i) : SV_Target
            {
                return _LineColor;
            }
            
            ENDCG

        }
    }
}
