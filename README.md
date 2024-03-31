# LearnURP

> Unity Version: **Unity2021.3.11f1**

记录一下在URP中实现的一些效果Demo。

注意需要修改一下URP的源码，暴露部分接口，把 `private`或者 `internal` 改为 `public`。

|            Class            |            Function or Property            |
| :--------------------------: | :----------------------------------------: |
|                              |         GetCameraColorFrontBuffer         |
|                              |              SwapColorBuffer              |
| UniversalRenderPipelineAsset | rendererDisplayList<br />rendererIndexList |
|                              |                                            |

### [Grass(GPU Instance)](https://github.com/csdjk/LearnURP/tree/main/Assets/Scenes/GpuInstance/Grass)

![Grass.gif](https://s2.loli.net/2023/04/09/v7dtlaN1UqS9VuB.gif)

### [Ice](https://github.com/csdjk/LearnURP/tree/main/Assets/Scenes/Ice/)

![1709541340252](image/README/1709541340252.png)

### [Ice2](https://github.com/csdjk/LearnURP/tree/main/Assets/Scenes/Ice/)

![1709541151342](image/README/1709541151342.gif)

### [RainRipple](https://github.com/csdjk/LearnURP/tree/main/Assets/Scenes/RainRipple/)

![1707015580970](image/README/1707015580970.gif)

### [Rain(天刀方案)](https://github.com/csdjk/LearnURP/tree/main/Assets/Scenes/Rain/)

![1705320482504](image/README/Rain.gif)

### [SSR](https://github.com/csdjk/LearnURP/tree/main/Assets/Scenes/SSR/)

![1705320482504](image/README/SSR.gif)

### [SSPR](https://github.com/csdjk/LearnURP/tree/main/Assets/Scenes/SSPR/)

![1705320482504](image/README/SSPR.gif)

### [FastVolumeLight](https://github.com/csdjk/LearnURP/tree/main/Assets/Scenes/VolumeLight/)

后处理实现，适合移动端的体积光。

![1709545228438](image/README/1709545228438.gif)

### [毛发](https://github.com/csdjk/LearnURP/tree/main/Assets/Scenes/Fur/)

![1709690809134](image/README/1709690809134.png)

### [ParallaxMapping](https://github.com/csdjk/LearnURP/tree/main/Assets/Scenes/ParallaxMapping/)

![1709881395783](image/README/1709881395783.png)
![1709882630528](image/README/1709882630528.png)
