using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEditor;
using Unity.Jobs;
using Unity.Collections;


public class NoiseGenerationWindow : EditorWindow
{

    [SerializeField]
    private GenerationLayer[] layers = new[] { new GenerationLayer(LayerMode.Multiply) };

    private GenerationLayer? copy_buffer = null;
    

    private int resolution = 64;

    private static int[] resolutions_2 = new[] { 16, 32, 64, 128, 256, 512, 1024, 2048, 4096 };
    private static int[] resolutions_3 = new[] { 16, 32, 64, 128, 256 };
    private static string[] resolutions_2s = new[] { "16", "32", "64", "128", "256", "512", "1024", "2048", "4096" };
    private static string[] resolutions_3s = new[] { "16", "32", "64", "128", "256" };

    private bool is_3d = false;

    private Vector2 tiling_2 = new Vector2(1, 1);
    private Vector3 tiling_3 = new Vector3(1, 1, 1);

    private string file_name = "texture";

    private Texture2D texture = null;
    private int x_tile = 1;
    private int y_tile = 1;

    // UI Variables

    private bool can_generate = true;
    private bool can_write = true;

    private Vector2 scrollPosition = new Vector2();

    private bool textureSettings = true;

    private SerializedObject Window_SO;


    private struct WriteTextureJob : IJobParallelFor
    {
        public NativeArray<Color> TextureData;

        [DeallocateOnJobCompletion]
        [ReadOnly]
        private NativeArray<GenerationLayer> layers;

        private bool is_3d;
        private int resolution;
        private int pixel_count;
        private int x_tile;

        [DeallocateOnJobCompletion]
        [ReadOnly]
        private NativeArray<float> ValueBuffer;

        public WriteTextureJob(NativeArray<Color> TextureData, GenerationLayer[] layers, bool is_3d, int resolution, int x_tile, NativeArray<float>[] ValueBuffers)
        {
            this.TextureData = TextureData;
            this.layers = new NativeArray<GenerationLayer>(layers, Allocator.Persistent);
            this.is_3d = is_3d;
            this.resolution = resolution;
            this.pixel_count = resolution * resolution * ((is_3d) ? resolution : 1);
            this.x_tile = x_tile;
            
            this.ValueBuffer = new NativeArray<float>(layers.Length * pixel_count, Allocator.Persistent);
            for (int i = 0; i < layers.Length; i++)
            {
                NativeSlice<float> layer_slice = new NativeSlice<float>(ValueBuffers[i]);
                NativeSlice<float> buffer_slice = new NativeSlice<float>(this.ValueBuffer, i * pixel_count, pixel_count);

                buffer_slice.CopyFrom(layer_slice);
            }
        }

