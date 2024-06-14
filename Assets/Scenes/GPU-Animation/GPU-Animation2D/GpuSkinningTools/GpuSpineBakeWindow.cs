using UnityEngine;
using UnityEditor;
using UnityEngine.UIElements;
using System;
using System.Collections.Generic;
using UnityEditor.UIElements;
using System.IO;
using System.Linq;

namespace LcLTools
{
    public class GpuSpineBakeWindow : EditorWindow
    {
         GameObject m_FbxObject = null;
        List<MeshFilter> m_MeshRenderers = new List<MeshFilter>();

        List<AnimationClip> m_AnimationClips = new List<AnimationClip>();
        GpuSpineBaker m_GpuSpineBaker = new GpuSpineBaker();
        ObjectField m_ComputeShaderField;
        TextField m_OutputFolderField;
        EnumField m_AnimationTypeField;
        ListView m_AnimationClipListView;
        Toggle m_MergeAnimationClipsToggle;
        Label m_TipsLabel;
        PopupField<MeshFilter> m_SkinnedMeshField;

        [MenuItem("LcLTools/GPU动画转换工具")]
        private static void ShowWindow()
        {
            var window = GetWindow<GpuSpineBakeWindow>();
            window.titleContent = new GUIContent("GPU Spine Bake");
            window.Show();
            window.Focus();
        }

        public void CreateGUI()
        {
            var margin = 5;
            VisualElement root = rootVisualElement;
            root.style.paddingBottom = 10;
            root.style.paddingTop = 10;
            root.style.paddingLeft = 5;
            root.style.paddingRight = 5;

            m_SkinnedMeshField = new PopupField<MeshFilter>("Mesh", m_MeshRenderers, 0)
            {
                style = { marginTop = margin },
            };

            m_ComputeShaderField = new ObjectField("Compute Shader")
            {
                objectType = typeof(ComputeShader),
                value = LcLEditorUtilities.GetAssetByName<ComputeShader>("TransformPosition"),
                style = { marginTop = margin }
            };
            m_ComputeShaderField.RegisterValueChangedCallback(evt =>
            {
                m_GpuSpineBaker.ComputeShader = evt.newValue as ComputeShader;
            });
            root.Add(m_ComputeShaderField);


            var objectField = new ObjectField("FBX Object")
            {
                objectType = typeof(GameObject),
                style = { marginTop = margin }
            };
            objectField.RegisterValueChangedCallback(evt =>
            {
                m_FbxObject = evt.newValue as GameObject;
                InitAnimationData();
                m_SkinnedMeshField.choices = m_MeshRenderers;
                m_SkinnedMeshField.value = m_MeshRenderers.Count > 0 ? m_MeshRenderers[0] : null;

            });
            root.Add(objectField);
            objectField.value = m_FbxObject;

            m_OutputFolderField = new TextField("Output Folder")
            {
                value = "Assets/Scenes/GPU-Animation/Output",
                style = { marginTop = margin }
            };
            root.Add(m_OutputFolderField);
            root.Add(m_SkinnedMeshField);


            m_AnimationTypeField = new EnumField("Animation Type", AnimationType.Skeleton)
            {
                style = { marginTop = margin }
            };
            m_AnimationTypeField.RegisterValueChangedCallback(evt =>
            {
                var type = (AnimationType)evt.newValue;
                m_GpuSpineBaker.AnimationType = type;
                var vertexCount = m_SkinnedMeshField.value.sharedMesh.vertexCount;
                if (type == AnimationType.Vertices && vertexCount > 2048)
                {
                    m_TipsLabel.style.display = DisplayStyle.Flex;
                    m_TipsLabel.text = $"模型顶点数过多({vertexCount}),请使用Skeleton动画";
                }
                else
                {
                    m_TipsLabel.style.display = DisplayStyle.None;
                }
            });
            root.Add(m_AnimationTypeField);


            m_TipsLabel = new Label("模型顶点数过多,请使用Skeleton动画")
            {
                style = {
                    marginTop = margin,
                    color = Color.yellow,
                    alignSelf = Align.Center,
                    display = DisplayStyle.None
                }
            };
            root.Add(m_TipsLabel);



            m_MergeAnimationClipsToggle = new Toggle("Merge Animation Clips")
            {
                value = true,
                style = { marginTop = margin }
            };
            root.Add(m_MergeAnimationClipsToggle);

            Func<VisualElement> makeItem = () =>
            {
                var obj = new ObjectField()
                {
                    objectType = typeof(AnimationClip),
                    style = { marginTop = margin }
                };
                obj.RegisterValueChangedCallback(evt =>
                {
                    int i = (int)(evt.target as ObjectField)?.userData;
                    if (i < m_AnimationClips.Count)
                        m_AnimationClips[i] = evt.newValue as AnimationClip;
                });
                return obj;
            };

            Action<VisualElement, int> bindItem = (element, index) =>
            {
                var obj = element as ObjectField;
                obj.userData = index;
                obj.value = index < m_AnimationClips.Count ? m_AnimationClips[index] : null;
            };

            m_AnimationClipListView = new ListView(m_AnimationClips, 20, makeItem, bindItem)
            {
                selectionType = SelectionType.Multiple,
                showAddRemoveFooter = true,
                reorderable = true,
                reorderMode = ListViewReorderMode.Animated,
                showBorder = true,
                headerTitle = "Animation Clip",
                showFoldoutHeader = true,
                style = { marginTop = margin }
            };
            m_AnimationClipListView.showAddRemoveFooter = true;
            m_AnimationClipListView.showAlternatingRowBackgrounds = AlternatingRowBackground.None;
            m_AnimationClipListView.showBoundCollectionSize = true;
            m_AnimationClipListView.selectionType = SelectionType.Multiple;
            {
                var lockBtn = new Button(ResetAnimationClips)
                {
                    text = "Reset",
                    style = {
                        height = 20,
                        width = 50,
                        position= Position.Absolute,
                        bottom = 0
                    }
                };
                m_AnimationClipListView.hierarchy.ElementAt(0).Add(lockBtn);
            }
            root.Add(m_AnimationClipListView);


            var button = new Button(Convert)
            {
                text = "Bake",
                style = { height = 30, marginTop = margin }
            };
            root.Add(button);
        }

