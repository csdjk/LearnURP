using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class VolumetricLightComponent : MonoBehaviour
{
    public float intensity = 1.0f;
    public Color lightingColor = Color.white;

    public bool TryGetViewPosition(Camera camera, out Vector3 viewPosition)
    {
        viewPosition = camera.WorldToViewportPoint(camera.transform.position - transform.forward);

        if (viewPosition.x < -1 || viewPosition.x > 2 || viewPosition.y < -1 || viewPosition.y > 2)
        {
            return false;
        }

        if (viewPosition.z <= 0)
        {
            return false;
        }

        return true;
    }

    void OnEnable()
    {
        VolumetricLightData.Instance.AddData(this);
    }


    void OnDisable()
    {
        VolumetricLightData.Instance.RemoveData(this);
    }
}

public class VolumetricLightData
{
    private static VolumetricLightData m_Instance = null;
    private static readonly object m_Padlock = new object();
    private static List<VolumetricLightComponent> m_Data = new List<VolumetricLightComponent>();

    public static VolumetricLightData Instance
    {
        get
        {
            if (m_Instance == null)
            {
                lock (m_Padlock)
                {
                    if (m_Instance == null)
                    {
                        m_Instance = new VolumetricLightData();
                    }
                }
            }
            return m_Instance;
        }
    }
    public List<VolumetricLightComponent> Data { get { return m_Data; } }

    public void AddData(VolumetricLightComponent newData)
    {
        Debug.Assert(Instance == this, "VolumetricLightData can have only one instance");

        if (!m_Data.Contains(newData))
        {
            m_Data.Add(newData);
        }
    }
    public void RemoveData(VolumetricLightComponent data)
    {
        Debug.Assert(Instance == this, "VolumetricLightData can have only one instance");

        if (m_Data.Contains(data))
        {
            m_Data.Remove(data);
        }
    }

}
