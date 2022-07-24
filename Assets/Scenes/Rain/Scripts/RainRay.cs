using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class RainRay : MonoBehaviour
{

    public static RainRay Instance;

    public float boundSize = 0;
    public float boundSizeBase = 0f;

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
        // Ray ray = Camera.main.ScreenPointToRay(transform.position);
        Ray ray = new Ray(transform.position, Vector3.up);
        RaycastHit hit;
        if (Physics.Raycast(ray, out hit, 99999, LayerMask.GetMask("SceneStatic")))
        {
            Debug.Log(hit.transform.name);
            var collider = hit.collider;
            Debug.Log(collider.bounds.size);
            boundSize = collider.bounds.size.x + boundSizeBase;
        }
        else
        {
            boundSize = boundSizeBase;
        }
        Debug.DrawRay(ray.origin, ray.direction * 100, Color.red);
    }
}