        void Convert()
        {
            if (m_FbxObject == null)
            {
                Debug.LogError("FBX Object is null");
                return;
            }
            var folderPath = Path.Combine(m_OutputFolderField.value, m_FbxObject.name);
            m_GpuSpineBaker.ComputeShader = m_ComputeShaderField.value as ComputeShader;
            m_GpuSpineBaker.AnimationType = (AnimationType)m_AnimationTypeField.value;
            m_GpuSpineBaker.BakeAnimationTexture(m_FbxObject, m_AnimationClips, folderPath, m_MergeAnimationClipsToggle.value);
        }


        void InitAnimationData()
        {
            if (m_FbxObject == null)
                return;
            m_MeshRenderers.Clear();
            m_FbxObject.GetComponentsInChildren(m_MeshRenderers);
        }

        void ResetAnimationClips()
        {
            m_AnimationClips.Clear();
            string assetPath = AssetDatabase.GetAssetPath(m_FbxObject);
            UnityEngine.Object[] objs = AssetDatabase.LoadAllAssetsAtPath(assetPath);

            foreach (var obj in objs)
            {
                if (obj is AnimationClip)
                {
                    var clip = obj as AnimationClip;
                    if (clip.hideFlags == (HideFlags.HideInHierarchy | HideFlags.NotEditable))
                        continue;
                    m_AnimationClips.Add(clip);
                }
            }
            m_AnimationClipListView.itemsSource = m_AnimationClips;
            m_AnimationClipListView.Rebuild();
        }
    }
}
