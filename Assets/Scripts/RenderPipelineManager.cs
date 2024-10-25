using System.Linq;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public static class RenderPipelineAssetManager
{
    public static UniversalRenderPipelineAsset RenderPipelineAsset
    {
        get
        {
            return GraphicsSettings.currentRenderPipeline as UniversalRenderPipelineAsset;
        }
    }

    public static ScriptableRendererData[] RendererDataList
    {
        get
        {
            return RenderPipelineAsset.rendererDataList;
        }
    }


    public static ScriptableRendererData DefaultRendererData
    {
        get
        {
            if (RendererDataList != null)
            {
                return RendererDataList[0];
            }
            return null;
        }
    }

     public static ScriptableRendererData GetRendererDataByName(string name)
    {
        if (RendererDataList != null)
        {
            foreach (var rendererData in RendererDataList)
            {
                if (rendererData != null && rendererData.name == name)
                {
                    return rendererData;
                }
            }
        }
        return null;
    }

    public static T GetRendererFeatures<T>(this ScriptableRendererData renderData) where T : ScriptableRendererFeature
    {
        if (renderData != null)
        {
            foreach (var rendererFeature in renderData.rendererFeatures)
            {
                if (rendererFeature != null && rendererFeature.GetType() == typeof(T))
                {
                    return rendererFeature as T;
                }
            }
        }
        return null;
    }

    public static T GetRendererFeatures<T>(this ScriptableRendererData renderData,string name) where T : ScriptableRendererFeature
    {
        if (renderData != null)
        {
            foreach (var rendererFeature in renderData.rendererFeatures)
            {
                if (rendererFeature != null && rendererFeature.GetType() == typeof(T) && rendererFeature.name == name)
                {
                    return rendererFeature as T;
                }
            }
        }
        return null;
    }

}
