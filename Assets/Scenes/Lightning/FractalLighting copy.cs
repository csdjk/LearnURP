// using System;
// using System.Collections;
// using System.Collections.Generic;
// using System.Diagnostics;
// using UnityEditor;
// using UnityEngine;
// using UnityEngine.Profiling;
// using Random = UnityEngine.Random;

// public struct Line
// {
//     public Vector3 start;
//     public Vector3 end;
//     public bool isReal;
//     public float width;
//     public Color color;

//     public Line(Vector3 start, Vector3 end, float width, Color color, bool isReal)
//     {
//         this.start = start;
//         this.end = end;
//         this.isReal = isReal;
//         this.width = width;
//         this.color = color;
//     }
// }

// public class LightningBolt
// {
//     public GameObject GameObject { get; private set; }
//     private Mesh mesh;

//     private List<Vector3> vertices = new List<Vector3>();
//     private List<int> triangles = new List<int>();
//     private List<Vector2> uvs = new List<Vector2>();
//     private readonly List<Color32> colors = new List<Color32>();
    
//     public LightningBolt()
//     {

//     }
//     public void Reset()
//     {
//         vertexIndex = 0;
//         if (mesh)
//             mesh.Clear();
//         vertices.Clear();
//         triangles.Clear();
//         uvs.Clear();
//         colors.Clear();
//         debugList.Clear();
//     }
// }

// [ExecuteInEditMode]
// public class FractalLighting : MonoBehaviour
// {
//     [Header("Debug")]
//     public bool debug = true;
//     public bool drawLine = true;
//     public bool meshType = true;
//     public int seed = 5;
//     public int showMeshNum = 5;
//     private int showMeshNumCache = 5;

//     [Header("Parm")]
//     public Vector3 startPos = new Vector3(0, 0, 0);
//     public Vector3 endPos = new Vector3(5, 5, 5);
//     public int totalGenerations = 5;
//     public int generation = 5;
//     public float chaosFactor = 0.15f;
//     // 出现分支的概率
//     public float branchChance = 0.15f;
//     // 分形最大次数
//     public int maxFractalTime = 5;
//     // 分支距离
//     public float branchLength = 0.2f;
//     // 闪电宽度
//     public float lightningWidth = 1f;

//     [Range(0, 0.5f)]
//     // 每个quad延伸长度
//     public float lightningQuadExtend = 0.1f;

//     public List<List<Line>> lightningBoltList = new List<List<Line>>();

//     public Material mat;
//     private GameObject goParent;
//     private System.Random random;

//     private Vector3 mainCameraPos;

//     private List<Vector3> vertices = new List<Vector3>();
//     private List<int> triangles = new List<int>();
//     private List<Vector2> uvs = new List<Vector2>();
//     private readonly List<Color32> colors = new List<Color32>();
//     private Mesh mesh;

//     private Stopwatch sw = new Stopwatch();

//     // Start is called before the first frame update
//     void OnEnable()
//     {
//         sw.Reset();
//         sw.Start();
//         CreateLightningBolt();
//         sw.Stop();
//         UnityEngine.Debug.Log(string.Format("total: {0} ms", sw.ElapsedMilliseconds));
//     }

//     void Update()
//     {

//         if (showMeshNum != showMeshNumCache)
//         {
//             lightningBoltList.Clear();
//             DestroyImmediate(goParent);

//             showMeshNumCache = showMeshNum;
//             CreateLightningBolt();
//         }
//     }


//     void OnDisable()
//     {
//         lightningBoltList.Clear();
//         DestroyImmediate(goParent);
//     }


//     void CreateLightningBolt()
//     {
//         if (debug)
//             random = new System.Random(seed);
//         else
//             random = new System.Random();

