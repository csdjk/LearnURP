using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEngine.Serialization;
using Random = UnityEngine.Random;

namespace LcLTools
{
    public struct InstanceInfo
    {
        public Matrix4x4 localToWorld;
        // public Vector4 texParams;
    }

    [ExecuteAlways]
    public class GpuAnimationInstance : MonoBehaviour
    {
        // 当前动画在第几帧
        public static readonly int FrameIndexID = Shader.PropertyToID("_FrameIndex");

        // 下一个动画在第几帧
        public static readonly int BlendFrameIndexID = Shader.PropertyToID("_BlendFrameIndex");

        // 下一个动画的混合程度
        public static readonly int BlendProgressID = Shader.PropertyToID("_BlendProgress");

        // 混合开关
        public static readonly int BlendID = Shader.PropertyToID("_Blend");
        public static readonly int InstanceInfoBufferID = Shader.PropertyToID("_InstanceInfoBuffer");

        public AnimationType animationType = AnimationType.Skeleton;
        public float speed = 1;
        public float blendSpeed = 1;
        public GpuAnimationData animationData;
        public Mesh instanceMesh;
        public Material[] instanceMaterials;
        public int instanceCount = 1000;
        public float randRadius = 100;
        ComputeBuffer computeBuffer;
        List<InstanceInfo> instanceInfos = new List<InstanceInfo>();
        [Range(1, 10000)] public float boundsRadius = 10000;


        GpuAnimationClip m_CurrentClip;
        GpuAnimationClip m_NextClip;
        float m_CurrentFrame;
        bool m_IsLooping;
        bool m_IsBlending;
        float m_BlendProgress;

        void OnEnable()
        {
            Play(animationData.clips[0], speed, true);
            UpdateBuffers();
        }

        public void Play(GpuAnimationClip clip, float speed = 1, bool loop = true)
        {
            if (m_CurrentClip != null)
            {
                m_IsBlending = true;
                m_NextClip = clip;
                m_BlendProgress = 0;
                foreach (var mat in instanceMaterials)
                {

                    if (mat)
                    {
                        mat.SetFloat(BlendFrameIndexID, m_NextClip.startFrame);
                        mat.SetFloat(BlendProgressID, 0);
                        mat.SetInt(BlendID, 1);
                    }
                }
            }
            else
            {
                m_CurrentClip = clip;
                m_CurrentFrame = clip.startFrame;
            }

            m_IsLooping = loop;
            this.speed = speed;
            foreach (var mat in instanceMaterials)
            {
                if (mat == null) continue;

                mat.SetInt(FrameIndexID, (int)m_CurrentFrame);
            }
        }

        public void UpdateAnimation()
        {
            if (m_IsBlending)
            {
                m_BlendProgress += Time.deltaTime * blendSpeed * 10;
                if (m_BlendProgress >= 1)
                {
                    m_CurrentClip = m_NextClip;
                    m_CurrentFrame = m_NextClip.startFrame;
                    m_IsBlending = false;
                }

                foreach (var mat in instanceMaterials)
                {
                    if (mat == null) continue;
                    mat.SetFloat(BlendProgressID, m_BlendProgress);
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

                foreach (var mat in instanceMaterials)
                {
                    if (mat)
                    {
                        mat.SetInt(FrameIndexID, (int)m_CurrentFrame);
                        mat.SetInt(BlendID, 0);
                    }
                }
            }
        }

        void Update()
        {
            if (animationData == null || animationData.clips.Length == 0 || instanceCount <= 0 || instanceMaterials.Length == 0)
                return;

            UpdateAnimation();
            UpdateBuffers();
            for (int i = 0; i < instanceMaterials.Length; i++)
            {
                if (instanceMaterials[i])
                {
                    Graphics.DrawMeshInstancedProcedural(instanceMesh, i, instanceMaterials[i], new Bounds(Vector3.zero, new Vector3(boundsRadius, boundsRadius, boundsRadius)), instanceCount);
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

        void UpdateBuffers()
        {
            if (computeBuffer != null)
                computeBuffer.Release();

            Random.InitState(0);
            instanceInfos.Clear();

            for (int i = 0; i < instanceCount; i++)
            {
                Vector3 randPos = Random.insideUnitSphere * randRadius;
                randPos.y = 0;
                // 旋转
                float rot = Random.Range(0, 360);

                // 缩放
                var localToWorld = Matrix4x4.TRS(transform.TransformPoint(randPos), Quaternion.Euler(0, rot, 0), Vector3.one);

                var treeInfo = new InstanceInfo()
                {
                    localToWorld = localToWorld,
                    // texParams = texParams
                };
                instanceInfos.Add(treeInfo);
            }

            computeBuffer = new ComputeBuffer(instanceCount, 64 + 0);
            computeBuffer.SetData(instanceInfos);
            foreach (var mat in instanceMaterials)
            {
                if (mat == null) continue;
                mat.SetBuffer(InstanceInfoBufferID, computeBuffer);
            }
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
