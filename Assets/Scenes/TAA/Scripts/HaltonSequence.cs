using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace LcLGame
{
    /// <summary>
    /// An utility class to compute samples on the Halton sequence.
    /// https://en.wikipedia.org/wiki/Halton_sequence
    /// </summary>
   public struct HaltonSequence
    {
        int count;
        int index;
        float[] arrX;
        float[] arrY;

        public Matrix4x4 prevViewProj;
        public int frameCount;

        public HaltonSequence(int count)
        {
            this.count = count;
            index = 0;
            arrX = new float[count];
            arrY = new float[count];
            prevViewProj = Matrix4x4.zero;
            frameCount = 0;
            for (int i = 0; i < arrX.Length; i++)
            {
                arrX[i] = get(i, 2);
            }

            for (int i = 0; i < arrY.Length; i++)
            {
                arrY[i] = get(i, 3);
            }
        }

        float get(int index, int @base)
        {
            float fraction = 1;
            float result = 0;

            while (index > 0)
            {
                fraction /= @base;
                result += fraction * (index % @base);
                index /= @base;
            }

            return result;
        }

        /// <summary>
        /// Gets a deterministic sample in the Halton sequence.
        /// </summary>
        public void Get(out float x, out float y)
        {
            if (++index == count) index = 1;
            x = arrX[index];
            y = arrY[index];
        }

        public (float, float) Get()
        {
            if (++index == count) index = 1;
            return (arrX[index], arrY[index]);
        }
    }
}
