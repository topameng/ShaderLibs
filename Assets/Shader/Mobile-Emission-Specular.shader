Shader "Topameng/Emission/Specular" 
{
	Properties 
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_MaskTex ("Gloss (R) Mission(G)", 2D) = "white" {}
		_SpecStrength("Specular Strength", Range(0.1, 10)) = 1
		_Shininess ("Shininess", Range (0.03, 1)) = 0.078125		
		_Emission ("Emission Strength", Range (0, 4)) = 1
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
			#pragma exclude_renderers ps3 xbox360 flash xboxone ps4 psp2
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma multi_compile_fog
			#pragma multi_compile_fwdbase nolightmap nodynlightmap
			#include "Mobile-VertexLit.cginc" 						
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}

		Pass 
		{			
			Tags { "LightMode" = "ForwardAdd" }
			ZWrite Off
			Blend One One

			CGPROGRAM					
			#define PHONG_LIGHTING 1				
			#pragma exclude_renderers ps3 xbox360 flash xboxone ps4 psp2
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma multi_compile_fog
			#pragma multi_compile_fwdadd			
			#include "Mobile-VertexLitAdd.cginc" 						
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}	

	//Fallback "Topameng/Diffuse"
}
