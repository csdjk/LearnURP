using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace LcLTools
{
    [ExecuteAlways]
    public class GpuAnimation : MonoBehaviour
    {
        public AnimationType animationType = AnimationType.Skeleton;
        public float speed = 1;
        public GpuAnimationData animationData;
        Material[] m_Materials;

        // 当前动画在第几帧
        public static readonly int frameIndex = Shader.PropertyToID("_FrameIndex");
        // 下一个动画在第几帧
        public static readonly int blendFrameIndex = Shader.PropertyToID("_BlendFrameIndex");
        // 下一个动画的混合程度
        public static readonly int blendProgress = Shader.PropertyToID("_BlendProgress");
        // 混合开关
        public static readonly int blend = Shader.PropertyToID("_Blend");

        private void OnEnable()
        {
            m_Materials = GetComponent<Renderer>().sharedMaterials;
            Play(animationData.clips[0], speed, true).Play(animationData.clips[1], speed, true);
        }

        public GpuAnimation Play(GpuAnimationClip clip, float speed = 1, bool loop = true)
        {


            return this;
        }

        private void Update()
        {


        }

        private void OnDisable()
        {

        }

    }
}
