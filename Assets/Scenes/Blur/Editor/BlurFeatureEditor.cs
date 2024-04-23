using UnityEngine;
using UnityEditor;
using UnityEngine.UIElements;
using System;

namespace LcLGame
{
    [CustomEditor(typeof(BlurFeature))]
    public class BlurFeatureEditor : Editor
    {
        private SerializedProperty m_BlurTypeProp;
        private SerializedProperty m_GaussianSettingsProp;
        private SerializedProperty m_BilateralFilterSettingsProp;


        private void OnEnable()
        {
            m_BlurTypeProp = serializedObject.FindProperty("blurType");
            m_GaussianSettingsProp = serializedObject.FindProperty("gaussianSettings");
            m_BilateralFilterSettingsProp = serializedObject.FindProperty("bilateralFilterSettings");
        }
        public override void OnInspectorGUI()
        {
            EditorGUILayout.PropertyField(m_BlurTypeProp);
            switch ((BlurType)m_BlurTypeProp.enumValueIndex)
            {
                case BlurType.GaussianBlur:
                    EditorGUILayout.PropertyField(m_GaussianSettingsProp);
                    break;
                case BlurType.BilateralFilter:
                    EditorGUILayout.PropertyField(m_BilateralFilterSettingsProp);
                    break;
            }

            serializedObject.ApplyModifiedProperties();
        }

    }
}
