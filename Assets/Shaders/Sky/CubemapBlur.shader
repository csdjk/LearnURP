// ================================= LOD Blur 天空盒 =================================
Shader "LcL/Common/CubemapBlur"
{
    Properties
    {
        _Tint ("Tint Color", Color) = (.5, .5, .5, .5)
        [Gamma] _Exposure ("Exposure", Range(0, 8)) = 1.0
        _Rotation ("Rotation", Range(0, 360)) = 0
        _Blur ("Blur", Range(0, 1)) = 0
        [NoScaleOffset] _Tex ("Cubemap   (HDR)", Cube) = "grey" { }

        [Foldout(_SKY_FOG)]_SKY_FOG ("Fog", float) = 0
        [ShowIf(_SKY_FOG, 1)]_FogColor ("Fog Color", Color) = (0.5, 0.5, 0.5, 1)
        [ShowIf(_SKY_FOG, 1)]_CenterY ("Fog Start Height", Range(-1,1)) = 0
        [ShowIf(_SKY_FOG, 1)]_FogSoftness ("Fog Softness", Range(0,1)) = 0.1
        [FoldoutEnd][ShowIf(_SKY_FOG, 1)]_FogIntensity ("Fog Intensity", Range(0,1)) = 1
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Background" "RenderType" = "Background" "PreviewType" = "Skybox"
        }
        Cull Off ZWrite Off

        Pass
        {

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #pragma multi_compile _ _SKY_FOG

            samplerCUBE _Tex;
            half4 _Tex_HDR;
            half4 _Tint;
            half _Exposure;
            float _Rotation;
            float _Blur;

            half4 _FogColor;
            float _CenterY;
            float _FogSoftness;
            float _FogIntensity ;

            float3 RotateAroundYInDegrees(float3 vertex, float degrees)
            {
                float alpha = degrees * UNITY_PI / 180.0;
                float sina, cosa;
                sincos(alpha, sina, cosa);
                float2x2 m = float2x2(cosa, -sina, sina, cosa);
                return float3(mul(m, vertex.xz), vertex.y).xzy;
            }

            struct appdata_t
            {
                float4 vertex : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 texcoord : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            v2f vert(appdata_t v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                float3 rotated = RotateAroundYInDegrees(v.vertex, _Rotation);
                o.vertex = UnityObjectToClipPos(rotated);
                o.texcoord = v.vertex.xyz;
                // o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldPos = v.vertex.xyz;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float lod = _Blur * 6.0f;
                half4 tex = texCUBElod(_Tex, float4(i.texcoord, lod));
                half3 c = DecodeHDR(tex, _Tex_HDR);
                c = c * _Tint.rgb * unity_ColorSpaceDouble.rgb;
                c *= _Exposure;

                // float3 view_pos = UnityWorldToViewPos(i.worldPos);

                #ifdef _SKY_FOG
                float maskUp = smoothstep(_CenterY, _CenterY + _FogSoftness, i.worldPos.y);
                float maskDown = smoothstep(_CenterY, _CenterY - _FogSoftness, i.worldPos.y);
                float fogFactor = max(maskUp, maskDown);
                fogFactor = lerp(1, fogFactor, _FogIntensity);
                c = lerp(_FogColor.rgb, c, fogFactor);
                #endif

                return half4(c, 1);
            }
            ENDCG
        }
    }
    CustomEditor "LcLShaderEditor.LcLShaderGUI"

    Fallback Off
}
