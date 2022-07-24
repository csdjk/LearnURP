using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using UnityEditor;
using UnityEngine;
using UnityEngine.Profiling;
using Random = UnityEngine.Random;

public struct Line
{
    public Vector3 start;
    public Vector3 end;
    public bool isReal;
    public float width;
    public Color32 color;

    public Line(Vector3 start, Vector3 end, float width, Color color, bool isReal)
    {
        this.start = start;
        this.end = end;
        this.isReal = isReal;
        this.width = width;
        this.color = color;
    }
}
[Serializable]
public class LightningParameters
{
    public Vector3 startPos = new Vector3(20, 20, 0);
    public Vector3 endPos = new Vector3(0, 0, 0);
    [Tooltip("迭代总数")]
    public int totalGenerations = 8;
    [Tooltip("迭代次数")]
    public int generation = 6;
    [Tooltip("偏移因子")]
    public float chaosFactor = 0.15f;
    [Tooltip("出现分支的概率")]
    public float branchChance = 0.5f;
    [Tooltip("分形最大次数")]
    public int maxFractalTime = 5;
    [Tooltip("分支距离")]
    public float branchLength = 0.2f;
    [Tooltip("闪电宽度")]
    public float lightningWidth = 0.1f;
    [Tooltip("每个quad延伸长度")]
    public float lightningQuadExtend = 0f;

    public Material material;

    public LightningParameters()
    {

    }
}

[ExecuteInEditMode]

public class FractalLighting : MonoBehaviour
{
    [Header("Debug")]
    public bool debug = true;
    public bool drawLine = true;
    public bool meshType = true;
    public int seed = 5;
    public int showMeshNum = 5;
    private int showMeshNumCache = 5;

    public LightningParameters lightningParms;
    private Stopwatch sw;

    private LightningBolt bolt;

    public static FractalLighting Instance;

    void OnEnable()
    {
        Instance = this;
        // sw.Reset();
        // sw.Start();
        if (debug)
        {
            bolt = new LightningBolt(lightningParms, seed);
        }
        else
        {
            bolt = new LightningBolt(lightningParms, Time.frameCount);
        }
        bolt.CreateLightningBolt();

        // UnityEngine.Debug.Log(lightningParms.totalGenerations);
        // sw.Stop();
        // UnityEngine.Debug.Log(string.Format("total: {0} ms", sw.ElapsedMilliseconds));
    }
    private Color[] debugColors = { Color.red, Color.blue, Color.green, Color.magenta, Color.cyan, Color.yellow, Color.white };

#if UNITY_EDITOR

    void OnDrawGizmosSelected()
    {

        if (bolt.lightningBoltList.Count == 0 || !debug || !drawLine)
            return;

        var colorIndex = -1;
        var width = 0.1f;
        foreach (var segments in bolt.lightningBoltList)
        {
            var index = 0;
            colorIndex++;
            if (colorIndex >= debugColors.Length)
                colorIndex = 0;
            Gizmos.color = debugColors[colorIndex];
            foreach (var segment in segments)
            {
                if (segment.isReal)
                {
                    Gizmos.color = debugColors[colorIndex];

                    var start = segment.start;
                    var end = segment.end;
                    var mid = (start + end) * 0.5f;
                    Gizmos.DrawSphere(segment.start, 0.1f);
                    Gizmos.DrawLine(start, end);
                    Gizmos.color = debugColors[colorIndex] * 0.5f;
                    index++;
                }
            }
        }
    }
#endif

    private void Update()
    {
#if UNITY_EDITOR
        if (debug && showMeshNumCache != showMeshNum)
        {
            showMeshNumCache = showMeshNum;
            bolt.Clear();
            bolt.CreateLightningBolt();
        }
        return;
#endif

        // }
    }
    void OnDisable()
    {
        bolt.Clear();
    }
}

public class LightningBolt
{
    private static readonly Vector2 uv1 = new Vector2(0.0f, 0.0f);
    private static readonly Vector2 uv2 = new Vector2(1.0f, 0.0f);
    private static readonly Vector2 uv3 = new Vector2(0.0f, 1.0f);
    private static readonly Vector2 uv4 = new Vector2(1.0f, 1.0f);
    // =================渲染组件=================
    private GameObject go;
    public MeshRenderer meshRenderer;
    private MeshFilter meshFilter;
    private Mesh mesh;
    private Material material;

