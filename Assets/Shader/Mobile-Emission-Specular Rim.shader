Shader "Topameng/Emission/Specular Rim" 
{
	Properties 
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_MaskTex ("Gloss (R) Mission(G)", 2D) = "white" {}
		_SpecStrength("Specular Strength", Range(0.1, 10)) = 1
		_Shininess ("Shininess", Range (0.03, 1)) = 0.078125		
		_Emission ("Emission Strength", Range (0, 4)) = 1
		_RimColor("Rim Color", Color) = (0.03,0.03,0.03,0.03)
		_RimWidth("Rim Width", float) = 0.5
	}

	SubShader 
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}	
		LOD 150

		Pass 
		{
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM		
			#define EMISSION_ON 1	
			#define PHONG_LIGHTING 1
			#define RIM_LIGHT 1
			#pragma exclude_renderers ps3 xbox360 flash xboxone ps4 psp2
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "Mobile-VertexLit.cginc" 			
			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}	

	Fallback "Topameng/Diffuse"
}
