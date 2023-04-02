
using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Reflection;

[CustomEditor(typeof(SerializeMe))]
public class SerializeMeEditor : Editor
{
    public override void OnInspectorGUI()
    {
        SerializeMe asset = (SerializeMe)target;
        base.OnInspectorGUI();
        foreach (var instance in asset.m_Instances)
        {
            EditorGUILayout.LabelField(instance.name);
            DrawGUI(instance);
        }
        foreach (var setting in asset.settingDatas)
        {
            EditorGUILayout.LabelField(setting.name);
            DrawGUI(setting.setting);
        }
        if (GUILayout.Button("Add Base"))
            asset.m_Instances.Add(CreateInstance<MyBaseClass>());
        if (GUILayout.Button("Add Child"))
            asset.m_Instances.Add(CreateInstance<ChildClass>());

        if (GUILayout.Button("Add")){

            asset.AddEffect(CreateInstance<SettingAssetsData>());
        }

    }
    public void DrawGUI<T>(T setting)
    {
        if (setting == null)
        {
            return;
        }
        Type type = setting.GetType();
        var fields = type.GetFields(BindingFlags.Instance | BindingFlags.Static | BindingFlags.NonPublic | BindingFlags.Public);
        foreach (FieldInfo field in fields)
        {
            var value = field.GetValue(setting);
            if (field.FieldType == typeof(Color))
            {
                field.SetValue(setting, EditorGUILayout.ColorField(field.Name, (Color)value));
            }
            else if (field.FieldType == typeof(float))
            {
                var attribute = field.GetCustomAttribute<RangeAttribute>();
                if (attribute == null)
                {
                    field.SetValue(setting, EditorGUILayout.FloatField(field.Name, (float)value));
                }
                else
                {
                    field.SetValue(setting, EditorGUILayout.Slider(field.Name, (float)value, attribute.min, attribute.max));
                }
            }
            else if (field.FieldType == typeof(int))
            {
                var attribute = field.GetCustomAttribute<RangeAttribute>();
                if (attribute == null)
                {
                    field.SetValue(setting, EditorGUILayout.IntField(field.Name, (int)value));
                }
                else
                {
                    field.SetValue(setting, EditorGUILayout.IntSlider(field.Name, (int)value, (int)attribute.min, (int)attribute.max));
                }
            }
            else if (field.FieldType == typeof(bool))
            {
                field.SetValue(setting, EditorGUILayout.Toggle(field.Name, (bool)value));
            }
        }
    }
}


[CustomEditor(typeof(ChildClass))]
public class ChildClassEditor : Editor
{
    public override void OnInspectorGUI()
    {
        ChildClass asset = (ChildClass)target;
        // base.OnInspectorGUI();
        asset.m_FloatField = EditorGUILayout.Slider("FloatField", asset.m_FloatField, 0f, 10f);
    }
}