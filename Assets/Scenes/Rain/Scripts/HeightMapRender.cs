using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class HeightMapRender : MonoBehaviour
{
    private Camera myCamera;
    private RenderTexture sceneHeightRT;
    private int resolutionValue = 256;

    void OnEnable()
    {
        myCamera = transform.GetComponent<Camera>();

        RenderTextureFormat rtFormat = RenderTextureFormat.ARGB32;
        sceneHeightRT = RenderTexture.GetTemporary(resolutionValue, resolutionValue, 64, rtFormat);
        sceneHeightRT.hideFlags = HideFlags.DontSave;
        Shader.SetGlobalTexture("_SceneDepth", sceneHeightRT);
        myCamera.targetTexture = sceneHeightRT;
    }
    void OnDisable()
    {
        sceneHeightRT.Release();
    }


    void Update()
    {
        // VP 矩阵
        Matrix4x4 ProjectionMatrix = GL.GetGPUProjectionMatrix(myCamera.projectionMatrix, false);
        Matrix4x4 ViewMatrix = myCamera.worldToCameraMatrix;
        Matrix4x4 VP_Matrix = ProjectionMatrix * ViewMatrix;
        Shader.SetGlobalMatrix("_DepthCameraMatrixVP", VP_Matrix);
    }
    private void OnGUI()
    {
        GUI.DrawTexture(new Rect(0, 0, 512, 512), sceneHeightRT, ScaleMode.ScaleToFit, false, 1);
    }
}
