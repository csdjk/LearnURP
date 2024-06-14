using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace LcLTools
{
    [ExecuteAlways]
    public class GpuAnimation : MonoBehaviour
    {
        // 当前动画在第几帧
        public static readonly int FrameIndexID = Shader.PropertyToID("_FrameIndex");

        // 下一个动画在第几帧
        public static readonly int BlendFrameIndexID = Shader.PropertyToID("_BlendFrameIndex");

        // 下一个动画的混合程度
        public static readonly int BlendProgressID = Shader.PropertyToID("_BlendProgress");

        // 混合开关
        public static readonly int BlendID = Shader.PropertyToID("_Blend");

        public AnimationType animationType = AnimationType.Skeleton;
        public float speed = 1;
        public float blendSpeed = 1;
        public GpuAnimationData animationData;
        Material[] m_Materials;

        private GpuAnimationClip m_CurrentClip;
        private float m_CurrentFrame;
        private bool m_IsLooping;
        private bool m_IsBlending;
        private GpuAnimationClip m_NextClip;
        private float m_BlendProgress;

        private void OnEnable()
        {
            m_Materials = GetComponent<Renderer>().sharedMaterials;
            if (animationData)
                Play(animationData.clips[0], speed, true);
        }

        public GpuAnimation Play(GpuAnimationClip clip, float speed = 1, bool loop = true)
        {
            if (m_CurrentClip != null)
            {
                m_IsBlending = true;
                m_NextClip = clip;
                m_BlendProgress = 0;
                foreach (var material in m_Materials)
                {
                    material.SetFloat(BlendFrameIndexID, m_NextClip.startFrame);
                    material.SetFloat(BlendProgressID, 0);
                    material.SetInt(BlendID, 1);
                }
            }
            else
            {
                m_CurrentClip = clip;
                m_CurrentFrame = clip.startFrame;
            }

            m_IsLooping = loop;
            this.speed = speed;

            foreach (var material in m_Materials)
            {
                material.SetInt(FrameIndexID, (int)m_CurrentFrame);
            }

            return this;
        }

        private void Update()
        {
            if (animationData == null || animationData.clips.Length == 0)
                return;

            if (m_IsBlending)
            {
                m_BlendProgress += Time.deltaTime * blendSpeed * 10;
                if (m_BlendProgress >= 1)
                {
                    m_CurrentClip = m_NextClip;
                    m_CurrentFrame = m_NextClip.startFrame;
                    m_IsBlending = false;
                }

                foreach (var material in m_Materials)
                {
                    material.SetFloat(BlendProgressID, m_BlendProgress);
                }
            }
            else
            {
                m_CurrentFrame += Time.deltaTime * m_CurrentClip.frameRate * speed;
                if (m_CurrentFrame >= m_CurrentClip.endFrame)
                {
                    if (m_IsLooping)
                    {
                        m_CurrentFrame = m_CurrentClip.startFrame;
                    }
                    else
                    {
                        m_CurrentFrame = m_CurrentClip.endFrame;
                    }
                }

                foreach (var material in m_Materials)
                {
                    material.SetInt(FrameIndexID, (int)m_CurrentFrame);
                    material.SetInt(BlendID, 0);
                }
            }
        }

        public void Stop()
        {
            m_CurrentClip = null;
            m_CurrentFrame = 0;
            m_IsLooping = false;
            m_IsBlending = false;
            m_NextClip = null;
            m_BlendProgress = 0;
        }

        void OnGUI()
        {
            if (GUI.Button(new Rect(10, 10, 100, 50), "Play0"))
            {
                Play(animationData.clips[0], speed, true);
            }

            if (GUI.Button(new Rect(10, 70, 100, 50), "Play1"))
            {
                Play(animationData.clips[1], speed, true);
            }

            if (GUI.Button(new Rect(10, 130, 100, 50), "Play2"))
            {
                Play(animationData.clips[2], speed, true);
            }
        }
    }
}