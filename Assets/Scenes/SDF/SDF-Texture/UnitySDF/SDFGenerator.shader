Shader "Internal/SDFGenerator" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _SourceTex ("Source Texture", 2D) = "white" {}
        _Spread("Spread", Float) = 1
        _Feather("Feather", Range(0, 1)) = 0.125
        _Channel("Channel", Float) = 3
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass {
            Blend One Zero

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile _ FIRSTPASS

            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;
            float _Spread;
            float _Channel;

            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 sampleEdgeUV(float2 uv) {
                float4 edge = tex2Dlod(_MainTex, float4(uv, 0, 0));
                if (edge.a < 0.5) edge.xy = -10000;
                return edge;
            }
            float inBounds(float2 uv) {
                return all(uv > 0) && all(uv < 1);
            }

            static float2 offsets[] = {
                float2(+0, -1),
                float2(-1, +0),
                float2(+1, +0),
                float2(+0, +1),
                float2(-1, -1),
                float2(-1, +1),
                float2(+1, -1),
                float2(+1, +1),
            };

            fixed4 frag(v2f input) : SV_Target{
                float2 uv = input.uv;

                // How far each sample should spread
                float2 uvo = _MainTex_TexelSize.xy * _Spread;

                // Compute a distance factor based on the smaller edge
                float2 dstFact = _MainTex_TexelSize.zw / max(_MainTex_TexelSize.z, _MainTex_TexelSize.w);

#if defined(FIRSTPASS)
                // Detect edges
                float solidCount = 0;
                float4 self = tex2D(_MainTex, uv);
                bool selfSolid = self[_Channel] >= 0.5;
                float4 outuv = float4(-1000, -1000, selfSolid ? 1 : 0, 0);
                for (float i = 0; i < 8; ++i) {
                    float2 euv = uv + uvo * offsets[i];
                    float4 edge = tex2Dlod(_MainTex, float4(euv, 0, 0)) * inBounds(euv);
                    // An edge is when two neighbouring pixels have different "solid" results
                    if ((edge[_Channel] >= 0.5) != selfSolid) {
                        float l = (0.5 - self[_Channel]) / (edge[_Channel] - self[_Channel]);
                        euv = lerp(uv, euv, l);
                        if (length((euv.xy - uv) * dstFact) < length((outuv.xy - uv) * dstFact)) {
                            outuv.xy = euv.xy;
                            outuv.a = 1;    // Mark this result as valid
                        }
                    }
                }
                return outuv;
#else
                // Get the current nearest edge
                float4 outuv = sampleEdgeUV(uv);
                for (float i = 0; i < 8; ++i) {
                    // Sample 8 points to find another nearest candidate
                    float2 euv = uv + uvo * offsets[i];
                    float4 edge = sampleEdgeUV(euv);
                    // If the new edge is nearer, use it instead
                    if (length((edge.xy - uv) * dstFact) < length((outuv.xy - uv) * dstFact)) {
                        outuv.xy = edge.xy;
                        outuv.a = 1;    // Mark this result as valid
                    }
                }
                return outuv;
#endif
            }
            ENDCG
        }

        Pass {
            Name "FinalPass"
            Blend One Zero

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            struct v2f {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _SourceTex;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;
            float _Feather;
            float _Channel;

            v2f vert(appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            float4 sampleEdgeUV(float2 uv) {
                float4 edge = tex2D(_MainTex, uv);
                if (edge.a < 0.5) edge.xy = -10000;
                return edge;
            }
            fixed4 frag(v2f input) : SV_Target {
                // Get the computed nearest edge
                float4 edge = sampleEdgeUV(input.uv);
                // Compute a distance factor based on the smaller edge
                float2 dstFact = _MainTex_TexelSize.zw / max(_MainTex_TexelSize.z, _MainTex_TexelSize.w);
                // Compute the distance
                float dst = length((input.uv - edge.xy) * dstFact);
                // Compute the SDF from distance (based on 'solid' (in b) and 'feather' distance)
                dst = 0.5 + dst * (step(0.5, edge.b) * 2 - 1) / _Feather;
                float4 source = tex2D(_SourceTex, edge.b > 0.5 ? input.uv : edge.xy);
                switch (_Channel) {
                case 0: source.r = dst; break;
                case 1: source.g = dst; break;
                case 2: source.b = dst; break;
                case 3: source.a = dst; break;
                }
                return source;
            }
            ENDCG
        }
    }
}
