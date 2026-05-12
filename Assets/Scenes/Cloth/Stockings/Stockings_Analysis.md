# Stockings Shader 丝袜材质 - 深度分析

> **路径**：`Assets/Scenes/Cloth/Stockings/Stockings.shader`  
> **Shader名称**：`LcL/Cloth/Stockings`  
> **渲染管线**：URP (Universal Render Pipeline)  
> **自定义编辑器**：`LcLShaderEditor.LcLShaderGUI`

---

## 一、整体概览

该 Shader 用于模拟**半透明丝袜**的视觉效果，核心思路是：

1. 利用 **NdotV（法线与视线夹角）** 模拟丝袜的菲涅耳（Fresnel）特性——视角越掠射，越能看到皮肤/暗部；
2. 利用 **StockMap 纹理** 编码丝袜编织图案的密度/厚度信息；
3. 利用 **高度遮罩（Height Mask）** 控制丝袜在角色身体上的覆盖范围（例如：大腿以上裸露，以下穿袜）；
4. 通过多层颜色混合，最终合成出兼具**暗部边缘感**与**丝质光泽**的丝袜效果。

---

## 二、渲染设置

```c
Tags
{
    "RenderType" = "Opaque"
    "Queue"      = "Geometry"
    "RenderPipeline" = "UniversalPipeline"
}
```

| 设置项 | 值 | 说明 |
|--------|-----|------|
| RenderType | Opaque | 不透明渲染类型 |
| Queue | Geometry | 几何体渲染队列，不做透明排序 |
| RenderPipeline | UniversalPipeline | 仅在 URP 下生效 |

> **注意**：尽管视觉上丝袜是半透明的，但此 Shader 渲染类型为 Opaque，  
> 半透明效果完全通过**颜色混合**在 `frag` 着色器内部实现，而非依赖硬件 Alpha Blend。

---

## 三、Properties 参数详解

### 3.1 纹理贴图

| 属性名 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `_StockMap` | Texture2D | white | 丝袜信息贴图，多通道复用（详见下方通道说明） |

#### StockMap 通道布局

| 通道 | 变量名 | 采样方式 | 用途 |
|------|--------|----------|------|
| **R** | — | — | 未使用 |
| **G** | `stockMap.y` | 原始 UV | 编织密度/厚度图（0=稀疏透明，1=紧密不透明） |
| **B** | `stockRangeZ` | UV × `_StockMap_ST.xy`（Tiling缩放） | 用于粗糙度扰动，增加丝面细节变化 |

> G 通道负责控制丝袜编织纹理的疏密，B 通道以更高频率（通过Tiling）采样，提供表面粗糙度变化，模拟丝线的微观细节。

---

### 3.2 颜色参数

| 属性名 | 默认值 | 说明 |
|--------|--------|------|
| `_BaseColor` | (1,1,1,1) 白色 | 基础颜色（皮肤色），透过丝袜可见 |
| `_StockColor` | (0.83,0.72,0.64,1) 肤色调 | 丝袜本体颜色，用于高 Alpha 区域 |
| `_StockDarkColor` | (0,0,0,1) 黑色 | 丝袜暗部颜色（边缘加重效果） |

---

### 3.3 丝袜效果参数

| 属性名 | 范围 | 默认值 | 说明 |
|--------|------|--------|------|
| `_StockDarkWidth` | 0–1 | 0.2 | 暗部边缘宽度（NdotV 阈值），值越大暗部越宽 |
| `_StockDarkSoftness` | 0–1 | 0.1 | 暗部边缘柔化程度，避免硬边 |
| `_StockPow` | 0–100 | 5.0 | 边缘高光指数（类Phong），值越大高光越集中 |
| `_StockRoughness` | 0–1 | 0.5 | 丝袜整体粗糙度，影响透明度计算 |
| `_StockThicknessPow` | 0.1–5 | 1.0 | 厚度图的Gamma调整，控制纹理对比度 |
| `_StockThickness` | 0–1 | 0 | 全局丝袜厚度，0=最薄（最透明），1=最厚（最不透明） |

---

### 3.4 高度遮罩参数（Height Mask）

| 属性名 | 范围 | 默认值 | 说明 |
|--------|------|--------|------|
| `_ObjectBoundY` | Vector | (0,1,0,0) | 物体模型空间 Y 轴边界（x=最小值，y=最大值） |
| `_HeightMaskThreshold` | 0–1 | 0.8 | 遮罩阈值（归一化高度），高于此值的区域开始无丝袜效果 |
| `_HeightMaskSmoothness` | 0–1 | 0.1 | 遮罩边缘柔化宽度 |

---

## 四、顶点着色器（vert）

```c
Varyings vert(Attributes input)
{
    output.positionCS = GetVertexPositionInputs(input.positionOS.xyz).positionCS;
    output.uv         = input.uv;
    output.color      = input.color;
    output.positionOS = input.positionOS.xyz;   // 保留模型空间坐标
    output.positionWS = positionInputs.positionWS;
    output.normalWS   = GetVertexNormalInputs(input.normalOS.xyz).normalWS;
}
```

