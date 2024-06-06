using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace LcLTools
{
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

        private void OnEnable()
        {
        }

        private void OnDisable()
        {
        }
    }
}
