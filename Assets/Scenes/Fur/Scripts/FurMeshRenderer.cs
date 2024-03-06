using System;
using UnityEngine;

namespace LcLGame
{
    [ExecuteAlways]
    public class FurMeshRenderer : MonoBehaviour
    {
        public Mesh furMesh;
        public Material furMaterial;
        public int instanceCount = 50;

        private Matrix4x4[] matrices; // Matrices for instances

        private void OnValidate()
        {
            matrices = new Matrix4x4[instanceCount];
        }

        void OnEnable()
        {
            furMesh = GetComponent<MeshFilter>().sharedMesh;

            matrices = new Matrix4x4[instanceCount];
        }

        void Update()
        {
            for (int i = 0; i < instanceCount; i++)
            {
                matrices[i] = transform.localToWorldMatrix;
            }
            furMaterial.SetInt("_PassNumber", instanceCount);

            Graphics.DrawMeshInstanced(furMesh, 0, furMaterial, matrices);
        }
    }
}
