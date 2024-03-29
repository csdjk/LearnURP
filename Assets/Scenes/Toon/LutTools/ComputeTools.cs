using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[ExecuteAlways]
public class ComputeTools : MonoBehaviour
{
    public Vector3 lightVector = new Vector3(0.0f, 0.43359f, 0.81641f);

    public Matrix4x4 matrixM;
    private void OnEnable()
    {
        //根据光照向量计算旋转角度
        Quaternion rotation = Quaternion.LookRotation(lightVector);
        Vector3 eulerAngle = rotation.eulerAngles;
        Debug.Log("Euler Angle: " + eulerAngle);
        Debug.Log("Forward " + transform.forward);


        Matrix4x4 matrixM = new Matrix4x4(
                  new Vector4(-0.02951f, -0.9974f, -0.06578f, 0.0f),
                  new Vector4(0.35816f, -0.07199f, 0.93088f, 0.0f),
                  new Vector4(-0.9332f, 0.00391f, 0.35935f, 0.0f),
                  new Vector4(-0.00487f, 1.48987f, -0.02953f, 1.0f)
              );

        CalculateModelScaleRotationCenter(matrixM);

    }


    private void CalculateModelScaleRotationCenter(Matrix4x4 matrixM)
    {

        // 获取模型的缩放值
        Vector3 scale = new Vector3(matrixM.GetColumn(0).magnitude, matrixM.GetColumn(1).magnitude, matrixM.GetColumn(2).magnitude);
        Debug.Log("Scale: " + scale);

        // 获取模型的旋转角度
        Quaternion rotation = matrixM.rotation;
        Vector3 eulerAngle = rotation.eulerAngles;
        Debug.Log("Euler Angle: " + eulerAngle);

        // 获取模型中心的世界坐标
        Vector3 modelCenterWorld = matrixM.GetColumn(3);
        Debug.Log("Model Center World: " + modelCenterWorld);
    }

}
