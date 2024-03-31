using System;
using UnityEngine.Experimental.Rendering;
using Unity.Mathematics;
using LcLGame;


namespace UnityEngine.Rendering.Universal
{

    [ExecuteAlways]
    public class PlanerReflection : MonoBehaviour
    {

        [Serializable]
        public enum ResolutionMulltiplier { Full, Half, Third, Quarter }

        [Serializable]
        public class PlanarReflectionSettings
        {
            public ResolutionMulltiplier resolutionMultiplier = ResolutionMulltiplier.Full;
            public float clipPlaneOffset = 0.07f;
            public LayerMask reflectLayers = -1;
            public string cameraTag = "MainCamera";
            public bool shadows;
            public CameraClearFlags clearFlags;
            public Color backgroundColor = new Color(0, 0, 0, 0);
        }
        public int rendererIndex = 0;
        [SerializeField]
        public PlanarReflectionSettings settings = new PlanarReflectionSettings();
        public GameObject targetPlane;
        public float planeOffset;

        [SerializeField, HideInInspector]
        Camera m_ReflectionCamera;
        RenderTexture m_ReflectionTexture;
        readonly int m_PlanarReflectionTextureId = Shader.PropertyToID("_PlanarReflectionTexture");

        private void OnEnable()
        {
            var rpAsset = UniversalRenderPipeline.asset;

            // int selectedRenderer = EditorGUI.IntPopup(controlRect, Styles.rendererType, selectedRendererOption, rpAsset.rendererDisplayList, rpAsset.rendererIndexList);


            // if (IsSupport())
            {
                RenderPipelineManager.beginCameraRendering += ExecutePlanarReflections;
            }
        }

        public static bool IsSupport()
        {
            return QualitySettings.GetQualityLevel() == 0;
        }

        private void OnDisable()
        {
            Cleanup();
        }

        private void OnDestroy()
        {
            Cleanup();
        }

        private void OnValidate()
        {
            ClearRT();
        }
        private void Cleanup()
        {
            RenderPipelineManager.beginCameraRendering -= ExecutePlanarReflections;
            if (m_ReflectionCamera)
            {
                CoreUtils.Destroy(m_ReflectionCamera.gameObject);
                m_ReflectionCamera = null;
            }
            ClearRT();
        }


        private void ClearRT()
        {
            if (m_ReflectionTexture)
            {
                RenderTexture.ReleaseTemporary(m_ReflectionTexture);
                m_ReflectionTexture = null;
            }
        }

        private static void SafeDestroy(Object obj)
        {
#if UNITY_EDITOR
            DestroyImmediate(obj);
#else
                Destroy(obj);
#endif
        }

        // 校验Camera tag
        private bool CheckCameraTag(Camera camera)
        {
            // #if UNITY_EDITOR
            //             if (camera.cameraType == CameraType.SceneView)
            //             {
            //                 return true;
            //             }
            // #endif
            if (settings.cameraTag.Equals(string.Empty) || camera.CompareTag(settings.cameraTag))
            {
                return true;
            }
            return false;
        }
        private void ExecutePlanarReflections(ScriptableRenderContext context, Camera camera)
        {
            //过滤部分Camera
            if (camera.cameraType == CameraType.Reflection || camera.cameraType == CameraType.Preview)
            {
                return;
            }
            if (camera.gameObject.TryGetComponent(out UniversalAdditionalCameraData additionalCameraData))
            {
                // 过滤Overlay Camera
                if (additionalCameraData.renderType == CameraRenderType.Overlay)
                {
                    return;
                }
            }

            if (!CheckCameraTag(camera))
            {
                return;
            }
            // 防止 当Camera和plane刚好在同一水平面时报错
            Plane reflectionPlane = new Plane(transform.up, transform.position);
            if (Mathf.Abs(Vector3.Dot(transform.up, camera.transform.forward)) < 0.01f && (camera.orthographic || reflectionPlane.GetDistanceToPoint(camera.transform.position) < 0.025f))
            {
                return;
            }

            if (targetPlane == null)
            {
                targetPlane = gameObject;
            }
            if (m_ReflectionCamera == null)
            {
                m_ReflectionCamera = CreateReflectCamera();
            }

            var data = new PlanarReflectionSettingData(); // save quality settings and lower them for the planar reflections
            data.Set(); // set quality settings

            UpdateReflectionCamera(camera);  // 设置相机位置和方向等参数
            CreatePlanarReflectionTexture(camera);  // create and assign RenderTexture

            // BeginPlanarReflections?.Invoke(context, _reflectionCamera); // callback Action for PlanarReflection
            // if (!camera.orthographic)
            {
                // 开始渲染
                UniversalRenderPipeline.RenderSingleCamera(context, m_ReflectionCamera);
            }

            // restore the quality settings
            data.Restore();
            Shader.SetGlobalTexture(m_PlanarReflectionTextureId, m_ReflectionTexture);
        }

