using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class NewBehaviourScript : MonoBehaviour
{
    public AnimationClip clip;
    [Range(0, 2)] public float clipTime;
    public Transform target;
    public Transform local;
    public Transform target2;

    private void OnValidate()
    {
        clip.SampleAnimation(gameObject, clipTime);

        Matrix4x4 mat = local.worldToLocalMatrix * target.parent.localToWorldMatrix;
        Debug.Log(mat);

        Vector3 transformedPosition = mat.MultiplyPoint3x4(target.localPosition);

        target2.localPosition = transformedPosition;
        // Debug.Log(target.localPosition);

    }

    void OnEnable()
    {

        clip.SampleAnimation(gameObject, clipTime);



        
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            clip.SampleAnimation(gameObject, clip.length); //采样最后一帧状态
        }
    }
}