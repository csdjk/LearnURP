# vbr.fx 光照构成分析

> **来源**：`Assets/Scenes/Specular/vbr.fx`  
> **描述**：F-PBR Shader for DM62，支持多种可选光照特性的模块化 PBR 着色器

---

## 一、纹理资源总览

| 采样器 | 用途 |
|---|---|
| `sam_diffuse` | 漫反射贴图（Base Color） |
| `sam_other0` | 变色贴图 / 细节法线 / 卡通金属纹样 |
| `sam_other1` | PBR 参数贴图（R=金属度，G=SSS，B=粗糙度） |
| `sam_other2` | 环境全景图（Panorama Cubemap，用 `tex2Dlod` 采样） |
| `sam_other3` | 法线贴图（Normal Map） |
| `sam_other4` | 各向异性流向图（Flowmap，RG=方向，B=噪声） |
| `sam_shadow` | 阴影贴图 |

---

## 二、PBR 材质参数

```
金属度  metallic  = saturate(sam_other1.R + metal_multi)
粗糙度  roughness = saturate(sam_other1.B + rough_multi)
SSS强度 sss       = sam_other1.G  →  clamp(2*G - 1, 0, 1)
```

支持手动覆盖（`MANUL_ENABLE`）或按通道叠加偏移量。

---

## 三、法线系统

### 3.1 基础法线（`XNORMAL_MAP_ENABLE`）

从 `sam_other3` 采样，在切线空间重建世界法线：

```
tangentNormal.xy = sam_other3.xy * 2 - 1
N = normalize(tangentNormal.x * T + tangentNormal.y * B + vertexN)
```

### 3.2 细节法线叠加（`FIBER_ENABLE`）

从 `sam_other0` 采样细节法线，叠加到基础法线上：

```
detailNormal = sam_other0.xy * 2 - 1
finalNormal = normalize(T*(base.x + detail.x*mask) + B*(base.y + detail.y*mask) + vertexN)
```

支持 UV 随机旋转（`FIBER_UV_ROT`）及动画流速（`fiberNormalSpeed * FrameTime`）。

### 3.3 卡通化法线偏移（`CARTOON_ENABLE`）

将法线在 View 方向上做平滑插值，减弱高频凹凸感：

```
blend = smoothstep(cartoonPosFactor.x, cartoonPosFactor.y, dot(V, N))
N_cartoon = normalize(lerp(N, V, blend * cartoonFactor.x * maskB))
```

---

## 四、阴影系统（`SHADOW_MAP_ENABLE`）

### 4.1 标准单采样

```
shadowFactor = tex2Dproj(sam_shadow, float4(shadowUV, depth, 1))
```

### 4.2 九宫格多重采样（`SHADOW_MULTI_SAMPLE`）

在 1/1024 像素偏移的 3×3 核上采样，取平均：

```
shadowFactor = (s0 + s1 + ... + s8) / 9.0
```

### 4.3 阴影强度修正

可利用以下通道微调自投影强度：

| 宏 | 来源通道 |
|---|---|
| `SHADOW_FIX` | 变色贴图 R 通道 |
| `SHADOW_FIX_A` | 漫反射贴图 A 通道 |
| `SHADOW_FIX_AB` | 各向异性贴图 B 通道 |

---

## 五、直接光照（Diffuse + Specular）

主光源方向与颜色来自 `ShadowLightAttr[1/3]`。

### 5.1 漫反射

```
diffuse_albedo = baseColor^2 * diffuse_intensity   // 近似 gamma 空间平方
NdotL = saturate(dot(N, -L))
diffuse_final = (1 - metallic) * diffuse_albedo * (NdotL + sss_contrib) * lightColor
```

### 5.2 直接镜面反射（Cook-Torrance GGX）

三项分别为：

**Fresnel — Schlick + SG 近似**

```
F = F0 + (1 - F0) * SG(1 - NdotV)
F0 = lerp(0.04, baseColor, metallic)
```

**法线分布 — GGX**

```
D = roughness^4 / (π * (NdotH*(roughness^4 - 1) + 1)^2)
clamped to max 10000
```

**几何遮蔽 — Disney Schlick**

```
k = 0.5 * roughness
G = 0.25 / ((NdotV*(1-k)+k) * (NdotL*(1-k)+k))
```

**合并**

```
specular_direct = D * F * G * NdotL * lightColor * shadowFactor
```

---

## 六、各向异性高光（`ANISO_ENABLE`）

基于 **Kajiya-Kay sin-band** 模型，使用 FlowMap 驱动高光方向。

