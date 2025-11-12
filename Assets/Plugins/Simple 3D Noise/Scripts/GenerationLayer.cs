using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Unity.Jobs;
using Unity.Collections;

[System.Serializable]
public enum LayerMode
{
    Multiply,
    Add,
    Subract,
    Divide,
    Max,
    Min
}

[System.Flags]
public enum ChannelFlag
{
    R = (1 << 0),
    G = (1 << 1),
    B = (1 << 2),
    A = (1 << 3)
}

[System.Serializable]
public struct GenerationLayer
{
    public FractalGenerator Generator;
    public LayerMode Mode;
    [EnumFlag]
    public ChannelFlag Channels;
    public bool Visible;
    
    public GenerationLayer Copy()
    {
        GenerationLayer copy = new GenerationLayer();
        copy.Channels = Channels;
        copy.Mode = Mode;
        copy.Generator = Generator.Copy();
        copy.Visible = Visible;
        return copy;
    }

    public GenerationLayer(
        LayerMode Mode = LayerMode.Multiply,
        ChannelFlag Channels = ChannelFlag.A | ChannelFlag.B | ChannelFlag.G | ChannelFlag.R,
        bool Visible = true)
    {
        this.Generator = new FractalGenerator(0);
        this.Mode = Mode;
        this.Channels = Channels;
        this.Visible = Visible;
    }

    public GenerationLayer(
        FractalGenerator Generator,
        LayerMode Mode = LayerMode.Multiply,
        ChannelFlag Channels = ChannelFlag.A | ChannelFlag.B | ChannelFlag.G | ChannelFlag.R,
        bool Visible = true)
    {
        this.Generator = Generator;
        this.Mode = Mode;
        this.Channels = Channels;
        this.Visible = Visible;
    }

}

public struct GenerationLayerJob : IJobParallelFor
{

    private GenerationLayer layer;
    private int resolution;
    private bool is_3d;
    private int x_tile;
    private Vector3 tiling;
    
    public NativeArray<float> ValueBuffer;

    public GenerationLayerJob(GenerationLayer layer, int resolution, bool is_3d, int x_tile, Vector3 tiling)
    {
        this.layer = layer;
        this.resolution = resolution;
        this.is_3d = is_3d;
        this.x_tile = x_tile;
        this.tiling = tiling;

        ValueBuffer = new NativeArray<float>(resolution * resolution * ((is_3d) ? resolution : 1), Allocator.Persistent);

    }

    public void Execute(int index)
    {
        if (is_3d)
        {
            int X = index % (resolution * x_tile);
            int Y = index / (resolution * x_tile);
            int x = index % resolution;
            int y = Y % resolution;
            int z = (Y / resolution) + (X / resolution);

            ValueBuffer[index] = layer.Generator.Generate(((x * tiling.x) / resolution) % 1.0f, ((y * tiling.y) / resolution) % 1.0f, ((z * tiling.z) / resolution) % 1.0f);
        }
        else
        {
            int x = index % resolution;
            int y = index / resolution;

            ValueBuffer[index] = layer.Generator.Generate(((x * tiling.x) / resolution) % 1.0f, ((y * tiling.y) / resolution) % 1.0f);
        }
    }
}