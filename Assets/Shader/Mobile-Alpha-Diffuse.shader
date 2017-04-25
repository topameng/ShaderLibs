Shader "Topameng/Transparent/Diffuse" 
{
	Properties 
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}		
	}

	SubShader 
	{		
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		LOD 200

		ZWrite Off		
		Blend SrcAlpha OneMinusSrcAlpha

		Pass 
		{
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM						
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
	}	

	//Fallback "Transparent/VertexLit"	
}
