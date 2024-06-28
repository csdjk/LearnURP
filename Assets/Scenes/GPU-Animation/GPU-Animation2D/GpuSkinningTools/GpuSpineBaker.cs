// using UnityEngine;
// using UnityEditor;
// using UnityEngine.UIElements;
// using System;
// using System.Collections.Generic;
// using UnityEditor.UIElements;
// using System.IO;
// using System.Reflection;
// using System.Linq;
// using System.Diagnostics;
// using Spine;
// using Spine.Unity;
// using Debug = UnityEngine.Debug;
//
// namespace LcLTools
// {
//     public enum AnimationType
//     {
//         // 顶点动画
//         Vertices = 0,
//
//         // 骨骼动画
//         Skeleton,
//     };
//
//
//     struct BoneWeightData
//     {
//         public int boneIndex0;
//         public int boneIndex1;
//         public int boneIndex2;
//         public int boneIndex3;
//         public float weight0;
//         public float weight1;
//         public float weight2;
//         public float weight3;
//     };
//
//     public class GpuSpineBaker
//     {
//         int m_KernelVAT = -1;
//         int m_KernelBone = -1;
//         Transform m_TargetTransform;
//         string m_MeshPath;
//
//         List<MeshFilter> m_MeshFilters = new List<MeshFilter>();
//         AnimationType m_AnimationType = AnimationType.Skeleton;
//         Mesh m_MeshInstance;
//         Material m_MaterialInstance;
//
//         public AnimationType AnimationType
//         {
//             get { return m_AnimationType; }
//             set { m_AnimationType = value; }
//         }
//
//
//         ComputeShader m_ComputeShader = null;
//
//         public ComputeShader ComputeShader
//         {
//             get { return m_ComputeShader; }
//             set { m_ComputeShader = value; }
//         }
//
//         Vector3[] Vertices => m_MeshInstance.vertices;
//
//
//         // BindPoses 保存的是骨骼矩阵,用于把顶点从 模型空间 转换到 骨骼空间
//         // BindPose = bone.worldToLocalMatrix * model.localToWorldMatrix
//
//         // private Matrix4x4[] m_BonesMatrices => m_MeshFilters.Select(mf =>
//         // {
//         //     // var boneMatrix = m_TargetTransform.worldToLocalMatrix * mf.transform.localToWorldMatrix;
//         //     // var boneMatrix = m_TargetTransform.worldToLocalMatrix * mf.transform.localToWorldMatrix;
//         //     var boneMatrix =  mf.transform.localToWorldMatrix;
//         //     Vector3 center = new Vector3(0.01f, 2.69f, 0.00f);
//         //     boneMatrix.m03 -= center.x;
//         //     boneMatrix.m13 -= center.y;
//         //     boneMatrix.m23 -= center.z;
//         //     return boneMatrix;
//         //     // return m_TargetTransform.worldToLocalMatrix * mf.transform.parent.localToWorldMatrix;
//         // }).ToArray();
//         //
//
//         Dictionary<string, Transform> boneTable = new Dictionary<string, Transform>();
//         List<Transform> boneList = new List<Transform>();
//         Dictionary<string, Transform> slotTable = new Dictionary<string, Transform>();
//
//         private Matrix4x4[] m_BonesMatrices
//         {
//             get
//             {
//                 var skeletonAnimation = m_TargetTransform.GetComponentInChildren<SkeletonAnimation>();
//                 var skeletonData = skeletonAnimation.skeleton.Data; // 获取SkeletonData
//                 var bones = skeletonData.Bones.Items; // 获取所有骨骼数据
//                 var boneMatrices = new Matrix4x4[bones.Length]; // 初始化矩阵数组
//                 var bones2 = skeletonAnimation.skeleton.Bones.Items;
//                 var skin = skeletonData.Skins.Items[0]; // 获取皮肤数据
//                 GameObject prefabRoot = ObjectFactory.CreateGameObject("root");
//                 boneTable.Clear();
//                 boneList.Clear();
//                 slotTable.Clear();
//                 //create bones
//                 for (int i = 0; i < skeletonData.Bones.Count; i++)
//                 {
//                     var boneData = skeletonData.Bones.Items[i];
//                     Transform boneTransform = ObjectFactory.CreateGameObject(boneData.Name).transform;
//                     boneTransform.parent = prefabRoot.transform;
//                     boneTable.Add(boneTransform.name, boneTransform);
//                     boneList.Add(boneTransform);
//                 }
//
//                 for (int i = 0; i < skeletonData.Bones.Count; i++)
//                 {
//                     var boneData = skeletonData.Bones.Items[i];
//                     Transform boneTransform = boneTable[boneData.Name];
//                     Transform parentTransform = null;
//                     if (i > 0)
//                         parentTransform = boneTable[boneData.Parent.Name];
//                     else
//                         parentTransform = boneTransform.parent;
//
//                     boneTransform.parent = parentTransform;
//                     boneTransform.localPosition = new Vector3(boneData.X, boneData.Y, 0);
//                     var tm = boneData.TransformMode;
//                     if (tm.InheritsRotation())
//                         boneTransform.localRotation = Quaternion.Euler(0, 0, boneData.Rotation);
//                     else
//                         boneTransform.rotation = Quaternion.Euler(0, 0, boneData.Rotation);
//
//                     if (tm.InheritsScale())
//                         boneTransform.localScale = new Vector3(boneData.ScaleX, boneData.ScaleY, 1);
//
//                 }
//
//                 //create slots and attachments
//                 for (int slotIndex = 0; slotIndex < skeletonData.Slots.Count; slotIndex++)
//                 {
//                     var slotData = skeletonData.Slots.Items[slotIndex];
//                     Transform slotTransform = ObjectFactory.CreateGameObject(slotData.Name).transform;
//                     slotTransform.parent = prefabRoot.transform;
//                     slotTable.Add(slotData.Name, slotTransform);
//
//                     var skinEntries = new List<Skin.SkinEntry>();
//                     skin.GetAttachments(slotIndex, skinEntries);
//                     if (skin != skeletonData.DefaultSkin)
//                         skeletonData.DefaultSkin.GetAttachments(slotIndex, skinEntries);
//
//                     for (int a = 0; a < skinEntries.Count; a++)
//                     {
//                         var attachment = skinEntries[a].Attachment;
//                         string attachmentName = skinEntries[a].Name;
//                         string attachmentMeshName = "[" + slotData.Name + "] " + attachmentName;
//                         Vector3 offset = Vector3.zero;
//                         float rotation = 0;
//                         Mesh mesh = null;
//                         Material material = null;
//                         bool isWeightedMesh = false;
//
//                         if (attachment is RegionAttachment)
//                         {
//                             var regionAttachment = (RegionAttachment)attachment;
//                             offset.x = regionAttachment.X;
//                             offset.y = regionAttachment.Y;
//                             rotation = regionAttachment.Rotation;
//                         }
//                         else if (attachment is MeshAttachment)
//                         {
//                             var meshAttachment = (MeshAttachment)attachment;
//                             isWeightedMesh = (meshAttachment.Bones != null);
//                             offset.x = 0;
//                             offset.y = 0;
//                             rotation = 0;
//                         }
//                         else
//                             continue;
//
//                         Transform attachmentTransform = ObjectFactory.CreateGameObject(attachmentName).transform;
//                         attachmentTransform.parent = slotTransform;
//                         attachmentTransform.localPosition = offset;
//                         attachmentTransform.localRotation = Quaternion.Euler(0, 0, rotation);
//                         if (attachmentName != slotData.AttachmentName)
//                             attachmentTransform.gameObject.SetActive(false);
//                     }
//                 }
//
//                 foreach (var slotData in skeletonData.Slots)
//                 {
//                     Transform slotTransform = slotTable[slotData.Name];
//                     slotTransform.parent = boneTable[slotData.BoneData.Name];
//                     slotTransform.localPosition = Vector3.zero;
//                     slotTransform.localRotation = Quaternion.identity;
//                     slotTransform.localScale = Vector3.one;
//                 }
//
//                 for (int j = 0; j < boneList.Count; j++)
//                 {
//                     var bone = boneList[j];
//                     var mat = bones2[j].GetMatrix4x4();
//                     // boneMatrices[j] = mat * bone.worldToLocalMatrix * solt.localToWorldMatrix;
//                 }
//
//                 // UnityEngine.Object.DestroyImmediate(prefabRoot);
//
//                 //
//                 // for (int i = 0; i < bones.Length; i++)
//                 // {
//                 //     var boneData = bones[i];
//                 //     // 获取骨骼的位置
//                 //     Vector3 position = new Vector3(boneData.X, boneData.Y, 0);
//                 //     // 获取骨骼的旋转（假设Rotation是以度为单位的，将其转换为弧度）
//                 //     Quaternion rotation = Quaternion.Euler(0, 0, boneData.Rotation);
//                 //     // 获取骨骼的缩放
//                 //     Vector3 scale = new Vector3(boneData.ScaleX, boneData.ScaleY, 1);
//                 //
//                 //     // 计算变换矩阵：先缩放，然后旋转，最后平移
//                 //     Matrix4x4 matrix = Matrix4x4.TRS(position, rotation, scale);
//                 //
//                 //     var mat = bones2[i].GetMatrix4x4();
//                 //     Debug.Log($"GetMatrix4x4_{i}:\n{mat}");
//                 //     Debug.Log($"matrix_{i}:\n{matrix}");
//                 //
//                 //     // 填充到矩阵数组
//                 //     boneMatrices[i] = m_TargetTransform.localToWorldMatrix*matrix * mat;
//                 // }
//
//                 return boneMatrices;
//             }
//         }
//
//         // private Matrix4x4[] m_BonesMatrices
//         // {
//         //     get
//         //     {
//         //         var skeletonAnimation = m_TargetTransform.GetComponentInChildren<SkeletonAnimation>();
//         //         var bones = skeletonAnimation.skeleton.Bones.Items;
//         //         var boneMatrices = new Matrix4x4[bones.Length];
//         //         for (int i = 0; i < bones.Length; i++)
//         //         {
//
//         //             boneMatrices[i] =  bones[i].GetMatrix4x4();
//         //         }
//
//         //         return boneMatrices;
//         //     }
//         // }
//
//         // public static Matrix4x4 GetMatrix4x4FromSpineBone(SpineBone bone)
//         // {
//         //     // 获取位置
//         //     Vector3 position = new Vector3(bone.Position.X, bone.Position.Y, 0);
//         //     // 获取旋转（假设Rotation是以度为单位的，将其转换为弧度）
//         //     float rotationRadians = MathF.PI / 180 * bone.Rotation;
//         //     // 获取缩放
//         //     Vector3 scale = new Vector3(bone.Scale.X, bone.Scale.Y, 1);
//         //
//         //     // 创建旋转矩阵
//         //     Matrix4x4 rotationMatrix = Matrix4x4.CreateRotationZ(rotationRadians);
//         //     // 创建缩放矩阵
//         //     Matrix4x4 scaleMatrix = Matrix4x4.CreateScale(scale);
//         //     // 创建平移矩阵
//         //     Matrix4x4 translationMatrix = Matrix4x4.CreateTranslation(position);
//         //
//         //     // 合并矩阵：先缩放，然后旋转，最后平移
//         //     Matrix4x4 matrix = scaleMatrix * rotationMatrix * translationMatrix;
//         //
//         //     return matrix;
//         // }
//
//         //
//         // private Matrix4x4[] m_BonesMatrices => {
//         //     var skeletonAnimation = m_TargetTransform.GetComponentInChildren<SkeletonAnimation>();
//         //     var bones = skeletonAnimation.skeleton.Bones.Items;
//         //
//         //     var boneMatrices = new Matrix4x4[bones.Length];
//         //     for (int i = 0; i < bones.Length; i++)
//         //     {
//         //
//         //         boneMatrices[i] = boneMatrix;
//         //     }
//         //
//         //     return boneMatrices;
//         // };
//
//
//         ComputeBuffer m_VertexBuffer;
//         ComputeBuffer m_BoneBuffer;
//
//         public int TotalFrame { get; set; } = 0;
//
//
//         GpuAnimationData m_AnimationData;
//
//         string m_VertexTexturePath;
//         RenderTexture m_VertexTexture;
//
//         public RenderTexture VertexTexture
//         {
//             get
//             {
//                 if (m_VertexTexture == null && Vertices.Length > 0 && TotalFrame > 0)
//                 {
//                     m_VertexTexture = CreateRenderTexture(Vertices.Length, TotalFrame);
//                 }
//
//                 return m_VertexTexture;
//             }
//             set { m_VertexTexture = value; }
//         }
//
//
//         /// <summary>
//         /// 骨骼纹理
//         /// </summary>
//         string m_BoneTexturePath;
//
//         RenderTexture m_BoneTexture;
//
//         public RenderTexture BoneTexture
//         {
//             get
//             {
//                 if (m_BoneTexture == null && m_BonesMatrices.Length > 0 && TotalFrame > 0)
//                 {
//                     // bone矩阵最后一行是float4(0,0,0,1),所以只需要保存前3行
//                     m_BoneTexture = CreateRenderTexture(m_BonesMatrices.Length * 3, TotalFrame);
//                 }
//
//                 return m_BoneTexture;
//             }
//             set { m_BoneTexture = value; }
//         }
//
//
//         public RenderTexture CreateRenderTexture(int width, int height,
//             RenderTextureFormat format = RenderTextureFormat.ARGBHalf)
//         {
//             if (width > SystemInfo.maxTextureSize || height > SystemInfo.maxTextureSize)
//             {
//                 UnityEngine.Debug.LogError("Requested size is too large.");
//                 return null;
//             }
//
//             RenderTexture rt = new RenderTexture(width, height, 0, format, RenderTextureReadWrite.Linear)
//             {
//                 filterMode = FilterMode.Point,
//                 enableRandomWrite = true,
//             };
//             rt.Create();
//             return rt;
//         }
//
//
//         public void Dispose()
//         {
//             m_BoneBuffer?.Release();
//             m_VertexBuffer?.Release();
//             ReleaseRenderTexture();
//         }
//
//         public void ReleaseRenderTexture()
//         {
//             m_VertexTexture?.Release();
//             m_BoneTexture?.Release();
//             m_VertexTexture = null;
//             m_BoneTexture = null;
//         }
//
//         public void Init(GameObject go, string folderPath)
//         {
//             Dispose();
//             if (m_ComputeShader == null)
//             {
//                 return;
//             }
//
//             m_TargetTransform = go.transform;
//
//             go.GetComponentsInChildren(m_MeshFilters);
//
//             CombineMeshes(folderPath);
//
//             m_KernelVAT = m_ComputeShader.FindKernel("KernelVAT");
//             m_KernelBone = m_ComputeShader.FindKernel("KernelBone");
//             m_BoneBuffer = new ComputeBuffer(m_BonesMatrices.Length, sizeof(float) * 16);
//             if (AnimationType == AnimationType.Vertices)
//             {
//                 m_VertexBuffer = new ComputeBuffer(Vertices.Length, sizeof(float) * 3);
//             }
//         }
//
//         public void DispatchVAT(int currentFrame)
//         {
//             m_VertexBuffer.SetData(Vertices);
//             m_BoneBuffer.SetData(m_BonesMatrices);
//             m_ComputeShader.SetBuffer(m_KernelVAT, "vertices", m_VertexBuffer);
//             m_ComputeShader.SetBuffer(m_KernelVAT, "bones", m_BoneBuffer);
//             m_ComputeShader.SetTexture(m_KernelVAT, "vertexTexture", VertexTexture);
//             m_ComputeShader.SetInt("frame", currentFrame);
//             m_ComputeShader.Dispatch(m_KernelVAT, Mathf.CeilToInt(VertexTexture.width / 1024.0f), VertexTexture.height,
//                 1);
//         }
//
//         // Stopwatch stopwatch = new Stopwatch();
//
//         public void DispatchBone(int currentFrame)
//         {
//             m_BoneBuffer.SetData(m_BonesMatrices);
//
//             m_ComputeShader.SetBuffer(m_KernelBone, "bones", m_BoneBuffer);
//             m_ComputeShader.SetTexture(m_KernelBone, "boneTexture", BoneTexture);
//             m_ComputeShader.SetInt("frame", currentFrame);
//             m_ComputeShader.Dispatch(m_KernelBone, Mathf.CeilToInt(BoneTexture.width / 1024.0f), BoneTexture.height, 1);
//         }
//
//
//         public int InitAnimationData(List<AnimationClip> animationClips)
//         {
//             m_AnimationData = ScriptableObject.CreateInstance<GpuAnimationData>();
//             var clips = new GpuAnimationClip[animationClips.Count];
//
//             int totalFrame = 0;
//
//             for (var i = 0; i < animationClips.Count; i++)
//             {
//                 AnimationClip clip = animationClips[i];
//                 if (clip == null) continue;
//                 float frameRate = clip.frameRate;
//                 int clipTotalFrame = Mathf.RoundToInt(clip.length * frameRate);
//                 totalFrame += clipTotalFrame;
//
//
//                 clips[i] = new GpuAnimationClip(clip.name, totalFrame - clipTotalFrame, totalFrame - 1, frameRate);
//             }
//
//             m_AnimationData.clips = clips;
//
//             return totalFrame;
//         }
//
//         public void BakeAnimationTexture(GameObject fbx, List<AnimationClip> animationClips, string folderPath,
//             bool merge = false)
//         {
//             if (merge)
//             {
//                 BakeAnimationTextureMerge(fbx, animationClips, folderPath);
//             }
//             else
//             {
//                 BakeAnimationTextureForeach(fbx, animationClips, folderPath);
//             }
//         }
//
//         public void BakeAnimationTextureMerge(GameObject fbx, List<AnimationClip> animationClips, string folderPath)
//         {
//             Init(fbx, folderPath);
//
//             // TotalFrame = InitAnimationData(animationClips);
//             TotalFrame = 10;
//             int currentFrame = 0;
//             for (int i = 0; i < TotalFrame; i++)
//             {
//                 DispatchBone(i);
//             }
//
//             for (var i = 0; i < animationClips.Count; i++)
//             {
//                 AnimationClip clip = animationClips[i];
//                 if (clip == null) continue;
//
//                 float frameRate = clip.frameRate;
//
//                 var clipTotalFrame = Mathf.RoundToInt(clip.length * frameRate);
//
//                 for (int frame = 0; frame < clipTotalFrame; frame++)
//                 {
//                     // 进度条
//                     EditorUtility.DisplayProgressBar("Baking Animation Texture",
//                         $"Processing frame:{frame}/{TotalFrame}", (float)currentFrame / TotalFrame);
//
//                     // 计算当前帧的时间
//                     float time = frame / frameRate;
//                     // 采样动画的当前帧
//                     clip.SampleAnimation(fbx, time);
//
//                     if (AnimationType == AnimationType.Vertices)
//                     {
//                         DispatchVAT(currentFrame);
//                     }
//                     else if (AnimationType == AnimationType.Skeleton)
//                     {
//                         DispatchBone(currentFrame);
//                     }
//
//                     currentFrame++;
//                 }
//             }
//
//             SaveTexture(folderPath, "Merge");
//             // CreateAnimationData(folderPath);
//             // CreateMaterial(folderPath);
//             // CreatePrefab(folderPath);
//             // CreatePrefab(folderPath, true);
//             EditorUtility.ClearProgressBar();
//
//             AssetDatabase.Refresh();
//         }
//
//
//         public void BakeAnimationTextureForeach(GameObject fbx, List<AnimationClip> animationClips, string folderPath)
//         {
//             Init(fbx, folderPath);
//             int totalSteps = InitAnimationData(animationClips);
//             int currentFrame = 0;
//
//             for (var i = 0; i < animationClips.Count; i++)
//             {
//                 AnimationClip clip = animationClips[i];
//                 if (clip == null) continue;
//                 ReleaseRenderTexture();
//
//                 float frameRate = clip.frameRate;
//
//                 // 计算总帧数
//                 TotalFrame = Mathf.RoundToInt(clip.length * frameRate);
//
//                 for (int frame = 0; frame < TotalFrame; frame++)
//                 {
//                     // 进度条
//                     EditorUtility.DisplayProgressBar("Baking Animation Texture",
//                         $"Processing frame:{frame}/{TotalFrame}", (float)currentFrame / totalSteps);
//
//                     // 计算当前帧的时间
//                     float time = frame / frameRate;
//                     // 采样动画的当前帧
//                     clip.SampleAnimation(fbx, time);
//                     if (AnimationType == AnimationType.Vertices)
//                     {
//                         DispatchVAT(frame);
//                     }
//                     else if (AnimationType == AnimationType.Skeleton)
//                     {
//                         DispatchBone(frame);
//                     }
//
//                     currentFrame++;
//                 }
//
//                 SaveTexture(folderPath, clip.name);
//             }
//
//             CreateAnimationData(folderPath);
//             CreateMaterial(folderPath);
//             CreatePrefab(folderPath);
//             CreatePrefab(folderPath, true);
//             EditorUtility.ClearProgressBar();
//             AssetDatabase.Refresh();
//         }
//
//         public void CreateAnimationData(string folderPath)
//         {
//             var path = Path.Combine(folderPath, $"{m_TargetTransform.name}_AnimData.asset");
//
//             if (AssetDatabase.LoadAssetAtPath<GpuAnimationData>(path) != null)
//             {
//                 AssetDatabase.DeleteAsset(path);
//             }
//
//             AssetDatabase.CreateAsset(m_AnimationData, path);
//             AssetDatabase.SaveAssets();
//             EditorUtility.SetDirty(m_AnimationData);
//         }
//
//         public void CreateMaterial(string folderPath)
//         {
//             Shader shader;
//             if (AnimationType == AnimationType.Vertices)
//             {
//                 shader = Shader.Find("LcL/GPU-Animation/GPU-AnimationVertex2D");
//                 m_MaterialInstance = new Material(shader);
//
//                 var vertexTex = AssetDatabase.LoadAssetAtPath<Texture2D>(m_VertexTexturePath);
//                 m_MaterialInstance.SetTexture("_AnimationTex", vertexTex);
//             }
//             else
//             {
//                 shader = Shader.Find("LcL/GPU-Animation/GPU-AnimationBone2D");
//                 m_MaterialInstance = new Material(shader);
//                 var vertexTex = AssetDatabase.LoadAssetAtPath<Texture2D>(m_BoneTexturePath);
//                 m_MaterialInstance.SetTexture("_AnimationTex", vertexTex);
//             }
//
//             var matPath = Path.Combine(folderPath, $"{m_TargetTransform.name}_Mat.mat");
//
//             if (AssetDatabase.LoadAssetAtPath<Material>(matPath) != null)
//             {
//                 AssetDatabase.DeleteAsset(matPath);
//             }
//
//             AssetDatabase.CreateAsset(m_MaterialInstance, matPath);
//             AssetDatabase.SaveAssets();
//             EditorUtility.SetDirty(m_MaterialInstance);
//         }
//
//
//         public void CreatePrefab(string folderPath, bool instance = false)
//         {
//             var instanceTag = instance ? "_Instance" : "";
//             var prefabPath = Path.Combine(folderPath, $"{m_TargetTransform.name}{instanceTag}.prefab");
//             var prefab = new GameObject(m_TargetTransform.name);
//
//             if (instance)
//             {
//                 // var anim = prefab.AddComponent<GpuAnimationInstance>();
//                 // anim.animationData = m_AnimationData;
//                 // anim.instanceMaterial = m_MaterialInstance;
//                 // anim.instanceMesh = m_MeshInstance;
//             }
//             else
//             {
//                 var meshFilter = prefab.AddComponent<MeshFilter>();
//                 var renderer = prefab.AddComponent<MeshRenderer>();
//                 var anim = prefab.AddComponent<GpuAnimation>();
//                 meshFilter.sharedMesh = m_MeshInstance;
//                 renderer.sharedMaterial = m_MaterialInstance;
//                 anim.animationData = m_AnimationData;
//             }
//
//             if (AssetDatabase.LoadAssetAtPath<GameObject>(prefabPath) != null)
//             {
//                 AssetDatabase.DeleteAsset(prefabPath);
//             }
//
//             PrefabUtility.SaveAsPrefabAsset(prefab, prefabPath);
//             EditorUtility.SetDirty(prefab);
//             UnityEngine.Object.DestroyImmediate(prefab);
//         }
//
//         Vector3 GetCenter(List<MeshFilter> components)
//         {
//             if (components != null && components.Count > 0)
//             {
//                 Vector3 min = components[0].transform.position;
//                 Vector3 max = min;
//                 foreach (var comp in components)
//                 {
//                     min = Vector3.Min(min, comp.transform.position);
//                     max = Vector3.Max(max, comp.transform.position);
//                 }
//
//                 return min + ((max - min) / 2);
//             }
//
//             return Vector3.zero;
//         }
//
//         public void CombineMeshes(string folderPath)
//         {
//             var center = GetCenter(m_MeshFilters);
//             Debug.Log(center);
//             var combine = new CombineInstance[m_MeshFilters.Count];
//             for (var i = 0; i < m_MeshFilters.Count; i++)
//             {
//                 var mf = m_MeshFilters[i];
//                 var meshTemp = UnityEngine.Object.Instantiate(mf.sharedMesh);
//
//                 var uvs = meshTemp.vertices.Select(v => new Vector4(i, 0, 0, 0)).ToArray();
//                 meshTemp.SetUVs(1, uvs);
//                 combine[i].mesh = meshTemp;
//                 Matrix4x4 matrix4X4 = mf.transform.localToWorldMatrix;
//                 matrix4X4.m03 -= center.x;
//                 matrix4X4.m13 -= center.y;
//                 matrix4X4.m23 -= center.z;
//                 combine[i].transform = matrix4X4;
//                 // Debug.Log(mf);
//             }
//
//             m_MeshInstance = new Mesh();
//             m_MeshInstance.CombineMeshes(combine, true, true);
//             var path = Path.Combine(folderPath, $"{m_TargetTransform.name}_Mesh.asset");
//
//             if (!Directory.Exists(folderPath))
//             {
//                 Directory.CreateDirectory(folderPath);
//             }
//
//             if (AssetDatabase.LoadAssetAtPath<Mesh>(path) != null)
//             {
//                 AssetDatabase.DeleteAsset(path);
//             }
//
//             AssetDatabase.CreateAsset(m_MeshInstance, path);
//             AssetDatabase.SaveAssets();
//             EditorUtility.SetDirty(m_MeshInstance);
//         }
//
//         public void SaveTexture(string path, string clipName)
//         {
//             if (AnimationType == AnimationType.Vertices)
//             {
//                 var vertexTexPath = Path.Combine(path, $"{m_TargetTransform.name}_{clipName}_V.asset");
//                 m_VertexTexturePath = SaveRenderTexture(VertexTexture, vertexTexPath);
//             }
//             else if (AnimationType == AnimationType.Skeleton)
//             {
//                 var boneTexPath = Path.Combine(path, $"{m_TargetTransform.name}_{clipName}_Bone.asset");
//                 m_BoneTexturePath = SaveRenderTexture(BoneTexture, boneTexPath);
//             }
//         }
//
//
//         public string SaveRenderTexture(RenderTexture rt, string path)
//         {
//             RenderTexture.active = rt;
//             Texture2D tex = new Texture2D(rt.width, rt.height, TextureFormat.RGBAHalf, false);
//             tex.filterMode = rt.filterMode;
//
//             tex.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
//             tex.Apply();
//             RenderTexture.active = null;
//
//
//             string directoryPath = Path.GetDirectoryName(path);
//             if (!Directory.Exists(directoryPath))
//             {
//                 Directory.CreateDirectory(directoryPath);
//             }
//
//             //delete old file
//             if (AssetDatabase.LoadAssetAtPath<Texture2D>(path) != null)
//             {
//                 AssetDatabase.DeleteAsset(path);
//             }
//
//             AssetDatabase.CreateAsset(tex, path);
//             AssetDatabase.SaveAssets();
//             EditorUtility.SetDirty(tex);
//
//             return path;
//         }
//     }
// }
