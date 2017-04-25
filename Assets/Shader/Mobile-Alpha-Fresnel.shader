Shader "Topameng/Transparent/Fresnel" 
{
	Properties 
	{						
		_Color( "Rim Color", Color ) = ( 0,0.8741257,1,1 )				
		_RimWidth ("Rim Width", float) = 0.8
	}

	SubShader 
	{
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		LOD 100	
		
		Blend One OneMinusSrcAlpha			
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
				float rim = 1.0 - saturate(dot (viewDir, i.normal));			
				rim = smoothstep(1.0 - _RimWidth, 1.0, rim);		
				fixed4 clr = _Color * rim;				
				return clr;				
			}
			ENDCG
		}			 			
	}	
}