**关键点**：
- 同时传递 **模型空间坐标（positionOS）** 和 **世界空间坐标（positionWS）**；
- 模型空间坐标用于高度遮罩计算（不受物体移动影响）；
- 世界空间坐标用于计算视线方向（View Direction）。

---

## 五、核心算法分析

### 5.1 高度遮罩（HeightMask）

```c
float ObjectBound01(float3 positionOS)
{
    float objMinY  = _ObjectBoundY.x;
    float objMaxY  = _ObjectBoundY.y;
    float heightNorm = (positionOS.y - objMinY) / (objMaxY - objMinY);
    return saturate(heightNorm);
}

float HeightMask(float3 positionOS)
{
    float height01   = ObjectBound01(positionOS);
    float height_mask = smoothstep(
        _HeightMaskThreshold - _HeightMaskSmoothness,
        _HeightMaskThreshold + _HeightMaskSmoothness,
        height01
    );
    return height_mask;
}
```

**原理图示**：

```
高度(归一化) 0 ─────────────── [threshold-soft] ~~~~ [threshold+soft] ──── 1
height_mask  0                        0          → 渐变 →        1          1
丝袜效果     完整丝袜效果                                              无丝袜效果
```

- 返回值 `0` → 完整丝袜效果（腿部下方）
- 返回值 `1` → 无丝袜效果（腰部以上裸露部分）
- 通过 `smoothstep` 保证边缘过渡自然

---

### 5.2 丝袜核心着色（Stockings 函数）

```c
float3 Stockings(float2 uv, float3 N, float3 V, float3 baseColor, float height_mask)
```

#### Step 1：采样 StockMap

```c
// B通道：带Tiling的粗糙度扰动采样
float stockRangeZ = SAMPLE_TEXTURE2D(_StockMap, sampler_StockMap, uv * _StockMap_ST.xy).z;
// RG通道：原始UV采样（编织密度）
float2 stockMap   = SAMPLE_TEXTURE2D(_StockMap, sampler_StockMap, uv).xy;
```

#### Step 2：厚度图处理

```c
float stock_thickness_map = pow(stockMap.y, _StockThicknessPow);
```

对 G 通道做幂运算，`_StockThicknessPow > 1` 使密集区更紧，`< 1` 使稀疏区更宽，调节编织纹理的视觉对比度。

#### Step 3：粗糙度计算

```c
float roughnessAdjust = (stockRangeZ * 0.5) - 0.5;   // 映射到 [-0.5, 0]
float finalRoughness  = _StockRoughness * roughnessAdjust + 1.0;
```

`stockRangeZ` 范围 [0,1]，`roughnessAdjust` 映射为 [-0.5, 0]，使 `finalRoughness ∈ [1 - 0.5×_StockRoughness, 1.0]`，始终为正值，用于调整最终透明度。

#### Step 4：NdotV 边缘光计算

```c
float rimValue    = max(dot(N, V), 0.001);
```

- `rimValue ≈ 1`：法线正对视线（正面）
- `rimValue ≈ 0`：法线与视线垂直（边缘掠射角）

#### Step 5：暗部边缘梯度

```c
float rimGradient = 1 - smoothstep(
    _StockDarkWidth - _StockDarkSoftness,
    _StockDarkWidth + _StockDarkSoftness,
    rimValue
);
```

**可视化**：

```
rimValue:   0 ──── [width-soft] ~~ [width+soft] ──────── 1
rimGradient: 1              →渐变→          0             0
暗部程度:    最暗(边缘)                              最亮(正面)
```

当 NdotV 小于 `_StockDarkWidth` 时，`rimGradient = 1`（边缘暗部最强）；大于时，`rimGradient = 0`（正面无暗部）。

#### Step 6：高度遮罩融合（逻辑OR合并）

```c
rimGradient = rimGradient + height_mask - rimGradient * height_mask;
```

这是**屏幕混合（Screen Blend）**，等价于逻辑 OR：

$$\text{result} = 1 - (1 - A)(1 - B) = A + B - AB$$

- 若 `height_mask = 1`（腰部以上）→ `rimGradient` 强制为 1，使该区域显现暗部（无丝袜的裸肤效果）
- 若 `height_mask = 0`（腿部）→ `rimGradient` 保持原值，正常显示丝袜边缘暗部

#### Step 7：厚度图调制暗部梯度

```c
rimGradient = 1 - (1 - rimGradient) * stock_thickness_map;
```

再次使用 Screen 混合逻辑：在丝袜编织稀疏处（`stock_thickness_map ≈ 0`），`rimGradient` 趋近于 1（暗部更重）；在编织紧密处（`stock_thickness_map ≈ 1`），`rimGradient` 保持原值。这使暗部效果跟随编织密度变化，稀疏处更暗，体现丝袜的通透感。

#### Step 8：暗部颜色合成

```c
float3 darkColorBlend  = lerp(1, _StockDarkColor.xyz, rimGradient);
float3 stockDarkResult = lerp(1, baseColor.xyz * darkColorBlend, rimGradient);
```