        private int2 ReflectionResolution(Camera cam, float scale)
        {
            var x = (int)(cam.pixelWidth * scale * GetScaleValue());
            var y = (int)(cam.pixelHeight * scale * GetScaleValue());
            return new int2(Mathf.Max(x, 2), Mathf.Max(y, 2));
        }

        private float GetScaleValue()
        {
            switch (settings.resolutionMultiplier)
            {
                case ResolutionMulltiplier.Full:
                    return 1f;
                case ResolutionMulltiplier.Half:
                    return 0.5f;
                case ResolutionMulltiplier.Third:
                    return 0.33f;
                case ResolutionMulltiplier.Quarter:
                    return 0.25f;
                default:
                    return 0.5f; // default to half res
            }
        }

        private void CreatePlanarReflectionTexture(Camera cam)
        {
            if (m_ReflectionTexture == null)
            {
                var res = ReflectionResolution(cam, UniversalRenderPipeline.asset.renderScale);  // 获取 RT 的大小
                const bool useHdr10 = true;
                const RenderTextureFormat hdrFormat = useHdr10 ? RenderTextureFormat.RGB111110Float : RenderTextureFormat.DefaultHDR;
                // const RenderTextureFormat hdrFormat = useHdr10 ? RenderTextureFormat.ARGB32 : RenderTextureFormat.DefaultHDR;
                m_ReflectionTexture = RenderTexture.GetTemporary(res.x, res.y, 16, GraphicsFormatUtility.GetGraphicsFormat(hdrFormat, false));
                m_ReflectionTexture.wrapMode = TextureWrapMode.Repeat;
                m_ReflectionTexture.name = "Planar Reflection Texture";
            }
            m_ReflectionCamera.targetTexture = m_ReflectionTexture;

        }
        private void UpdateCamera(Camera src, Camera dest)
        {
            if (dest == null) return;

            // dest.CopyFrom(src);
            dest.aspect = src.aspect;
            dest.cameraType = src.cameraType;   // 这个参数不同步就错
            dest.clearFlags = src.clearFlags;
            dest.fieldOfView = src.fieldOfView;
            dest.depth = src.depth;
            dest.farClipPlane = src.farClipPlane;
            dest.focalLength = src.focalLength;
            dest.useOcclusionCulling = false;

            if (settings.clearFlags != 0)
            {
                dest.clearFlags = settings.clearFlags;
                dest.backgroundColor = settings.backgroundColor;
            }
            else
            {
                dest.clearFlags = src.clearFlags;
                dest.backgroundColor = src.backgroundColor;
            }

            if (dest.gameObject.TryGetComponent(out UniversalAdditionalCameraData camData))
            {
                // todo
                camData.renderShadows = settings.shadows; // turn off shadows for the reflection camera
            }
        }

        // Calculates reflection matrix around the given plane
        private static Matrix4x4 CalculateReflectionMatrix(Vector4 plane)
        {
            Matrix4x4 reflectionMat = Matrix4x4.identity;
            reflectionMat.m00 = (1F - 2F * plane[0] * plane[0]);
            reflectionMat.m01 = (-2F * plane[0] * plane[1]);
            reflectionMat.m02 = (-2F * plane[0] * plane[2]);
            reflectionMat.m03 = (-2F * plane[3] * plane[0]);

            reflectionMat.m10 = (-2F * plane[1] * plane[0]);
            reflectionMat.m11 = (1F - 2F * plane[1] * plane[1]);
            reflectionMat.m12 = (-2F * plane[1] * plane[2]);
            reflectionMat.m13 = (-2F * plane[3] * plane[1]);

            reflectionMat.m20 = (-2F * plane[2] * plane[0]);
            reflectionMat.m21 = (-2F * plane[2] * plane[1]);
            reflectionMat.m22 = (1F - 2F * plane[2] * plane[2]);
            reflectionMat.m23 = (-2F * plane[3] * plane[2]);

            reflectionMat.m30 = 0F;
            reflectionMat.m31 = 0F;
            reflectionMat.m32 = 0F;
            reflectionMat.m33 = 1F;

            return reflectionMat;
        }
        // Given position/normal of the plane, calculates plane in camera space.
        private Vector4 CameraSpacePlane(Camera cam, Vector3 pos, Vector3 normal, float sideSign)
        {
            var offsetPos = pos + normal * settings.clipPlaneOffset;
            var m = cam.worldToCameraMatrix;
            var cameraPosition = m.MultiplyPoint(offsetPos);
            var cameraNormal = m.MultiplyVector(normal).normalized * sideSign;
            return new Vector4(cameraNormal.x, cameraNormal.y, cameraNormal.z, -Vector3.Dot(cameraPosition, cameraNormal));
        }

