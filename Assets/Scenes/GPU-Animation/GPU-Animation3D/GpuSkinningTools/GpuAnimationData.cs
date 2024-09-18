using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace LcLTools
{
    public enum AnimationType
    {
        // 顶点动画
        Vertices = 0,

        // 骨骼动画
        Skeleton,
    };

    public struct BoneWeightData
    {
        public int boneIndex0;
        public int boneIndex1;
        public int boneIndex2;
        public int boneIndex3;
        public float weight0;
        public float weight1;
        public float weight2;
        public float weight3;
    };

    [Serializable]
    public class GpuAnimationClip
    {
        public string name;
        public int startFrame;
        public int endFrame;
        public float frameRate;

        public GpuAnimationClip(string name, int startFrame, int endFrame, float frameRate)
        {
            this.name = name;
            this.startFrame = startFrame;
            this.endFrame = endFrame;
            this.frameRate = frameRate;
        }
    }


    // [ExecuteAlways]
    [CreateAssetMenu(fileName = "GpuAnimationData", menuName = "LcL/GPU Animation/GpuAnimationData", order = 0)]
    public class GpuAnimationData : ScriptableObject
    {
        public AnimationType animationType = AnimationType.Skeleton;

        public GpuAnimationClip[] clips;
    }
}
