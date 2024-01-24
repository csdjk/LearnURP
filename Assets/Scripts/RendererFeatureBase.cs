
namespace LcLGame
{
    using UnityEditor;
    using UnityEngine;
    using UnityEngine.Rendering;
    using UnityEngine.Rendering.Universal;

    [ExecuteAlways]
    public abstract class RendererFeatureBase : MonoBehaviour
    {
        protected abstract void Create();
        protected abstract void AddRenderPasses(ScriptableRenderer renderer);

        protected virtual void Dispose()
        {
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


        // private void OnValidate()
        // {
        //     OnDisable();
        //     OnEnable();
        // }

        private void BeginCameraRendering(ScriptableRenderContext context, Camera camera)
        {
            CameraType cameraType = camera.cameraType;
            if (cameraType == CameraType.Preview)
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
