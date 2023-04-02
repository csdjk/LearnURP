
using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[Serializable]
public class MyBaseClass : ScriptableObject
{
    // [SerializeField]
    [Range(0, 5)]
    public int m_IntField;
}
[Serializable]
public class ChildClass : MyBaseClass
{
    // [SerializeField]
    [Range(0, 5)]
    public float m_FloatField;
}

[Serializable]
public class SettingAssetsData : ScriptableObject
{
    public string effectName;
    public bool show;

    public PostProcessSetting setting;
}


[Serializable]
public class PostProcessSetting : ScriptableObject
{
    public bool active = true;
}

[Serializable]
public class SettingsTest : PostProcessSetting
{
    public Color color = new Color(1, 1, 1, 1);
    [Range(0, 10)]
    public float threshold = 1;
    [Range(0, 10)]
    public float intensity = 1;
    [Range(0, 8)]
    public int iterations = 5;

    [Range(0, 1)]
    public float scatter = 0.5f;

    [Range(-1f, 5f)]
    public float blurRadius = 0f;
}

[CreateAssetMenu(menuName = "Render/SerializeMe")]
[Serializable]
public class SerializeMe : ScriptableObject
{
    // [SerializeField]
    public List<MyBaseClass> m_Instances;
    public List<SettingAssetsData> settingDatas = new List<SettingAssetsData>();

    [SerializeReference]
    public Dictionary<string, SettingAssetsData> maps = new Dictionary<string, SettingAssetsData>();

    public void OnEnable()
    {
        if (m_Instances == null)
            m_Instances = new List<MyBaseClass>();


        // hideFlags = HideFlags.HideAndDontSave;
    }

    public void AddEffect(SettingAssetsData data)
    {
        data.name = "test";
        data.setting = CreateInstance<SettingsTest>();
        settingDatas.Add(data);

        maps.Add("test", data);

    }
}
