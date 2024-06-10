struct InstanceInfo
{
    float4x4 localToWorld;
};
StructuredBuffer<InstanceInfo> _InstanceInfoBuffer;

void setup()
{
	#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED

		#ifdef unity_ObjectToWorld
			#undef unity_ObjectToWorld
		#endif

		#ifdef unity_WorldToObject
			#undef unity_WorldToObject
		#endif

		// unity_ObjectToWorld = VisibleShaderDataBuffer[unity_InstanceID].PositionMatrix;
		// unity_WorldToObject = VisibleShaderDataBuffer[unity_InstanceID].InversePositionMatrix;

		InstanceInfo bufferData = _InstanceInfoBuffer[unity_InstanceID];
		unity_ObjectToWorld = bufferData.localToWorld;
	#endif
}
