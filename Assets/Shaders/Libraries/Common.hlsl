//---------------------------Utils------------------------------------//
float3 CameraPositionWS(float3 wPos)
{
	return _WorldSpaceCameraPos.xyz;
}

float ObjectPosRand01()
{
	return frac(UNITY_MATRIX_M[0][3] + UNITY_MATRIX_M[1][3] + UNITY_MATRIX_M[2][3]);
}

float3 GetPivotPos()
{
	return float3(UNITY_MATRIX_M[0][3], UNITY_MATRIX_M[1][3] + 0.25, UNITY_MATRIX_M[2][3]);
}

float DistanceFadeFactor(float3 wPos, float4 params)
{
	if (params.z == 0) return 0;

	float pixelDist = length(CameraPositionWS(wPos).xyz - wPos.xyz);

	//Distance based scalar
	return saturate((pixelDist - params.x) / params.y);
}

void ApplyLODCrossfade(inout float factor, float2 clipPos)
{
	#if LOD_FADE_CROSSFADE
		float hash = GenerateHashedRandomFloat(clipPos.xy);
		factor = lerp(hash, factor, unity_LODFade.x > 0 ? unity_LODFade.x : 1);
	#endif
}

float3 DeriveNormal(float3 positionWS)
{
	float3 dpx = ddx(positionWS);
	float3 dpy = ddy(positionWS) * _ProjectionParams.x;
	return normalize(cross(dpx, dpy));
}

float InterleavedNoise(float2 coords, float t)
{
	return t * (InterleavedGradientNoise(coords, 0) + t);
}

#define ANGLE_FADE_DITHER_SIZE 0.49
