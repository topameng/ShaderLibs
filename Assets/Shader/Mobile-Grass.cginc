// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

/*
作者: topameng 日期: 2016-10-31
作用: Grass + 顶点动画
*/
#define UNITY_PASS_FORWARDBASE
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"
#include "Globals.cginc"

sampler2D _MainTex;
float4 _MainTex_ST;	
fixed4 _Color;
	
float _WindEdgeFlutter;
float _WindEdgeFlutterFreqScale;
float4 _Wind;

#ifdef ALPHA_CUTOFF
float _Cutoff; 		
#endif

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

#ifdef LIGHTMAP_OFF	

	struct appdata_vertex 
	{
		float4 vertex : POSITION;
		float3 normal : NORMAL;
	#ifdef VERTEX_ALPHA_WIND
		fixed4 color: COLOR;
	#endif	
		float4 texcoord : TEXCOORD0;
	};

	struct v2f 
	{
		float4 pos : SV_POSITION;	
		float2 uv : TEXCOORD0;	
		fixed3 light : TEXCOORD1;	
		fixed3 vlight : TEXCOORD2;						
		SHADOW_COORDS(3)
		UNITY_FOG_COORDS(4)	
	};
		
	v2f vert(appdata_vertex v)
	{
		v2f o;		
		UNITY_INITIALIZE_OUTPUT(v2f, o);
		float4 wind;					

		wind.xyz = mul((float3x3)unity_WorldToObject,_Wind.xyz);
	#ifdef VERTEX_ALPHA_WIND
		wind.w	= _Wind.w  * v.color.a;
	#else
		wind.w	= _Wind.w  * v.texcoord.y;
	#endif	
					
		float4	windParams	= float4(0,_WindEdgeFlutter,v.texcoord.yy);
		float2	time 		= _Time.yy * float2(_WindEdgeFlutterFreqScale,1);
		float4	mdlPos		= AnimateGrassVertex(v.vertex,v.normal,windParams,wind, time);
			
		o.pos = mul(UNITY_MATRIX_MVP, mdlPos);
		o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);			
	
		fixed3 worldN = UnityObjectToWorldNormal(v.normal);
		float3 worldPos = mul(unity_ObjectToWorld, mdlPos).xyz;
		#ifndef USING_DIRECTIONAL_LIGHT
	    	fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
		#else
	    	fixed3 lightDir = _WorldSpaceLightPos0.xyz;
		#endif	

		o.light = Lambert(worldN, lightDir);	
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
		UNITY_TRANSFER_FOG(o,o.pos);
		return o;
	}

	fixed4 frag (v2f i) : SV_Target
	{
		fixed4 tex = tex2D (_MainTex, i.uv) * _Color;				
	#ifdef ALPHA_CUTOFF
		clip(tex.a - _Cutoff);
	#endif
	
		fixed3 clr = tex.rgb * i.light;
		fixed4 c = fixed4(clr, tex.a);

	#ifdef SHADOWS_SCREEN
		c.rgb *= SHADOW_ATTENUATION(i);	
	#endif

		c.rgb += i.vlight * tex.rgb;	
		UNITY_APPLY_FOG(i.fogCoord, c);  
		return c;
	}
#else

	struct appdata_vertex 
	{
		float4 vertex : POSITION;
		float3 normal : NORMAL;
	#ifdef VERTEX_ALPHA_WIND
		fixed4 color: COLOR;
	#endif	
		float4 texcoord : TEXCOORD0;
		float4 texcoord1 : TEXCOORD1;
		float4 texcoord2 : TEXCOORD2;
	};

	struct v2f 
	{
		float4 pos : SV_POSITION;	
		float2 uv : TEXCOORD0;	
		float4 lmap : TEXCOORD1;			
		SHADOW_COORDS(2)
		UNITY_FOG_COORDS(3)	
	};

	v2f vert(appdata_vertex v)
	{
		v2f o;		
		UNITY_INITIALIZE_OUTPUT(v2f, o);
		float4 wind;					

		wind.xyz = mul((float3x3)unity_WorldToObject,_Wind.xyz);
	#ifdef VERTEX_ALPHA_WIND
		wind.w	= _Wind.w  * v.color.a;
	#else
		wind.w	= _Wind.w  * v.texcoord.y;
	#endif	
					
		float4	windParams	= float4(0,_WindEdgeFlutter,v.texcoord.yy);
		float2	time 		= _Time.yy * float2(_WindEdgeFlutterFreqScale,1);
		float4	mdlPos		= AnimateGrassVertex(v.vertex,v.normal,windParams,wind, time);
			
		o.pos = mul(UNITY_MATRIX_MVP, mdlPos);
		o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);			
		o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;	

	#ifndef DYNAMICLIGHTMAP_OFF
	  	o.lmap.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
	#endif
	
		TRANSFER_SHADOW(o);	
		UNITY_TRANSFER_FOG(o,o.pos);
		return o;
	}

	fixed4 frag (v2f i) : SV_Target
	{
		fixed4 tex = tex2D (_MainTex, i.uv) * _Color;				
	#ifdef ALPHA_CUTOFF
		clip(tex.a - _Cutoff);
	#endif

		fixed4 c = fixed4(0, 0, 0, tex.a);  		
		half3 light = SimpleUnityGI(i.lmap, SHADOW_ATTENUATION(i));
		c.rgb = tex.rgb * light;	
		UNITY_APPLY_FOG(i.fogCoord, c);  
		return c;
	}

#endif