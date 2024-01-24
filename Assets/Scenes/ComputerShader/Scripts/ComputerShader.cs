using UnityEditor;
using UnityEngine;

[ExecuteAlways]
public class ComputerShader : MonoBehaviour
{
    public ComputeShader computeShader;
    public Vector3Int threadGroupSize = new Vector3Int(2, 2, 2);
    public Vector3Int bufferSize = new Vector3Int(2, 2, 2);
    public Vector3Int numThreads = new Vector3Int(2, 2, 2);
    public Color threadGroupColor = Color.green;
    public Color threadColor = Color.red;

    public ComputeBuffer computeBuffer;
    private int m_Kernel;
    [HideInInspector]
    public Vector4[] data;
    GUIStyle m_Style = new GUIStyle("box");

    private void OnValidate()
    {

    }

    // 根据bufferSize 重新计算线程组大小
    public Vector3Int RecalculateThreadGroupSize()
    {
        threadGroupSize.x = Mathf.CeilToInt(bufferSize.x / (float)numThreads.x);
        threadGroupSize.y = Mathf.CeilToInt(bufferSize.y / (float)numThreads.y);
        threadGroupSize.z = Mathf.CeilToInt(bufferSize.z / (float)numThreads.z);
        return threadGroupSize;
    }

    // 根据线程组大小 重新计算bufferSize
    public Vector3Int RecalculateBufferSize()
    {
        bufferSize.x = threadGroupSize.x * numThreads.x;
        bufferSize.y = threadGroupSize.y * numThreads.y;
        bufferSize.z = threadGroupSize.z * numThreads.z;
        RecreateComputeBuffer();
        return bufferSize;
    }


    // 重新生成ComputerBuffer
    public void RecreateComputeBuffer()
    {
        if (computeBuffer != null)
        {
            computeBuffer.Release();
        }
        computeBuffer = new ComputeBuffer(bufferSize.x * bufferSize.y * bufferSize.z, sizeof(float) * 4);
        data = new Vector4[bufferSize.x * bufferSize.y * bufferSize.z];
        computeBuffer.SetData(data);
    }
    private void OnEnable()
    {
        // renderTexture = new RenderTexture(textureSize, textureSize, 0);
        // renderTexture.enableRandomWrite = true;
        // renderTexture.Create();
        RecreateComputeBuffer();

        m_Kernel = computeShader.FindKernel("CSMain");
        m_Style.alignment = TextAnchor.MiddleCenter;
    }
    private void Update()
    {
        if (computeBuffer == null) return;
        computeShader.SetBuffer(m_Kernel, "Result", computeBuffer);
        computeShader.Dispatch(m_Kernel, threadGroupSize.x, threadGroupSize.y, threadGroupSize.z);
    }
    private void OnDisable()
    {
        computeBuffer.Release();
    }
    private void OnGUI()
    {
        if (enabled)
        {
            computeBuffer.GetData(data);
            GUILayout.BeginVertical("box");
            for (int x = 0; x < threadGroupSize.x; x++)
            {
                for (int y = 0; y < threadGroupSize.y; y++)
                {
                    for (int z = 0; z < threadGroupSize.z; z++)
                    {
                        GUILayout.Label($"Thread Group ({x}, {y}, {z}):");
                        GUILayout.BeginHorizontal();
                        for (int i = 0; i < numThreads.x; i++)
                        {
                            for (int j = 0; j < numThreads.y; j++)
                            {
                                for (int k = 0; k < numThreads.z; k++)
                                {
                                    var value = data[(x * threadGroupSize.y * threadGroupSize.z + y * threadGroupSize.z + z) * numThreads.x * numThreads.y * numThreads.z + (i * numThreads.y * numThreads.z + j * numThreads.z + k)];
                                    GUILayout.Label($"({i}, {j}, {k}): {value.x}, {value.y}, {value.z}");
                                }
                            }
                        }
                        GUILayout.EndHorizontal();
                    }
                }
            }
            GUILayout.EndVertical();
        }
    }

    private void OnDrawGizmos()
    {
        if (enabled)
        {
            // data = new Vector4[bufferSize.x * bufferSize.y * bufferSize.z];

            computeBuffer.GetData(data);
            var boxSizeGroup = Vector3.one;
            var boxSizeThread = new Vector3(boxSizeGroup.x / numThreads.x, boxSizeGroup.y / numThreads.y, boxSizeGroup.z / numThreads.z);
            var boxSizeThreadHalf = boxSizeThread / 2;
            int count = 0;
            // 根据线程组来绘制立方体
            for (int x = 0; x < threadGroupSize.x; x++)
            {
                for (int y = 0; y < threadGroupSize.y; y++)
                {
                    for (int z = 0; z < threadGroupSize.z; z++)
                    {
                        Gizmos.color = threadGroupColor;
                        m_Style.normal.textColor = threadGroupColor;
                        var groupPos = new Vector3(x, y, z);
                        Gizmos.DrawWireCube(groupPos, boxSizeGroup);
                        Handles.Label(groupPos, $"{x} {y} {z}", m_Style);

                        var origin = groupPos - boxSizeThreadHalf;
                        // 在每个线程组里绘制每个线程，线程数量由numThreads决定，线程的位置中心点为线程组的中心点，大小为size/numThreads
                        for (int i = 0; i < numThreads.x; i++)
                        {
                            for (int j = 0; j < numThreads.y; j++)
                            {
                                for (int k = 0; k < numThreads.z; k++)
                                {
                                    Gizmos.color = threadColor;
                                    m_Style.normal.textColor = threadColor;
                                    // 局部坐标转换为世界坐标
                                    var threadPos = origin + new Vector3(k * boxSizeThread.x, j * boxSizeThread.y, i * boxSizeThread.z);
                                    Gizmos.DrawWireCube(threadPos, boxSizeThread - new Vector3(0.01f, 0.01f, 0.01f));
                                    var value = data[count];

                                    Handles.Label(threadPos, $"{value.x} {value.y} {value.z}", m_Style);
                                    count++;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