    // =================Mesh数据=================
    private List<Vector3> vertices = new List<Vector3>();
    private List<int> triangles = new List<int>();
    private List<Vector2> uvs = new List<Vector2>();
    private readonly List<Color32> colors = new List<Color32>();
    private readonly List<Vector3> normals = new List<Vector3>();
    private readonly List<Vector4> lineDirs = new List<Vector4>();

    private int vertexIndex = 0;

    public List<List<Line>> lightningBoltList = new List<List<Line>>();

    private System.Random random;

    private Vector3 mainCameraPos;
    private LightningParameters lightningParms;


    public LightningBolt(LightningParameters lightningParms, int seed)
    {
        this.lightningParms = lightningParms;
        Init(seed);
    }


    public void Init(int seed)
    {
        random = new System.Random(seed);
        mainCameraPos = Camera.main.transform.position;
        go = new GameObject();
        meshRenderer = go.AddComponent<MeshRenderer>();
        material = meshRenderer.material = lightningParms.material;
        meshFilter = go.AddComponent<MeshFilter>();
        mesh = new Mesh();
        mesh.MarkDynamic();
        meshFilter.mesh = mesh;
    }

    public void CreateLightningBolt()
    {

        GenerateLightningBoltPath(lightningParms.startPos, lightningParms.endPos, lightningParms.generation, lightningParms.totalGenerations, 0);
        // Mesh lightningMesh = meshType ? ConvertMesh(lightningBoltList) : ConvertMesh0(lightningBoltList);
        ConvertLightningBoltMesh();
        // ConvertMesh0();
    }

    public void Clear()
    {
#if UNITY_EDITOR
        GameObject.DestroyImmediate(go);
#else
        GameObject.Destroy(go);
#endif
        Reset();
    }
    public void Reset()
    {
        random = new System.Random(Time.frameCount);
        lightningBoltList.Clear();
        vertexIndex = 0;
        vertices.Clear();
        triangles.Clear();
        uvs.Clear();
        colors.Clear();
        lineDirs.Clear();
        normals.Clear();
    }
    /// <summary>
    /// 生成闪电
    /// </summary>
    /// <param name="start">起始位置</param>
    /// <param name="end">结束位置</param>
    /// <param name="generation">迭代次数</param>
    /// <param name="totalGenerations">最大迭代次数</param>
    /// <param name="fractalTime">分形次数</param>
    private void GenerateLightningBoltPath(Vector3 start, Vector3 end, int generation, int totalGenerations, int fractalTime)
    {
        if (fractalTime > lightningParms.maxFractalTime)
        {
            return;
        }
        List<Line> segments = new List<Line>();
        segments.Add(new Line { start = start, end = end });


        // 每个分支减少宽度
        float widthMultiplier = (float)generation / (float)totalGenerations;
        widthMultiplier *= widthMultiplier;
        var lineWidth = lightningParms.lightningWidth * 1;

        var color = new Color32();
        color.a = (byte)(255.0f * widthMultiplier);

        int startIndex = 0;
        var offsetAmount = (end - start).magnitude * lightningParms.chaosFactor;
        while (generation-- > 0)
        {
            bool isReal = generation == 0;
            int previousStartIndex = startIndex;
            startIndex = segments.Count;
            for (int i = previousStartIndex; i < startIndex; i++)
            {
                start = segments[i].start;
                end = segments[i].end;
                // 中点
                Vector3 midPoint = (start + end) * 0.5f;

                // 随机位置偏移
                midPoint += RandomVector(start, end, offsetAmount);
                var line1 = new Line { start = start, end = midPoint, width = lineWidth, color = color, isReal = isReal };
                var line2 = new Line { start = midPoint, end = end, width = lineWidth, color = color, isReal = isReal };
                segments.Add(line1);
                segments.Add(line2);
                // 生成分支
                if ((float)random.NextDouble() < lightningParms.branchChance)
                {
                    var forkMultiplier = (float)random.NextDouble() * lightningParms.branchLength;
                    Vector3 branchVector = (midPoint - start) * forkMultiplier;
                    Vector3 splitEnd = midPoint + branchVector;
                    GenerateLightningBoltPath(midPoint, splitEnd, generation, totalGenerations, fractalTime + 1);
                }
                if (isReal)
                {
                    vertexIndex = AddVertexs(line1, vertexIndex);
                    vertexIndex = AddVertexs(line2, vertexIndex);

                }
            }
            offsetAmount *= 0.5f;
        }

        lightningBoltList.Add(segments);
    }
    /// <summary>
    /// 随机位置
    /// </summary>
    /// <param name="start"></param>
    /// <param name="end"></param>
    /// <param name="offsetAmount">偏移量</param>
    /// <returns></returns>
    private Vector3 RandomVector(Vector3 start, Vector3 end, float offsetAmount)
    {
        Vector3 direction = (end - start).normalized;
        Vector3 side = Vector3.Cross(start, end);
        if (side == Vector3.zero)
        {
            side = GetPerpendicularVector(direction);
        }
        else
        {
            side.Normalize();
        }

        //随机偏移距离
        float distance = ((float)random.NextDouble() + 0.1f) * offsetAmount;

        //随机旋转角度
        float rotationAngle = (float)random.NextDouble() * 360.0f;

        //绕着方向旋转，然后由垂直向量偏移
        return Quaternion.AngleAxis(rotationAngle, direction) * side * distance;
    }
    private Vector3 GetPerpendicularVector(Vector3 directionNormalized)
    {
        if (directionNormalized == Vector3.zero)
        {
            return Vector3.right;
        }
        else
        {
            // use cross product to find any perpendicular vector around directionNormalized:
            // 0 = x * px + y * py + z * pz
            // => pz = -(x * px + y * py) / z
            // for computational stability use the component farthest from 0 to divide by
            float x = directionNormalized.x;
            float y = directionNormalized.y;
            float z = directionNormalized.z;
            float px, py, pz;
            float ax = Mathf.Abs(x);
            float ay = Mathf.Abs(y);
            float az = Mathf.Abs(z);
            if (ax >= ay && ay >= az)
            {
                // x is the max, so we can pick (py, pz) arbitrarily at (1, 1):
                py = 1.0f;
                pz = 1.0f;
                px = -(y * py + z * pz) / x;
            }
            else if (ay >= az)
            {
                // y is the max, so we can pick (px, pz) arbitrarily at (1, 1):
                px = 1.0f;
                pz = 1.0f;
                py = -(x * px + z * pz) / y;
            }
            else
            {
                // z is the max, so we can pick (px, py) arbitrarily at (1, 1):
                px = 1.0f;
                py = 1.0f;
                pz = -(x * px + y * py) / z;
            }
            return new Vector3(px, py, pz).normalized;
        }
    }