//         Reset();
//         mainCameraPos = Camera.main.transform.position;
//         goParent = new GameObject();
//         goParent.transform.parent = transform;
//         GenerateLightningBoltStandard(startPos, endPos, generation, totalGenerations, 0);
//         Mesh lightningMesh = meshType ? ConvertMesh(lightningBoltList) : ConvertMesh0(lightningBoltList);
//         var bolt = new GameObject();
//         bolt.AddComponent<MeshRenderer>().material = mat;
//         bolt.AddComponent<MeshFilter>().mesh = lightningMesh;
//         bolt.transform.parent = goParent.transform;
//     }

//     public void Reset()
//     {
//         vertexIndex = 0;
//         if (mesh)
//             mesh.Clear();
//         vertices.Clear();
//         triangles.Clear();
//         uvs.Clear();
//         colors.Clear();
//         debugList.Clear();
//     }
//     private int vertexIndex = 0;
//     /// <summary>
//     /// 生成闪电
//     /// </summary>
//     /// <param name="start">起始位置</param>
//     /// <param name="end">结束位置</param>
//     /// <param name="generation">迭代次数</param>
//     /// <param name="totalGenerations">最大迭代次数</param>
//     /// <param name="fractalTime">分形次数</param>
//     public void GenerateLightningBoltStandard(Vector3 start, Vector3 end, int generation, int totalGenerations, int fractalTime)
//     {
//         if (fractalTime > maxFractalTime)
//         {
//             return;
//         }
//         List<Line> segments = new List<Line>();
//         segments.Add(new Line { start = start, end = end });


//         // 每个分支减少宽度
//         float widthMultiplier = (float)generation / (float)totalGenerations;
//         widthMultiplier *= widthMultiplier;
//         var lineWidth = lightningWidth * widthMultiplier;

//         var color = Color.black;
//         color.a = (byte)(255.0f * widthMultiplier);

//         int startIndex = 0;
//         var offsetAmount = (end - start).magnitude * chaosFactor;
//         while (generation-- > 0)
//         {
//             bool isReal = generation == 0;
//             int previousStartIndex = startIndex;
//             startIndex = segments.Count;
//             for (int i = previousStartIndex; i < startIndex; i++)
//             {
//                 start = segments[i].start;
//                 end = segments[i].end;
//                 // 中点
//                 Vector3 midPoint = (start + end) * 0.5f;

//                 // 随机位置偏移
//                 midPoint += RandomVector(start, end, offsetAmount);
//                 var line1 = new Line { start = start, end = midPoint, width = lineWidth, color = color, isReal = isReal };
//                 var line2 = new Line { start = midPoint, end = end, width = lineWidth, color = color, isReal = isReal };
//                 segments.Add(line1);
//                 segments.Add(line2);
//                 // 生成分支
//                 if ((float)random.NextDouble() < branchChance)
//                 {
//                     var forkMultiplier = (float)random.NextDouble() * branchLength;
//                     Vector3 branchVector = (midPoint - start) * forkMultiplier;
//                     Vector3 splitEnd = midPoint + branchVector;
//                     GenerateLightningBoltStandard(midPoint, splitEnd, generation, totalGenerations, fractalTime + 1);
//                 }
//                 if (isReal)
//                 {
//                     vertexIndex = AddVertexs(line1, vertexIndex);
//                     vertexIndex = AddVertexs(line2, vertexIndex);
//                 }
//             }
//             offsetAmount *= 0.5f;
//         }

//         lightningBoltList.Add(segments);
//     }
//     /// <summary>
//     /// 随机位置
//     /// </summary>
//     /// <param name="start"></param>
//     /// <param name="end"></param>
//     /// <param name="offsetAmount">偏移量</param>
//     /// <returns></returns>
//     private Vector3 RandomVector(Vector3 start, Vector3 end, float offsetAmount)
//     {
//         Vector3 direction = (end - start).normalized;
//         Vector3 side = Vector3.Cross(start, end);
//         if (side == Vector3.zero)
//         {
//             side = GetPerpendicularVector(direction);
//         }
//         else
//         {
//             side.Normalize();
//         }

//         //随机偏移距离
//         float distance = ((float)random.NextDouble() + 0.1f) * offsetAmount;

