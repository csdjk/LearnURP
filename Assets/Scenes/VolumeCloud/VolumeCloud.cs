using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class VolumeCloud : MonoBehaviour
{
    static VolumeCloud instance;
    public static VolumeCloud Instance => instance;
    public static readonly int cloudTextureID = Shader.PropertyToID("_CloudTexture");
    public static readonly int voxelSizeID = Shader.PropertyToID("_VoxelSize");
    public static readonly int invScaleID = Shader.PropertyToID("_InvScale");
    public static readonly int globalScaleID = Shader.PropertyToID("_GlobalScale");
    public static readonly int invResolutionID = Shader.PropertyToID("_InvResolution");
    public static readonly int scaleID = Shader.PropertyToID("_Scale");


    public Texture3D cloudTexture;
    public Vector3 noiseTiling = new Vector3(1, 1, 1);
    public Vector3 noiseOffset = new Vector3(0, 0, 0);
    public Texture2D blurNoise;
    public Vector2 blurTiling = new Vector2(1, 1);
    [Range(0, 0.1f)]
    public float blurIntensity = 0.01f;

    public Color color = Color.white;
    public Color shadowColor = Color.black;
    [Range(0, 5)]
    public int downSample = 1;
    [Range(0, 300)]
    public int maxStep = 100;
    [Range(0.001f, 0.3f)]
    public float sdfThreshold = 0.0f;
    [Range(0, 2)]
    public float stepScale = 1f;
    [Range(0, 10f)]
    public float densityScale = 1;
    [Range(0, 10f)]
    public float densityPower = 1;


    [Range(0, 1)]
    public float lightAbsorptionThroughCloud = 1f;

    [Range(0, 1)]
    public float darknessThreshold = 0.1f;
    [Range(0, 1)]
    public float scatterForward = 0.1f;
    [Range(0, 1)]
    public float scatterBackward = 0.1f;
    [Range(0, 1)]
    public float scatterWeight = 0.1f;


    public Vector3 BoundMax => transform.position + transform.localScale * 0.5f;
    public Vector3 BoundMin => transform.position - transform.localScale * 0.5f;




    public Vector3 resolution => new Vector3(cloudTexture.width, cloudTexture.height, cloudTexture.depth);
    [HideInInspector]
    public Vector3 invScale;
    [HideInInspector]
    public Vector3 voxelSize;
    [HideInInspector]
    public float inverseResolution;
    [HideInInspector]
    public float boundSize;


    static Vector3 VoxelSize(Vector3 textureResolution, out float inverseResolution)
    {
        inverseResolution = 1.0f / Mathf.Max(textureResolution.x, textureResolution.y, textureResolution.z);
        return new Vector3(textureResolution.x * inverseResolution, textureResolution.y * inverseResolution, textureResolution.z * inverseResolution);
    }

    void OnEnable()
    {
        instance = this;
    }

    void OnDisable()
    {
        instance = null;
    }

    private void OnValidate()
    {
        UpdateCloudData();
    }

#if UNITY_EDITOR
    void Update()
    {
        UpdateCloudData();
    }
#endif

    void UpdateCloudData()
    {
        if(cloudTexture == null)
        {
            return;
        }
        voxelSize = VoxelSize(resolution, out inverseResolution);
        invScale = new Vector3(1.0f / voxelSize.x, 1.0f / voxelSize.y, 1.0f / voxelSize.z);
        boundSize = Mathf.Max(transform.localScale.x, transform.localScale.y, transform.localScale.z) / 2;
    }
}
