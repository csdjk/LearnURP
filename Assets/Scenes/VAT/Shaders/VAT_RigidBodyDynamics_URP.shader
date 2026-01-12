Shader "LcL/VAT/RigidBodyDynamics_URP"
{
    Properties
    {
        [Header(Animation Control)]
        [ToggleUI]_EnableAutoPlayback("Enable Auto Playback", Float) = 1
        _FirstFrameGameTime("Game Time at First Frame", Float) = 0
        _ManualDisplayFrame("Manual Display Frame", Float) = 1
        _PlaybackSpeed("Playback Speed", Float) = 1
        _HoudiniFPS("Houdini FPS", Float) = 60

        [Header(Interpolation Settings)]
        [ToggleUI]_EnableInterframeInterpolation("Enable Interframe Interpolation", Float) = 0
        [ToggleUI]_EnableColorInterpolation("Enable Color Interpolation", Float) = 0
        [ToggleUI]_EnableSpareColorInterpolation("Enable Spare Color Interpolation", Float) = 0

        [Header(Normal Settings)]
        [ToggleUI]_SupportSurfaceNormals("Support Surface Normal Maps", Float) = 1
        [ToggleUI]_EnableTwoSidedNormals("Enable Two Sided Normals", Float) = 0

        [Header(VAT Textures)]
        [NoScaleOffset]_PositionTexture("Position Texture", 2D) = "white" {}
        [NoScaleOffset]_PositionTexture2("Position Texture 2 (Optional)", 2D) = "white" {}
        [NoScaleOffset]_RotationTexture("Rotation Texture", 2D) = "white" {}
        [NoScaleOffset]_ColorTexture("Color Texture", 2D) = "white" {}
        [NoScaleOffset]_SpareColorTexture("Spare Color Texture", 2D) = "white" {}

        [Header(Scale Settings)]
        [ToggleUI]_ScaleInPositionAlpha("Piece Scales Are in Position Alpha", Float) = 1
        _GlobalScaleMultiplier("Global Piece Scale Multiplier", Float) = 1

        [Header(Velocity Stretch)]
        [ToggleUI]_EnableVelocityStretch("Enable Stretch by Velocity", Float) = 0
        _VelocityStretchAmount("Stretch by Velocity Amount", Float) = 0

        [Header(Frame Animation)]
        [ToggleUI]_AnimateFirstFrame("Animate First Frame", Float) = 0

        [Header(Shader Features)]
        [Toggle(_ENABLE_COLOR_TEXTURE)]_ENABLE_COLOR_TEXTURE("Enable Color Texture", Float) = 1
        [Toggle(_ENABLE_SMOOTH_TRAJECTORIES)]_ENABLE_SMOOTH_TRAJECTORIES("Enable Smoothly Interpolated Trajectories", Float) = 0
        [Toggle(_ENABLE_NORMAL_TEXTURE)]_ENABLE_NORMAL_TEXTURE("Enable Surface Normal Map", Float) = 0
        [Toggle(_ENABLE_TWO_POSITION_TEXTURES)]_ENABLE_TWO_POSITION_TEXTURES("Positions Require Two Textures", Float) = 0

        [Header(Bounds Info)]
        _FrameCount("Frame Count", Float) = 0
        _BoundMaxX("Bound Max X", Float) = 0
        _BoundMaxY("Bound Max Y", Float) = 0
        _BoundMaxZ("Bound Max Z", Float) = 0
        _BoundMinX("Bound Min X", Float) = 0
        _BoundMinY("Bound Min Y", Float) = 0
        _BoundMinZ("Bound Min Z", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Geometry"
            "ShaderGraphShader" = "true"
        }

        LOD 300

        Pass
        {
            Name "Universal Forward"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex VertexFunction
            #pragma fragment FragmentFunction

            // URP keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK

            // Custom shader features
            #pragma shader_feature_local_vertex _ _ENABLE_TWO_POSITION_TEXTURES
            #pragma shader_feature_local_vertex _ _ENABLE_SMOOTH_TRAJECTORIES
            #pragma shader_feature_local _ _ENABLE_COLOR_TEXTURE
            #pragma shader_feature_local_fragment _ _ENABLE_NORMAL_TEXTURE

            // Unity includes
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"

            // Material Properties
            CBUFFER_START(UnityPerMaterial)
                // Animation control
                float _FirstFrameGameTime;
                float _VelocityStretchAmount;
                float _EnableVelocityStretch;
                float _EnableInterframeInterpolation;
                float _EnableColorInterpolation;
                float _EnableSpareColorInterpolation;
                float _EnableAutoPlayback;
                float _ManualDisplayFrame;
                float _SupportSurfaceNormals;

                // Texture properties
                float4 _PositionTexture_TexelSize;
                float4 _PositionTexture2_TexelSize;
                float4 _RotationTexture_TexelSize;
                float4 _ColorTexture_TexelSize;
                float4 _SpareColorTexture_TexelSize;

                // Animation settings
                float _PlaybackSpeed;
                float _HoudiniFPS;
                float _FrameCount;

                // Bounds
                float _BoundMaxX;
                float _BoundMaxY;
                float _BoundMaxZ;
                float _BoundMinX;
                float _BoundMinY;
                float _BoundMinZ;

                // Additional settings
                float _EnableTwoSidedNormals;
                float _ScaleInPositionAlpha;
                float _GlobalScaleMultiplier;
                float _AnimateFirstFrame;
            CBUFFER_END

            // Texture declarations
            TEXTURE2D(_PositionTexture);
            SAMPLER(sampler_PositionTexture);
            TEXTURE2D(_PositionTexture2);
            SAMPLER(sampler_PositionTexture2);
            TEXTURE2D(_RotationTexture);
            SAMPLER(sampler_RotationTexture);
            TEXTURE2D(_ColorTexture);
            SAMPLER(sampler_ColorTexture);
            TEXTURE2D(_SpareColorTexture);
            SAMPLER(sampler_SpareColorTexture);

            // Vertex input
            struct VertexInput
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 uv1 : TEXCOORD1;  // Piece ID and texture coordinates
                float4 uv2 : TEXCOORD2;  // Additional data
                float4 uv3 : TEXCOORD3;  // More additional data
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            // Vertex output / Fragment input
            struct VertexOutput
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : VAR_POSITION_WS;
                float3 normalWS : VAR_NORMAL_WS;
                float4 tangentWS : VAR_TANGENT_WS;
                float4 uv : VAR_TEXCOORD0;

                #ifdef _ENABLE_COLOR_TEXTURE
                float4 color : VAR_COLOR;
                #endif

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            // Utility functions
            void DecodeQuaternion(float3 xyz, float maxComponent, out float4 quaternion)
            {
                float w = sqrt(1.0 - dot(xyz, xyz));

                switch(maxComponent)
                {
                    case 0:
                        quaternion = float4(xyz.x, xyz.y, xyz.z, w);
                        break;
                    case 1:
                        quaternion = float4(w, xyz.y, xyz.z, xyz.x);
                        break;
                    case 2:
                        quaternion = float4(xyz.x, -w, xyz.z, -xyz.y);
                        break;
                    case 3:
                        quaternion = float4(xyz.x, xyz.y, -w, -xyz.z);
                        break;
                    default:
                        quaternion = float4(xyz.x, xyz.y, xyz.z, w);
                        break;
                }
            }

            float3 RotateByQuaternion(float3 vertex, float4 quaternion)
            {
                float3 temp = cross(quaternion.xyz, vertex) + quaternion.w * vertex;
                return vertex + 2.0 * cross(quaternion.xyz, temp);
            }

            float GetAnimationFrame(float gameTime, bool autoPlayback, float manualFrame)
            {
                if (autoPlayback)
                {
                    float timeOffset = gameTime - _FirstFrameGameTime;
                    float scaledTime = timeOffset * _PlaybackSpeed * _HoudiniFPS;
                    return fmod(scaledTime, _FrameCount);
                }
                else
                {
                    return manualFrame;
                }
            }

            float2 GetVATUV(float pieceID, float frame, float totalFrames)
            {
                float u = fmod(pieceID - 1.0, totalFrames) / totalFrames;
                float v = 1.0 - (floor((pieceID - 1.0) / totalFrames) / totalFrames);
                return float2(u, v);
            }

            // Vertex shader
            VertexOutput VertexFunction(VertexInput input)
            {
                VertexOutput output = (VertexOutput)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                // Extract piece information from UV channels
                float pieceID = input.uv1.x;
                float currentFrame = GetAnimationFrame(_Time.y, _EnableAutoPlayback, _ManualDisplayFrame);

                // Calculate texture coordinates for VAT sampling
                float2 vatUV = GetVATUV(pieceID, currentFrame, _FrameCount);

                // Sample position texture
                float4 positionSample = SAMPLE_TEXTURE2D_LOD(_PositionTexture, sampler_PositionTexture, vatUV, 0);

                #ifdef _ENABLE_TWO_POSITION_TEXTURES
                    float4 positionSample2 = SAMPLE_TEXTURE2D_LOD(_PositionTexture2, sampler_PositionTexture2, vatUV, 0);
                    float3 worldPosition = positionSample.rgb + positionSample2.rgb * 0.01;
                #else
                    float3 worldPosition = positionSample.rgb;
                #endif

                // Sample rotation texture
                float4 rotationSample = SAMPLE_TEXTURE2D_LOD(_RotationTexture, sampler_RotationTexture, vatUV, 0);
                float4 rotation;
                DecodeQuaternion(rotationSample.rgb, floor(rotationSample.a * 4), rotation);

                // Apply scale from position alpha channel if enabled
                float pieceScale = _GlobalScaleMultiplier;
                if (_ScaleInPositionAlpha > 0.5)
                {
                    pieceScale *= positionSample.a;
                }

                // Transform vertex position
                float3 localVertex = input.positionOS.xyz * pieceScale;
                float3 rotatedVertex = RotateByQuaternion(localVertex, rotation);
                float3 finalPosition = rotatedVertex + worldPosition;

                // Transform normal and tangent
                float3 rotatedNormal = RotateByQuaternion(input.normalOS, rotation);
                float3 rotatedTangent = RotateByQuaternion(input.tangentOS.xyz, rotation);

                // Set output values
                output.positionWS = finalPosition;
                output.normalWS = normalize(rotatedNormal);
                output.tangentWS = float4(normalize(rotatedTangent), input.tangentOS.w);
                output.positionCS = TransformWorldToHClip(finalPosition);
                output.uv = input.uv1;

                #ifdef _ENABLE_COLOR_TEXTURE
                    float4 colorSample = SAMPLE_TEXTURE2D_LOD(_ColorTexture, sampler_ColorTexture, vatUV, 0);
                    output.color = colorSample;
                #endif

                return output;
            }

            // Fragment shader
            half4 FragmentFunction(VertexOutput input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                // Setup surface data
                SurfaceData surfaceData = (SurfaceData)0;

                #ifdef _ENABLE_COLOR_TEXTURE
                    surfaceData.albedo = input.color.rgb;
                    surfaceData.alpha = input.color.a;
                #else
                    surfaceData.albedo = float3(0.8, 0.8, 0.8);
                    surfaceData.alpha = 1.0;
                #endif

                surfaceData.metallic = 0.0;
                surfaceData.smoothness = 0.5;
                surfaceData.normalTS = float3(0, 0, 1);
                surfaceData.occlusion = 1.0;
                surfaceData.emission = 0.0;

                // Setup input data
                InputData inputData = (InputData)0;
                inputData.positionWS = input.positionWS;
                inputData.normalWS = normalize(input.normalWS);
                inputData.viewDirectionWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
                inputData.shadowCoord = TransformWorldToShadowCoord(input.positionWS);
                inputData.fogCoord = ComputeFogFactor(input.positionCS.z);
                inputData.vertexLighting = half3(0, 0, 0);
                inputData.bakedGI = half3(0, 0, 0);
                inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
                inputData.shadowMask = half4(1, 1, 1, 1);

                // Calculate lighting
                half4 color = UniversalFragmentPBR(inputData, surfaceData);

                // Apply fog
                color.rgb = MixFog(color.rgb, inputData.fogCoord);

                return color;
            }

            ENDHLSL
        }
    }
}