```
// 解码 FlowMap [-1, 1]
flow = tex(sam_other4)
decoded = (flow - 0.5) * 2

// 各向异性方向（切线空间到世界空间）
anisoDir = normalize(decoded.x * T + decoded.y * B)

// 偏移法线（normal_offset 整体偏移 + flow.z 噪声抖动）
shiftedN = normalize(N * (normal_offset + (flow.z - 0.5) * noise_offset) + anisoDir)

// sin 带高光
NdotV_shifted = saturate(dot(shiftedN, V))
highlight = max(sin(NdotV_shifted * PI), 0)
```

**各向异性影响环境采样**（`ANISO_ENVIR`）：

```
// 用 newAnisoFactor.z/w 将反射方向混合向 shiftedN
envDir = normalize(lerp(reflect(-V, N), reflect(-V, shiftedN),
         saturate(newAnisoFactor.z + newAnisoFactor.w * NdotV)))
```

---

## 七、环境光照（`ENVIR_ENABLE`）

### 7.1 漫反射环境 — 球谐（SH）

使用预烘焙的 3 阶 SH 矩阵（`envSHR/G/B`），输入视图空间法线：

```
sh_color = float3(dot(N4, envSHR*N4), dot(N4, envSHG*N4), dot(N4, envSHB*N4))
diffuse_env = albedo * (NdotL * lightColor + sh_color * shadowFactor * envBrightness)
```

### 7.2 镜面环境 — 全景图

从 `sam_other2`（全景 HDR 贴图）采样，用粗糙度控制 mip 级别：

```
mip = roughness / 0.14
// 将反射方向转换为全景 UV
phi   = atan2(R.z, R.x) + PI
theta = acos(R.y)
envUV = float2(phi / (2*PI), theta / PI)
envColor = tex2Dlod(sam_other2, float4(envUV, 0, mip)).rgb * alpha * 130
```

### 7.3 环境 Fresnel BRDF — Lazarov 近似

```
// EnvBRDFApprox (Lazarov 2013)
r  = roughness * c0 + c1   // c0=(-1,-0.0275,-0.572,0.022), c1=(1,0.0425,1.04,-0.04)
a  = min(r.x^2, exp2(-9.28 * NdotV)) * r.x + r.y
envBRDF = float2(-1.04, 1.04) * a + r.zw

specular_env = envColor * (F0 * envBRDF.x + envBRDF.y * envFresnelBrightness) * aoFactor
```

### 7.4 AO 对环境光的影响

```
ao_blend = lerp(lerp(1, ao, NdotV), ao, 2*saturate(0.5-ao)*AO_slider)
envLight *= ao_blend
```

---

## 八、SSS（次表面散射）

### 8.1 经典 SSS（`SSS_ENABLE`）

利用 wrap lighting 模拟皮下散射：

```
// wrap NdotL（延伸阴暗边界）
NdotL_wrap = min(saturate((NdotL + 0.45) / 1.45), shadowFactor)
NdotL_wrap_sq = NdotL_wrap^2

// 用 SSS 通道在 wrap 和 standard 之间插值
NdotL_sss = lerp(NdotL_standard, NdotL_wrap_sq, sss * sss_factor)
```

暗部背光透射色（蓝调散射）：

```
sss_scatter = saturate(baseColor - max(maxChannel-0.39, 0.1)) * sss_factor
diffuse_env += sss_scatter * sh * 2.35 * 0.3
```

### 8.2 新 SSS（`SSS_NEW_ENABLE`）

基于物理折射的 Refraction SSS：

```
refractDir = normalize(refract(-V, N, 1/IOR))
sssIntensity = saturate(abs(dot(refractDir, L)))
             * (1 + sssFactorNew.w * curvature)
             * smoothstep(sssFFactorNew.x, sssFFactorNew.y, 1 - NdotV)
baseColor_sss = lerp(gray, baseColor, 1 + sss_mask * (skyTransmit + lightTransmit))
            + sss_mask * sssColor * sssIntensity
```

---

## 九、清漆层（`CLEARCOAT_ENABLE`）

在主 PBR 层上叠加一层薄膜高光，使用独立 GGX Cook-Torrance：

```
// 清漆 F0 = lerp(0.04, 1.0, clearCoatEnv.y)
F_coat = F_Schlick(coatF0, NdotV)
D_coat = D_GGX(clearCoatFactor.x, NdotH)
G_coat = G_Schlick(clearCoatFactor.x, NdotV, NdotL)

specular_coat = D_coat * F_coat * G_coat * clearCoatFactor.y * lightColor * NdotL
// 叠加时对主层做能量守恒衰减
specular_final = main_specular * (1 - coat_intensity*0.5) + specular_coat
```

清漆也有独立的环境采样（另一次全景图 `tex2Dlod`）。

---

## 十、薄膜干涉（`FILM_REF`）

基于薄膜光学干涉模型，为每个 RGB 波长单独计算：

