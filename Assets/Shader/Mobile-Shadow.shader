Shader "Topameng/Transparent/Shadow" 
{
	Properties 
	{
		_Sphere0("S0",	Vector) = (0,0,0,0)
		_Sphere1("S0",	Vector) = (0,0,0,0)
		_Sphere2("S0",	Vector) = (0,0,0,0)
		_Intensity("Intensity",Range(0, 1)) = 0.9
	}

	SubShader 
	{
		Tags { "Queue"="Transparent-20" "IgnoreProjector"="True" "RenderType"="Transparent" }

		Blend DstColor Zero
		Cull Off 
		Lighting Off 
		ZWrite Off 		
		ColorMask RGB

		Pass 
		{
			CGPROGRAM
			#pragma exclude_renderers ps3 xbox360 flash xboxone ps4 psp2
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment frag			
			#include "UnityCG.cginc"

			#define USE_PERPIXEL_AO
	
			struct v2f 
			{
				float4 pos : SV_POSITION;
				fixed4 color: COLOR;
			#if defined(USE_PERPIXEL_AO)
				float3 worldPos	: TEXCOORD0;
				float3 normal	: TEXCOORD1;
			#endif
			};

			float4	_Sphere0;
			float4	_Sphere1;
			float4	_Sphere2;
			float	_Intensity;

			float SphereAO(float4 sphere, float3 pos, float3 normal)
			{
				float3	dir = sphere.xyz - pos;
				float	d	= length(dir);			
				dir /= d;

				float v = sphere.w / d;
				return dot(normal, dir) * v * v;
			}

			v2f vert (appdata_base v)
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);
				float3 worldPos 	= mul(unity_ObjectToWorld,v.vertex);
				float3 worldNormal	= mul((float3x3)unity_ObjectToWorld,v.normal);
				float ao;

				o.pos	= mul(UNITY_MATRIX_MVP, v.vertex);

			#if defined(USE_PERPIXEL_AO)
				o.worldPos = worldPos;
				o.normal = worldNormal;		
				o.color = 1;					
			#else
				ao = 1 - saturate(SphereAO(_Sphere0,worldPos,worldNormal) + SphereAO(_Sphere1,worldPos,worldNormal) + SphereAO(_Sphere2,worldPos,worldNormal));
				ao = max(ao, 1 - _Intensity);
				o.color = fixed4(ao,ao,ao,ao);
			#endif
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
			#if defined(USE_PERPIXEL_AO)
				float3 worldPos		= i.worldPos;
				float3 worldNormal	= i.normal;				
				float ao = 1 - saturate(SphereAO(_Sphere0, worldPos, worldNormal) + SphereAO(_Sphere1, worldPos, worldNormal) + SphereAO(_Sphere2, worldPos, worldNormal));
				ao = max(ao, 1 - _Intensity);

				return ao;
			#else
				return i.color;
			#endif
			}
			ENDCG
		}
	}
}