        private void UpdateReflectionCamera(Camera curCamera)
        {
            if (targetPlane == null)
            {
                Debug.LogError("target plane is null!");
            }

            Vector3 planeNormal = targetPlane.transform.up;
            Vector3 planePos = targetPlane.transform.position + planeNormal * planeOffset;

            UpdateCamera(curCamera, m_ReflectionCamera);  // 同步当前相机数据

            // 获取视空间平面，使用反射矩阵，将图像根据平面对称上下颠倒
            var planVS = new Vector4(planeNormal.x, planeNormal.y, planeNormal.z, -Vector3.Dot(planeNormal, planePos));
            Matrix4x4 reflectionMat = CalculateReflectionMatrix(planVS);
            m_ReflectionCamera.worldToCameraMatrix = curCamera.worldToCameraMatrix * reflectionMat;
            // 斜截视锥体
            var clipPlane = CameraSpacePlane(m_ReflectionCamera, planePos, planeNormal, 1.0f);

            var newProjectionMat = CalculateObliqueMatrix(curCamera, clipPlane);
            m_ReflectionCamera.projectionMatrix = newProjectionMat;
            m_ReflectionCamera.cullingMask = settings.reflectLayers; // never render water layer

        }
        private Matrix4x4 CalculateObliqueMatrix(Camera cam, Vector4 plane)
        {

            Vector4 Q_clip = new Vector4(Mathf.Sign(plane.x), Mathf.Sign(plane.y), 1f, 1f);
            Vector4 Q_view = cam.projectionMatrix.inverse.MultiplyPoint(Q_clip);

            Vector4 scaled_plane = plane * 2.0f / Vector4.Dot(plane, Q_view);
            Vector4 M3 = scaled_plane - cam.projectionMatrix.GetRow(3);

            Matrix4x4 new_M = cam.projectionMatrix;
            new_M.SetRow(2, M3);

            // 使用 unity API
            // var new_M = cam.CalculateObliqueMatrix(plane);
            return new_M;
        }

        private Camera CreateReflectCamera()
        {
            var go = new GameObject("PlanarReflectionCamera", typeof(Camera));
            var cameraData = go.AddComponent(typeof(UniversalAdditionalCameraData)) as UniversalAdditionalCameraData;
            cameraData.requiresColorOption = CameraOverrideOption.Off;
            cameraData.requiresDepthOption = CameraOverrideOption.Off;
            cameraData.renderShadows = false;
            cameraData.SetRenderer(rendererIndex);
            // SetCameraRender(cameraData);

            var reflectionCamera = go.GetComponent<Camera>();
            // reflectionCamera.tag = "PlanarReflectionCamera";
            reflectionCamera.transform.SetPositionAndRotation(transform.position, transform.rotation);  // 相机初始位置设为当前 gameobject 位置
            reflectionCamera.depth = -10;  // 渲染优先级 [-100, 100]
            reflectionCamera.enabled = false;
            reflectionCamera.transform.SetParent(transform);
            go.hideFlags = HideFlags.HideAndDontSave;
            return reflectionCamera;
        }



        class PlanarReflectionSettingData
        {
            private readonly bool m_Fog;
            private readonly int m_MaxLod;
            private readonly float m_LodBias;
            private bool m_InvertCulling;

            public PlanarReflectionSettingData()
            {
                m_Fog = RenderSettings.fog;
                m_MaxLod = QualitySettings.maximumLODLevel;
                m_LodBias = QualitySettings.lodBias;
            }

            public void Set()
            {
                m_InvertCulling = GL.invertCulling;
                GL.invertCulling = !m_InvertCulling;  // 因为镜像后绕序会反，将剔除反向
                RenderSettings.fog = false;
                QualitySettings.maximumLODLevel = 1;
                QualitySettings.lodBias = m_LodBias * 0.5f;
            }

            public void Restore()
            {
                GL.invertCulling = m_InvertCulling;
                RenderSettings.fog = m_Fog;
                QualitySettings.maximumLODLevel = m_MaxLod;
                QualitySettings.lodBias = m_LodBias;
            }
        }

    }
}
