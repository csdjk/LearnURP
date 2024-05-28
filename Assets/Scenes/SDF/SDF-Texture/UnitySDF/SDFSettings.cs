using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System.IO;
using UnityEngine.Experimental.Rendering;
using System.Text.RegularExpressions;
#if UNITY_EDITOR
using UnityEditor;
#endif

#if UNITY_EDITOR

// Usage:
// Name a texture 'texturename+sdf'
public class SDFImporter : AssetPostprocessor {

    static readonly Regex SDFPattern = new Regex("(?:\\+sdf)(f)?(4)?");

    private SDFGenerator.TextureModes GetMode(string path) {
        var match = SDFPattern.Match(assetPath);
        if (!match.Success) return (SDFGenerator.TextureModes)0;
        return match.Groups[2].Success ? SDFGenerator.TextureModes.RGBA : SDFGenerator.TextureModes.A;
    }

    void OnPreprocessTexture() {
        // Check if the name ends with +sdf
        var match = SDFPattern.Match(assetPath);
        if (!match.Success) return;
        // Check if we should change import format
        if (match.Groups[1].Success) {
            if (assetImporter is TextureImporter importer) {
                SDFImporter.SetImportParameters(importer, GetMode(assetPath));
            }
        }
    }

    // After the texture is imported
    public void OnPostprocessTexture(Texture2D texture) {
        // Check if the name ends with +sdf
        var match = SDFPattern.Match(assetPath);
        if (!match.Success) return;

        var material = SDFSettings.CreateGeneratorMaterial();
        if (material == null) {
            Debug.LogError("Failed to find SDF material", texture);
            return;
        }
        // Load uncompressed texture data
        bool linear = false;
        if (assetImporter is TextureImporter importer) linear = !importer.sRGBTexture;
        var original = new Texture2D(2, 2, TextureFormat.RGBA32, false, linear);
        if (!ImageConversion.LoadImage(original, File.ReadAllBytes(assetPath))) {
            Debug.LogError("Failed to load image. It might be the wrong format", texture);
        }
        var gradient = Mathf.Min(20f / Mathf.Max(texture.width, texture.height), 0.25f);
        material.SetFloat("_Feather", gradient);
        var result = SDFGenerator.Generate(original, material, GetMode(assetPath), texture.width, texture.height);
        var pixels = result.GetPixels32();
        texture.SetPixels32(pixels);
        texture.Apply(true);

        // Cleanup
        GameObject.DestroyImmediate(original);
        GameObject.DestroyImmediate(material);
    }

    public static void SetImportParameters(TextureImporter importer, SDFGenerator.TextureModes mode) {
        importer.sRGBTexture = (mode & SDFGenerator.TextureModes.RGB) == 0;
        var settings = importer.GetDefaultPlatformTextureSettings();
        settings.format =
            mode == SDFGenerator.TextureModes.A ? TextureImporterFormat.Alpha8 :
            mode == SDFGenerator.TextureModes.RGB ? TextureImporterFormat.RGB24 :
            TextureImporterFormat.RGBA32;
        importer.SetPlatformTextureSettings(settings);
        importer.SaveAndReimport();
    }

}
#endif

// Logic for generating a signed distance field (using a shader)
public class SDFSettings : ScriptableObject {

    // Optional - should the material be stored in this singleton?
    public Material GeneratorMaterial;

#if UNITY_EDITOR
    public static SDFSettings GetInstance() {
        SDFSettings settings = null;
        string[] guids = AssetDatabase.FindAssets(string.Format("t:{0}", typeof(SDFSettings)));
        foreach (var guid in guids) {
            string assetPath = AssetDatabase.GUIDToAssetPath(guid);
            settings = AssetDatabase.LoadAssetAtPath<SDFSettings>(assetPath);
            if (settings != null) break;
        }
        return settings;
    }
    public static Material CreateGeneratorMaterial() {
        var settings = SDFSettings.GetInstance();
        Material material;
        if (settings != null && settings.GeneratorMaterial != null) {
            material = new Material(settings.GeneratorMaterial);
        } else {
            var shader = Shader.Find("Internal/SDFGenerator");
            if (shader == null) return null;
            material = new Material(shader);
        }
        return material;
    }
#endif

}
