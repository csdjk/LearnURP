Shader "LcL/GPU-Animation/GPU-AnimationBone2D"
{
    Properties
    {
        _BaseMap ("Texture", 2D) = "white" { }
        _BaseColor ("Color", Color) = (1, 1, 1, 1)
        _AnimationTex ("Bone Texture", 2D) = "white" { }
        _FrameIndex ("Frame Index", Int) = 0
        _BlendFrameIndex ("Blend Frame Index", Int) = 0
        _BlendProgress ("Blend Progress", Range(0.0, 1.0)) = 0.0
        [Toggle(_DEBUG)] _DEBUG ("Debug(Auto Play)", float) = 0
    }
    SubShader
    {
        Tags
        {
            "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane"
        }
        Fog
        {
            Mode Off
        }
        Cull Off
        ZWrite Off
        Blend One OneMinusSrcAlpha
        Lighting Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 vertexColor : COLOR;
                float2 uv : TEXCOORD0;
                float4 boneIndexs : TEXCOORD1;
            };

            struct v2f
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                fixed4 vertexColor : COLOR;
            };

            sampler2D _BaseMap;
            Texture2D _AnimationTex;

            float4 _BaseMap_ST;
            float4 _BaseColor;
            float4 _AnimationTex_TexelSize;
            int _Blend;
            // 当前动画第几帧
            int _FrameIndex;
            // 下一个动画在第几帧
            int _BlendFrameIndex;
            // 下一个动画的融合程度
            float _BlendProgress;
            int _DEBUG;

            float4x4 GetBoneMatrix(uint boneIndex, uint frame)
            {
                uint startIndex = boneIndex * 3;
                float4x4 boneMatrix = 0;
                boneMatrix[0] = _AnimationTex.Load(int3(startIndex + 0, frame, 0));
                boneMatrix[1] = _AnimationTex.Load(int3(startIndex + 1, frame, 0));
                boneMatrix[2] = _AnimationTex.Load(int3(startIndex + 2, frame, 0));
                boneMatrix[3] = float4(0, 0, 0, 1);
                return boneMatrix;
            }

            #pragma enable_d3d11_debug_symbols

            void TransformBoneAnimation(float4 boneIndexs, inout float4 positionOS)
            {
                if (_DEBUG)
                {
                    uint w, h;
                    _AnimationTex.GetDimensions(w, h);
                    _FrameIndex = floor(abs(_SinTime.w) * h) % h;
                }
                //提取当前帧骨骼矩阵
                float4x4 boneMatrix = GetBoneMatrix(boneIndexs.x, _FrameIndex);

                //混合下一个动画
                if (_Blend)
                {
                    //提取下一个动画的第一帧骨骼矩阵
                    float4x4 boneMatrixBlend = GetBoneMatrix(boneIndexs.x, _BlendFrameIndex);
                    boneMatrix = lerp(boneMatrix, boneMatrixBlend, _BlendProgress);
                }

                //转换坐标的本质流程: 模型空间 -> 世界空间 -> 骨骼空间 -> 世界空间 -> 模型空间
                positionOS = mul(boneMatrix, positionOS);
            }

            v2f vert(appdata v)
            {
                v2f o;

                TransformBoneAnimation(v.boneIndexs, v.vertex);

                o.positionCS = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                o.vertexColor = v.vertexColor * float4(_BaseColor.rgb * _BaseColor.a, _BaseColor.a); // Combine a PMA version of _Color with vertexColor.

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_BaseMap, i.uv) * i.vertexColor;
                return col;
            }
            ENDCG
        }
    }
}