- 第一层：在白色和暗部颜色之间插值 → `darkColorBlend`
- 第二层：在白色和（基础色×暗色混合）之间插值 → `stockDarkResult`

这是一种**乘积暗化**，`rimGradient` 越大，结果越暗，颜色越接近 `_StockDarkColor`。

#### Step 9：丝袜透明度（stockAlpha）计算

```c
float stockAlpha = finalRoughness * stockMap.y;          // 基础透明度
stockAlpha = stockAlpha * (1 - _StockThickness);         // 全局厚度调节
float edgeLight  = max(pow(rimValue, _StockPow), 0.004); // 边缘高光（Phong-like）
stockAlpha = stockAlpha * (1 - height_mask);             // 高度遮罩屏蔽
stockAlpha = clamp(stockAlpha * edgeLight, 0.0, 1.0);   // 最终透明度
```

**各因子作用**：

| 因子 | 作用 |
|------|------|
| `finalRoughness` | 粗糙度越高，透明度越低 |
| `stockMap.y` | 编织越密，透明度越低 |
| `(1 - _StockThickness)` | 丝袜越厚，透明度越低 |
| `edgeLight = pow(NdotV, _StockPow)` | 正面观察时高光强，边缘减弱（与暗部方向相反，制造正面透亮的视觉效果） |
| `(1 - height_mask)` | 高于阈值区域 Alpha=0，完全不显示丝袜 |

> **关键洞察**：`edgeLight` 在正面（NdotV=1）最大，边缘（NdotV=0）最小。这与 `rimGradient` 方向相反，二者协同：边缘暗部强、正面丝袜颜色强，共同构成丝袜的立体通透感。

#### Step 10：最终颜色合成

```c
float3 finalStockColor = lerp(baseColor.xyz * stockDarkResult, _StockColor.xyz, stockAlpha);
```

- `stockAlpha = 0`：完全显示 `baseColor × stockDarkResult`（皮肤色+边缘暗部）
- `stockAlpha = 1`：完全显示 `_StockColor`（丝袜颜色）
- 中间值：丝袜和皮肤色自然过渡

---

## 六、完整 Stockings 函数数据流

```
StockMap (G通道) ──pow──> stock_thickness_map
                                 │
NdotV ──────> rimGradient ──OR──> rimGradient ──Screen──> rimGradient
              (暗部梯度)   ↑                     ↑
                       height_mask         thickness_map
                           │
                    darkColorBlend = lerp(1, StockDarkColor, rimGradient)
                    stockDarkResult = lerp(1, BaseColor×darkColorBlend, rimGradient)

StockMap (B通道) ──> roughnessAdjust ──> finalRoughness
                                              │
StockMap (G通道) ──────────────────────> stockAlpha = finalRoughness × stockMap.y
                                              × (1 - _StockThickness)
NdotV ──pow──> edgeLight ────────────> stockAlpha × edgeLight × (1 - height_mask)
                                              │
                                    finalStockColor = lerp(
                                        BaseColor × stockDarkResult,
                                        _StockColor,
                                        stockAlpha
                                    )
```

---

## 七、Pass 结构

| Pass | LightMode | 功能 |
|------|-----------|------|
| Pass 0 | `UniversalForward` | 主渲染Pass，执行上述完整丝袜着色 |
| Pass 1 | `ShadowCaster` | 投影Pass，使用 URP 内置 `ShadowCasterPass.hlsl` |
| Pass 2 | `DepthOnly` | 深度预写Pass，支持深度预渲染优化 |

---

## 八、优化与特性

### 优点
1. **无 Alpha Blend**：Opaque 队列，避免透明排序问题，性能更好；
2. **多通道纹理复用**：一张 `StockMap` 同时承载密度图（G）和粗糙度扰动（B），节省 Texture 采样次数；
3. **数学模拟半透明**：通过 NdotV + 颜色混合在不透明管线中实现透明感，兼容性强；
4. **高度遮罩**：可灵活控制丝袜覆盖范围，无需修改模型。

### 局限性
1. **没有阴影接收**：`frag` 中注释掉了阴影坐标采样，不计算主光源阴影影响；
2. **无光照模型**：不计算漫反射/镜面反射，效果风格化偏强，不适合写实场景；
3. **高度遮罩依赖手动设置** `_ObjectBoundY`，需要根据每个角色模型单独调整。

---

## 九、参数调节指南

| 视觉目标 | 调节参数 |
|----------|----------|
| 丝袜更透明（能看到更多皮肤） | 降低 `_StockThickness`，降低 `_StockRoughness` |
| 边缘暗部更明显 | 增大 `_StockDarkWidth`，加深 `_StockDarkColor` |
| 暗部边缘更柔和 | 增大 `_StockDarkSoftness` |
| 正面丝袜光泽更集中 | 增大 `_StockPow` |
| 编织纹理对比更强 | 调整 `_StockThicknessPow`（>1 增强对比） |
| 丝袜只覆盖腿部 | 设置 `_ObjectBoundY`，调低 `_HeightMaskThreshold` |
| 丝袜覆盖范围边界更柔和 | 增大 `_HeightMaskSmoothness` |

---

*分析生成时间：2026/05/09*
