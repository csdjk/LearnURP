using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace LcLTools
{


    public class GpuSkinningBaker
    {
        int m_KernelVAT = -1;
        int m_KernelBone = -1;
        Transform m_TargetTransform;
        Mesh m_MeshInstance;
        Material m_MaterialInstance;
        public SkinnedMeshRenderer SelectSkinnedMeshRenderer { get; set; }

        public AnimationType AnimationType { get; set; } = AnimationType.Skeleton;


        public ComputeShader ComputeShader { get; set; } = null;

        Vector3[] Vertices => SelectSkinnedMeshRenderer.sharedMesh.vertices;
        Vector3[] Normals => SelectSkinnedMeshRenderer.sharedMesh.normals;

        Vector4[] Tangents => SelectSkinnedMeshRenderer.sharedMesh.tangents;

        //
        Transform[] Bones => SelectSkinnedMeshRenderer.bones;

        // BindPoses 保存的是骨骼矩阵,用于把顶点从 模型空间 转换到 骨骼空间
        // BindPose = bone.worldToLocalMatrix * model.localToWorldMatrix
        Matrix4x4[] BindPoses => SelectSkinnedMeshRenderer.sharedMesh.bindposes;
        BoneWeight[] BoneWeights => SelectSkinnedMeshRenderer.sharedMesh.boneWeights;

        Matrix4x4[] BonesMatrices =>
            Bones.Select((bone, index) => bone.localToWorldMatrix * BindPoses[index]).ToArray();

        BoneWeightData[] m_BoneWeightsData;
        ComputeBuffer m_VertexBuffer;
        ComputeBuffer m_NormalBuffer;
        ComputeBuffer m_TangentBuffer;
        ComputeBuffer m_BoneBuffer;
        ComputeBuffer m_BoneWeightBuffer;


        int m_TotalFrame = 0;

        public int TotalFrame { get; set; } = 0;


        GpuAnimationData m_AnimationData;

        string m_VertexTexturePath;
        RenderTexture m_VertexTexture;

        public RenderTexture VertexTexture
        {
            get
            {
                if (m_VertexTexture == null && Vertices.Length > 0 && TotalFrame > 0)
                {
                    m_VertexTexture = CreateRenderTexture(Vertices.Length, TotalFrame);
                }

                return m_VertexTexture;
            }
            set => m_VertexTexture = value;
        }

        string m_NormalTexturePath;
        RenderTexture m_NormalTexture;

        public RenderTexture NormalTexture
        {
            get
            {
                if (m_NormalTexture == null && Vertices.Length > 0 && TotalFrame > 0)
                {
                    m_NormalTexture = CreateRenderTexture(Vertices.Length, TotalFrame);
                }

                return m_NormalTexture;
            }
            set => m_NormalTexture = value;
        }


        /// <summary>
        /// 骨骼纹理
        /// </summary>
        string m_BoneTexturePath;

        RenderTexture m_BoneTexture;

        public RenderTexture BoneTexture
        {
            get
            {
                if (m_BoneTexture == null && Bones.Length > 0 && TotalFrame > 0)
                {
                    // bone矩阵最后一行是float4(0,0,0,1),所以只需要保存前3行
                    m_BoneTexture = CreateRenderTexture(Bones.Length * 3, TotalFrame);
                }

                return m_BoneTexture;
            }
            set => m_BoneTexture = value;
        }


        public RenderTexture CreateRenderTexture(int width, int height,
            RenderTextureFormat format = RenderTextureFormat.ARGBHalf)
        {
            if (width > SystemInfo.maxTextureSize || height > SystemInfo.maxTextureSize)
            {
                UnityEngine.Debug.LogError("Requested size is too large.");
                return null;
            }

            RenderTexture rt = new RenderTexture(width, height, 0, format, RenderTextureReadWrite.Linear)
            {
                filterMode = FilterMode.Point,
                enableRandomWrite = true,
            };
            rt.Create();
            return rt;
        }


        public void Dispose()
        {
            m_BoneBuffer?.Release();
            m_VertexBuffer?.Release();
            m_BoneWeightBuffer?.Release();
            ReleaseRenderTexture();
        }

        public void ReleaseRenderTexture()
        {
            m_VertexTexture?.Release();
            m_NormalTexture?.Release();
            m_BoneTexture?.Release();
            m_NormalTexture = null;
            m_VertexTexture = null;
            m_BoneTexture = null;
        }

        private void Init(GameObject go)
        {
            Dispose();
            if (ComputeShader == null)
            {
                return;
            }

            m_TargetTransform = go.transform;
            m_KernelVAT = ComputeShader.FindKernel("KernelVAT");
            m_KernelBone = ComputeShader.FindKernel("KernelBone");

            m_BoneBuffer = new ComputeBuffer(Bones.Length, sizeof(float) * 16);
            m_BoneWeightBuffer = new ComputeBuffer(BoneWeights.Length, sizeof(int) * 4 + sizeof(float) * 4);
            m_VertexBuffer = new ComputeBuffer(Vertices.Length, sizeof(float) * 3);
            m_NormalBuffer = new ComputeBuffer(Normals.Length, sizeof(float) * 3);
            m_TangentBuffer = new ComputeBuffer(Tangents.Length, sizeof(float) * 4);

            m_BoneWeightsData = BoneWeights.Select((bw, index) => new BoneWeightData
            {
                boneIndex0 = bw.boneIndex0,
                boneIndex1 = bw.boneIndex1,
                boneIndex2 = bw.boneIndex2,
                boneIndex3 = bw.boneIndex3,
                weight0 = bw.weight0,
                weight1 = bw.weight1,
                weight2 = bw.weight2,
                weight3 = bw.weight3
            }).ToArray();
        }

        private void DispatchVAT(int currentFrame)
        {
            m_VertexBuffer.SetData(Vertices);
            m_NormalBuffer.SetData(Normals);
            m_TangentBuffer.SetData(Tangents);
            m_BoneBuffer.SetData(BonesMatrices);
            m_BoneWeightBuffer.SetData(m_BoneWeightsData);

            ComputeShader.SetBuffer(m_KernelVAT, "vertices", m_VertexBuffer);
            ComputeShader.SetBuffer(m_KernelVAT, "normals", m_NormalBuffer);
            ComputeShader.SetBuffer(m_KernelVAT, "tangents", m_TangentBuffer);
            ComputeShader.SetBuffer(m_KernelVAT, "bones", m_BoneBuffer);
            ComputeShader.SetBuffer(m_KernelVAT, "boneWeights", m_BoneWeightBuffer);
            ComputeShader.SetTexture(m_KernelVAT, "vertexTexture", VertexTexture);
            ComputeShader.SetTexture(m_KernelVAT, "normalTexture", NormalTexture);
            ComputeShader.SetInt("frame", currentFrame);
            ComputeShader.Dispatch(m_KernelVAT, Mathf.CeilToInt(VertexTexture.width / 1024.0f), VertexTexture.height,
                1);
        }

        // Stopwatch stopwatch = new Stopwatch();

        private void DispatchBone(int currentFrame)
        {
            m_BoneBuffer.SetData(BonesMatrices);
            ComputeShader.SetBuffer(m_KernelBone, "bones", m_BoneBuffer);
            ComputeShader.SetTexture(m_KernelBone, "boneTexture", BoneTexture);
            ComputeShader.SetInt("frame", currentFrame);
            ComputeShader.Dispatch(m_KernelBone, Mathf.CeilToInt(BoneTexture.width / 1024.0f), BoneTexture.height, 1);
        }


        private int InitAnimationData(List<AnimationClip> animationClips)
        {
            m_AnimationData = ScriptableObject.CreateInstance<GpuAnimationData>();
            var clips = new GpuAnimationClip[animationClips.Count];

            int totalFrame = 0;

            for (var i = 0; i < animationClips.Count; i++)
            {
                AnimationClip clip = animationClips[i];
                if (clip == null) continue;
                float frameRate = clip.frameRate;
                int clipTotalFrame = Mathf.RoundToInt(clip.length * frameRate);
                totalFrame += clipTotalFrame;


                clips[i] = new GpuAnimationClip(clip.name, totalFrame - clipTotalFrame, totalFrame - 1, frameRate);
            }

            m_AnimationData.clips = clips;

            return totalFrame;
        }

        public void BakeAnimationTexture(GameObject fbx, List<AnimationClip> animationClips, string folderPath,
            bool merge = false)
        {
            if (merge)
            {
                BakeAnimationTextureMerge(fbx, animationClips, folderPath);
            }
            else
            {
                BakeAnimationTextureForeach(fbx, animationClips, folderPath);
            }
        }

        private void BakeAnimationTextureMerge(GameObject fbx, List<AnimationClip> animationClips, string folderPath)
        {
            Init(fbx);

            TotalFrame = InitAnimationData(animationClips);
            int currentFrame = 0;

            for (var i = 0; i < animationClips.Count; i++)
            {
                AnimationClip clip = animationClips[i];
                if (clip == null) continue;

                float frameRate = clip.frameRate;

                var clipTotalFrame = Mathf.RoundToInt(clip.length * frameRate);

                for (int frame = 0; frame < clipTotalFrame; frame++)
                {
                    // 进度条
                    EditorUtility.DisplayProgressBar("Baking Animation Texture",
                        $"Processing frame:{frame}/{TotalFrame}", (float)currentFrame / TotalFrame);

                    // 计算当前帧的时间
                    float time = frame / frameRate;
                    // 采样动画的当前帧
                    clip.SampleAnimation(fbx, time);

                    if (AnimationType == AnimationType.Vertices)
                    {
                        DispatchVAT(currentFrame);
                    }
                    else if (AnimationType == AnimationType.Skeleton)
                    {
                        DispatchBone(currentFrame);
                    }

                    currentFrame++;
                }
            }

            SaveTexture(folderPath, "Merge");
            CreateMesh(folderPath);
            CreateAnimationData(folderPath);
            CreateMaterial(folderPath);
            CreatePrefab(folderPath);
            CreatePrefab(folderPath, true);
            EditorUtility.ClearProgressBar();

            AssetDatabase.Refresh();
        }


        public void BakeAnimationTextureForeach(GameObject fbx, List<AnimationClip> animationClips, string folderPath)
        {
            Init(fbx);
            int totalSteps = InitAnimationData(animationClips);
            int currentFrame = 0;

            for (var i = 0; i < animationClips.Count; i++)
            {
                AnimationClip clip = animationClips[i];
                if (clip == null) continue;
                ReleaseRenderTexture();

                float frameRate = clip.frameRate;

                // 计算总帧数
                TotalFrame = Mathf.RoundToInt(clip.length * frameRate);

                for (int frame = 0; frame < TotalFrame; frame++)
                {
                    // 进度条
                    EditorUtility.DisplayProgressBar("Baking Animation Texture",
                        $"Processing frame:{frame}/{TotalFrame}", (float)currentFrame / totalSteps);

                    // 计算当前帧的时间
                    float time = frame / frameRate;
                    // 采样动画的当前帧
                    clip.SampleAnimation(fbx, time);
                    if (AnimationType == AnimationType.Vertices)
                    {
                        DispatchVAT(frame);
                    }
                    else if (AnimationType == AnimationType.Skeleton)
                    {
                        DispatchBone(frame);
                    }

                    currentFrame++;
                }

                SaveTexture(folderPath, clip.name);
            }

            CreateMesh(folderPath);
            CreateAnimationData(folderPath);
            CreateMaterial(folderPath);
            CreatePrefab(folderPath);
            CreatePrefab(folderPath, true);
            EditorUtility.ClearProgressBar();
            AssetDatabase.Refresh();
        }

        public void CreateAnimationData(string folderPath)
        {
            var path = Path.Combine(folderPath, $"{m_TargetTransform.name}_AnimData.asset");

            if (AssetDatabase.LoadAssetAtPath<GpuAnimationData>(path) != null)
            {
                AssetDatabase.DeleteAsset(path);
            }

            AssetDatabase.CreateAsset(m_AnimationData, path);
            AssetDatabase.SaveAssets();
            EditorUtility.SetDirty(m_AnimationData);
        }


        public void CreateMaterial(string folderPath)
        {
            Shader shader;
            if (AnimationType == AnimationType.Vertices)
            {
                shader = Shader.Find("LcL/GPU-Animation/GPU-AnimationVertex");
                m_MaterialInstance = new Material(shader);

                var vertexTex = AssetDatabase.LoadAssetAtPath<Texture2D>(m_VertexTexturePath);
                var normalTex = AssetDatabase.LoadAssetAtPath<Texture2D>(m_NormalTexturePath);
                m_MaterialInstance.SetTexture("_AnimationTex", vertexTex);
                m_MaterialInstance.SetTexture("_AnimationNormalTex", normalTex);
            }
            else
            {
                shader = Shader.Find("LcL/GPU-Animation/GPU-AnimationBone");
                m_MaterialInstance = new Material(shader);
                var vertexTex = AssetDatabase.LoadAssetAtPath<Texture2D>(m_BoneTexturePath);
                m_MaterialInstance.SetTexture("_AnimationTex", vertexTex);
            }

            var matPath = Path.Combine(folderPath, $"{m_TargetTransform.name}_Mat.mat");

            if (AssetDatabase.LoadAssetAtPath<Material>(matPath) != null)
            {
                AssetDatabase.DeleteAsset(matPath);
            }

            AssetDatabase.CreateAsset(m_MaterialInstance, matPath);
            AssetDatabase.SaveAssets();
            EditorUtility.SetDirty(m_MaterialInstance);
        }


        public void CreatePrefab(string folderPath, bool instance = false)
        {
            var materials = new List<Material>();
            SelectSkinnedMeshRenderer.sharedMaterials.ToList().ForEach(m => materials.Add(m_MaterialInstance));
            var instanceTag = instance ? "_Instance" : "";
            var prefabPath = Path.Combine(folderPath, $"{m_TargetTransform.name}{instanceTag}.prefab");
            var prefab = new GameObject(m_TargetTransform.name);

            if (instance)
            {
                var anim = prefab.AddComponent<GpuAnimationInstance>();
                anim.animationData = m_AnimationData;
                anim.instanceMaterials = materials.ToArray();
                anim.instanceMesh = m_MeshInstance;
            }
            else
            {
                var meshFilter = prefab.AddComponent<MeshFilter>();
                var renderer = prefab.AddComponent<MeshRenderer>();
                var anim = prefab.AddComponent<GpuAnimation>();
                meshFilter.sharedMesh = m_MeshInstance;
                renderer.sharedMaterials = materials.ToArray();
                anim.animationData = m_AnimationData;
            }

            if (AssetDatabase.LoadAssetAtPath<GameObject>(prefabPath) != null)
            {
                AssetDatabase.DeleteAsset(prefabPath);
            }

            PrefabUtility.SaveAsPrefabAsset(prefab, prefabPath);
            EditorUtility.SetDirty(prefab);
            UnityEngine.Object.DestroyImmediate(prefab);
        }


        /// <summary>
        /// 创建Mesh，并且把bone Index和Weight保存到UV1 和 UV2
        /// </summary>
        public void CreateMesh(string folderPath)
        {
            // 创建新的Mesh
            m_MeshInstance = UnityEngine.Object.Instantiate(SelectSkinnedMeshRenderer.sharedMesh);

            // 将骨骼索引和权重保存到UV1和UV2
            var boneIndexs = BoneWeights
                .Select(bw => new Vector4(bw.boneIndex0, bw.boneIndex1, bw.boneIndex2, bw.boneIndex3)).ToArray();
            var boneWeights = BoneWeights.Select(bw => new Vector4(bw.weight0, bw.weight1, bw.weight2, bw.weight3))
                .ToArray();

            m_MeshInstance.SetUVs(1, boneIndexs);
            m_MeshInstance.SetUVs(2, boneWeights);

            var path = Path.Combine(folderPath, $"{m_TargetTransform.name}_Mesh.asset");

            if (AssetDatabase.LoadAssetAtPath<Mesh>(path) != null)
            {
                AssetDatabase.DeleteAsset(path);
            }

            AssetDatabase.CreateAsset(m_MeshInstance, path);
            AssetDatabase.SaveAssets();
            EditorUtility.SetDirty(m_MeshInstance);
        }


        public void SaveTexture(string path, string clipName)
        {
            if (AnimationType == AnimationType.Vertices)
            {
                var vertexTexPath = Path.Combine(path, $"{m_TargetTransform.name}_{clipName}_TextureV.asset");
                var normalTexPath = Path.Combine(path, $"{m_TargetTransform.name}_{clipName}_TextureN.asset");
                m_VertexTexturePath = SaveRenderTexture(VertexTexture, vertexTexPath);
                m_NormalTexturePath = SaveRenderTexture(NormalTexture, normalTexPath);
            }
            else if (AnimationType == AnimationType.Skeleton)
            {
                var boneTexPath = Path.Combine(path, $"{m_TargetTransform.name}_{clipName}_TextureBone.asset");
                m_BoneTexturePath = SaveRenderTexture(BoneTexture, boneTexPath);
            }
        }


        public string SaveRenderTexture(RenderTexture rt, string path)
        {
            RenderTexture.active = rt;
            Texture2D tex = new Texture2D(rt.width, rt.height, TextureFormat.RGBAHalf, false);
            tex.filterMode = rt.filterMode;

            tex.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
            tex.Apply();
            RenderTexture.active = null;


            string directoryPath = Path.GetDirectoryName(path);
            if (!Directory.Exists(directoryPath))
            {
                Directory.CreateDirectory(directoryPath);
            }

            //delete old file
            if (AssetDatabase.LoadAssetAtPath<Texture2D>(path) != null)
            {
                AssetDatabase.DeleteAsset(path);
            }

            AssetDatabase.CreateAsset(tex, path);
            AssetDatabase.SaveAssets();
            EditorUtility.SetDirty(tex);

            return path;
        }
    }
}
