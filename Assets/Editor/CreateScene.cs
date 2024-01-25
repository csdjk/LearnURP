using UnityEngine;
using UnityEditor;
using UnityEngine.UIElements;
using System;
using UnityEngine.SceneManagement;
using System.Runtime.CompilerServices;
using UnityEditor.Rendering;
using UnityEditor.SceneManagement;
using UnityEngine.Rendering;


[InitializeOnLoad]
public static class CreateSceneHandler
{
    // [InitializeOnLoadMethod]
    static CreateSceneHandler()
    {
        EditorSceneManager.newSceneCreated += OnNewSceneCreated;
    }


    static void OnNewSceneCreated(Scene scene, NewSceneSetup setup, NewSceneMode mode)
    {
        Debug.Log("New scene created: " + scene.name);
    }


    // [MenuItem("Assets/LcL/CreateScene", false, 0)]
    // static void CreateScene(MenuCommand menuCommand)
    // {
    //     // 创建新的场景
    //     Scene scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);
    //     EditorSceneManager.SetActiveScene(scene);
    //
    //     // 创建全局音量
    //     var go = CoreEditorUtils.CreateGameObject("Global Volume", menuCommand.context);
    //     var volume = go.AddComponent<Volume>();
    //     volume.isGlobal = true;
    //
    //     // 创建平面
    //     GameObject plane = GameObject.CreatePrimitive(PrimitiveType.Plane);
    //     plane.name = "Plane";
    //
    //     // 创建光源
    //     GameObject lightGameObject = new GameObject("Light");
    //     var lightComp = lightGameObject.AddComponent<Light>();
    //     lightComp.type = LightType.Directional;
    //
    //     // 创建相机
    //     GameObject cameraGameObject = new GameObject("Main Camera");
    //     var cameraComp = cameraGameObject.AddComponent<Camera>();
    //     cameraComp.fieldOfView = 60;
    //
    //     // 保存场景,获取选择的文件夹路径
    //     string scenePath =  AssetDatabase.GetAssetPath(Selection.activeObject);
    //     EditorSceneManager.SaveScene(scene, scenePath);
    // }

}


