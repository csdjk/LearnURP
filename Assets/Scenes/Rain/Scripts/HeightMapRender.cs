using System.Collections;
using System.Collections.Generic;
using UnityEngine.Rendering;
using UnityEngine;
using UnityEngine.Rendering.Universal;

#if UNITY_EDITOR
using UnityEditor;
#endif

public enum HeightMapResolution
{
    [InspectorName("128")] _128 = 128,
    [InspectorName("256")] _256 = 256,
    [InspectorName("512")] _512 = 512,
    [InspectorName("1024")] _1024 = 1024,
}

[ExecuteAlways, DisallowMultipleComponent, RequireComponent(typeof(Camera))]
[CanEditMultipleObjects]
public class HeightMapRender : MonoBehaviour
{
    static readonly string m_HeightMapShaderName = "Hidden/SceneHeightMap";
    Camera m_Camera;

    public HeightMapResolution heightMapResolution = HeightMapResolution._512;

    [SerializeField, Tooltip("勾选后，Camera组件将会被锁定，不能再编辑，防止误操作")]
    private bool m_LockEdit = false;

    public bool LockEdit
    {
        set
        {
            if (value)
            {
                transform.hideFlags = HideFlags.NotEditable;
                if (m_Camera)
                {
                    m_Camera.hideFlags = HideFlags.NotEditable;
                }
            }
            else
            {
                transform.hideFlags = HideFlags.None;
                if (m_Camera)
                {
                    m_Camera.hideFlags = HideFlags.None;
                }
            }

            m_LockEdit = value;
        }
        get { return m_LockEdit; }
    }

    RenderTextureFormat m_Format = RenderTextureFormat.ARGB32;
    Shader m_HeightMapShader;

    Shader HeightMapShader
    {
        get
        {
            if (m_HeightMapShader == null)
            {
                m_HeightMapShader = Shader.Find(m_HeightMapShaderName);
            }

            return m_HeightMapShader;
        }
    }

    HeightMapResolution m_HeightMapResolutionCache = HeightMapResolution._128;
    RenderTexture m_SceneHeightRT;

    public RenderTexture SceneHeightRT
    {
        get
        {
            if (m_SceneHeightRT == null || m_HeightMapResolutionCache != heightMapResolution)
            {
                m_SceneHeightRT?.Release();
                m_HeightMapResolutionCache = heightMapResolution;
                var size = (int)heightMapResolution;
                m_SceneHeightRT = RenderTexture.GetTemporary(size, size, 64, m_Format);
            }

            return m_SceneHeightRT;
        }
        set { m_SceneHeightRT = value; }
    }

    [SerializeField] private Matrix4x4 m_SceneHeightMatrixVP;
    private HeightMapRenderPass m_ScriptablePass;

    public static Matrix4x4 SceneHeightMatrixVP;
    void OnValidate()
    {
        LockEdit = m_LockEdit;
        Init();
    }

    void OnEnable()
    {
        LockEdit = m_LockEdit;
        Init();
        SceneHeightMatrixVP = m_SceneHeightMatrixVP;
#if UNITY_EDITOR

        m_ScriptablePass = new HeightMapRenderPass(SceneHeightRT)
        {
            renderPassEvent = RenderPassEvent.AfterRenderingTransparents
        };
        RenderPipelineManager.beginCameraRendering += BeginCameraRendering;
#endif
    }



    void OnDisable()
    {
#if UNITY_EDITOR
        m_SceneHeightRT?.Release();
        m_HeightMapShader = null;
        RenderPipelineManager.beginCameraRendering -= BeginCameraRendering;
#endif
    }

    void Init()
    {
        m_Camera = GetComponent<Camera>();
        m_Camera.transform.rotation = Quaternion.Euler(90, 0, 0);
        m_Camera.depth = -1;
        m_Camera.targetTexture = SceneHeightRT;
        // m_Camera.SetReplacementShader(HeightMapShader, "");
        if (Application.isPlaying)
        {
            m_Camera.enabled = false;
        }
        m_SceneHeightMatrixVP = GetMatrixVP();
    }


    public bool IsChanged()
    {
        var matrixVP = GetMatrixVP();
        return !matrixVP.Equals(m_SceneHeightMatrixVP);
    }

    void Update()
    {
        SetCameraParms();
    }

    public void SetCameraParms()
    {
        if (m_Camera)
        {
            m_Camera.orthographic = true;
            m_Camera.clearFlags = CameraClearFlags.Color;
            m_Camera.backgroundColor = Color.white;
            m_Camera.allowMSAA = false;
            m_Camera.allowHDR = false;
        }
    }

    public Vector3 WorldToCameraPosition(Vector3 pos)
    {
        var newPos = new Vector4(pos.x, pos.y, pos.z, 1);
        return m_Camera.worldToCameraMatrix * newPos;
    }

    public Vector3 WorldToProjectPosition(Vector3 pos)
    {
        var newPos = new Vector4(pos.x, pos.y, pos.z, 1);
        var matrixVP = GetMatrixVP();
        return matrixVP * newPos;
    }

    public Matrix4x4 GetMatrixVP()
    {
        Matrix4x4 ProjectionMatrix = GL.GetGPUProjectionMatrix(m_Camera.projectionMatrix, false);
        return ProjectionMatrix * m_Camera.worldToCameraMatrix;
    }


    private void BeginCameraRendering(ScriptableRenderContext context, Camera camera)
    {
        CameraType cameraType = camera.cameraType;
        if (cameraType == CameraType.Preview || !camera.gameObject.Equals(gameObject)) return;


        ScriptableRenderer renderer = camera.GetUniversalAdditionalCameraData().scriptableRenderer;

        renderer.EnqueuePass(m_ScriptablePass);
    }


    // ScripteableRenderPass
    class HeightMapRenderPass : ScriptableRenderPass
    {
        ProfilingSampler m_ProfilingSampler = new ProfilingSampler("HeightMapRender");
        RenderTexture m_SceneHeightRT;
        FilteringSettings m_FilteringSettings;
        ShaderTagId m_ShaderTagId = new ShaderTagId("UniversalForward");
        Material m_OverrideMaterial;

        public HeightMapRenderPass(RenderTexture target)
        {
            m_SceneHeightRT = target;
            m_FilteringSettings = new FilteringSettings(RenderQueueRange.all);
            m_OverrideMaterial = CoreUtils.CreateEngineMaterial(m_HeightMapShaderName);
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            Camera camera = renderingData.cameraData.camera;
            CommandBuffer cmd = CommandBufferPool.Get();

            DrawingSettings drawingSettings = CreateDrawingSettings(m_ShaderTagId, ref renderingData,
                renderingData.cameraData.defaultOpaqueSortFlags);
            drawingSettings.overrideMaterial = m_OverrideMaterial;
            drawingSettings.overrideMaterialPassIndex = 0;

            using (new ProfilingScope(cmd, m_ProfilingSampler))
            {
                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();

                cmd.SetRenderTarget(m_SceneHeightRT);
                cmd.ClearRenderTarget(true, true, Color.white);

                context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref m_FilteringSettings);
                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();
            }

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }
    }
}
