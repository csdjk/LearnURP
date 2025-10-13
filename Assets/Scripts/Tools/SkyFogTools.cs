using System;
using UnityEngine;

[ExecuteAlways]
public class SkyFogTools : MonoBehaviour
{
    public bool enableFog = true;
    public Color fogColor = Color.gray;
    [Range(-1f, 1f)]
    public float centerY = 0f;
    [Range(0f, 1f)]
    public float fogSoftness = 0.1f;
    [Range(0f, 1f)]
    public float fogIntensity = 1f;
    [Range(0f, 0.1f)]
    public float fogDensity = 0.04f;

    private void OnValidate()
    {
        // 设置全局雾颜色
        RenderSettings.fogColor = fogColor;
        RenderSettings.fogDensity = fogDensity;
        RenderSettings.fog = enableFog;
        Material currentSkybox = RenderSettings.skybox;

        // 设置天空盒材质参数
        if (currentSkybox != null)
        {
            if (enableFog)
                currentSkybox.EnableKeyword("_SKY_FOG");
            else
                currentSkybox.DisableKeyword("_SKY_FOG");

            currentSkybox.SetColor("_FogColor", fogColor);
            currentSkybox.SetFloat("_CenterY", centerY);
            currentSkybox.SetFloat("_FogSoftness", fogSoftness);
            currentSkybox.SetFloat("_FogIntensity", fogIntensity);
        }
    }
}
