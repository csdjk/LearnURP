using UnityEngine;

[ExecuteAlways]
public class PrintBound : MonoBehaviour
{
    void OnEnable()
    {
        // 获取当前对象的 Renderer
        Renderer renderer = GetComponent<Renderer>();
        if (renderer != null)
        {
            // 打印 Renderer 的 Bounds
            Debug.Log($"Renderer Bounds: Center = {renderer.bounds.center}, Size = {renderer.bounds.size}");
        }

        // 获取当前对象的 Collider
        Collider collider = GetComponent<Collider>();
        if (collider != null)
        {
            // 打印 Collider 的 Bounds
            Debug.Log($"Collider Bounds: Center = {collider.bounds.center}, Size = {collider.bounds.size}");
        }
    }
}
