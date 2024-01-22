using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[ExecuteAlways]
public class AutoLoadPipelineAsset : MonoBehaviour
{
    private static UniversalRenderPipelineAsset m_DefaultPipelineAsset;
    public static UniversalRenderPipelineAsset DefaultPipelineAsset
    {
        get
        {
            if (!m_DefaultPipelineAsset)
            {
                m_DefaultPipelineAsset = Resources.Load<UniversalRenderPipelineAsset>("UniversalRenderPipelineAsset");
            }
            return m_DefaultPipelineAsset;
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
            QualitySettings.renderPipeline = pipelineAsset;
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
        if (DefaultPipelineAsset)
        {
            GraphicsSettings.renderPipelineAsset = DefaultPipelineAsset;
            QualitySettings.renderPipeline = DefaultPipelineAsset;
        }
    }

}
