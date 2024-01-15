using UnityEngine;
using UnityEditor;
using UnityEngine.UIElements;
using System;
using UnityEditor.UIElements;

public class ReplacePrefab : EditorWindow
{
    [MenuItem("SceneTool/ReplacePrefab")]
    private static void ShowWindow()
    {
        var window = GetWindow<ReplacePrefab>();
        window.titleContent = new GUIContent("Replace Prefab");
        window.Show();
    }

    void OnEnable()
    {
    }

    public void CreateGUI()
    {
        VisualElement root = rootVisualElement;

        var label = new Label("用于替换的预制体列表")
        {
            style = {
                fontSize = 20,
                alignSelf = Align.Center
            }
        };
        root.Add(label);

        // 提示信息
        var info = new Label("选中场景中的物体，点击替换按钮，将会用预制体替换选中的物体")
        {
            style = {
                color = new Color(0,0.8f,0),
                fontSize = 15,
                alignSelf = Align.Center,
                marginTop = 10,
            }
        };
        root.Add(info);

        var info2 = new Label("注意：不要同时选中当前节点以及他的父节点")
        {
            style = {
                color = new Color(0.8f,0.8f,0),
                fontSize = 13,
                alignSelf = Align.Center,
                marginBottom = 10,
            }
        };
        root.Add(info2);

        Func<VisualElement> makeItem = () =>
        {
            var box = new VisualElement()
            {
                style = {
                    flexDirection = FlexDirection.Row,
                    width = Length.Percent(100),
                    justifyContent = Justify.SpaceBetween,
                }
            };
            var objectField = new ObjectField()
            {
                objectType = typeof(GameObject),
            };
            box.Add(objectField);

            var button = new Button()
            {
                text = "替换",
                style = {
                    width = 50,
                    height = 20,
                    marginLeft = 5,
                    marginRight = 5,
                }
            };
            box.Add(button);

            return box;
        };
        Action<VisualElement, int> bindItem = (element, index) =>
        {
            element.parent.style.alignSelf = Align.Center;
            element.Q<Button>().clicked += () =>
            {
                var objectField = element.Q<ObjectField>();
                ReplaceSelectGameObject(objectField.value as GameObject);
            };
        };

        var listView = new ListView(new[] { "1", "2" }, 30, makeItem, bindItem)
        {
            selectionType = SelectionType.Multiple,
            showAddRemoveFooter = true,
            reorderable = true,
            reorderMode = ListViewReorderMode.Animated,
            showBorder = true
        };
        listView.showAddRemoveFooter = true;
        listView.showAlternatingRowBackgrounds = AlternatingRowBackground.None;
        listView.showBoundCollectionSize = true;
        listView.selectionType = SelectionType.Single;
        root.Add(listView);



    }

    private void ReplaceSelectGameObject(GameObject prefab)
    {
        if (prefab == null)
        {
            EditorUtility.DisplayDialog("提示", "请选择一个预制体", "确定");
            return;
        }
        foreach (var selectedObject in Selection.gameObjects)
        {
            var prefabInstance = PrefabUtility.InstantiatePrefab(prefab) as GameObject;
            if (prefabInstance != null)
            {
                Undo.RegisterCompleteObjectUndo(selectedObject, selectedObject.name + " object state");
                Undo.RegisterCreatedObjectUndo(prefabInstance, "Spawn new prefab");
                prefabInstance.transform.position = selectedObject.transform.position;
                prefabInstance.transform.rotation = selectedObject.transform.rotation;
                prefabInstance.transform.localScale = selectedObject.transform.localScale;
                Undo.SetTransformParent(prefabInstance.transform, selectedObject.transform.parent, prefabInstance.name + " root parenting");
                Undo.RegisterCompleteObjectUndo(prefabInstance, prefabInstance.name + " object state");
                Undo.DestroyObjectImmediate(selectedObject);
            }
        }
    }
}