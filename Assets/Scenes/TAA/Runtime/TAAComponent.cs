using UnityEngine;

namespace GameOldBoy.Rendering
{
    public enum TAAQuality
    {
        VeryLow,
        Low,
        Medium,
        High,
        Custom
    }

    [AddComponentMenu("Rendering/GameOldBoy/Temporal Anti-Aliasing"), RequireComponent(typeof(Camera))]
    public class TAAComponent : MonoBehaviour
    {
        public bool Enabled = true;
        [Range(0.5f, 0.999f)]
        public float Blend = 0.9375f;
        public TAAQuality Quality = TAAQuality.High;
        public bool AntiGhosting = true;
        public bool UseBlurSharpenFilter;
        public bool UseBicubicFilter;
        public bool UseClipAABB;
        public bool UseDilation;
        public bool UseTonemap;
        public bool UseVarianceClipping;
        public bool UseYCoCgSpace;
        public bool Use4Tap;
        [Min(0)]
        public float Stability = 1.5f;
        [Range(0, 2f)]
        public float SharpenStrength = 0.1f;
        [Range(0, 1f)]
        public float HistorySharpening = 0.1f;
    }
}