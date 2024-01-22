using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[System.Serializable]
public class RainLayerData
{
    public Vector2 tilling = new Vector2(10f, 10f);
    public Vector2 speed = new Vector2(0f, 50f);
    [Range(0, 30)]
    public float depthBase = 0f;
    [Range(0, 50)]
    public float depthRange = 1f;

    [Range(0, 1)]
    public float threshold = 0.5f;
    [Range(0, 1)]
    public float smoothness = 0.5f;

    [Range(0, 10)]
    public float intensity = 1.5f;
}

[ExecuteAlways]
public class Rain : MonoBehaviour
{
    public Mesh rainMesh;
    public float meshScale = 1f;
    public Texture2D rainTexture = null;
    public Texture sceneHeightRT;

    public Color rainColor = Color.gray;
    public RainLayerData layerNear = new RainLayerData { depthBase = 2f, depthRange = 3 };
    public RainLayerData layerFar = new RainLayerData { tilling = new Vector2(20, 20), depthBase = 7, depthRange = 40 };

    public Vector3 windDir = Vector3.zero;


    public static Rain Instance;

    void OnEnable()
    {
        Instance = this;
    }


    void OnDisable()
    {
        Instance = null;
    }

    void Update()
    {

    }
}
