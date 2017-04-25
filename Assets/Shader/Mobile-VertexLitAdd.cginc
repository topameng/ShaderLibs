// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

/*
作者: topameng 日期: 2016-10-31
作用: Lambert or BlinnPhong + Fresnel + Reflection + Emission + UVAnim
*/
#define UNITY_PASS_FORWARDADD
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

sampler2D _MainTex;
float4 _MainTex_ST;
fixed4 _Color;

#if defined(ALPHA_CUTOFF) || defined(SOFT_CUTOFF)
float _Cutoff;
#endif

#ifdef SCROLL_UV
float _ScrollX;
float _ScrollY;
#endif

#ifdef RIM_LIGHT
fixed3 _RimColor;
fixed _RimWidth;
#endif

#ifdef FRESNEL_ON
fixed _Fresnel;
#endif

#ifdef REFLECTION_ON
samplerCUBE _EnvCube;
float _ReflStrength;
#endif

#if defined(REFLECTION_ON) || defined(PHONG_LIGHTING) || defined(EMISSION_ON)
sampler2D _MaskTex;
#endif

#ifdef EMISSION_ON
fixed _Emission;
#endif

#ifdef FADEOUT_FX
sampler2D _NoiseTex;
fixed4 _FXColor;
float _TimeOffs;
float _Duration;
float _Invert;
float _GlobalTime;
#endif

struct v2f
{
	float4 pos : SV_POSITION;	
	float2 uv : TEXCOORD0;
	fixed3 light : TEXCOORD1;	
	fixed4 srtf: TEXCOORD2;			//spec, rim, thr, fresnel		
#if defined(REFLECTION_ON)
	float3 worldRefl : TEXCOORD3;
#endif

	SHADOW_COORDS(4)
	UNITY_FOG_COORDS(5)
};

#ifdef PHONG_LIGHTING
fixed _Shininess;
fixed _SpecStrength;

void PhongLighting(float3 normal, float3 lightDir, float3 halfDir, out fixed3 diff, out fixed spec)
{	
	fixed NdotL = max(0, dot(normal, lightDir));	
	fixed NdotH = max(0, dot(normal, halfDir));

	diff = NdotL * _LightColor0;
	spec = pow(NdotH, _Shininess * 128.0) * _SpecStrength;
}
#else
fixed3 Lambert(float3 normal, float3 lightDir)
{	
#if HALF_LAMBERT
	fixed NdotL = dot(normal, lightDir);
	NdotL = NdotL * 0.5 + 0.5;
#else	
	fixed NdotL = DotClamped(normal, lightDir);
#endif	
	return NdotL * _LightColor0;
}
#endif

v2f vert(appdata_base v)
{
	v2f o;
	UNITY_INITIALIZE_OUTPUT(v2f, o);
	o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
	o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);	

#ifdef SCROLL_UV
	o.uv += frac(float2(_ScrollX, _ScrollY) * _Time.y);
#endif	
	
	float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
	fixed3 worldN = UnityObjectToWorldNormal(v.normal);
    fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
	float3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos)); 	

#if defined(PHONG_LIGHTING)
	float3 halfDir = normalize(lightDir + viewDir);	
#endif

#ifdef PHONG_LIGHTING		
	fixed spec = 0;
	PhongLighting(worldN, lightDir, halfDir, o.light, spec);
	o.srtf.x = spec;
#else	
	o.light = Lambert(worldN, lightDir);		
#endif	//PHONG_LIGHTING	

#ifdef SHADOWS_SCREEN
	TRANSFER_SHADOW(o);
#endif
	UNITY_TRANSFER_FOG(o, o.pos); 
	return o; 
}

fixed4 frag(v2f i) : SV_Target 
{		
	fixed4 tex = tex2D(_MainTex, i.uv) * _Color;	

#ifdef ALPHA_CUTOFF
	clip(tex.a - _Cutoff);
#elif (SOFT_CUTOFF)	
	clip(-(tex.a - _Cutoff) + 0.05);
#endif

#if defined(PHONG_LIGHTING) || defined(REFLECTION_ON) || defined(EMISSION_ON)
	fixed3 mask = tex2D(_MaskTex, i.uv).rgb;
#endif	

#ifdef PHONG_LIGHTING		
	fixed spec = i.srtf.x;

	#ifdef EMISSION_ON
		fixed3 specColor = mask.r;
	#else
		fixed3 specColor = mask;
	#endif

	fixed3 clr = _LightColor0 * spec * specColor + i.light * tex.rgb;	
#else	
	fixed3 clr = tex.rgb * i.light;
#endif

	fixed4 c = fixed4(clr, tex.a);

#if defined(SHADOWS_SCREEN)
	fixed atten = SHADOW_ATTENUATION(i);
	c.rgb *= atten;	
#endif	

#ifdef EMISSION_ON		
	c.rgb += tex.rgb * mask.b * _Emission;
#endif

#ifdef FADEOUT_FX
	fixed noise = tex2D(_NoiseTex, i.uv * 2).r;
	fixed threshold	= i.srtf.z;
	fixed killDiff = noise - threshold;
	fixed border = 1 - saturate(killDiff * 4);
	
	border *= border;
	border *= border;
	c.a = step(threshold, noise);
	c.rgb += _FXColor.xyz * border;		
#endif

#ifdef RIM_LIGHT
	fixed rimLight = i.srtf.y;
	c.rgb += _RimColor * rimLight;	
#endif

#ifdef REFLECTION_ON
	fixed3 reflcol = texCUBE(_EnvCube, i.worldRefl).rgb;
	reflcol *= mask * _ReflStrength;		

#if FRESNEL_ON
	reflcol *= i.srtf.w;
#endif

	c.rgb += reflcol;
#endif
	
	c.a = 0;
	UNITY_APPLY_FOG(i.fogCoord, c);
	return c;
}