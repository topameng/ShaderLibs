// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

//#define UNITY_SHADER_ENABLE_VOLUME_FOG
#define UNITY_SHADER_VOLUME_FOG_DIST_SCALE 0.075f

static const float PI = 3.1415926535897f;

//appdata_base + color
struct appdata_color
{
	fixed4 color  : COLOR;
	float4 vertex : POSITION;
	float3 normal : NORMAL;
	float4 texcoord : TEXCOORD0;	
};

float3 MFShadeVertexLights (float4 vertex, float3 normal)
{
	float3 viewpos = mul (UNITY_MATRIX_MV, vertex).xyz;
	float3 viewN = mul ((float3x3)UNITY_MATRIX_IT_MV, normal);
	float3 lightColor = 0;
	
	for (int i = 0; i < 4; i++) 
	{
		float3	toLight = unity_LightPosition[i].xyz - viewpos.xyz * unity_LightPosition[i].w;
		float	lengthSq = dot(toLight, toLight);
		float	atten = 1.0 / (1.0 + lengthSq * unity_LightAtten[i].z);
		float	diff = max (0, dot (viewN, normalize(toLight)));
		
		lightColor += unity_LightPosition[i].w > 0 ? unity_LightColor[i].rgb * (diff * atten) : 0;
//		lightColor += unity_LightPosition[i].w * float3(unity_LightColor[i].rgb * (diff * atten));
	}
	
	return lightColor;
}

float3 MFShadeVertexLightsExt(float4 vertex, float3 normal,out float3 strongestLightDir)
{
	float3 viewpos = mul (UNITY_MATRIX_MV, vertex).xyz;
	float3 viewN = mul ((float3x3)UNITY_MATRIX_IT_MV, normal);
	float3 lightColor = 0;
	
	for (int i = 0; i < 4; i++) 
	{
		float3	toLight		= unity_LightPosition[i].xyz - viewpos.xyz * unity_LightPosition[i].w;
		float	lengthSq	= dot(toLight, toLight);
		float	atten 		= (1 / (1.0 + lengthSq * unity_LightAtten[i].z)) * unity_LightPosition[i].w;
		float3	toLightNrm	= normalize(toLight);
		float	diff 		= max (0, dot (viewN, toLightNrm));
		
		strongestLightDir += toLightNrm * atten * step(1,dot(unity_LightColor[i].rgb > 0,float3(1,1,1)));		
		lightColor += float3(unity_LightColor[i].rgb * (diff * atten));
	}	
	
	return lightColor;
}

float4 MFSCurve4(float4 t)
{
	return t * t * (float(3.0).xxxx - 2.0f * t);
}

float4 MFSine4(float4 x)
{
	x = frac(x * (0.5 / PI) + 0.5) * 2 - 1;	
	return 4.0f * (x - x * abs(x));
}	

float4 MFCos4(float4 x)
{	
	return MFSine4(x + 0.5 * PI);
}	


float4 MFRand4(float4 v)
{
    float4 x = v * 78.233;
    	
	x = frac(x * (0.5 / PI) + 0.5) * 2 - 1;
	          
    return frac((x - x * abs(x)) * 43758.5453 * 4.0f);
}
	
// Generates continous random value from interval <0,1>
float4 Noise4(float4 v)
{
	float4	t	= frac(v);
	float4	r0	= MFRand4(v - t);
	float4	r1	= MFRand4(v - t + 1);
		
	return lerp(r0,r1,MFSCurve4(t));
}

fixed Fresnel(fixed vdoth, fixed bias, fixed power)
{
	return saturate(bias + (1 - bias) * pow(vdoth, power));
}

half3 MFMixNormals(half3 n1,half3 n2)
{
	half3 r = half3(n1.xy + n2.xy, n1.z*n2.z);   			
	return normalize(r);		
}


float CalcFadeOutFactor(float dist, float fadeNear, float fadeFar)
{	
	float near	= saturate(dist / fadeNear);
	float far	= 1 - saturate(max(dist - fadeFar, 0) * 0.2);
		
	far *= far;		
	near *= near;
	near *= near;		
	near *= far;

	return near;
}

float4 SmoothCurve( float4 x ) 
{   
	return x * x *( 3.0 - 2.0 * x );   
}

float4 TriangleWave( float4 x ) 
{   
	return abs( frac( x + 0.5 ) * 2.0 - 1.0 );   
}

float4 SmoothTriangleWave( float4 x ) 
{   
	return SmoothCurve( TriangleWave( x ) );   
}

float4 AnimateGrassVertex(float4 pos, float3 normal, float4 animParams,float4 wind, float2 time)
{	
	// animParams stored in color
	// animParams.x = branch phase
	// animParams.y = edge flutter factor
	// animParams.z = primary factor
	// animParams.w = secondary factor

	float fDetailAmp = 0.1f;
	float fBranchAmp = 0.3f;
	
	// Phases (object, vertex, branch)
	float fObjPhase = dot(unity_ObjectToWorld[3].xyz, 1);
	float fBranchPhase = fObjPhase + animParams.x;
	
	float fVtxPhase = dot(pos.xyz, animParams.y + fBranchPhase);
	
	// x is used for edges; y is used for branches	
	float2 vWavesIn = time + float2(fVtxPhase, fBranchPhase);
	
	// 1.975, 0.793, 0.375, 0.193 are good frequencies
	float4 vWaves = (frac( vWavesIn.xxyy * float4(1.975, 0.793, 0.375, 0.193) ) * 2.0 - 1.0);
	
	vWaves = SmoothTriangleWave( vWaves );
	float2 vWavesSum = vWaves.xz + vWaves.yw;

	// Edge (xz) and branch bending (y)
	float3 bend = animParams.y * fDetailAmp * normal.xyz;
	bend.y = animParams.w * fBranchAmp;
	pos.xyz += ((vWavesSum.xyx * bend) + (wind.xyz * vWavesSum.y * animParams.w)) * wind.w; 

	// Primary bending
	// Displace position
	pos.xyz += animParams.z * wind.xyz;
	
	return pos;
}

/*不超出opgles2.0, 禁用的分支是4.x方案，不支持Precomputed RealTime GI*/
inline half3 SimpleUnityGI(float4 lightmapUV, fixed atten)
{		
#if 1																
	fixed4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, lightmapUV.xy);
	half3 bakedColor = DecodeLightmap(bakedColorTex);
	half3 lm = bakedColor;		

	#ifdef SHADOWS_SCREEN
		lm = MixLightmapWithRealtimeAttenuation(lm, atten, bakedColorTex);
	#endif				

	#ifdef DYNAMICLIGHTMAP_ON						
		fixed4 realtimeColorTex = UNITY_SAMPLE_TEX2D(unity_DynamicLightmap, lightmapUV.zw);
		half3 realtimeColor = DecodeRealtimeLightmap (realtimeColorTex);						
		lm += realtimeColor;	
	#endif

	return lm;
#else	
  	fixed4 lmtex = UNITY_SAMPLE_TEX2D(unity_Lightmap, lightmapUV.xy);
  	half3 lm = DecodeLightmap(lmtex);

  	#ifdef SHADOWS_SCREEN		
      	#if defined(UNITY_NO_RGBM)
      		return min(lm, atten * 2);
      	#else
      		return max(min(lm, atten * 2 * lmtex.rgb), lm * atten);
      	#endif
    #else    		
		return lm;	
	#endif
#endif	
}
