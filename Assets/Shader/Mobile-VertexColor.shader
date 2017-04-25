
Shader "Topameng/Debug/VertexColor" 
{
	Properties 
	{
		_ShowAlpha ("Base Alpha cutoff", Range (0,1)) = 0
	}
	
	SubShader 
	{	
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}
				
		Cull Off 
		Lighting Off 		
		LOD 100

		Pass 
		{
			CGPROGRAM
			#pragma exclude_renderers ps3 xbox360 flash xboxone ps4 psp2
			#pragma fragmentoption ARB_precision_hint_fastest	
			#include "UnityCG.cginc"
			#include "Globals.cginc"			
			#pragma vertex vert
			#pragma fragment frag			

			struct v2f 
			{
				float4	pos	: SV_POSITION;
				float2	uv		: TEXCOORD0;
				fixed4	color	: TEXCOORD1;
			};

			fixed _ShowAlpha;

			v2f vert (appdata_color v)
			{
				v2f o;			
				o.uv 	= v.texcoord.xy;
				o.pos	= mul(UNITY_MATRIX_MVP, v.vertex);

				if (_ShowAlpha > 0)
				{
					o.color = v.color.a;
				}
				else
				{
					o.color	= v.color;
				}
						
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{			
				return i.color;
			}

			ENDCG 
		}	
	}
}