    public int AddVertexs2(Line line, int index)
    {
        int vertexIndex = vertices.Count;
        triangles.Add(vertexIndex++);
        triangles.Add(vertexIndex++);
        triangles.Add(vertexIndex);
        triangles.Add(vertexIndex--);
        triangles.Add(vertexIndex);
        triangles.Add(vertexIndex += 2);

        var color = line.color;
        var width = line.width;
        var start = line.start;
        var end = line.end;
        Vector4 dir = end - start;
        dir.w = width;

        var dirPrev1 = Vector3.zero;
        var dirPrev2 = Vector3.zero;
        if (lineDirs.Count == 0)
        {
            dirPrev1 = dir;
            dirPrev2 = dir;
        }
        else
        {
            dirPrev1 = lineDirs[lineDirs.Count - 3];
            dirPrev2 = lineDirs[lineDirs.Count - 1];
        }

        vertices.Add(start);
        vertices.Add(end);
        vertices.Add(start);
        vertices.Add(end);

        uvs.Add(uv1);
        uvs.Add(uv2);
        uvs.Add(uv3);
        uvs.Add(uv4);
        colors.Add(color);
        colors.Add(color);
        colors.Add(color);
        colors.Add(color);

        lineDirs.Add(dirPrev1);
        lineDirs.Add(dir);
        normals.Add(dir);
        normals.Add(dir);

        dir.w = -dir.w;
        lineDirs.Add(dirPrev2);
        lineDirs.Add(dir);
        normals.Add(dir);
        normals.Add(dir);
        index += 4;
        return index;
    }


