/*
作者: topameng 日期: 2016-10-31
作用: 顶点漫反射光照
*/

Shader "Topameng/Reflective/Diffuse" 
{
	Properties 
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_MaskTex ("Gloss (RGB)", 2D) = "white" {}
		_ReflStrength("Reflction strength", Range(0.0, 2)) = 1
	}

	SubShader 
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}	
		LOD 150

		Pass 
		{
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM		
			#define REFLECTION_ON 1	
			#pragma exclude_renderers ps3 xbox360 flash
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma skip_variants FOG_EXP FOG_EXP2 DIRLIGHTMAP_COMBINED DIRLIGHTMAP_SEPARATE
			#pragma multi_compile_fog
			#pragma multi_compile_fwdbase
			#include "Mobile-VertexLit.cginc" 						
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}

		UsePass "Mobile/VertexLit/SHADOWCASTER"		
	}		
}