//         //随机旋转角度
//         float rotationAngle = (float)random.NextDouble() * 360.0f;

//         //绕着方向旋转，然后由垂直向量偏移
//         return Quaternion.AngleAxis(rotationAngle, direction) * side * distance;
//     }
//     private Vector3 GetPerpendicularVector(Vector3 directionNormalized)
//     {
//         if (directionNormalized == Vector3.zero)
//         {
//             return Vector3.right;
//         }
//         else
//         {
//             // use cross product to find any perpendicular vector around directionNormalized:
//             // 0 = x * px + y * py + z * pz
//             // => pz = -(x * px + y * py) / z
//             // for computational stability use the component farthest from 0 to divide by
//             float x = directionNormalized.x;
//             float y = directionNormalized.y;
//             float z = directionNormalized.z;
//             float px, py, pz;
//             float ax = Mathf.Abs(x);
//             float ay = Mathf.Abs(y);
//             float az = Mathf.Abs(z);
//             if (ax >= ay && ay >= az)
//             {
//                 // x is the max, so we can pick (py, pz) arbitrarily at (1, 1):
//                 py = 1.0f;
//                 pz = 1.0f;
//                 px = -(y * py + z * pz) / x;
//             }
//             else if (ay >= az)
//             {
//                 // y is the max, so we can pick (px, pz) arbitrarily at (1, 1):
//                 px = 1.0f;
//                 pz = 1.0f;
//                 py = -(x * px + z * pz) / y;
//             }
//             else
//             {
//                 // z is the max, so we can pick (px, py) arbitrarily at (1, 1):
//                 px = 1.0f;
//                 py = 1.0f;
//                 pz = -(x * px + y * py) / z;
//             }
//             return new Vector3(px, py, pz).normalized;
//         }
//     }



//     public int AddVertexs(Line line, int index)
//     {
//         var color = line.color;
//         var width = line.width;
//         var lineDir = (line.end - line.start).normalized;
//         var start = line.start - lineDir * lightningQuadExtend;
//         var end = line.end + lineDir * lightningQuadExtend;
//         var mid = (start + end) * 0.5f;
//         var extendDir = Vector3.Cross(mid - mainCameraPos, lineDir).normalized;

//         var brPos = start + width * extendDir;
//         var blPos = start - width * extendDir;
//         var trPos = end + width * extendDir;
//         var tlPos = end - width * extendDir;

//         vertices.Add(brPos);
//         vertices.Add(blPos);
//         vertices.Add(trPos);
//         vertices.Add(tlPos);
//         triangles.Add(index + 1);
//         triangles.Add(index);
//         triangles.Add(index + 2);
//         triangles.Add(index + 1);
//         triangles.Add(index + 2);
//         triangles.Add(index + 3);
//         uvs.Add(new Vector2(1, 0));
//         uvs.Add(new Vector2(0, 0));
//         uvs.Add(new Vector2(1, 1));
//         uvs.Add(new Vector2(0, 1));
//         colors.Add(color);
//         colors.Add(color);
//         colors.Add(color);
//         colors.Add(color);

//         index += 4;
//         return index;
//     }
//     private List<Line> debugList = new List<Line>();
//     public Mesh ConvertMesh0(List<List<Line>> lightning)
//     {
//         if (mesh == null)
//         {
//             mesh = new Mesh();
//         }
//         mesh.Clear();
//         vertices.Clear();
//         triangles.Clear();
//         uvs.Clear();
//         debugList.Clear();

//         var first = true;
//         var idx = 0;
//         var extendDir = Vector3.zero;
//         foreach (var segments in lightningBoltList)
//         {
//             // Debug.Log("segments Count:" + segments.Count);

