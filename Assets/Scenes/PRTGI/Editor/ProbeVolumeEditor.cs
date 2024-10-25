using UnityEngine;
using UnityEditor;
using System;
using LcLTools;
using UnityEngine.SceneManagement;

namespace LcLGame.PRTGI
{
    [CustomEditor(typeof(ProbeVolume))]
    public class ProbeVolumeEditor : Editor
    {
        Type m_LightProbeVisualization;
        Type m_PointEditor;
        Mesh m_ProbeMesh;
        ProbeVolume m_ProbeVolume;

        // SerializedProperty m_ProbeDataProperty;
        private ProbeData m_ProbeData { get; set; }

        private void OnEnable()
        {
            m_LightProbeVisualization = ReflectionUtils.FindTypeByName("UnityEditor.LightProbeVisualization");
            m_PointEditor = ReflectionUtils.FindTypeByName("UnityEditor.PointEditor");
            m_ProbeVolume = target as ProbeVolume;
            m_ProbeMesh = Resources.GetBuiltinResource<Mesh>("Sphere.fbx");


            // m_ProbeDataProperty = serializedObject.FindProperty("probeData");
        }

        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();
            var rendererData = RenderPipelineAssetManager.GetRendererDataByName("PRTGI_Renderer_Bake");
            var bakeFeature = rendererData.GetRendererFeatures<ProbeBakeFeature>();
            if (GUILayout.Button("Generate Probes"))
            {
                m_ProbeVolume.GenerateProbes();
            }


            if (GUILayout.Button("Bake Probes"))
            {
                CheckProbeData();
                m_ProbeVolume.RenderCubemap();
            }
        }

        void CheckProbeData()
        {
            if (m_ProbeVolume.probeData == null)
            {
                var probeData = ScriptableObject.CreateInstance<ProbeData>();
                probeData.name = "ProbeVolumeData";
                //在当前场景目录下创建资源文件
                var lastActiveScene = SceneManager.GetActiveScene().path;
                var assetPath = LcLEditorUtilities.CreatePathInAssetDirectory(lastActiveScene, "ProbeVolumeData.asset");

                assetPath = AssetDatabase.GenerateUniqueAssetPath(assetPath);
                AssetDatabase.CreateAsset(probeData, assetPath);
                AssetDatabase.SaveAssets();
                m_ProbeVolume.probeData = probeData;
            }
        }
        // private void OnSceneGUI()
        // {
        //     var matrices = m_ProbeVolume.ProbePositions.Select(pos =>
        //         Matrix4x4.TRS(m_ProbeVolume.transform.TransformPoint(pos), Quaternion.identity,
        //             Vector3.one * m_ProbeVolume.scale)).ToArray();
        //     Graphics.DrawMeshInstanced(m_ProbeMesh, 0, m_ProbeVolume.material, matrices);
        // }
    }
}
