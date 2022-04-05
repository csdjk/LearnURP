Shader "Unlit/SimplePostProcess"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }

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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col * _Color;
            }

            //
            struct VS_OUTPUT
            {
                float4 dx_Position : SV_Position;
                float4 gl_Position : TEXCOORD2;
                float4 gl_FragCoord : TEXCOORD3;
                float4 v0 : TEXCOORD0;
                float v1 : TEXCOORD1;
            };
            #pragma warning(disable : 3556 3571)
            float2 vec2_ctor(float x0, float x1)
            {
                return float2(x0, x1);
            }
            float2 vec2_ctor(float2 x0)
            {
                return float2(x0);
            }
            // Uniforms

            uniform float4 _hlslcc_mtx4x4unity_ObjectToWorld[4] : register(c1);
            uniform float4 _hlslcc_mtx4x4unity_MatrixV[4] : register(c5);
            uniform float4 _hlslcc_mtx4x4unity_MatrixVP[4] : register(c9);
            uniform float4 __RainColor : register(c13);
            uniform float4 __Parallax : register(c14);
            uniform float4 __DownTrans : register(c15);
            uniform float __Tiling : register(c16);
            #ifdef ANGLE_ENABLE_LOOP_FLATTEN
                #define LOOP [loop]
                #define FLATTEN [flatten]
            #else
                #define LOOP
                #define FLATTEN
            #endif

            #define ATOMIC_COUNTER_ARRAY_STRIDE 4

            // Attributes
            static float4 _in_POSITION0 = {
                0, 0, 0, 0
            };
            static float2 _in_TEXCOORD0 = {
                0, 0
            };
            static float2 _in_TEXCOORD1 = {
                0, 0
            };

            static float4 gl_Position = float4(0, 0, 0, 0);

            // Varyings
            static  float4 _vs_TEXCOORD0 = {
                0, 0, 0, 0
            };
            static  float _vs_COLOR0 = {
                0
            };

            cbuffer DriverConstants : register(b1)
            {
                float4 dx_ViewAdjust : packoffset(c1);
                float2 dx_ViewCoords : packoffset(c2);
                float2 dx_ViewScale : packoffset(c3);
            };

            static float4 _u_xlat0 = {
                0, 0, 0, 0
            };
            static float4 _u_xlat1 = {
                0, 0, 0, 0
            };
            static bool _u_xlatb2 = {
                0
            };
            struct VS_INPUT
            {
                float4 _in_POSITION0 : TEXCOORD0;
                float2 _in_TEXCOORD0 : TEXCOORD1;
                float2 _in_TEXCOORD1 : TEXCOORD2;
            };

            void initAttributes(VS_INPUT input)
            {
                _in_POSITION0 = input._in_POSITION0;
                _in_TEXCOORD0 = input._in_TEXCOORD0;
                _in_TEXCOORD1 = input._in_TEXCOORD1;
            }


            VS_OUTPUT generateOutput(VS_INPUT input)
            {
                VS_OUTPUT output;
                output.gl_Position = gl_Position;
                output.dx_Position.x = gl_Position.x;
                output.dx_Position.y = -gl_Position.y;
                output.dx_Position.z = (gl_Position.z + gl_Position.w) * 0.5;
                output.dx_Position.w = gl_Position.w;
                output.gl_FragCoord = gl_Position;
                output.v0 = _vs_TEXCOORD0;
                output.v1 = _vs_COLOR0;

                return output;
            }

            VS_OUTPUT main(VS_INPUT input)
            {
                initAttributes(input);

                (_u_xlat0 = (_in_POSITION0.yyyy * unity_ObjectToWorld[1]));
                (_u_xlat0 = ((unity_ObjectToWorld[0] * _in_POSITION0.xxxx) + _u_xlat0));
                (_u_xlat0 = ((unity_ObjectToWorld[2] * _in_POSITION0.zzzz) + _u_xlat0));
                (_u_xlat0 = (_u_xlat0 + unity_ObjectToWorld[3]));
                (_u_xlat1 = (_u_xlat0.yyyy * _hlslcc_mtx4x4unity_MatrixVP[1]));
                (_u_xlat1 = ((_hlslcc_mtx4x4unity_MatrixVP[0] * _u_xlat0.xxxx) + _u_xlat1));
                (_u_xlat1 = ((_hlslcc_mtx4x4unity_MatrixVP[2] * _u_xlat0.zzzz) + _u_xlat1));
                (gl_Position = ((_hlslcc_mtx4x4unity_MatrixVP[3] * _u_xlat0.wwww) + _u_xlat1));

                _u_xlat0.xy = (_in_TEXCOORD0.xy * vec2_ctor(__Tiling, __Tiling) + float2(-0.5, -0.5));
                
                (_u_xlat0.z = dot(float2(0.9800666, -0.19866933), _u_xlat0.xy));
                (_u_xlat1.xy = (_u_xlat0.xz * __Parallax.xy));
                (_vs_TEXCOORD0.xz = _u_xlat1.xy);
                (_u_xlat0.w = dot(float2(0.19866933, 0.9800666), _u_xlat0.xy));
                (_vs_TEXCOORD0.yw = ((_u_xlat0.yw * __Parallax.xy) + (-__DownTrans.xy)));
                (_u_xlat0.x = ((-_hlslcc_mtx4x4unity_MatrixV[1].z) + - 0.40000001));
                (_u_xlat0.x = ((_u_xlat0.x * 3.5) + 1.0));
                (_u_xlat0.x = (_u_xlat0.x * _in_TEXCOORD1.x));
                (_u_xlatb2 = (_hlslcc_mtx4x4unity_MatrixV[1].z < - 0.40000001));
                float sc0d = {
                    0
                };
                if (_u_xlatb2)
                {
                    (sc0d = _u_xlat0.x);
                }
                else
                {
                    (sc0d = _in_TEXCOORD1.x);
                }
                (_u_xlat0.x = sc0d);
                (_vs_COLOR0 = (_u_xlat0.x * __RainColor.w));
                return generateOutput(input);
            }
            ENDCG

        }
    }
}