        public void Execute(int index)
        {
            float r = 0;
            float g = 0;
            float b = 0;
            float a = 1;

            for (int i = 0; i < layers.Length; i++)
            {
                float value = ValueBuffer[index + i * pixel_count];
                switch (layers[i].Mode)
                {
                    case LayerMode.Add:
                        if ((layers[i].Channels & ChannelFlag.R) == ChannelFlag.R) r += value;
                        if ((layers[i].Channels & ChannelFlag.G) == ChannelFlag.G) g += value;
                        if ((layers[i].Channels & ChannelFlag.B) == ChannelFlag.B) b += value;
                        if ((layers[i].Channels & ChannelFlag.A) == ChannelFlag.A) a += value;
                        break;
                    case LayerMode.Divide:
                        if ((layers[i].Channels & ChannelFlag.R) == ChannelFlag.R) r /= (value == 0) ? 1 : value;
                        if ((layers[i].Channels & ChannelFlag.G) == ChannelFlag.G) g /= (value == 0) ? 1 : value;
                        if ((layers[i].Channels & ChannelFlag.B) == ChannelFlag.B) b /= (value == 0) ? 1 : value;
                        if ((layers[i].Channels & ChannelFlag.A) == ChannelFlag.A) a /= (value == 0) ? 1 : value;
                        break;
                    case LayerMode.Max:
                        if ((layers[i].Channels & ChannelFlag.R) == ChannelFlag.R) r = (r > value) ? r : value;
                        if ((layers[i].Channels & ChannelFlag.G) == ChannelFlag.G) g = (g > value) ? g : value;
                        if ((layers[i].Channels & ChannelFlag.B) == ChannelFlag.B) b = (b > value) ? b : value;
                        if ((layers[i].Channels & ChannelFlag.A) == ChannelFlag.A) a = (a > value) ? a : value;
                        break;
                    case LayerMode.Min:
                        if ((layers[i].Channels & ChannelFlag.R) == ChannelFlag.R) r = (r < value) ? r : value;
                        if ((layers[i].Channels & ChannelFlag.G) == ChannelFlag.G) g = (g < value) ? g : value;
                        if ((layers[i].Channels & ChannelFlag.B) == ChannelFlag.B) b = (b < value) ? b : value;
                        if ((layers[i].Channels & ChannelFlag.A) == ChannelFlag.A) a = (a < value) ? a : value;
                        break;
                    case LayerMode.Multiply:
                        if ((layers[i].Channels & ChannelFlag.R) == ChannelFlag.R) r *= value;
                        if ((layers[i].Channels & ChannelFlag.G) == ChannelFlag.G) g *= value;
                        if ((layers[i].Channels & ChannelFlag.B) == ChannelFlag.B) b *= value;
                        if ((layers[i].Channels & ChannelFlag.A) == ChannelFlag.A) a *= value;
                        break;
                    case LayerMode.Subract:
                        if ((layers[i].Channels & ChannelFlag.R) == ChannelFlag.R) r -= value;
                        if ((layers[i].Channels & ChannelFlag.G) == ChannelFlag.G) g -= value;
                        if ((layers[i].Channels & ChannelFlag.B) == ChannelFlag.B) b -= value;
                        if ((layers[i].Channels & ChannelFlag.A) == ChannelFlag.A) a -= value;
                        break;
                }
            }

            r = Mathf.Clamp01(r);
            g = Mathf.Clamp01(g);
            b = Mathf.Clamp01(b);
            a = Mathf.Clamp01(a);

            if (is_3d) TextureData[index] = new Color(r, g, b, a);
            else TextureData[index] = new Color(r, g, b, a);
        }

    }


    [MenuItem("Window/Custom/Noise Generation")]
    public static void showWindow()
    {
        EditorWindow.GetWindow(typeof(NoiseGenerationWindow), false, "Noise Generation");
    }

