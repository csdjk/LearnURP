using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Worley : MonoBehaviour
{
    
    public static Vector2 Generate(float x, float y, int seed, int tile_x, int tile_y)
    {
        Vector2[,] points = new Vector2[3,3];

        Vector2 pos = new Vector2(x, y);
        Vector2 dist = new Vector2(3, 3);

        for (int i = -1; i < 2; i++)
        {
            for (int j = -1; j < 2; j++)
            {
                int x_i = (tile_x > 0) ? ((i + (int)x) % tile_x + tile_x) % tile_x : (i + (int)x);
                int y_j = (tile_y > 0) ? ((j + (int)y) % tile_y + tile_y) % tile_y : (j + (int)y);
                points[i + 1, j + 1] = RandomPoint(x_i, y_j, seed) + new Vector2((i + (int)x), (j + (int)y));
                float d = Vector2.Distance(points[i + 1, j + 1], pos);
                if (d < dist.x) dist.x = d;
                else if (d < dist.y) dist.y = d;
            }
        }
        
        return dist;
    }

    public static Vector2 Generate(float x, float y, float z, int seed, int tile_x, int tile_y, int tile_z)
    {
        Vector3[,,] points = new Vector3[3, 3, 3];

        Vector3 pos = new Vector3(x, y, z);
        Vector2 dist = new Vector2(3, 3);

        for (int i = -1; i < 2; i++)
        {
            for (int j = -1; j < 2; j++)
            {
                for (int k = -1; k < 2; k++)
                {
                    int x_i = (tile_x > 0) ? ((i + (int)x) % tile_x + tile_x) % tile_x : (i + (int)x);
                    int y_j = (tile_y > 0) ? ((j + (int)y) % tile_y + tile_y) % tile_y : (j + (int)y);
                    int z_k = (tile_z > 0) ? ((k + (int)z) % tile_z + tile_z) % tile_z : (k + (int)z);
                    points[i + 1, j + 1, k + 1] = RandomPoint(x_i, y_j, z_k, seed) + new Vector3((i + (int)x), (j + (int)y), (k + (int)z));
                    float d = Vector3.Distance(points[i + 1, j + 1, k + 1], pos);
                    if (d < dist.x) dist.x = d;
                    else if (d < dist.y) dist.y = d;
                }
            }
        }

        return dist;
    }

    private static Vector2 RandomPoint(int x, int y, int seed)
    {
        Vector2 p = new Vector2();
        System.Random rnd = new System.Random(hash(x, y, seed));
        p.x = (float)rnd.NextDouble();
        p.y = (float)rnd.NextDouble();
        return p;
    }

    private static Vector3 RandomPoint(int x, int y, int z, int seed)
    {
        Vector3 p = new Vector3();
        System.Random rnd = new System.Random(hash(x, y, z, seed));
        p.x = (float)rnd.NextDouble();
        p.y = (float)rnd.NextDouble();
        p.z = (float)rnd.NextDouble();
        return p;
    }

    private static int hash(int x, int y, int seed)
    {
        int h = seed + x * 374761393 + y * 668265263; // Prime constants
        h = (h ^ (h >> 13)) * 1274126177;
        return h ^ (h >> 16);
    }

    private static int hash(int x, int y, int z, int seed)
    {
        int h = seed + x * 374761393 + y * 668265263 + z * 458266957; // Prime constants
        h = (h ^ (h >> 13)) * 1274126177;
        return h ^ (h >> 16);
    }

}
