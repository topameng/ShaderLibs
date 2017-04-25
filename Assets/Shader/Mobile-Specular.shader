Shader "Topameng/Specular" 
{
	Properties 
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_MaskTex ("Gloss (RGB)", 2D) = "white" {}
		_SpecStrength("Specular strength", Range(0.5, 10)) = 1
		_Shininess ("Shininess", Range (0.03, 1)) = 0.078125
	}

	SubShader 
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}	
		LOD 150

		Pass 
		{
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM			
			#define PHONG_LIGHTING 1
			#pragma exclude_renderers ps3 xbox360 flash xboxone ps4 psp2 					
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
