Shader "LcL/PRTGI/ProbeDebug"
{
    Properties {}
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"
        }
        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            HLSLPROGRAM
            #pragma multi_compile_instancing

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Assets/Shaders/Libraries/Node.hlsl"
            #include "SH.hlsl"

            // uint3 _ProbeGridSize;
            // float4 _VoxelCorner;
            // #define _ProbeSpacing _VoxelCorner.w
            StructuredBuffer<float3> _CoefficientVoxel;

            #pragma enable_d3d11_debug_symbols

            struct Attributes
            {
                float4 positionOS : POSITION;
                float4 normalOS : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 sh : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 center : TEXCOORD2;
                uint  probeIndex: TEXCOORD3;
            };


            StructuredBuffer<float4x4> _InstanceInfoBuffer;

            Varyings vert(Attributes input, uint instanceID : SV_InstanceID)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                float4x4 objectToWorld = _InstanceInfoBuffer[instanceID];
                float3 positionWS = mul(objectToWorld, float4(input.positionOS.xyz, 1.0)).xyz;

                output.positionCS = TransformWorldToHClip(positionWS);
                output.normalWS = normalize(mul((float3x3)objectToWorld, input.normalOS.xyz));

                float3 center = float3(objectToWorld[0][3], objectToWorld[1][3], objectToWorld[2][3]);
                output.center = center;

                // SH
                uint probeIndex = GetProbeIndex(center, _ProbeSpacing, _ProbeGridSize, _VoxelCorner.xyz);
                float3 c[9];
                DecodeSHCoefficientFromVoxel(c, _CoefficientVoxel, probeIndex);
                // decode irradiance
                output.sh = IrradianceSH9(c, output.normalWS) * INV_PI;

                output.probeIndex = probeIndex;
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);

                float3 c[9];
                DecodeSHCoefficientFromVoxel(c, _CoefficientVoxel, input.probeIndex);
                // decode irradiance
                // float3 irradiance = IrradianceSH9(c, dir);
                // float3 Lo = irradiance / PI;
                // return float4(Lo, 1.0);

                return float4(input.sh, 1.0);
            }
            ENDHLSL
        }

    }
}