//             Vector3 prevTL = Vector3.zero;
//             Vector3 prevTR = Vector3.zero;
//             first = true;
//             foreach (var segment in segments)
//             {
//                 if (segment.isReal)
//                 {
//                     debugList.Add(segment);
//                     var width = segment.width;
//                     var start = segment.start;
//                     var end = segment.end;
//                     var mid = (start + end) * 0.5f;
//                     if (first)
//                     {
//                         extendDir = Vector3.Cross(mid - mainCameraPos, end - start).normalized;
//                     }


//                     var brPos = start + width * extendDir;
//                     var blPos = start - width * extendDir;
//                     var trPos = end + width * extendDir;
//                     var tlPos = end - width * extendDir;

//                     if (first)
//                     {
//                         prevTR = brPos;
//                         prevTL = blPos;
//                         first = false;
//                     }
//                     blPos = prevTL;
//                     brPos = prevTR;

//                     vertices.Add(brPos);
//                     vertices.Add(blPos);
//                     vertices.Add(trPos);
//                     vertices.Add(tlPos);
//                     triangles.Add(idx + 1);
//                     triangles.Add(idx);
//                     triangles.Add(idx + 2);
//                     triangles.Add(idx + 1);
//                     triangles.Add(idx + 2);
//                     triangles.Add(idx + 3);
//                     uvs.Add(new Vector2(1, 0));
//                     uvs.Add(new Vector2(0, 0));
//                     uvs.Add(new Vector2(1, 1));
//                     uvs.Add(new Vector2(0, 1));
//                     prevTR = trPos;
//                     prevTL = tlPos;
//                     idx += 4;

//                     if (vertices.Count == showMeshNum * 4 && debug)
//                         break;
//                 }
//                 if (vertices.Count == showMeshNum * 4 && debug)
//                     break;
//             }
//         }

//         mesh.SetVertices(vertices);
//         mesh.SetTriangles(triangles, 0);
//         mesh.SetUVs(0, uvs);
//         mesh.RecalculateNormals();
//         mesh.RecalculateBounds();
//         mesh.RecalculateTangents();
//         return mesh;
//     }


//     public Mesh ConvertMesh(List<List<Line>> lightning)
//     {
//         if (mesh == null)
//         {
//             mesh = new Mesh();
//         }

//         mesh.SetVertices(vertices);
//         mesh.SetTriangles(triangles, 0);
//         mesh.SetUVs(0, uvs);
//         mesh.SetColors(colors);
//         mesh.RecalculateNormals();
//         mesh.RecalculateBounds();
//         mesh.RecalculateTangents();
//         return mesh;
//     }
//     private Color[] debugColors = { Color.red, Color.blue, Color.green, Color.magenta, Color.cyan, Color.yellow, Color.white };

//     void OnDrawGizmosSelected()
//     {

//         if (lightningBoltList.Count == 0 || !debug || !drawLine)
//             return;

//         var colorIndex = -1;
//         var width = 0.1f;
//         foreach (var segments in lightningBoltList)
//         {
//             var index = 0;
//             colorIndex++;
//             if (colorIndex >= debugColors.Length)
//             {
//                 colorIndex = 0;
//             }
//             Gizmos.color = debugColors[colorIndex];
//             foreach (var segment in segments)
//             {
//                 if (segment.isReal)
//                 {
//                     Gizmos.color = debugColors[colorIndex];

//                     var start = segment.start;
//                     var end = segment.end;
//                     var mid = (start + end) * 0.5f;
//                     Vector3 normal = Vector3.Cross(mid - mainCameraPos, end - start).normalized;
//                     Gizmos.DrawSphere(segment.start, 0.1f);
//                     // Gizmos.DrawIcon(segment.start, "d_winbtn_mac_max", true);
//                     Gizmos.DrawLine(start, end);

//                     Gizmos.color = debugColors[colorIndex] * 0.5f;

//                     var brPos = start + width * normal;
//                     var blPos = start - width * normal;
//                     var trPos = end + width * normal;
//                     var tlPos = end - width * normal;


//                     // Gizmos.DrawLine(blPos, brPos);
//                     index++;
//                 }
//             }
//         }
//     }
// }

public class MyClass
{
    
}