    private void OnGUI()
    {
        Window_SO = new SerializedObject(this);
        GUIStyle boldFoldoutStyle = EditorStyles.foldout;
        FontStyle previousStyle = boldFoldoutStyle.fontStyle;
        boldFoldoutStyle.fontStyle = FontStyle.Bold;
        float smallestSize = (position.width < position.height) ? position.width : position.height;

        EditorGUILayout.BeginVertical();
        scrollPosition = EditorGUILayout.BeginScrollView(scrollPosition, false, false);

        textureSettings = EditorGUILayout.Foldout(textureSettings, "Texture Settings", boldFoldoutStyle);

        if (textureSettings)
        {
            //resolution = EditorGUILayout.IntField("Resolution", resolution);
            if (is_3d)
            {
                if (resolution > 256) resolution = 256;
                resolution = EditorGUILayout.IntPopup("Resolution", resolution, resolutions_3s, resolutions_3);
            }
            else resolution = EditorGUILayout.IntPopup("Resolution", resolution, resolutions_2s, resolutions_2);


            file_name = EditorGUILayout.TextField("File Name", file_name);
            is_3d = EditorGUILayout.Toggle("Is 3D", is_3d);
            if (is_3d)
            {
                x_tile = GetClosestToSquareFactor(resolution);
                y_tile = resolution / x_tile;
                tiling_2 = new Vector2(1, 1);
                tiling_3 = EditorGUILayout.Vector3Field("Pattern Tiling", tiling_3);
                EditorGUILayout.LabelField("Volume Texture X Tiles: " + x_tile);
                EditorGUILayout.LabelField("Volume Texture Y Tiles: " + y_tile);
            }
            else
            {
                if (x_tile != 1 || y_tile != 1)
                {
                    x_tile = 1;
                    y_tile = 1;
                }
                tiling_2 = EditorGUILayout.Vector2Field("Pattern Tiling", tiling_2);
                tiling_3 = new Vector3(1, 1, 1);
            }
        }
        EditorGUILayout.Space();

        int layers_count = layers.Length;

        int insert_at = -1;
        bool duplicate_flag = false;

        int removed = 0;
        int delete_at = -1;

        if (layers.Length == 0)
        {
            if (GUILayout.Button("Insert"))
            {
                insert_at = 0;
            }
        }

        for (int i = 0; i < layers.Length; i++)
        {
            EditorGUILayout.PropertyField(Window_SO.FindProperty("layers").GetArrayElementAtIndex(i), new GUIContent("Layer " + i.ToString() + ":"), true);
            EditorGUILayout.Space();
            
            EditorGUILayout.BeginHorizontal();

            EditorGUI.BeginDisabledGroup(i == 0);
            if (GUILayout.Button("Move Up", EditorStyles.miniButtonLeft))
            {
                GenerationLayer temp = layers[i];
                layers[i] = layers[i - 1];
                layers[i - 1] = temp;
            }
            EditorGUI.EndDisabledGroup();

            EditorGUI.BeginDisabledGroup(i == layers.Length - 1);
            if (GUILayout.Button("Move Down", EditorStyles.miniButtonMid))
            {
                GenerationLayer temp = layers[i];
                layers[i] = layers[i + 1];
                layers[i + 1] = temp;
            }
            EditorGUI.EndDisabledGroup();

            if (GUILayout.Button("Duplicate", EditorStyles.miniButtonMid))
            {
                insert_at = i + 1;
                duplicate_flag = true;
            }

            if (GUILayout.Button("Copy", EditorStyles.miniButtonMid))
            {
                copy_buffer = layers[i].Copy();
            }

            EditorGUI.BeginDisabledGroup(copy_buffer == null);
            if (GUILayout.Button("Paste", EditorStyles.miniButtonMid))
            {
                layers[i] = copy_buffer ?? new GenerationLayer(LayerMode.Multiply);
            }
            EditorGUI.EndDisabledGroup();

            if (GUILayout.Button("Insert", EditorStyles.miniButtonMid))
            {
                insert_at = i + 1;
            }

            if (GUILayout.Button("Delete", EditorStyles.miniButtonRight))
            {
                delete_at = i;
                removed++;
            }

            EditorGUILayout.EndHorizontal();
            EditorGUILayout.Space();
        }

        if (insert_at != -1)
        {
            GenerationLayer[] new_layers = new GenerationLayer[layers_count + 1];
            for (int i = 0; i < layers_count + 1; i++)
            {
                if (i < insert_at) new_layers[i] = layers[i];
                else if (i == insert_at && duplicate_flag) new_layers[i] = layers[i - 1].Copy();
                else if (i == insert_at) new_layers[i] = new GenerationLayer(0);
                else new_layers[i] = layers[i - 1];
            }
            layers = new_layers;
        }

        layers_count = layers.Length;
        if (delete_at != -1)
        {
            GenerationLayer[] updated_layers = new GenerationLayer[layers_count - removed];
            int _removed = 0;
            for (int i = 0; i < layers_count; i++)
            {
                if (i == delete_at) _removed++;
                else updated_layers[i - _removed] = layers[i];
            }
            layers = updated_layers;
        }

        EditorGUILayout.Space();

        EditorGUI.BeginDisabledGroup(!can_generate);
        bool generate_flag;
        if (texture == null) generate_flag = GUILayout.Button("Generate Texture");
        else generate_flag = GUILayout.Button("Update Texture");
        EditorGUI.EndDisabledGroup();
        if (generate_flag) GenerateTexture();

        EditorGUI.BeginDisabledGroup(texture == null);
        bool clear_flag;
        clear_flag = GUILayout.Button("Clear Texture");
        EditorGUI.EndDisabledGroup();
        if (clear_flag) texture = null;

        EditorGUI.BeginDisabledGroup(!can_write || texture == null);
        
        if (GUILayout.Button("Write Texture To File")) WriteTextureToFile();
        if (GUILayout.Button("Write Texture To Asset"))
        {
            Texture2D asset = new Texture2D(texture.width, texture.height, TextureFormat.RGBAFloat, false);
            Graphics.CopyTexture(texture, asset);
            AssetDatabase.CreateAsset(asset, "Assets/" + file_name + ".asset");
        }

        EditorGUI.EndDisabledGroup();

        if (texture != null)
        {
            EditorGUILayout.Space();
            GUILayout.Label("Preview: ");
            EditorGUILayout.Space();
            EditorGUI.DrawPreviewTexture(GUILayoutUtility.GetRect(position.width, position.width), texture, null, ScaleMode.ScaleToFit);
        }


        Window_SO.ApplyModifiedProperties();

        EditorGUILayout.EndScrollView();
        EditorGUILayout.EndVertical();

        boldFoldoutStyle.fontStyle = previousStyle;

    }

