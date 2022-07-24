Shader "Unlit/Ripple"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _Tilling ("Tilling", Range(0, 100)) = 1
        _Speed ("Speed", Range(0, 100)) = 1
        _RingWidth ("RingWidth", Range(0, 0.5)) = 0
        _RingSmoothness ("RingSmoothness", Range(0, 1)) = 0
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
            #include "Assets\Shaders\Libraries\Node.hlsl"

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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            float _Tilling;
            float _Speed;
            float _RingWidth;
            float _RingSmoothness;
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            
            half4 frag(v2f i) : SV_Target
            {
                half4 col = 1;
                float2 gridUV = i.uv * _Tilling;

                // gridUV += 1;

                float2 gridIndex = floor(gridUV);

                // 随机每个grid time，为了错开每个circle的出现时机
                float gridTime = random(floor(gridUV) * gridIndex);

                float speed = (_Time.x + gridTime) * _Speed;
                float size = frac(speed) * 0.5;

                // 随机位置
                float center = random(floor(speed) * gridIndex);

                float fadeOut = 1 - size;
                gridUV = frac(gridUV);
                col.rgb = DrawRing(gridUV, center, _RingWidth, size, _RingSmoothness) * fadeOut * fadeOut;


                col.rgb *= normalize(float3(gridUV - center, 0));
                return col;
            }
            ENDCG

        }
    }
}
