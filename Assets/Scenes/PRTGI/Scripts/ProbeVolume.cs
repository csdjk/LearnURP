using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Serialization;

namespace LcLGame.PRTGI
{
    [RequireComponent(typeof(LightProbeGroup)), ExecuteAlways]
    public class ProbeVolume : MonoBehaviour
    {
        public static int SampleCount = 64;
        public ComputeShader computeShader;
        public ProbeData probeData;
        public Material material;
        [Range(0.01f, 5.0f)] public float giIntensity = 1.0f;
        [Range(0.01f, 5.0f)] public float skyLightIntensity = 1.0f;

        public Vector3Int probeGridSize = new Vector3Int(5, 5, 5);
        public float probeSpacing = 1.0f;

        public ProbeDebugMode debugMode = ProbeDebugMode.None;
        [Range(0.01f, 1.0f)] public float probeScale = 0.3f;
        public ProbeDebugPos debugPos = ProbeDebugPos.None;
        LightProbeGroup m_LightProbeGroup;


        List<Probe> m_Probes = new List<Probe>();
        public List<Probe> Probes => m_Probes;
        public int ProbeCount => Probes.Count;
        public Vector3 Position => transform.position;
        public List<Vector3> ProbePositions => m_LightProbeGroup.probePositions.ToList();
        public Vector4 VoxelCorner => new Vector4(Position.x, Position.y, Position.z, probeSpacing);
        ComputeBuffer m_CoefficientVoxel;

#if UNITY_EDITOR
        Mesh m_ProbeInstanceMesh;
        ComputeBuffer m_InstanceBuffer;
#endif

        Camera m_BakeCamera;

        Camera BakeCamera
        {
            get
            {
                if (m_BakeCamera == null)
                {
                    GameObject go = new GameObject("BakeCamera");
                    m_BakeCamera = go.AddComponent<Camera>();
                    m_BakeCamera.clearFlags = CameraClearFlags.SolidColor;
                    m_BakeCamera.backgroundColor = new Color(0, 0, 0, 0);
                    var additionalCameraData = go.AddComponent<UniversalAdditionalCameraData>();
                    additionalCameraData.SetRenderer(1);
                }

                return m_BakeCamera;
            }
        }

        // Static Properties
        public static ProbeVolume Instance { get; private set; }
        static readonly int s_InstanceInfoBuffer = Shader.PropertyToID("_InstanceInfoBuffer");

        public ComputeBuffer CoefficientVoxel
        {
            get
            {
                if (m_CoefficientVoxel == null)
                {
                    m_CoefficientVoxel = new ComputeBuffer(ProbeCount * 9, sizeof(float) * 3);
                }

                return m_CoefficientVoxel;
            }
        }

        Vector3[] m_CoefficientVoxelClearValue;

        private void OnEnable()
        {
            Instance = this;
            m_LightProbeGroup = GetComponent<LightProbeGroup>();
            InitProbes();
            probeData?.TryLoadSurfelData(this);

            m_ProbeInstanceMesh = Resources.GetBuiltinResource<Mesh>("Sphere.fbx");
            SceneView.duringSceneGui += OnSceneGUI;
        }

        private void OnDisable()
        {
            Instance = null;
            SceneView.duringSceneGui -= OnSceneGUI;
        }

        public void InitProbesInstanceBuffer()
        {
#if UNITY_EDITOR
            m_InstanceBuffer?.Release();
            m_InstanceBuffer = new ComputeBuffer(ProbeCount, 64);
#endif
        }

        void InitProbes()
        {
            m_Probes.Clear();
            for (int i = 0; i < m_LightProbeGroup.probePositions.Length; i++)
            {
                Vector3 position = m_LightProbeGroup.probePositions[i];
                Vector3Int gridIndex = new Vector3Int(
                    Mathf.FloorToInt(position.x / probeSpacing),
                    Mathf.FloorToInt(position.y / probeSpacing),
                    Mathf.FloorToInt(position.z / probeSpacing)
                );
                position = transform.TransformPoint(position);
                var probe = new Probe(position, i, gridIndex, computeShader);
                m_Probes.Add(probe);
            }

            m_CoefficientVoxel?.Release();
            m_CoefficientVoxel = new ComputeBuffer(ProbeCount * 9, sizeof(float) * 3);
            m_CoefficientVoxelClearValue = new Vector3[ProbeCount * 9];
            InitProbesInstanceBuffer();
        }

