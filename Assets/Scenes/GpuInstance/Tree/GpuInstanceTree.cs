

using UnityEngine;
using System.Collections;
using System.Collections.Generic;

[ExecuteInEditMode]
public class GpuInstanceTree : MonoBehaviour
{
    public int seed = 1;

    [Range(1, 10000)]
    public int treeCount = 1;
    [Range(1, 1000)]
    public float radius = 100;
    [Range(1, 10000)]
    public float boundsRadius = 10000;
    public Vector2 scaleRange = Vector2.one;
    public Mesh treeMesh;
    public Material treeLeavesMaterial;
    public Material treeTrunkMaterial;


    private int cachedTreeCount = -1;
    private ComputeBuffer treeBuffer;
    private ComputeBuffer treeTrunkBuffer;

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

        Graphics.DrawMeshInstancedProcedural(treeMesh, 0, treeTrunkMaterial, new Bounds(Vector3.zero, new Vector3(boundsRadius, boundsRadius, boundsRadius)), treeCount);
        Graphics.DrawMeshInstancedProcedural(treeMesh, 1, treeLeavesMaterial, new Bounds(Vector3.zero, new Vector3(boundsRadius, boundsRadius, boundsRadius)), treeCount);
    }

    [ContextMenu("UpdateTreeBuffers")]
    private void ForceUpdateTreeBuffer()
    {
        UpdateBuffers();
    }

    void UpdateBuffers()
    {

        if (treeBuffer != null)
            treeBuffer.Release();
        if (treeTrunkBuffer != null)
            treeTrunkBuffer.Release();
        List<TreeInfo> treeInfos = new List<TreeInfo>();

        for (int i = 0; i < treeCount; i++)
        {
            Vector3 randPos = Random.insideUnitSphere * radius;
            randPos.y = 0;
            // 旋转
            float rot = Random.Range(0, 360);
            // Quaternion upToNormal = Quaternion.FromToRotation(Vector3.up, Ve);

            // 缩放
            float randScale = Random.Range(scaleRange.x, scaleRange.y);
            var localToWorld = Matrix4x4.TRS(transform.TransformPoint(randPos), Quaternion.Euler(0, rot, 0), new Vector3(randScale, randScale, randScale));

            //贴图参数，暂时不用管
            Vector2 texScale = Vector2.one;
            Vector2 texOffset = Vector2.zero;
            Vector4 texParams = new Vector4(texScale.x, texScale.y, texOffset.x, texOffset.y);

            var treeInfo = new TreeInfo()
            {
                localToWorld = localToWorld,
                texParams = texParams
            };
            treeInfos.Add(treeInfo);
        }

        treeBuffer = new ComputeBuffer(treeCount, 64 + 16);
        treeBuffer.SetData(treeInfos);
        treeLeavesMaterial.SetBuffer("_InstanceInfoBuffer", treeBuffer);

        treeTrunkBuffer = new ComputeBuffer(treeCount, 64 + 16);
        treeTrunkBuffer.SetData(treeInfos);
        treeTrunkMaterial.SetBuffer("_InstanceInfoBuffer", treeTrunkBuffer);

        cachedTreeCount = treeCount;
    }

    void OnDisable()
    {
        if (treeBuffer != null)
            treeBuffer.Release();
        treeBuffer = null;

        if (treeTrunkBuffer != null)
            treeTrunkBuffer.Release();
        treeTrunkBuffer = null;
    }



    public struct TreeInfo
    {
        public Matrix4x4 localToWorld;
        public Vector4 texParams;
    }
}