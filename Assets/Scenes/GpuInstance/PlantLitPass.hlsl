
// #define SHADOW_BIAS_OFFSET 0.01

// struct Varyings
// {
//     float4 positionCS : SV_POSITION;
//     #ifdef _NORMALMAP
//         float4 uv : TEXCOORD0;
//     #else
//         float2 uv : TEXCOORD0;
//     #endif
//     float4 color : COLOR0;
//     float4 positionWS : TEXCOORD2;
//     half3 normalWS : TEXCOORD3;
//     float2 mask : COLOR1;

//     #ifdef _NORMALMAP
//         half3 tangentWS : TEXCOORD4;
//         half3 bitangentWS : TEXCOORD5;
//     #endif

//     #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
//         float4 shadowCoord : TEXCOORD6; // compute shadow coord per-vertex for the main light
//     #endif

//     #ifdef _ADDITIONAL_LIGHTS_VERTEX
//         float3 vertexLight : TEXCOORD7;
//     #endif
//     UNITY_VERTEX_INPUT_INSTANCE_ID
//     UNITY_VERTEX_OUTPUT_STEREO
// };

// Varyings LitPassVertex(Attributes input, uint instanceID : SV_InstanceID)
// {
//     Varyings output;
//     UNITY_SETUP_INSTANCE_ID(input);
//     UNITY_TRANSFER_INSTANCE_ID(input, output);
//     UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

//     //风力影响强度
//     output.mask.r = input.color.r;
//     // 散射半透影响强度
//     output.mask.g = input.color.g;
    
//     float posOffset = ObjectPosRand01();

//     WindSettings wind = InitializeWindSettings(_WindAmbientStrength, _WindSpeed, _WindDirection, _WindSwinging, output.mask.r, _WindGustStrength, _WindGustFreq);
//     VertexInputs vertexInputs = GetVertexInputs(input);
//     VertexOutput vertexData = GetVertexOutput(vertexInputs, posOffset, wind);

//     //Vertex color
//     output.color = ApplyVertexColor(input.positionOS, vertexData.positionWS.xyz, _BaseColor.rgb, AO_MASK, _OcclusionStrength, _HueVariation);
//     //Apply per-vertex light if enabled in pipeline
//     #ifdef _ADDITIONAL_LIGHTS_VERTEX
//         //Pass to fragment shader to apply in Lighting function
//         output.vertexLight.rgb = VertexLighting(vertexData.positionWS, vertexData.normalWS);
//     #endif

//     output.uv.xy = TRANSFORM_TEX(input.uv, _BaseMap);
//     // output.positionWS = float4(vertexData.positionWS.xyz, ComputeFogFactor(vertexData.positionCS.z));
//     output.positionWS = float4(vertexData.positionWS.xyz, 1);
//     output.normalWS = vertexData.normalWS;
//     #ifdef _NORMALMAP
//         output.uv.zw = TRANSFORM_TEX(input.uv, _BumpMap);
//         output.tangentWS = vertexData.tangentWS;
//         output.bitangentWS = vertexData.bitangentWS;
//     #endif

//     #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) //Previously _MAIN_LIGHT_SHADOWS
//         //Only when when shadow cascades are per-pixel
//         #if defined(_SHADOWBIAS_CORRECTION)
//             //Move the shadowed position slightly away from the camera to avoid banding artifacts
//             float3 shadowPos = vertexData.positionWS + (vertexData.viewDir * SHADOW_BIAS_OFFSET);
//         #else
//             float3 shadowPos = vertexData.positionWS;
//         #endif

//         output.shadowCoord = TransformWorldToShadowCoord(shadowPos); //vertexData.positionWS
//     #endif
//     output.positionCS = vertexData.positionCS;

//     return output;
// }


// SurfaceData InitializeSurfaceData(Varyings input, float3 positionWS, WindSettings wind, Light mainLight)
// {
//     SurfaceData surfaceData;

//     float4 mainTex = SampleAlbedoAlpha(input.uv.xy, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
//     float3 albedo = mainTex.rgb;
//     albedo.rgb *= input.color.rgb;

//     //Tint by wind gust
//     wind.gustStrength = 1;
//     float gust = SampleGustMap(positionWS.xyz, wind);
//     albedo += gust * _WindGustTint * 10 * (mainLight.shadowAttenuation) * input.mask.r;

//     surfaceData.albedo = albedo;
//     surfaceData.specular = float3(0, 0, 0);
//     surfaceData.metallic = 0;
//     surfaceData.smoothness = _Smoothness;
//     #ifdef _NORMALMAP
//         surfaceData.normalTS = SampleNormal(input.uv.zw, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
//     #else
//         surfaceData.normalTS = float3(0.5, 0.5, 1);
//     #endif
//     surfaceData.emission = 0;
//     surfaceData.occlusion = 1;
//     surfaceData.alpha = mainTex.a;
//     return surfaceData;
// }

// half4 ForwardPassFragment(Varyings input) : SV_Target
// {
//     UNITY_SETUP_INSTANCE_ID(input);
//     UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
    
//     float3 positionWS = input.positionWS.xyz;

//     //Only when when shadow cascades are per-pixel
//     #if defined(_SHADOWBIAS_CORRECTION) && defined(MAIN_LIGHT_CALCULATE_SHADOWS)
//         //Move the shadowed position slightly away from the camera to avoid banding artifacts
//         half3 viewDirectionWS = SafeNormalize(GetCameraPositionWS() - positionWS);
//         float3 shadowPos = positionWS + (viewDirectionWS * SHADOW_BIAS_OFFSET);
//     #else
//         float3 shadowPos = positionWS;
//     #endif

//     float4 shadowCoord = float4(0, 0, 0, 0);
//     #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
//         shadowCoord = input.shadowCoord;
//     #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
//         shadowCoord = TransformWorldToShadowCoord(shadowPos);
//     #endif

//     Light mainLight = GetMainLight(shadowCoord);
//     WindSettings wind = InitializeWindSettings(_WindAmbientStrength, _WindSpeed, _WindDirection, _WindSwinging, input.mask.r, _WindGustStrength, _WindGustFreq);
//     SurfaceData surfaceData = InitializeSurfaceData(input, positionWS, wind, mainLight);

//     clip(surfaceData.alpha - _Cutoff);


//     #ifdef _NORMALMAP
//         half3 normalWS = TransformTangentToWorld(surfaceData.normalTS, half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz));
//     #else
//         half3 normalWS = input.normalWS;
//     #endif

//     #ifdef _ADDITIONAL_LIGHTS_VERTEX
//         half3 vertexLight = input.vertexLight;
//     #else
//         half3 vertexLight = 0;
//     #endif

//     float translucencyMask = input.mask.g * _Translucency;

//     float3 finalColor = ApplyLighting(surfaceData, mainLight, vertexLight,  normalWS, positionWS, translucencyMask);

//     // float fogFactor = input.positionWS.w;
//     // finalColor = MixFog(finalColor, fogFactor);
//     // finalColor = input.mask.g;

//     return half4(finalColor, surfaceData.alpha);
// }