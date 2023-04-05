using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering.Universal;

[ExecuteAlways]
public class Test : MonoBehaviour
{
    private void OnEnable()
    {
        // for (int i = 0; i < UnityEditor.SceneView.sceneViews.Count; i++)
        // {
        //     var sv = UnityEditor.SceneView.sceneViews[i] as UnityEditor.SceneView;
        // }


        var sceneViews = SceneView.sceneViews;
        for (var i = 0; i < sceneViews.Count; i++)
        {
            var sceneView = (SceneView)sceneViews[i];
            if (sceneView.camera.TryGetComponent(out UniversalAdditionalCameraData sceneViewCameraData))
            {
                sceneViewCameraData.SetRenderer(1);
            }
        }
    }
}