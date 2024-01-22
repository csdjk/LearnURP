Shader "Hidden/SceneHeightMap"
{

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        Fog
        {
            Mode Off
        }
        // Cull Off
        Cull Back
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 depth : TEXCOORD0;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.depth = o.vertex.zw;
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float depth = i.depth.x / i.depth.y;
                #if defined(UNITY_REVERSED_Z)
                    depth = 1 - depth;
                #endif
                return EncodeFloatRGBA(depth);
            }
            ENDCG
        }
    }
}
