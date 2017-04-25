// Upgrade NOTE: replaced '_Projector' with 'unity_Projector'

/*
Copyright (c) 2016 topameng(topameng@qq.com) All rights reserved.
*/

Shader "Topameng/Projector/Blend" 
{ 
	Properties 
	{
		_MainTex ("MainTex", 2D) = "gray" {}	
		//_FalloffTex ("FallOff", 2D) = "" {}							
	}

	Subshader 
	{
		Tags {"Queue"="Transparent"}

		Pass 
		{			
			ZWrite Off			
			Fog { Color (0, 0, 0) }			
			ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha					
			Offset -1, -1
 
			CGPROGRAM			
			#pragma fragmentoption ARB_precision_hint_fastest			
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			struct v2f 
			{
				half4 pos : SV_POSITION;
				half4 uv : TEXCOORD0;	
				//float4 uvFalloff : TEXCOORD1;							
			};
						   
			float4x4 unity_Projector;
			//float4x4 _ProjectorClip;
			
			v2f vert (float4 vertex : POSITION)
			{
				v2f o;
				o.pos = mul (UNITY_MATRIX_MVP, vertex);
				o.uv = mul (unity_Projector, vertex);	
				//o.uvFalloff = mul (_ProjectorClip, vertex);			
				return o;
			}
			
			sampler2D _MainTex;												
			//sampler2D _FalloffTex;

			fixed4 frag (v2f i) : SV_Target
			{				
				fixed4 tex = tex2Dproj (_MainTex, UNITY_PROJ_COORD(i.uv));							
				//fixed4 texF = tex2Dproj (_FalloffTex, UNITY_PROJ_COORD(i.uvFalloff));
				//tex *= texF.a;												
				return tex; 				
			}
 
			ENDCG
		}
	}
}

