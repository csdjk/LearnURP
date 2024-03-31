using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering.Universal;
using UnityEditor.Graphs;

namespace UnityEditor.Rendering.Universal
{

    [CustomEditor(typeof(PlanerReflection))]
    public class PlanerReflectionEditor : Editor
    {
        private SerializedProperty m_Settings;
        private SerializedProperty m_TargetPlane;
        private SerializedProperty m_PlaneOffset;
        private SerializedProperty m_ReflectionCamera;

        GUIContent m_RendererIndex = new GUIContent("Renderer");

        private void OnEnable()
        {
            m_Settings = serializedObject.FindProperty("settings");
            m_TargetPlane = serializedObject.FindProperty("targetPlane");
            m_PlaneOffset = serializedObject.FindProperty("planeOffset");
            // m_ReflectionCamera = serializedObject.FindProperty("m_ReflectionCamera");

        }
        public override void OnInspectorGUI()
        {
            var planer = target as PlanerReflection;
            var rpAsset = UniversalRenderPipeline.asset;

            planer.rendererIndex = EditorGUILayout.IntPopup(m_RendererIndex,planer.rendererIndex, rpAsset.rendererDisplayList, rpAsset.rendererIndexList);

            EditorGUILayout.PropertyField(m_Settings);
            EditorGUILayout.PropertyField(m_TargetPlane);
            // EditorGUILayout.PropertyField(m_ReflectionCamera);
            EditorGUILayout.PropertyField(m_PlaneOffset);


            // base.OnInspectorGUI();
            serializedObject.ApplyModifiedProperties();

        }
    }
}
