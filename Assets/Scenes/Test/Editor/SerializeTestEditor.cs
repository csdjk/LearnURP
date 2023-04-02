
using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Reflection;

[CustomEditor(typeof(SerializeTest))]
public class SerializeTestEditor : Editor
{
    SerializedProperty settings;

    private void OnEnable()
    {
        settings = serializedObject.FindProperty("list");

    }
    public override void OnInspectorGUI()
    {
        SerializeTest asset = (SerializeTest)target;
        base.OnInspectorGUI();
        foreach (var setting in asset.maps)
        {
            EditorGUILayout.LabelField(setting.Key);
            var serializedProperty = settings.GetArrayElementAtIndex(0);

            serializedProperty.serializedObject.Update();
            {
                var settingPropertys = serializedProperty.FindPropertyRelative("setting");
                foreach (SerializedProperty item in settingPropertys)
                {
                    item.serializedObject.Update();
                    EditorGUILayout.PropertyField(item);
                    item.serializedObject.ApplyModifiedProperties();
                }
            }
            serializedProperty.serializedObject.ApplyModifiedProperties();


        }

        if (GUILayout.Button("Add"))
        {

            asset.AddEffect();
        }

    }
}