    private Vector3 dirPrev;
    /// <summary>
    /// 填充顶点、三角形、uv等数据
    /// </summary>
    /// <param name="line"></param>
    /// <param name="index"></param>
    /// <returns></returns>
    public int AddVertexs(Line line, int index)
    {
#if UNITY_EDITOR
        if (FractalLighting.Instance.debug && vertices.Count >= FractalLighting.Instance.showMeshNum * 4)
        {
            return 0;
        }
#endif
        var color = line.color;
        var width = line.width;
        var lineDir = (line.end - line.start).normalized;
        var start = line.start - lineDir * lightningParms.lightningQuadExtend;
        var end = line.end + lineDir * lightningParms.lightningQuadExtend;
        // var mid = (start + end) * 0.5f;


        var dirStart = Vector3.Cross(start - mainCameraPos, lineDir).normalized;

        if (vertices.Count == 0)
        {
            dirPrev = dirStart;
        }

        var dirEnd = Vector3.Cross(end - mainCameraPos, lineDir).normalized;
        // var extendDir = Vector3.Cross(mainCameraPos - mid, lineDir).normalized;

        var brPos = start + width * dirPrev;
        var blPos = start - width * dirPrev;
        var trPos = end + width * dirEnd;
        var tlPos = end - width * dirEnd;

        vertices.Add(brPos);
        vertices.Add(blPos);
        vertices.Add(trPos);
        vertices.Add(tlPos);
        triangles.Add(index + 1);
        triangles.Add(index);
        triangles.Add(index + 2);
        triangles.Add(index + 1);
        triangles.Add(index + 2);
        triangles.Add(index + 3);
        uvs.Add(new Vector2(1, 0));
        uvs.Add(new Vector2(0, 0));
        uvs.Add(new Vector2(1, 1));
        uvs.Add(new Vector2(0, 1));
        colors.Add(color);
        colors.Add(color);
        colors.Add(color);
        colors.Add(color);

        dirPrev = dirEnd;
        index += 4;
        return index;
    }
    public Mesh ConvertMesh0()
    {
        mesh.Clear();
        vertices.Clear();
        triangles.Clear();
        uvs.Clear();

        var first = true;
        var idx = 0;
        var extendDir = Vector3.zero;
        foreach (var segments in lightningBoltList)
        {
            // Debug.Log("segments Count:" + segments.Count);

            Vector3 prevTL = Vector3.zero;
            Vector3 prevTR = Vector3.zero;
            first = true;
            foreach (var segment in segments)
            {
                if (segment.isReal)
                {
                    var width = segment.width;
                    var start = segment.start;
                    var end = segment.end;
                    var mid = (start + end) * 0.5f;
                    if (first)
                    {
                        extendDir = Vector3.Cross(mid - mainCameraPos, end - start).normalized;
                    }

                    var brPos = start + width * extendDir;
                    var blPos = start - width * extendDir;
                    var trPos = end + width * extendDir;
                    var tlPos = end - width * extendDir;

                    if (first)
                    {
                        prevTR = brPos;
                        prevTL = blPos;
                        first = false;
                    }
                    blPos = prevTL;
                    brPos = prevTR;

                    vertices.Add(brPos);
                    vertices.Add(blPos);
                    vertices.Add(trPos);
                    vertices.Add(tlPos);
                    triangles.Add(idx + 1);
                    triangles.Add(idx);
                    triangles.Add(idx + 2);
                    triangles.Add(idx + 1);
                    triangles.Add(idx + 2);
                    triangles.Add(idx + 3);
                    uvs.Add(new Vector2(1, 0));
                    uvs.Add(new Vector2(0, 0));
                    uvs.Add(new Vector2(1, 1));
                    uvs.Add(new Vector2(0, 1));
                    prevTR = trPos;
                    prevTL = tlPos;
                    idx += 4;
                }
            }
        }

        mesh.SetVertices(vertices);
        mesh.SetTriangles(triangles, 0);
        mesh.SetUVs(0, uvs);
        mesh.RecalculateNormals();
        mesh.RecalculateBounds();
        mesh.RecalculateTangents();
        return mesh;
    }

    public void ConvertLightningBoltMesh()
    {
        mesh.SetVertices(vertices);
        mesh.SetTangents(lineDirs);
        mesh.SetUVs(0, uvs);
        mesh.SetColors(colors);
        mesh.SetNormals(normals);
        mesh.SetTriangles(triangles, 0);

        mesh.RecalculateNormals();
        mesh.RecalculateBounds();
        mesh.RecalculateTangents();
    }
}
