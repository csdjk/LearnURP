
using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[Serializable]
public class SettingData
{
    public string effectName;
    public bool show;
    [SerializeReference]
    public Setting setting;
}


[Serializable]
public class Setting
{
    public bool active = true;
}

[Serializable]
public class SettingsA : Setting
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

[Serializable]
public class SerializeTest : MonoBehaviour
{
    [SerializeReference]
    public Dictionary<string, SettingAssetsData> maps = new Dictionary<string, SettingAssetsData>();


    public List<int> list = new List<int>();

    public void OnEnable()
    {
    }

    public void AddEffect()
    {
        maps.Add($"test{maps.Count}", new SettingAssetsData());
    }
}
