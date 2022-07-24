Shader "lcl/TillingCircle"
{
    Properties
    {
        _Tilling ("Tilling", Range(0, 100)) = 1
        _Smoothness ("Smoothness", Range(0, 1)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Assets\Shaders\Libraries\Noise.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            
            float _Tilling;
            float _Smoothness;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            half4 frag(v2f i) : SV_Target
            {
                float2 scaledUV = i.uv * _Tilling;
                float2 flooredUV = floor(scaledUV);
                float2 gridUV = frac(scaledUV);
                float dist = length(gridUV - 0.5) ;
                float size = random(flooredUV) * 0.5;
                float circles = smoothstep(size, size - _Smoothness, dist);
                return circles;
            }
            ENDCG

        }
    }
}
