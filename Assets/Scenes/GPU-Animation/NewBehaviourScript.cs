using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NewBehaviourScript : MonoBehaviour
{
    public Animation mAmt;
    public AnimationClip clip;

    void Start()
    {
        // clip = mAmt.clip;
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
