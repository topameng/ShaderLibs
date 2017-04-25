Shader "Topameng/Reflective/Specular Rim" 
{
	Properties 
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "black" {}
		_MaskTex ("Gloss (RGB)", 2D) = "white" {}
		_SpecStrength("Specular Strength", Range(0.1, 10)) = 1
		_Shininess ("Shininess", Range (0.03, 1)) = 0.078125
		_ReflStrength("Reflction strength", Range(0.0, 2)) = 1
		_RimColor("Rim Color", Color) = (0.03,0.03,0.03,0.03)
		_RimWidth("Rim Width", float) = 0.5
	}

	SubShader 
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}	
		LOD 200

		Pass 
		{
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM		
			#define PHONG_LIGHTING 1
			#define REFLECTION_ON 1	
			#define RIM_LIGHT 1
			#pragma exclude_renderers ps3 xbox360 flash xboxone ps4 psp2
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma skip_variants FOG_EXP FOG_EXP2 DIRLIGHTMAP_COMBINED DIRLIGHTMAP_SEPARATE
			#pragma multi_compile _ FOG_OFF
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
