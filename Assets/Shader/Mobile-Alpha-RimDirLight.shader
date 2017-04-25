Shader "Topameng/Transparent/FakeRimLight" 
{
	Properties 
	{						
		_Color( "Rim Color", Color ) = ( 0,0.8741257,1,1 )				
		_FakeLight("Fake Light Dir", Vector) = (1,2,1,0)		
		_RimParam ("Rim Param", Range(0,2)) = 1.2
		_RimWidth ("Rim Width", Range(0,2)) = 0.8
	}

	SubShader 
	{
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		LOD 100	
		
		Blend SrcAlpha OneMinusSrcAlpha				
		ZWrite Off 			

		Pass 
		{
			CGPROGRAM
			#pragma exclude_renderers ps3 xbox360 flash xboxone ps4 psp2
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment frag	
			#include "UnityCG.cginc"

			fixed4 _Color;				
			fixed _RimWidth;
			float4 _FakeLight;			
			float _RimParam;

			struct v2f 
			{
				float4 pos	: SV_POSITION;
				float3 normal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;				
			};

			v2f vert (appdata_base v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);				
				o.normal = UnityObjectToWorldNormal(v.normal);				
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{	
				float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));	
			#ifndef USING_DIRECTIONAL_LIGHT
    			float3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
			#else
    			float3 lightDir = _WorldSpaceLightPos0.xyz;
			#endif						
			
				float rim = 1.0 - saturate(dot (viewDir, i.normal));			
				rim = smoothstep(1.0 - _RimWidth, 1.0, rim);		
				float rim2 = saturate(dot(i.normal, lightDir.xyz));
				fixed4 clr = _Color * rim * rim2 * _RimParam;							
				return clr;			
			}
			ENDCG
		}			 			
	}	
}
