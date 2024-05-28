using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System.IO;
using UnityEngine.Experimental.Rendering;
using System;
#if UNITY_EDITOR
using UnityEditor;
#endif

#if UNITY_EDITOR
// More pretty editor for the manual generator
[CustomEditor(typeof(SDFGenerator))]
public class SDFGeneratorEditor : Editor {

    public override void OnInspectorGUI() {
        EditorGUILayout.HelpBox(new GUIContent(
            "Drag an image into the slot below and click 'Generate'" +
            " or append '+sdf' to the end of the filename.\n" +
            "(ie. 'TestImage+sdf.png')"));
        base.OnInspectorGUI();
        var generator = (SDFGenerator)target;
        if (GUI.Button(EditorGUILayout.GetControlRect(), "Generate")) {
            generator.GenerateStatic();
        }
    }

}
#endif

[CreateAssetMenu(menuName = "2D/SDF Generator")]
public class SDFGenerator : ScriptableObject {

    [Flags]
    public enum TextureModes {
        R = 0x01, G = 0x02, B = 0x04, A = 0x08,
        RGB = R | G | B,
        RGBA = R | G | B | A,
    }

    [Header("Settings")]
    [Tooltip("Process only the Alpha channel, or process all channels")]
    public TextureModes Mode = TextureModes.A;
    [Tooltip("How far the SDF should spread (in percentange of texture size)")]
    public float GradientSizePX = 20;
    [Tooltip("Set the import settings to be optimal for an SDF")]
    public bool SetImportSettings = true;

    //public TextureImporterFormat FormatOverride = TextureImporterFormat.Automatic;

    [Header("Source Textures")]
    public Texture2D[] Targets;

#if UNITY_EDITOR
    [ContextMenu("Generate Static")]
    public void GenerateStatic() {
        // Validate the input
        if ((Mode & (TextureModes.RGB)) != 0) {
            foreach (var target in Targets) {
                if (GraphicsFormatUtility.IsSRGBFormat(target.graphicsFormat)) {
                    Debug.LogWarning("Texture " + target + " is sRGB but is being used as an RGB distance field. Consider importing it as linear.");
                }
            }
        }
        // Configure material
        var material = SDFSettings.CreateGeneratorMaterial();
        // Generate based on source textures
        foreach (var target in Targets) {
            material.SetFloat("_Feather", GradientSizePX / Mathf.Max(target.width, target.height));
            GenerateAsset(target, material);
        }
        // Cleanup
        DestroyImmediate(material);
    }

    public void GenerateAsset(Texture2D texture, Material material) {
        // Generate SDF data
        var result = Generate(texture, material, Mode);

        // Generate the new assest
        var path = AssetDatabase.GetAssetPath(texture);
        path = Path.GetDirectoryName(path) + "/" + Path.GetFileNameWithoutExtension(path) + ".sdf.png";
        File.WriteAllBytes(path, result.EncodeToPNG());
        AssetDatabase.Refresh();
        DestroyImmediate(result);

        // Disable compression and use simple format
        if (AssetImporter.GetAtPath(path) is TextureImporter importer && SetImportSettings) {
            SDFImporter.SetImportParameters(importer, Mode);
            var ogpath = AssetDatabase.GetAssetPath(texture);
            var ogimporter = string.IsNullOrEmpty(ogpath) ? default : AssetImporter.GetAtPath(path) as TextureImporter;
            if (ogimporter != null) {
                // Preserve sRGB if not processing any RGB
                if ((Mode & TextureModes.RGB) == 0) {
                    importer.sRGBTexture = ogimporter.sRGBTexture;
                }
            }
        }
    }
#endif

