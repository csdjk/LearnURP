using UnityEngine;
using UnityEditor;
using System.IO;

public class TerrainToObjExporter : EditorWindow
{
    private enum VertexCountLevel
    {
        Low,
        Medium,
        High
    }

    private VertexCountLevel vertexCountLevel = VertexCountLevel.Medium;

    [MenuItem("SceneTool/Terrain to OBJ")]
    public static void ShowWindow()
    {
        GetWindow<TerrainToObjExporter>("Terrain to OBJ");
    }

    private void OnGUI()
    {
        GUILayout.Label("选择需要导出的地形", EditorStyles.boldLabel);

        vertexCountLevel = (VertexCountLevel)EditorGUILayout.EnumPopup("顶点数量", vertexCountLevel);

        if (GUILayout.Button("Export"))
        {
            GameObject[] selectedObjects = Selection.gameObjects;
            string path = EditorUtility.SaveFilePanel("Save Terrain as OBJ", "", "terrain.obj", "obj");
            if (!string.IsNullOrEmpty(path))
            {
                using (StreamWriter sw = new StreamWriter(path, false))
                {
                    int totalVertices = 0;
                    for (int i = 0; i < selectedObjects.Length; i++)
                    {
                        Terrain terrain = selectedObjects[i].GetComponent<Terrain>();
                        if (terrain != null)
                        {
                            totalVertices += ExportToObj(sw, terrain, totalVertices);
                        }
                        else
                        {
                            Debug.LogError("没有地形被选中==========");
                        }
                    }
                }
            }
        }
    }

    private int ExportToObj(StreamWriter sw, Terrain terrain, int startVertexIndex)
    {
        TerrainData terrainData = terrain.terrainData;
        Vector3 terrainSize = terrainData.size;

        int resolution = GetResolution();

        for (int y = 0; y < resolution; y++)
        {
            for (int x = 0; x < resolution; x++)
            {
                float height = terrainData.GetInterpolatedHeight(y / (float)(resolution - 1), x / (float)(resolution - 1));
                Vector3 localVertex = new Vector3(
                    x / (float)(resolution - 1) * terrainSize.x,
                    height / terrainData.size.y * terrainSize.y,
                    y / (float)(resolution - 1) * terrainSize.z
                );
                Vector3 worldVertex = terrain.transform.TransformPoint(localVertex);
                sw.Write(string.Format("v {0} {1} {2}\n", worldVertex.x, worldVertex.y, worldVertex.z));
            }
        }

        for (int y = 0; y < resolution - 1; y++)
        {
            for (int x = 0; x < resolution - 1; x++)
            {
                int index1 = startVertexIndex + (y * resolution) + x;
                int index2 = startVertexIndex + (y * resolution) + x + 1;
                int index3 = startVertexIndex + ((y + 1) * resolution) + x;
                int index4 = startVertexIndex + ((y + 1) * resolution) + x + 1;

                sw.Write(string.Format("f {0} {1} {2}\n", index1 + 1, index2 + 1, index3 + 1));
                sw.Write(string.Format("f {0} {1} {2}\n", index2 + 1, index4 + 1, index3 + 1));
            }
        }

        return resolution * resolution;
    }

    private int GetResolution()
    {
        switch (vertexCountLevel)
        {
            case VertexCountLevel.Low:
                return 64;
            case VertexCountLevel.Medium:
                return 128;
            case VertexCountLevel.High:
                return 256;
            default:
                return 128;
        }
    }
}