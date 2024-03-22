Shader "LcL/ToonOutline"
{
    Properties
    {
        [Toggle(_TOON_HAIR)]_TOON_HAIR ("IsHair", float) = 0
        _OutlineWidth ("Outline Width", Range(0, 0.2)) = 0.05
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 0)
        _OutlineColorIntensity ("Outline Intensity", Range(0, 1)) = 1

        [Toggle(_USE_MATERIAL_VALUES_LUT)]_USE_MATERIAL_VALUES_LUT ("UseMaterialValuesLUT", float) = 1
        [ShowIf(_USE_MATERIAL_VALUES_LUT)][NoScaleOffset]_LightMap ("LightMap", 2D) = "white" { }
        [ShowIf(_USE_MATERIAL_VALUES_LUT)][NoScaleOffset]_MaterialValuesPackLUT ("MaterialValuesPackLUT", 2D) = "white" { }

        _OutlineExtdStart ("Outline Extd Start", Range(0, 10)) = 6.52
        _OutlineExtdMax ("Outline Extd Max", Range(0, 30)) = 18.16
        _OutlineScale ("Outline Scale", Range(0, 1)) = 0.015
        _OutlineOffset ("Outline Offset", Range(0, 1)) = 0

        _ES_OutLineLightedVal ("OutLineLightedVal", Range(0, 1)) = 0.0
        _ES_OutLineDarkenVal ("OutLineDarkenVal", Range(0, 1)) = 0.0

        _OffsetFactor ("Offset Factor", Range(-10, 10)) = -0.3
        _OffsetUnits ("Offset Units", Range(-10, 10)) = -0.3
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline"
        }
        Pass
        {
            Tags
            {
                "LightMode"="ToonOutlineLit"
            }
            Offset [_OffsetFactor], [_OffsetUnits]

            Blend SrcAlpha OneMinusSrcAlpha
            Cull Front
            ZWrite Off

            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #pragma shader_feature _TOON_HAIR
            #pragma shader_feature _USE_MATERIAL_VALUES_LUT

            CBUFFER_START(UnityPerMaterial)
                float4 _OutlineColor;
                float _OutlineWidth;
                float _OutlineOffset;
                float _OutlineScale;
                float _OutlineExtdStart;
                float _OutlineExtdMax;
                float _OutlineColorIntensity;
                float _ES_OutLineDarkenVal;
                float _ES_OutLineLightedVal;
            CBUFFER_END

            TEXTURE2D(_LightMap);
            SAMPLER(sampler_LightMap);

            TEXTURE2D(_MaterialValuesPackLUT);
            SAMPLER(sampler_MaterialValuesPackLUT);

            #pragma vertex ToonOutlineVertex
            #pragma fragment ToonOutlineFragment

            #include "ToonOutlineCore.hlsl"
            ENDHLSL
        }
    }
}
