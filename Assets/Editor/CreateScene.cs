using UnityEngine;
using UnityEditor;
using UnityEngine.UIElements;
using System;

public class LcLEditorWindow : EditorWindow
{
    [MenuItem("Window/My Editor Window")]
    private static void ShowWindow()
    {
        var window = GetWindow<LcLEditorWindow>();
        window.titleContent = new GUIContent("My Editor Window");
        window.Show();
    }

    void OnEnable()
    {
        CreateGUI();
    }

    public void CreateGUI()
    {
        VisualElement root = rootVisualElement;

        var label = new Label("Hello World!");
        root.Add(label);

        var button = new Button(() => { Debug.Log("Hello World"); });
        root.Add(button);

        Func<VisualElement> makeItem = () =>
        {
            return new Label();
        };
        Action<VisualElement, int> bindItem = (element, index) =>
        {
            (element as Label).text = "Element " + index;
        };

        var listView = new ListView(new[] { "1", "2", "3", "4", "5" }, 20, makeItem, bindItem);
        listView.selectionType = SelectionType.Multiple;
        listView.showAddRemoveFooter = true;
        listView.reorderable = true;
        listView.reorderMode = ListViewReorderMode.Animated;
        listView.showBorder = true;
        listView.showAddRemoveFooter = true;
        listView.showAlternatingRowBackgrounds = AlternatingRowBackground.None;
        listView.showBoundCollectionSize = true;
        listView.selectionType = SelectionType.Single;
        listView.onSelectedIndicesChange += obj =>
        {
            Debug.Log("onSelectedIndicesChanged");
        };
        listView.onItemsChosen += obj =>
        {
            Debug.Log("onItemsChosen");
        };
        listView.onSelectionChange += obj =>
        {
            Debug.Log("onSelectionChange");
        };
        root.Add(listView);
    }
}