        public void GenerateProbes()
        {
            var probePositions = new Vector3[probeGridSize.x * probeGridSize.y * probeGridSize.z];
            for (int x = 0; x < probeGridSize.x; x++)
            {
                for (int y = 0; y < probeGridSize.y; y++)
                {
                    for (int z = 0; z < probeGridSize.z; z++)
                    {
                        Vector3 position = new Vector3(x, y, z) * probeSpacing;
                        probePositions[x + y * probeGridSize.x + z * probeGridSize.x * probeGridSize.y] = position;
                    }
                }
            }

            m_LightProbeGroup.probePositions = probePositions;
            InitProbes();
        }

        ProbeData GetProbeData()
        {
            if (probeData == null)
            {
                probeData = ScriptableObject.CreateInstance<ProbeData>();
                probeData.name = "ProbeVolumeData";
                // AssetDatabase.CreateAsset(probeData, "Assets/Scenes/PRTGI/Resources/ProbeVolumeData.asset");
            }

            return probeData;
        }

        public void RenderCubemap()
        {
            var rendererData = RenderPipelineAssetManager.GetRendererDataByName("PRTGI_Renderer_Bake");
            if (rendererData == null)
            {
                Debug.LogError("RendererData is null");
                return;
            }

            var bakeFeature = rendererData.GetRendererFeatures<ProbeBakeFeature>();
            InitProbes();

            foreach (var probe in m_Probes)
            {
                probe.Bake(BakeCamera, bakeFeature);
            }

            GetProbeData()?.StorageSurfelData(this);

            CoreUtils.Destroy(BakeCamera.gameObject);
        }

        public void ClearCoefficientVoxel(CommandBuffer cmd)
        {
            cmd.SetBufferData(CoefficientVoxel, m_CoefficientVoxelClearValue);
        }


#if UNITY_EDITOR
        private GUIStyle m_Style;

        private GUIStyle Style
        {
            get
            {
                if (m_Style == null)
                {
                    m_Style = new GUIStyle(EditorStyles.label);
                    m_Style.alignment = TextAnchor.MiddleCenter;
                    m_Style.normal.textColor = new Color(1, 1, 1, 0.8f);
                    // m_Style.normal.textColor = Color.white;
                    m_Style.fontSize = 12;
                }

                return m_Style;
            }
        }

        private void OnSceneGUI(SceneView sceneView)
        {
            var matrices = ProbePositions.Select(pos =>
                Matrix4x4.TRS(transform.TransformPoint(pos), Quaternion.identity,
                    Vector3.one * probeScale)).ToArray();

            m_InstanceBuffer.SetData(matrices);
            material.SetBuffer(s_InstanceInfoBuffer, m_InstanceBuffer);
            Graphics.DrawMeshInstancedProcedural(m_ProbeInstanceMesh, 0, material,
                new Bounds(Vector3.zero, Vector3.one * 10000),
                ProbeCount);

            //在探针位置绘制text
            foreach (var probe in m_Probes)
            {
                var text = "";
                switch (debugPos)
                {
                    case ProbeDebugPos.None:
                        return;
                    case ProbeDebugPos.Index:
                        text = probe.index.ToString();
                        break;
                    case ProbeDebugPos.WorldPos:
                        text = probe.position.ToString();
                        break;
                    case ProbeDebugPos.GridIndex:
                        text = probe.gridIndex.ToString();
                        break;
                }

                //世界坐标转屏幕坐标
                CameraProjectionCache cam = new CameraProjectionCache(Camera.current);
                Vector2 screenPosition = cam.WorldToGUIPoint(probe.position);

                Vector2 stringSize = Style.CalcSize(new GUIContent(text));
                Rect rect = new Rect(0f, 0f, stringSize.x + 6, stringSize.y + 4);
                rect.center = screenPosition ;

                Handles.BeginGUI();
                {
                    GUI.color = new Color(0, 0, 0, 0.5f);
                    GUI.DrawTexture(rect, EditorGUIUtility.whiteTexture);
                    GUI.color = Style.normal.textColor;
                    GUI.Label(rect, text, Style);
                }
                Handles.EndGUI();
            }
        }
#endif


        [DrawGizmo(GizmoType.Selected | GizmoType.Active | GizmoType.NonSelected)]
        static void DrawGizmos(ProbeVolume probeVolume, GizmoType gizmoType)
        {
            if (probeVolume.m_Probes != null && probeVolume.m_Probes.Count > 0)
            {
                // probeVolume.m_Probes[0].DrawGizmos(probeVolume.debugMode);

                foreach (var probe in probeVolume.Probes)
                {
                    probe.DrawGizmos(probeVolume.debugMode);
                }
            }
        }
    }
}