```
// 以红色通道(波长650nm)为例
sin2_t = (1 - NdotV^2) / n_R^2
delta  = 2 * n_R * coat_depth * sqrt(1 - sin2_t) / 650 + 0.5
phi    = 2 * PI * delta * 2
r0     = ((1 - n_R) / (1 + n_R))^2
filmR  = r0 + (1 - r0) * (0.5 - 0.5*cos(phi))
```

RGB 三通道分别用不同折射率（`refractive_index.xyz`）和参考波长（650/510/470nm）计算，形成彩虹色薄膜效果。

---

## 十一、补充光照特性

### Rim Light（轮廓光）

```
rim = SG(1 - NdotV, rim_power)          // SG: 指数近似高斯
rim_final = smoothstep(start, end, rim) * rim_color * rim_multi
```

### 补光（`DIR_AMBIENT_ENABLE`）

来自自定义位置的方向补光（fill light），贡献到漫反射：

```
fillDir = normalize(mul(float3(l_pos_x,y,z), inverse_view))
fill = dir_ambient * saturate(dot(N, fillDir)) * dir_ambient_intensity * (0.5*kD + 0.5)
```

### 自发光（`SELF_BLING`）

```
emissive = saturate((alpha - 0.5) * 2) * emissive_intensity * albedo
```

### 卡通金属光泽（`CARTOON_METAL`）

通过 `sam_other0` 流动纹样 + 屏幕空间 UV 模拟卡通风格金属高光。

---

## 十二、Tone Mapping

两路输出可插值混合：

| 路径 | 公式 |
|---|---|
| Filmic（默认） | `color / (color + 0.187) * 1.035` |
| sqrt 路径 | `sqrt(color) / 1.5`（用于 bloom 预处理）|

```
final = lerp(sqrt_path, filmic_path, u_tonemapping_factor)
```

Bloom 强度写入 alpha：

```
alpha_out = luminance(specular) * saturate(metallic + bloom_range) * illum_multi
          + emissive_atten * emissive_bloom
```

---

## 十三、光照组合总览

```
final_color =
    // ① 直接漫反射 (含 SSS NdotL 修正)
    diffuse_albedo * kD * NdotL_sss * lightColor * shadowFactor

    // ② 直接镜面高光 (GGX Cook-Torrance)
  + D * F * G * NdotL * lightColor * shadowFactor

    // ③ 各向异性高光 (sin-band Kajiya-Kay)
  + anisoHighlight * NdotL * lightColor * shadowFactor

    // ④ 环境漫反射 (SH)
  + albedo * kD * sh_color * ao * envBrightness

    // ⑤ 环境镜面反射 (全景图 + EnvBRDF Lazarov)
  + envColor * (F0*envBRDF.x + envBRDF.y) * ao * envBrightness

    // ⑥ 清漆层 (可选 CLEARCOAT_ENABLE)
  + clearCoat_specular_direct + clearCoat_specular_env

    // ⑦ 薄膜干涉 (可选 FILM_REF)
  + filmColor * filmIntensity

    // ⑧ 新 SSS 透射 (可选 SSS_NEW_ENABLE)
  + sss_transmit * lightColor

    // ⑨ Rim Light
  + rim_color * rim_intensity

    // ⑩ 自发光 (可选 SELF_BLING)
  + emissive

    // ⑪ 补光 (可选 DIR_AMBIENT_ENABLE)
  + fill_light
```

---

## 十四、可选功能宏汇总

| 宏 | 说明 |
|---|---|
| `XNORMAL_MAP_ENABLE` | 法线贴图（默认开启） |
| `ENVIR_ENABLE` | 环境反射（默认开启） |
| `ANISO_ENABLE` | 各向异性高光（FlowMap 驱动） |
| `ANISO_ENVIR` | 各向异性影响环境采样方向 |
| `SSS_ENABLE` | 经典 wrap-lighting SSS |
| `SSS_NEW_ENABLE` | 基于折射的新 SSS |
| `CLEARCOAT_ENABLE` | 清漆层 |
| `FILM_REF` | 薄膜干涉 |
| `FIBER_ENABLE` | 细节法线叠加 |
| `CARTOON_ENABLE` | 卡通化法线偏移 |
| `CARTOON_METAL` | 卡通金属光泽 |
| `SELF_BLING` | 自发光 |
| `DIR_AMBIENT_ENABLE` | 方向补光 |
| `POINT_LIGHT_ENABLE` | 点光源 |
| `SHADOW_MAP_ENABLE` | 阴影（默认开启） |
| `SHADOW_MULTI_SAMPLE` | 9 宫格软阴影 |
| `OUTLINE_ENABLE` | 剪影描边 |
| `CHANGECOLOR_ENABLE` | 多层变色系统 |
| `HAIR_RIM` | 头发边缘变色 |
| `EYE_ENABLE` | 眼睛特殊处理 |
