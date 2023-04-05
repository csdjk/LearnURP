

using UnityEngine;
using System.Collections;
using System.Collections.Generic;

[ExecuteInEditMode]
public class GpuInstanceGrass : MonoBehaviour
{
    public int seed = 1;

    [Range(1, 100000)]
    public int grassCount = 1;
    [Range(1, 1000)]
    public float radius = 100;

    [Range(1, 10000)]
    public float boundsRadius = 10000;

    public Vector3 grassScale = Vector3.one;

    public Mesh treeMesh;
    public Material grassMaterial;

    public Transform playerTrs;
    // 碰撞范围
    [Range(0, 10)]
    public float crashRadius;
    // 下压强度
    [Range(0, 100)]
    public float pushStrength;

    private int cachedTreeCount = -1;
    private ComputeBuffer grassBuffer;

    void Start()
    {
        UpdateBuffers();
    }

    void Update()
    {

        // if (cachedTreeCount != treeCount)
        // {
        Random.InitState(seed);
        UpdateBuffers();
        // }

        if (playerTrs)
        {
            Vector4 playerPos = playerTrs.TransformPoint(Vector3.zero);
            playerPos.w = crashRadius;
            grassMaterial.SetVector("_PlayerPos", playerPos);
            grassMaterial.SetFloat("_PushStrength", pushStrength);
        }
        Graphics.DrawMeshInstancedProcedural(treeMesh, 0, grassMaterial, new Bounds(Vector3.zero, new Vector3(boundsRadius, boundsRadius, boundsRadius)), grassCount);
    }

    [ContextMenu("UpdateTreeBuffers")]
    private void ForceUpdateTreeBuffer()
    {
        UpdateBuffers();
    }

    void UpdateBuffers()
    {


        if (grassBuffer != null)
            grassBuffer.Release();
        List<GrassInfo> grassInfos = new List<GrassInfo>();

        for (int i = 0; i < grassCount; i++)
        {
            Vector3 randPos = Random.insideUnitSphere * radius;
            randPos.y = 0;
            // 旋转
            float rot = Random.Range(0, 360);
            // Quaternion upToNormal = Quaternion.FromToRotation(Vector3.up, Ve);

            // 缩放
            // float randScale = Random.Range(0.2f, 0.3f);
            var localToWorld = Matrix4x4.TRS(transform.TransformPoint(randPos), Quaternion.Euler(0, rot, 0), grassScale);

            //贴图参数，暂时不用管
            Vector2 texScale = Vector2.one;
            Vector2 texOffset = Vector2.zero;
            Vector4 texParams = new Vector4(texScale.x, texScale.y, texOffset.x, texOffset.y);

            var treeInfo = new GrassInfo()
            {
                localToWorld = localToWorld,
                texParams = texParams
            };
            grassInfos.Add(treeInfo);
        }

        grassBuffer = new ComputeBuffer(grassCount, 64 + 16);
        grassBuffer.SetData(grassInfos);
        grassMaterial.SetBuffer("_InstanceInfoBuffer", grassBuffer);

        cachedTreeCount = grassCount;
    }

    void OnDisable()
    {
        if (grassBuffer != null)
            grassBuffer.Release();
        grassBuffer = null;
    }



    public struct GrassInfo
    {
        public Matrix4x4 localToWorld;
        public Vector4 texParams;
    }


    void OnDrawGizmosSelected()
    {
        // Draw a yellow cube at the transform position
        Gizmos.color = Color.red;
        Gizmos.DrawWireCube(transform.position, new Vector3(boundsRadius, boundsRadius, boundsRadius));
    }
}