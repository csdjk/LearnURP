using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ExecuteAlways]
public class Test : MonoBehaviour
{
    public Vector3 lightVector = new Vector3(0.0f, 0.43359f, 0.81641f);
    private void OnEnable()
    {
        Quaternion rotation = Quaternion.LookRotation(lightVector);
        Vector3 eulerAngle = rotation.eulerAngles;
        Debug.Log("Euler Angle: " + eulerAngle);

        Debug.Log(transform.forward);
    }


}
