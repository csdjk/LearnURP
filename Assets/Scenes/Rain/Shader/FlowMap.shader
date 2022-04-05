Shader "Unlit/FlowMap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _FlowMap ("Flow Map", 2D) = "white" { }
        _Tilling ("Tilling", Range(0, 10)) = 1
        _Speed ("Speed", Range(0.1, 10)) = 1
        _Strength ("_Strength", Range(0.1, 10)) = 1
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

            sampler2D _FlowMap;
            float4 _FlowMap_ST;
            sampler2D _MainTex;
            float _Speed;
            float _Strength;
            float _Tilling;
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _FlowMap);
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                half speed = _Time.x * _Speed;
                half speed1 = frac(speed);
                half speed2 = frac(speed + 0.5);

                half4 flow = tex2D(_FlowMap, i.uv);
                half2 flow_uv = - (flow.xy * 2 - 1);

                half2 flow_uv1 = flow_uv * speed1 * _Strength;
                half2 flow_uv2 = flow_uv * speed2 * _Strength;

                flow_uv1 += (i.uv * _Tilling);
                flow_uv2 += (i.uv * _Tilling);

                half4 col = tex2D(_MainTex, flow_uv1);
                half4 col2 = tex2D(_MainTex, flow_uv2);

                float lerpValue = abs(speed1 * 2 - 1);
                half4 finalCol = lerp(col, col2, lerpValue);

                return finalCol;
            }
            ENDCG

        }
    }
}
