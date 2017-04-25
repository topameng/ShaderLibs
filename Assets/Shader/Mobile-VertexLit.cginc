// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

/*
作者: topameng 日期: 2016-10-31
作用: Lambert or BlinnPhong + Fresnel + Reflection + Emission + UVAnim
*/
#define UNITY_PASS_FORWARDBASE
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"
#include "Globals.cginc"
#include "UnityStandardUtils.cginc"

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

#ifdef LIGHTMAP_OFF 
	struct v2f
	{
		float4 pos : SV_POSITION;	
		float2 uv : TEXCOORD0;
		fixed3 light : TEXCOORD1;	
		fixed3 vlight : TEXCOORD2;
		fixed4 srtf: TEXCOORD3;			//spec, rim, thr, fresnel
	#if defined(REFLECTION_ON)
		float3 worldRefl : TEXCOORD4;
	#endif
		SHADOW_COORDS(5)
		UNITY_FOG_COORDS(6)
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
	#ifndef USING_DIRECTIONAL_LIGHT
    	fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
	#else
    	fixed3 lightDir = _WorldSpaceLightPos0.xyz;
	#endif	
		float3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos)); 	

	#if defined(PHONG_LIGHTING) || defined(FRESNEL_ON)
		float3 halfDir = normalize(lightDir + viewDir);	
	#endif

	#if FRESNEL_ON
		fixed VdotH = max(0, dot(viewDir,worldN));		
		o.srtf.w = Fresnel(VdotH, _Fresnel, 5);;
	#endif
	
	#ifdef PHONG_LIGHTING		
		fixed spec = 0;
		PhongLighting(worldN, lightDir, halfDir, o.light, spec);
		o.srtf.x = spec;
	#else	
		o.light = Lambert(worldN, lightDir);		
	#endif		

	#ifdef RIM_LIGHT
		fixed rimLight = 1 - saturate(dot(viewDir, worldN));
		o.srtf.y = smoothstep(1.0 - _RimWidth, 1.0, rimLight);		
	#endif

	#ifdef FADEOUT_FX
		float t = saturate((_TimeOffs + _GlobalTime) / _Duration); 	
		o.srtf.z = _Invert; // > 0 ? 1 - t : t;
	#endif

	#ifdef REFLECTION_ON  	  	
		o.worldRefl = reflect(-viewDir, worldN);
	#endif

	o.vlight = 0;
	#if UNITY_SHOULD_SAMPLE_SH
		#ifdef VERTEXLIGHT_ON
			o.vlight += Shade4PointLights(
				unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
				unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
				unity_4LightAtten0, worldPos, worldN);
		#endif

		o.vlight = ShadeSHPerVertex(worldN, o.vlight);	
	#endif	
	
		TRANSFER_SHADOW(o);	

	#if !defined(FOG_OFF)
		UNITY_TRANSFER_FOG(o,o.pos);
	#endif	
		return o; 
	}

	fixed4 frag(v2f i) : SV_Target 
	{				
		fixed4 tex = tex2D(_MainTex, i.uv) * _Color;
	#ifdef ALPHA_CUTOFF		
		clip(tex.a - _Cutoff);
	#elif SOFT_CUTOFF
		clip(-(tex.a - _Cutoff) + 0.1);		
	#endif

	#if defined(PHONG_LIGHTING) || defined(REFLECTION_ON) || defined(EMISSION_ON)
		fixed3 mask = tex2D(_MaskTex, i.uv).rgb;
	#endif	

	#ifdef PHONG_LIGHTING		
		fixed spec = i.srtf.x;

		#ifdef EMISSION_ON
			fixed3 specColor = mask.rrr;
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

		c.rgb += i.vlight * tex.rgb;	

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

	#if !defined(FOG_OFF)			
		UNITY_APPLY_FOG(i.fogCoord, c);  				
	#endif
		return c;		
	}
#else
	struct appdata_lightmap
	{
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float4 texcoord : TEXCOORD0;
		float4 texcoord1 : TEXCOORD1;
		float4 texcoord2 : TEXCOORD2;
	};

	struct v2f
	{
		float4 pos : SV_POSITION;	
		float2 uv : TEXCOORD0;
		float4 lmap : TEXCOORD1;
		fixed4 srtf: TEXCOORD2;			//spec, rim, thr, fresnel
	#if defined(REFLECTION_ON)
		float3 worldRefl : TEXCOORD3;
	#endif
		SHADOW_COORDS(4)
		UNITY_FOG_COORDS(5)
	};

	v2f vert(appdata_lightmap v)
	{
		v2f o;
		UNITY_INITIALIZE_OUTPUT(v2f, o);
		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
		o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);	
		o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;

	#ifndef DYNAMICLIGHTMAP_OFF
	  	o.lmap.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
	#endif

	#ifdef SCROLL_UV
		o.uv += frac(float2(_ScrollX, _ScrollY) * _Time.y);
	#endif

	#if defined(RIM_LIGHT) || defined(REFLECTION_ON)
		float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
		fixed3 worldN = UnityObjectToWorldNormal(v.normal);
		float3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos)); 	
	#endif

	#ifdef RIM_LIGHT
		fixed rimLight = 1 - saturate(dot(viewDir, worldN));
		o.srtf.y = smoothstep(1.0 - _RimWidth, 1.0, rimLight);
	#endif
	
	#ifdef REFLECTION_ON  	  	
		o.worldRefl = reflect(-viewDir, worldN);
	#endif
	
		TRANSFER_SHADOW(o);
		UNITY_TRANSFER_FOG(o,o.pos);
		return o;
	}

	fixed4 frag(v2f i) : SV_Target 
	{				
		fixed4 tex = tex2D(_MainTex, i.uv) * _Color;
	#ifdef ALPHA_CUTOFF		
		clip(tex.a - _Cutoff);
	#elif SOFT_CUTOFF
		clip(-(tex.a - _Cutoff) + 0.1);			
	#endif

	#if defined(PHONG_LIGHTING) || defined(REFLECTION_ON) || defined(EMISSION_ON)
		fixed3 mask = tex2D(_MaskTex, i.uv).rgb;
	#endif		

	fixed4 c = fixed4(0, 0, 0, tex.a);  		
	half3 light = SimpleUnityGI(i.lmap, SHADOW_ATTENUATION(i));
	c.rgb = tex.rgb * light;

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

	#ifdef EMISSION_ON		
		c.rgb += tex.rgb * mask.b * _Emission;
	#endif

		UNITY_APPLY_FOG(i.fogCoord, c);  			
		return c;
	}
#endif