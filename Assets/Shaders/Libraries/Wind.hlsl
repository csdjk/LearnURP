//Properties
TEXTURE2D(_WindMap);       SAMPLER(sampler_WindMap);
float4 _GlobalWindParams;
//X: Strength
//W: (int bool) Wind zone present
float _WindStrength;
//float4 _WindDirection;

//Nature Renderer parameters
float4 GlobalWindDirectionAndStrength;
//X: Gust dir X
//Y: Gust dir Y
//Z: Gust speed
//W: Gust strength
float4 _GlobalShiver;
//X: Shiver speed
//Y: Shiver strength

struct WindSettings
{
	float mask;
	float strength;
	float speed;
	float4 direction;
	float swinging;

	float randObject;
	float randVertex;
	float randObjectStrength;

	float gustStrength;
	float gustFrequency;
};

WindSettings InitializeWindSettings(in float strength, float speed, float4 direction, float swinging, float mask,  float gustStrength, float gustFrequency)
{
	WindSettings s = (WindSettings)0;

	//Apply WindZone strength
	if (_GlobalWindParams.w > 0)
	{
		strength *= _GlobalWindParams.x;
		gustStrength *= _GlobalWindParams.x;
		//direction.xz += _WindDirection.xz;
	}

	//Nature renderer params
	if (_GlobalShiver.y > 0)
	{
		strength += _GlobalShiver.y;
		speed += _GlobalShiver.x;
	}
	if (GlobalWindDirectionAndStrength.w > 0)
	{
		gustStrength += GlobalWindDirectionAndStrength.w;
		direction.xz += GlobalWindDirectionAndStrength.xy;
	}

	s.strength = strength;
	s.speed = speed;
	s.direction = direction;
	s.swinging = swinging;
	s.mask = mask;
	s.gustStrength = gustStrength;
	s.gustFrequency = gustFrequency;

	return s;
}

void SampleGustTexture_float(in float3 wPos, in float speed, in float freq, in float3 dir, out float3 tex)
{

	float2 uv = (wPos.xz * freq) + _Time.x * speed * dir.xz;

	tex = SAMPLE_TEXTURE2D_LOD(_WindMap, sampler_WindMap, uv, 0).rgb;
}

//World-align UV moving in wind direction
float2 GetGustingUV(float3 wPos, WindSettings s)
{
	return(wPos.xz * s.gustFrequency * 0.01) + (_TimeParameters.x * s.speed * s.gustFrequency * 0.01) * - s.direction.xz;
}

float SampleGustMapLOD(float3 wPos, WindSettings s)
{
	float2 gustUV = GetGustingUV(wPos, s);
	float gust = SAMPLE_TEXTURE2D_LOD(_WindMap, sampler_WindMap, gustUV, 0).r;

	gust *= s.gustStrength * s.mask;

	return gust;
}

float SampleGustMap(float3 wPos, WindSettings s)
{
	float2 gustUV = GetGustingUV(wPos, s);

	float gust = SAMPLE_TEXTURE2D(_WindMap, sampler_WindMap, gustUV).r;

	gust *= s.gustStrength * s.mask;

	return gust;
}

float4 GetWindOffset(in float3 positionOS, in float3 wPos, float rand, WindSettings s)
{
	float4 offset;

	float f = length(positionOS.xz) ;

	// float strength = s.strength * 0.5 * lerp(1, rand, s.randObjectStrength);
	float strength = s.strength;
	//Combine
	// float sine = sin(s.speed * (_TimeParameters.x + (rand * s.randObject) + f));
	float sine = sin(s.speed * (_TimeParameters.x + f));
	//Remap from -1/1 to 0/1
	sine = lerp(sine * 0.5 + 0.5, sine, s.swinging);

	//Apply gusting
	float gust = SampleGustMapLOD(wPos, s);

	//Scale sine
	sine = sine * s.mask * strength;

	//Mask by direction vector + gusting push
	offset.xz = sine + gust;
	offset.y = s.mask;

	//Summed offset strength
	float windWeight = length(offset.xz) + 0.0001;
	//Slightly negate the triangle-shape curve
	windWeight = pow(windWeight, 1.5);
	offset.y *= windWeight;

	//Wind strength in alpha
	offset.a = sine + gust;

	return offset;
}