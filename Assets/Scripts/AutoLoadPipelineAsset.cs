using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[ExecuteAlways]
public class AutoLoadPipelineAsset : MonoBehaviour
{
    private static UniversalRenderPipelineAsset _defaultPipelineAsset;
    public static UniversalRenderPipelineAsset defaultPipelineAsset
    {
        get
        {
            if (!_defaultPipelineAsset)
            {
                _defaultPipelineAsset = Resources.Load<UniversalRenderPipelineAsset>("UniversalRenderPipelineAsset");
            }
            return _defaultPipelineAsset;
        }
    }
    public UniversalRenderPipelineAsset pipelineAsset;

    private void OnEnable()
    {
        UpdatePipeline();
    }

    private void OnValidate()
    {
        UpdatePipeline();
    }

    void UpdatePipeline()
    {
        if (pipelineAsset)
        {
            GraphicsSettings.renderPipelineAsset = pipelineAsset;
        }
        else
        {
            ResetPipeline();
        }
    }

    private void OnDisable()
    {
        ResetPipeline();
    }

    // [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]
    private void ResetPipeline()
    {
        if (defaultPipelineAsset)
        {
            GraphicsSettings.renderPipelineAsset = defaultPipelineAsset;
        }
    }

}
