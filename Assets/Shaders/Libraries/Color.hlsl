//Single channel overlay
float BlendOverlay(float a, float b)
{
	return(b < 0.5) ? 2.0 * a * b : 1.0 - 2.0 * (1.0 - a) * (1.0 - b);
}

//RGB overlay
float3 BlendOverlay(float3 a, float3 b)
{
	float3 color;
	color.r = BlendOverlay(a.r, b.r);
	color.g = BlendOverlay(a.g, b.g);
	color.b = BlendOverlay(a.b, b.b);
	return color;
}


//---------------------------------------------------------------
//Apply object and vertex hue colors
float3 ApplyHue(in float4 iColor, in float3 oColor)
{
	return lerp(oColor, iColor.rgb, iColor.a);
}

float3 ApplyAmbientOcclusion(in float3 color, in float mask, in float amount)
{
	return lerp(color, color * mask, amount);
}

//Shading (RGB=hue   A=brightness)
float4 ApplyVertexColor( in float3 baseColor, in float mask, in float aoAmount,  in float4 hue)
{
	float4 col = float4(baseColor, 1);

	//Apply hue
	col.rgb = ApplyHue(hue, col);

	#if defined(_AO_ON)
		//Apply ambient occlusion
		float ambientOcclusion = ApplyAmbientOcclusion(col.a, col.a * mask, aoAmount);
		col.rgb *= ambientOcclusion;
	#endif
	return col;
}


inline float3 applyHue(float3 aColor, float aHue)
{
    float angle = radians(aHue);
    float3 k = float3(0.57735, 0.57735, 0.57735);
    float sinAngle, cosAngle;
    sincos(angle, sinAngle, cosAngle);
    return aColor * cosAngle + cross(k, aColor) * sinAngle + k * dot(k, aColor) * (1 - cosAngle);
}

// hsbc = half4(_Hue, _Saturation, _Brightness, _Contrast);
inline float4 applyHSBCEffect(float4 startColor, half4 hsbc)
{
    float hue = 360 * hsbc.r;
    float saturation = hsbc.g * 2;
    float brightness = hsbc.b * 2 - 1;
    float contrast = hsbc.a * 2;
    
    float4 outputColor = startColor;
    outputColor.rgb = applyHue(outputColor.rgb, hue);
    outputColor.rgb = (outputColor.rgb - 0.5f) * contrast + 0.5f;
    outputColor.rgb = outputColor.rgb + brightness;
    float3 intensity = dot(outputColor.rgb, float3(0.39, 0.59, 0.11));
    outputColor.rgb = lerp(intensity, outputColor.rgb, saturation);
    
    return outputColor;
}
