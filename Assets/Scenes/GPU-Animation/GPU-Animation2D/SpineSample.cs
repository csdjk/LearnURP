using System;
using System.Collections;
using System.Collections.Generic;
using Spine.Unity;
using UnityEngine;

[ExecuteAlways]
public class SpineSample : MonoBehaviour
{
    public SkeletonAnimation skeletonAnimation;

    public SkeletonDataAsset skeletonDataAsset;
    public Spine.AnimationState state;

    public Spine.AnimationState AnimationState
    {
        get
        {
            Initialize(false);
            return this.state;
        }
    }

    public void Initialize(bool overwrite, bool quiet = false)
    {
        // if (valid && !overwrite)
        //     return;
        // base.Initialize(overwrite, quiet);
        //
        // if (!valid)
        //     return;
        state = new Spine.AnimationState(skeletonDataAsset.GetAnimationStateData());
        // wasUpdatedAfterInit = false;

//         if (!string.IsNullOrEmpty(_animationName))
//         {
//             skeletonDataAsset.GetSkeletonData()
//             var animationObject = skeletonDataAsset.GetSkeletonData(false).FindAnimation(_animationName);
//             if (animationObject != null)
//             {
//                 state.SetAnimation(0, animationObject, loop);
// #if UNITY_EDITOR
//                 if (!Application.isPlaying)
//                     Update(0f);
// #endif
//             }
//         }
    }

    private void OnValidate()
    {
    }

    void OnEnable()
    {
        var skeletonData = skeletonDataAsset.GetSkeletonData(true);
        // foreach (var bone in skeletonData.Bones.Items)
        // {
        //     Debug.Log(bone);
        //     UnityEngine.Debug.Log(bone.GetMatrix4x4());
        // }
        foreach (var bone in skeletonAnimation.skeleton.Bones.Items)
        {
            Debug.Log(bone);
            UnityEngine.Debug.Log(bone.GetMatrix4x4());
        }
    }

    // Update is called once per frame
    void Update()
    {
    }
}