    public static Texture2D Generate(Texture2D texture, Material material, TextureModes mode, int width = -1, int height = -1) {
        Texture2D result = null;
        Color32[] pixels = null;
        for (int c = 3; c >= 0; c--) {
            if (((int)mode & (1 << c)) == 0) continue;
            material.SetFloat("_Channel", c);
            var resultC = Generate(texture, material, width, height);
            if (result == null) {
                // We can use alpha directly (generator outputs in A channel)
                result = resultC;
            } else {
                // Otherwise we'll just pack on CPU
                if (pixels == null) pixels = result.GetPixels32();
                var resPx = resultC.GetPixels32();
                for (int i = 0; i < pixels.Length; i++) {
                    pixels[i][c] = resPx[i][c];
                }
                DestroyImmediate(resultC);
            }
        }
        if (pixels != null)
            result.SetPixels32(pixels);
        return result;
    }

    // Generate a distance field
    // The "material" must be a SDF generating material (ie. the one at UnitySDF/SDFGenerator.mat)
    // Optionally push the results to the specified texture (must be a compatible format)
    public static Texture2D Generate(Texture2D texture, Material material, int width = -1, int height = -1) {
        // Allocate some temporary buffers
        var stepFormat = new RenderTextureDescriptor(texture.width, texture.height, GraphicsFormat.R16G16B16A16_UNorm, 0, 0);
        stepFormat.sRGB = false;
        var target1 = RenderTexture.GetTemporary(stepFormat);
        var target2 = RenderTexture.GetTemporary(stepFormat);
        target1.filterMode = FilterMode.Point;
        target2.filterMode = FilterMode.Point;
        target1.wrapMode = TextureWrapMode.Clamp;
        target2.wrapMode = TextureWrapMode.Clamp;

        var firstPass = 0;
        var finalPass = material.FindPass("FinalPass");

        // Detect edges of image
        material.EnableKeyword("FIRSTPASS");
        material.SetFloat("_Spread", 1);
        Graphics.Blit(texture, target1, material, firstPass);
        material.DisableKeyword("FIRSTPASS");
        Swap(ref target1, ref target2);

        // Gather nearest edges with varying spread values
        for (int i = 11; i >= 0; i--) {
            material.SetFloat("_Spread", Mathf.Pow(2, i));
            Graphics.Blit(target2, target1, material, firstPass);
            Swap(ref target1, ref target2);
        }

        var resultFormat = new RenderTextureDescriptor(texture.width, texture.height, GraphicsFormat.R8G8B8A8_UNorm, 0, 0);
        resultFormat.sRGB = GraphicsFormatUtility.IsSRGBFormat(texture.graphicsFormat);
        var resultTarget = RenderTexture.GetTemporary(resultFormat);
        resultTarget.wrapMode = TextureWrapMode.Clamp;

        // Compute the final distance from nearest edge value
        material.SetTexture("_SourceTex", texture);
        Graphics.Blit(target2, resultTarget, material, finalPass);

        if (width == -1) width = texture.width;
        if (height == -1) height = texture.height;
        var result = new Texture2D(width, height, GraphicsFormat.R8G8B8A8_UNorm, 0, TextureCreationFlags.None);

        // If the texture needs to be resized, resize it here
        if (result.width != texture.width || result.height != texture.height) {
            var resultTarget2 = RenderTexture.GetTemporary(result.width, result.height, 0, GraphicsFormat.R8G8B8A8_UNorm);
            resultTarget2.wrapMode = TextureWrapMode.Clamp;
            Graphics.Blit(resultTarget, resultTarget2);
            Swap(ref resultTarget, ref resultTarget2);
            RenderTexture.ReleaseTemporary(resultTarget2);
        }

        // Copy to CPU
        result.ReadPixels(new Rect(0, 0, result.width, result.height), 0, 0);

        // Clean up
        RenderTexture.ReleaseTemporary(resultTarget);
        RenderTexture.ReleaseTemporary(target2);
        RenderTexture.ReleaseTemporary(target1);

        return result;
    }

    private static void Swap<T>(ref T v1, ref T v2) {
        var t = v1;
        v1 = v2;
        v2 = t;
    }

}
