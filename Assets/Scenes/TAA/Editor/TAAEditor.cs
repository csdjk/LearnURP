using UnityEditor;
using UnityEngine;

namespace GameOldBoy.Rendering
{
    [CustomEditor(typeof(TAA))]
    public class TAAEditor : Editor
    {
        SerializedProperty m_PreviewInSceneView;
        SerializedProperty m_UseMotionVector;
        SerializedProperty m_RenderingMode;
        SerializedProperty m_WorkOnPrepass;
        SerializedProperty m_IgonreTransparentObject;
        SerializedProperty m_Use32Bit;
        SerializedProperty m_Shader;
        TAA taa;

        void OnEnable()
        {
            m_PreviewInSceneView = serializedObject.FindProperty("PreviewInSceneView");
            m_UseMotionVector = serializedObject.FindProperty("UseMotionVector");
            m_RenderingMode = serializedObject.FindProperty("RenderingMode");
            m_WorkOnPrepass = serializedObject.FindProperty("WorkOnPrepass");
            m_IgonreTransparentObject = serializedObject.FindProperty("IgonreTransparentObject");
            m_Use32Bit = serializedObject.FindProperty("Use32Bit");
            m_Shader = serializedObject.FindProperty("Shader");
            taa = (TAA) target;
        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();
            EditorGUILayout.LabelField("Option", EditorStyles.boldLabel);
            EditorGUI.indentLevel++;
            EditorGUILayout.PropertyField(m_PreviewInSceneView, new GUIContent("Preview in Scene View"));
#if UNITY_2021_2_OR_NEWER
            EditorGUILayout.PropertyField(m_UseMotionVector, new GUIContent("Use Motion Vector Texture"));
            EditorGUILayout.PropertyField(m_RenderingMode);
#else
            GUI.enabled = false;
            EditorGUILayout.PropertyField(m_UseMotionVector, new GUIContent("Use Motion Vector Texture"));
            EditorGUILayout.PropertyField(m_RenderingMode);
            GUI.enabled = true;
            taa.UseMotionVector = false;
            taa.RenderingMode = RenderingMode.Forward;
            EditorGUILayout.HelpBox("Motion Vectors feature and Deferred Path requires Unity 2021.2 and URP 12.", MessageType.Warning);
#endif
            EditorGUILayout.PropertyField(m_WorkOnPrepass);
            EditorGUILayout.PropertyField(m_IgonreTransparentObject);
            EditorGUI.indentLevel--;
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Debug", EditorStyles.boldLabel);
            EditorGUI.indentLevel++;
            EditorGUILayout.PropertyField(m_Use32Bit, new GUIContent("Use 32-bit Color Depth per Channel"));
            GUI.enabled = false;
            EditorGUILayout.PropertyField(m_Shader);
            GUI.enabled = true;
            EditorGUI.indentLevel--;
            serializedObject.ApplyModifiedProperties();
        }
    }
}