    private void OnInspectorUpdate()
    {
        Repaint();
    }

    private void GenerateTexture()
    {
        can_generate = false;
        can_write = false;
        
        texture = new Texture2D(resolution * x_tile, resolution * y_tile, TextureFormat.RGBAFloat, false);
        
        int vis_count = 0;
        for (int i = 0; i < layers.Length; i++)
        {
            if (layers[i].Visible) vis_count++;
        }
        GenerationLayer[] visible_layers = new GenerationLayer[vis_count];
        int v = 0;
        for (int i = 0; i < layers.Length; i++)
        {
            if (layers[i].Visible) visible_layers[v++] = layers[i];
        }


        GenerationLayerJob[] jobs = new GenerationLayerJob[visible_layers.Length];
        JobHandle[] handles = new JobHandle[visible_layers.Length];

        for (int i = 0; i < visible_layers.Length; i++)
        {
            jobs[i] = new GenerationLayerJob(visible_layers[i], resolution, is_3d, x_tile, (is_3d) ? tiling_3 : new Vector3(tiling_2.x, tiling_2.y));
            handles[i] = jobs[i].Schedule(resolution * resolution * ((is_3d) ? resolution : 1), 128);
        }

        NativeArray<float>[] ValueBuffers = new NativeArray<float>[visible_layers.Length];
        for (int i = 0; i < visible_layers.Length; i++)
        {
            EditorUtility.DisplayProgressBar("Generating Texture Data", "Updating all texture layers [" + (i + 1) + "/" + visible_layers.Length + "]", i / (float)visible_layers.Length);
            handles[i].Complete();
            ValueBuffers[i] = jobs[i].ValueBuffer;
        }

        EditorUtility.DisplayProgressBar("Generating Texture Data", "Writing data to texture.", 0);
        int pixel_count = resolution * resolution * ((is_3d) ? resolution : 1);
        WriteTextureJob write_job = new WriteTextureJob(texture.GetRawTextureData<Color>(), visible_layers, is_3d, resolution, x_tile, ValueBuffers);
        JobHandle write_handle = write_job.Schedule(pixel_count, 128);

        write_handle.Complete();
        EditorUtility.DisplayProgressBar("Generating Texture Data", "Writing data to texture.", 1);
        
        for (int i = 0; i < visible_layers.Length; i++)
        {
            jobs[i].ValueBuffer.Dispose();
        }

        texture.Apply();

        EditorUtility.ClearProgressBar();

        can_generate = true;
        can_write = true;
    }

    private void WriteTextureToFile()
    {
        Debug.Log("Writing texture to file...");
        byte[] data = ImageConversion.EncodeToPNG(texture);
        if (!Directory.Exists(Application.dataPath + "\\..\\Output\\")) Directory.CreateDirectory(Application.dataPath + "\\..\\Output\\");
        File.WriteAllBytes(Application.dataPath + "\\..\\Output\\" + file_name + ".png", data);
        Debug.Log("Writen to file.");
    }

    private static int GetClosestToSquareFactor(int i)
    {
        int test = (int)Mathf.Sqrt(i);
        while (i % test != 0.0f)
        {
            test--;
        }
        return test;
    }

}
