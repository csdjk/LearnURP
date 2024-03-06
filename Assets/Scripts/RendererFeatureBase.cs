
namespace LcLGame
{
    using UnityEditor;
    using UnityEngine;
    using UnityEngine.Rendering;
    using UnityEngine.Rendering.Universal;

    [ExecuteAlways]
    public abstract class RendererFeatureBase : MonoBehaviour
    {
        public abstract void Create();
        public abstract void AddRenderPasses(ScriptableRenderer renderer);

        public virtual void Dispose()
        {
        }
        public virtual bool RenderPreview()
        {
            return false;
        }
        private void OnEnable()
        {
            RenderPipelineManager.beginCameraRendering += BeginCameraRendering;
            Create();
        }

        private void OnDisable()
        {
            RenderPipelineManager.beginCameraRendering -= BeginCameraRendering;
            Dispose();
        }


        private void OnValidate()
        {
            Dispose();
            Create();
        }

        private void BeginCameraRendering(ScriptableRenderContext context, Camera camera)
        {
            CameraType cameraType = camera.cameraType;
            if (!RenderPreview() && cameraType == CameraType.Preview)
                return;

            ScriptableRenderer renderer = camera.GetUniversalAdditionalCameraData().scriptableRenderer;
            AddRenderPasses(renderer);
        }
    }


    [CustomEditor(typeof(RendererFeatureBase))]
    public class RendererFeatureBaseEditor : Editor
    {
        public override void OnInspectorGUI()
        {
            EditorGUI.BeginChangeCheck();

            base.OnInspectorGUI();

            if (EditorGUI.EndChangeCheck())
            {
                Debug.Log("VAR");
            }

        }
    }

}
