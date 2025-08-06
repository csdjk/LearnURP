using System;
using UnityEngine;
using UnityEditor;
using UnityEngine.Serialization;

[ExecuteAlways]
public class LookDevSetting : MonoBehaviour
{
    public enum LightScenarios
    {
        LowContrast,
        MidContrast,
        HighContrast
    }

    [FormerlySerializedAs("lightMode")] [Header("Light Configuration")]
    public LightScenarios lightScenarios;
    [HideInInspector]
    public Light mainLight; // 主灯光
    public MeshRenderer skyboxRenderer; // 天空盒渲染器
    public ReflectionProbe reflectionProbe;

    public float lowKeyLightIntensity = 0.5f;
    public float lowKeyAmbientIntensity = 1.6f;

    public float midKeyLightIntensity = 1.0f;
    public float midKeyAmbientIntensity = 1.32f;

    public float highKeyLightIntensity = 4f;
    public float highKeyAmbientIntensity = 1.0f;

    [Header("Skybox Materials")]
    public Material lowKeySkybox;
    public Material midKeySkybox;
    public Material highKeySkybox;

    private void OnEnable()
    {
        mainLight = GetComponent<Light>();
        reflectionProbe = FindObjectOfType<ReflectionProbe>();
    }

    public void ApplyLighting()
    {
        switch (lightScenarios)
        {
            case LightScenarios.LowContrast:
                SetLighting(lowKeyLightIntensity, lowKeyAmbientIntensity);
                SetSkyboxMaterial(lowKeySkybox);
                break;
            case LightScenarios.MidContrast:
                SetLighting(midKeyLightIntensity, midKeyAmbientIntensity);
                SetSkyboxMaterial(midKeySkybox);
                break;
            case LightScenarios.HighContrast:
                SetLighting(highKeyLightIntensity, highKeyAmbientIntensity);
                SetSkyboxMaterial(highKeySkybox);
                break;
        }
    }

    private void SetLighting(float lightIntensity, float ambientIntensity)
    {
        if (mainLight)
        {
            mainLight.intensity = lightIntensity;
        }

        RenderSettings.ambientIntensity = ambientIntensity;
        if (reflectionProbe)
        {
            reflectionProbe.intensity = ambientIntensity;
            // reflectionProbe.RenderProbe();
        }
    }

    private void SetSkyboxMaterial(Material skyboxMaterial)
    {
        if (skyboxRenderer && skyboxMaterial)
        {
            skyboxRenderer.sharedMaterial = skyboxMaterial;
        }
    }
}

[CustomEditor(typeof(LookDevSetting))]
public class LookDevSettingEditor : Editor
{
    public override void OnInspectorGUI()
    {
        LookDevSetting lookDev = (LookDevSetting)target;

        // 显示枚举选择
        var content = new GUIContent("Light Scenarios", "高对比度（16）、中对比度（2.6）、低对比度（1.65）的光照场景设置");
        lookDev.lightScenarios = (LookDevSetting.LightScenarios)EditorGUILayout.EnumPopup("Light Scenarios", lookDev.lightScenarios);

        // 显示主灯光
        lookDev.skyboxRenderer = (MeshRenderer)EditorGUILayout.ObjectField("Skybox Renderer", lookDev.skyboxRenderer, typeof(MeshRenderer), true);
        lookDev.reflectionProbe = (ReflectionProbe)EditorGUILayout.ObjectField("Reflection Probe", lookDev.reflectionProbe, typeof(ReflectionProbe), true);

        Material skyboxMaterial;
        // 根据选择的模式显示对应的参数
        switch (lookDev.lightScenarios)
        {
            case LookDevSetting.LightScenarios.LowContrast:
                lookDev.lowKeyLightIntensity = EditorGUILayout.FloatField("Light Intensity", lookDev.lowKeyLightIntensity);
                lookDev.lowKeySkybox = (Material)EditorGUILayout.ObjectField("Skybox", lookDev.lowKeySkybox, typeof(Material), false);
                lookDev.lowKeyAmbientIntensity = EditorGUILayout.FloatField("SkyboxLight Intensity", lookDev.lowKeyAmbientIntensity);
                break;
            case LookDevSetting.LightScenarios.MidContrast:
                lookDev.midKeyLightIntensity = EditorGUILayout.FloatField("Light Intensity", lookDev.midKeyLightIntensity);
                lookDev.midKeySkybox = (Material)EditorGUILayout.ObjectField("Skybox", lookDev.midKeySkybox, typeof(Material), false);
                lookDev.midKeyAmbientIntensity = EditorGUILayout.FloatField("SkyboxLight Intensity", lookDev.midKeyAmbientIntensity);
                break;
            case LookDevSetting.LightScenarios.HighContrast:
                lookDev.highKeyLightIntensity = EditorGUILayout.FloatField("Light Intensity", lookDev.highKeyLightIntensity);
                lookDev.highKeySkybox = (Material)EditorGUILayout.ObjectField("Skybox", lookDev.highKeySkybox, typeof(Material), false);
                lookDev.highKeyAmbientIntensity = EditorGUILayout.FloatField("SkyboxLight Intensity", lookDev.highKeyAmbientIntensity);
                break;
        }

        // 保存更改
        if (GUI.changed)
        {
            lookDev.ApplyLighting();
            EditorUtility.SetDirty(lookDev);
        }
    }
}
