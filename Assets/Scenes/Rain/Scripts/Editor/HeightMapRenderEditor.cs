using System.IO;
using UnityEngine;
using UnityEditor;
using System;

namespace LcLTools
{


    [CustomEditor(typeof(HeightMapRender))]
    public class HeightMapRenderEditor : Editor
    {
        private SerializedObject m_HeightMapSO;
        private SerializedProperty m_HeightMapResolution;
        private SerializedProperty m_LockEdit;
        private SerializedProperty m_SceneHeightMatrixVP;
        private static string m_PrevPath;
        // 预览面板
        public override bool HasPreviewGUI()
        {
            return true;
        }

        void OnEnable()
        {
            m_HeightMapSO = new SerializedObject(target);
            m_HeightMapResolution = m_HeightMapSO.FindProperty("heightMapResolution");
            m_LockEdit = m_HeightMapSO.FindProperty("m_LockEdit");
            m_SceneHeightMatrixVP = m_HeightMapSO.FindProperty("m_SceneHeightMatrixVP");
        }

        public override void OnPreviewGUI(Rect r, GUIStyle background)
        {
            var heightMap = target as HeightMapRender;
            if (!heightMap.SceneHeightRT)
                return;

            float halfWidth = r.width / 2;
            float size = Mathf.Min(halfWidth, r.height);
            GUI.DrawTexture(r, heightMap.SceneHeightRT, ScaleMode.ScaleToFit, false);
        }

        public override void OnInspectorGUI()
        {
            var render = target as HeightMapRender;
            // base.DrawDefaultInspector();
            m_HeightMapSO.Update();
            EditorGUILayout.PropertyField(m_HeightMapResolution);
            EditorGUILayout.BeginHorizontal();
            {
                EditorGUILayout.PropertyField(m_LockEdit);
                GUILayout.Label("勾选后，Camera组件将会被锁定，不能再编辑，防止误操作");
            }
            EditorGUILayout.EndHorizontal();
            if (render.IsChanged())
            {
                GUI.color = Color.yellow;
                GUIContent c = EditorGUIUtility.TrTextContent("Height Camera已经发生变化,请重新渲染一下高度图", EditorGUIUtility.IconContent("console.erroricon").image);
                GUILayout.Label(c);
                GUI.color = Color.white;
            }
            else
            {
                GUI.color = Color.white;
            }
            EditorGUI.BeginDisabledGroup(true);
            {
                EditorGUILayout.PropertyField(m_SceneHeightMatrixVP);
            }
            EditorGUI.EndDisabledGroup();

            // if (GUILayout.Button("Debug"))
            // {
            //     var pos = render.debugPos.position;

            //     Debug.Log($"world pos:{pos} - camera pos:{render.WorldToCameraPosition(pos)} \n project pos:{render.WorldToProjectPosition(pos)}");
            // }
            if (GUILayout.Button("保存高度图", GUILayout.Height(50)))
            {
                // 保存RT
                var tex = render.SceneHeightRT;
                string path = (m_PrevPath == null || m_PrevPath.Equals(String.Empty)) ? Application.dataPath : m_PrevPath;
                tex.name = "HeightMap";
                path = EditorUtility.SaveFilePanel("Save Texture", path, tex ? tex.name : "", "tga");
                if (!path.Equals(String.Empty))
                {
                    m_PrevPath = path;
                    LcLEditorUtilities.SaveRenderTextureToTexture(tex, path);

                    var assetsPath = LcLUtility.AssetsRelativePath(path);
                    AssetDatabase.ImportAsset(assetsPath);

                    var importer = TextureImporter.GetAtPath(assetsPath) as TextureImporter;
                    var setting = importer.GetPlatformTextureSettings("Android");
                    setting.overridden = true;
                    setting.maxTextureSize = tex.width;
                    setting.format = TextureImporterFormat.RGBA32;
                    importer.SetPlatformTextureSettings(setting);
                    importer.mipmapEnabled = false;
                    AssetDatabase.ImportAsset(assetsPath);


                    // // 保存VP矩阵
                    // JsonUtility.ToJson(render.sceneHeightMatrixVP, true);
                    // path = $"{Path.GetDirectoryName(path)}/{Path.GetFileNameWithoutExtension(path)}Data.json";
                    // var content = JsonUtility.ToJson(render.sceneHeightMatrixVP, true);
                    // File.WriteAllText(path, content);
                    AssetDatabase.Refresh();


                    var heightRT = AssetDatabase.LoadAssetAtPath<Texture2D>(assetsPath);
                    // var rain = render.GetComponent<Rain>();
                    // if (rain)
                    // {
                    //     rain.sceneHeightRT = heightRT;
                    // }
                    // render.LockEdit = true;
                    // render.SaveMatrixVP();
                }
            }

            m_HeightMapSO.ApplyModifiedProperties();
        }
    }

}

