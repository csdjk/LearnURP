using UnityEditor;
using UnityEditor.UIElements;
using UnityEngine;
using UnityEngine.UIElements;

[CustomEditor(typeof(ComputerShaderVisualizer))]
public class ComputerShaderEditor : Editor
{
    private SerializedProperty computeShaderProp;
    private SerializedProperty threadGroupSizeProp;
    private SerializedProperty bufferSizeProp;
    private SerializedProperty numThreadsProp;
    private SerializedProperty threadGroupColorProp;
    private SerializedProperty threadColorProp;
    private void OnEnable()
    {
        computeShaderProp = serializedObject.FindProperty("computeShader");
        threadGroupSizeProp = serializedObject.FindProperty("threadGroupSize");
        bufferSizeProp = serializedObject.FindProperty("bufferSize");
        numThreadsProp = serializedObject.FindProperty("numThreads");
        threadGroupColorProp = serializedObject.FindProperty("threadGroupColor");
        threadColorProp = serializedObject.FindProperty("threadColor");
    }

    public override VisualElement CreateInspectorGUI()
    {
        var root = new VisualElement();
        var cs = (ComputerShaderVisualizer)target;
        var computeShaderField = new PropertyField(computeShaderProp);
        var threadGroupSizeField = new PropertyField(threadGroupSizeProp);
        threadGroupSizeField.RegisterValueChangeCallback((evt) =>
        {
            cs.RecalculateBufferSize();
        });
        var bufferSizeField = new PropertyField(bufferSizeProp);
        bufferSizeField.RegisterValueChangeCallback((evt) =>
        {
            cs.RecalculateThreadGroupSize();
        });
        var numThreadsField = new PropertyField(numThreadsProp)
        {
            label = "NumThreads(对应CS中的[numthreads(x, y, z)])"
        };
        var threadGroupColorField = new PropertyField(threadGroupColorProp);
        var threadColorField = new PropertyField(threadColorProp);
        root.Add(computeShaderField);
        root.Add(threadGroupSizeField);
        root.Add(bufferSizeField);
        root.Add(numThreadsField);
        root.Add(threadGroupColorField);
        root.Add(threadColorField);

        // add button
        var button = new Button(() =>
        {
            var window = EditorWindow.GetWindow<ComputerShaderWindow>();
            window.Initialize(cs.threadGroupSize, cs.numThreads, cs.data);
            window.Show();
        })
        {
            text = "Debug"
        };
        root.Add(button);
        return root;
    }
}


public class ComputerShaderWindow : EditorWindow
{
    private Vector3Int threadGroupSize;
    private Vector3Int numThreads;
    private Vector4[] data;
    private int selectedGroupIndex = -1;

    public void Initialize(Vector3Int threadGroupSize, Vector3Int numThreads, Vector4[] data)
    {
        this.threadGroupSize = threadGroupSize;
        this.numThreads = numThreads;
        this.data = data;
        this.selectedGroupIndex = -1;
    }


    private void OnGUI()
    {
        GUILayout.BeginHorizontal();
        DrawGroupList();
        DrawThreadList();
        GUILayout.EndHorizontal();
    }

    private void DrawGroupList()
    {
        GUILayout.BeginVertical(GUILayout.Width(200));
        GUILayout.Label("Thread Groups");
        for (int z = 0; z < threadGroupSize.z; z++)
        {
            for (int y = 0; y < threadGroupSize.y; y++)
            {
                for (int x = 0; x < threadGroupSize.x; x++)
                {
                    int index = x + y * threadGroupSize.x + z * threadGroupSize.x * threadGroupSize.y;
                    if (GUILayout.Button($"({x}, {y}, {z})", selectedGroupIndex == index ? "ButtonSelected" : "Button"))
                    {
                        selectedGroupIndex = index;
                    }
                }
            }
        }
        GUILayout.EndVertical();
    }

    private void DrawThreadList()
    {
        if (selectedGroupIndex >= 0)
        {
            GUILayout.BeginVertical();
            GUILayout.Label($"Threads in Group ({selectedGroupIndex % threadGroupSize.x}, {(selectedGroupIndex / threadGroupSize.x) % threadGroupSize.y}, {selectedGroupIndex / (threadGroupSize.x * threadGroupSize.y)})");
            int startIndex = selectedGroupIndex * numThreads.x * numThreads.y * numThreads.z;
            for (int i = 0; i < numThreads.x; i++)
            {
                for (int j = 0; j < numThreads.y; j++)
                {
                    for (int k = 0; k < numThreads.z; k++)
                    {
                        Vector4 value = data[startIndex + (i * numThreads.y * numThreads.z + j * numThreads.z + k)];
                        GUILayout.Label($"({i}, {j}, {k}): {value.x}, {value.y}, {value.z}");
                    }
                }
            }
            GUILayout.EndVertical();
        }
    }
}