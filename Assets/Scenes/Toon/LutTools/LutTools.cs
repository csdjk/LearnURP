using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[ExecuteAlways]
public class LutTools : MonoBehaviour
{
    public Vector3 lightVector = new Vector3(0.0f, 0.43359f, 0.81641f);
    public Material material;
    public Texture2D source;
    public RenderTexture target;
    private void OnEnable()
    {
        Quaternion rotation = Quaternion.LookRotation(lightVector);
        Vector3 eulerAngle = rotation.eulerAngles;
        Debug.Log("Euler Angle: " + eulerAngle);
        Debug.Log("Forward " + transform.forward);
    }

    private void Update()
    {
        CopyTextureToRT();
    }
    void CopyTextureToRT()
    {
        // 确保source和target都已经被初始化
        if (source != null && target != null && material != null)
        {
            Graphics.Blit(source, target, material);
        }
    }

}
