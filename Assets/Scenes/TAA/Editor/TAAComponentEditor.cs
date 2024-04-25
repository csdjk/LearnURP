using UnityEditor;
using UnityEngine;

namespace GameOldBoy.Rendering
{
    [CustomEditor(typeof(TAAComponent))]
    public class TAAComponentEditor : Editor
    {
        SerializedProperty m_Enabled;
        SerializedProperty m_Blend;
        SerializedProperty m_Quality;
        SerializedProperty m_AntiGhosting;
        SerializedProperty m_UseBlurSharpenFilter;
        SerializedProperty m_UseBicubicFilter;
        SerializedProperty m_UseClipAABB;
        SerializedProperty m_UseDilation;
        SerializedProperty m_UseTonemap;
        SerializedProperty m_UseVarianceClipping;
        SerializedProperty m_UseYCoCgSpace;
        SerializedProperty m_Stability;
        SerializedProperty m_SharpenStrength;
        SerializedProperty m_HistorySharpening;
        SerializedProperty m_Use4Tap;
        TAAComponent taa;
        bool showAdvanced;
        TAAQuality _taaQuality_last;

        void OnEnable()
        {
            m_Enabled = serializedObject.FindProperty("Enabled");
            m_Blend = serializedObject.FindProperty("Blend");
            m_Quality = serializedObject.FindProperty("Quality");
            m_AntiGhosting = serializedObject.FindProperty("AntiGhosting");
            m_UseBlurSharpenFilter = serializedObject.FindProperty("UseBlurSharpenFilter");
            m_UseBicubicFilter = serializedObject.FindProperty("UseBicubicFilter");
            m_UseClipAABB = serializedObject.FindProperty("UseClipAABB");
            m_UseDilation = serializedObject.FindProperty("UseDilation");
            m_UseTonemap = serializedObject.FindProperty("UseTonemap");
            m_UseVarianceClipping = serializedObject.FindProperty("UseVarianceClipping");
            m_UseYCoCgSpace = serializedObject.FindProperty("UseYCoCgSpace");
            m_Stability = serializedObject.FindProperty("Stability");
            m_SharpenStrength = serializedObject.FindProperty("SharpenStrength");
            m_HistorySharpening = serializedObject.FindProperty("HistorySharpening");
            m_Use4Tap = serializedObject.FindProperty("Use4Tap");
            taa = (TAAComponent)target;
            _taaQuality_last = taa.Quality;
        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();
            EditorGUILayout.PropertyField(m_Enabled);
            EditorGUILayout.PropertyField(m_Blend);
            EditorGUILayout.PropertyField(m_AntiGhosting);
            EditorGUILayout.PropertyField(m_Quality);
            showAdvanced = EditorGUILayout.Foldout(showAdvanced, "Advanced");
            if (_taaQuality_last != taa.Quality)
            {
                if (taa.Quality == TAAQuality.Custom)
                {
                    showAdvanced = true;
                }
                _taaQuality_last = taa.Quality;
            }
            EditorGUI.indentLevel++;
            switch (taa.Quality)
            {
                case TAAQuality.VeryLow:
                    taa.Use4Tap = true;
                    taa.UseBlurSharpenFilter = false;
                    taa.UseBicubicFilter = false;
                    taa.UseClipAABB = false;
                    taa.UseDilation = false;
                    taa.UseTonemap = false;
                    taa.UseVarianceClipping = false;
                    taa.UseYCoCgSpace = false;
                    GUI.enabled = false;
                    if (showAdvanced)
                    {
                        EditorGUILayout.PropertyField(m_Use4Tap);
                        if (!taa.Use4Tap)
                        {
                            EditorGUILayout.PropertyField(m_UseBlurSharpenFilter, new GUIContent("Use Sharpen Filter"));
                        }
                        EditorGUILayout.PropertyField(m_UseBicubicFilter);
                        EditorGUILayout.PropertyField(m_UseClipAABB);
                        EditorGUILayout.PropertyField(m_UseDilation);
                        EditorGUILayout.PropertyField(m_UseTonemap);
                        EditorGUILayout.PropertyField(m_UseVarianceClipping);
                        EditorGUILayout.PropertyField(m_UseYCoCgSpace, new GUIContent("Use YCoCg Space"));
                    }
                    GUI.enabled = true;
                    break;
                case TAAQuality.Low:
                    taa.Use4Tap = false;
                    taa.UseBlurSharpenFilter = false;
                    taa.UseBicubicFilter = false;
                    taa.UseClipAABB = true;
                    taa.UseDilation = false;
                    taa.UseTonemap = false;
                    taa.UseVarianceClipping = true;
                    taa.UseYCoCgSpace = false;
                    GUI.enabled = false;
                    if (showAdvanced)
                    {
                        EditorGUILayout.PropertyField(m_Use4Tap);
                        if (!taa.Use4Tap)
                        {
                            EditorGUILayout.PropertyField(m_UseBlurSharpenFilter, new GUIContent("Use Sharpen Filter"));
                        }
                        EditorGUILayout.PropertyField(m_UseBicubicFilter);
                        EditorGUILayout.PropertyField(m_UseClipAABB);
                        EditorGUILayout.PropertyField(m_UseDilation);
                        EditorGUILayout.PropertyField(m_UseTonemap);
                        EditorGUILayout.PropertyField(m_UseVarianceClipping);
                        EditorGUILayout.PropertyField(m_UseYCoCgSpace, new GUIContent("Use YCoCg Space"));
                    }
                    GUI.enabled = true;
                    break;
                case TAAQuality.Medium:
                    taa.Use4Tap = false;
                    taa.UseBlurSharpenFilter = false;
                    taa.UseBicubicFilter = false;
                    taa.UseClipAABB = true;
                    taa.UseDilation = false;
                    taa.UseTonemap = true;
                    taa.UseVarianceClipping = true;
                    taa.UseYCoCgSpace = true;
                    GUI.enabled = false;
                    if (showAdvanced)
                    {
                        EditorGUILayout.PropertyField(m_Use4Tap);
                        if (!taa.Use4Tap)
                        {
                            EditorGUILayout.PropertyField(m_UseBlurSharpenFilter, new GUIContent("Use Sharpen Filter"));
                        }
                        EditorGUILayout.PropertyField(m_UseBicubicFilter);
                        EditorGUILayout.PropertyField(m_UseClipAABB);
                        EditorGUILayout.PropertyField(m_UseDilation);
                        EditorGUILayout.PropertyField(m_UseTonemap);
                        EditorGUILayout.PropertyField(m_UseVarianceClipping);
                        EditorGUILayout.PropertyField(m_UseYCoCgSpace, new GUIContent("Use YCoCg Space"));
                    }
                    GUI.enabled = true;
                    break;
                case TAAQuality.High:
                    taa.Use4Tap = false;
                    taa.UseBlurSharpenFilter = true;
                    taa.UseBicubicFilter = true;
                    taa.UseClipAABB = true;
                    taa.UseDilation = true;
                    taa.UseTonemap = true;
                    taa.UseVarianceClipping = true;
                    taa.UseYCoCgSpace = true;
                    GUI.enabled = false;
                    if (showAdvanced)
                    {
                        EditorGUILayout.PropertyField(m_Use4Tap);
                        if (!taa.Use4Tap)
                        {
                            EditorGUILayout.PropertyField(m_UseBlurSharpenFilter, new GUIContent("Use Sharpen Filter"));
                        }
                        EditorGUILayout.PropertyField(m_UseBicubicFilter);
                        EditorGUILayout.PropertyField(m_UseClipAABB);
                        EditorGUILayout.PropertyField(m_UseDilation);
                        EditorGUILayout.PropertyField(m_UseTonemap);
                        EditorGUILayout.PropertyField(m_UseVarianceClipping);
                        EditorGUILayout.PropertyField(m_UseYCoCgSpace, new GUIContent("Use YCoCg Space"));
                    }
                    GUI.enabled = true;
                    break;
                case TAAQuality.Custom:
                    if (showAdvanced)
                    {
                        EditorGUILayout.PropertyField(m_Use4Tap);
                        if (!taa.Use4Tap)
                        {
                            EditorGUILayout.PropertyField(m_UseBlurSharpenFilter, new GUIContent("Use Sharpen Filter"));
                        }
                        EditorGUILayout.PropertyField(m_UseBicubicFilter);
                        EditorGUILayout.PropertyField(m_UseClipAABB);
                        EditorGUILayout.PropertyField(m_UseDilation);
                        EditorGUILayout.PropertyField(m_UseTonemap);
                        EditorGUILayout.PropertyField(m_UseVarianceClipping);
                        EditorGUILayout.PropertyField(m_UseYCoCgSpace, new GUIContent("Use YCoCg Space"));
                    }
                    break;
            }
            EditorGUI.indentLevel--;
            if (taa.UseVarianceClipping)
            {
                EditorGUILayout.PropertyField(m_Stability);
            }
            if (taa.UseBlurSharpenFilter && !taa.Use4Tap)
            {
                EditorGUILayout.PropertyField(m_SharpenStrength);
            }
            if (taa.UseBicubicFilter)
            {
                EditorGUILayout.PropertyField(m_HistorySharpening);
            }
            serializedObject.ApplyModifiedProperties();
        }
    }
}