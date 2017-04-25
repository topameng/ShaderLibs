Shader "Topameng/Transparent/Cutout/Hair" 
{
	Properties 
	{
		_Color ("Main Color", Color) = (1, 1, 1, 1)
		_MainTex ("Base (RGB) Alpha (A)", 2D) = "white" {}
		_Cutoff ("Base Alpha cutoff", Range (0.05,.99)) = .7
	}

	SubShader 
	{
		Tags { "Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout" }	
		LOD 300	
		Cull off		

		Pass 
		{			
			Tags { "LightMode" = "ForwardBase"}	
			Blend SrcAlpha OneMinusSrcAlpha
										
			CGPROGRAM			
			#define HALF_LAMBERT 1	
			#define ALPHA_CUTOFF 1
			#pragma exclude_renderers ps3 xbox360 flash xboxone ps4 psp2		
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma skip_variants FOG_EXP FOG_EXP2 DIRLIGHTMAP_COMBINED DIRLIGHTMAP_SEPARATE			
			#include "Mobile-VertexLit.cginc" 			
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}

		Pass 
		{			
			Tags { "LightMode" = "ForwardBase"}												
			ZWrite off					
			Blend SrcAlpha OneMinusSrcAlpha			

			CGPROGRAM		
			#define HALF_LAMBERT 1	
			#define SOFT_CUTOFF 1	
			#pragma exclude_renderers ps3 xbox360 flash xboxone ps4 psp2		
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma skip_variants FOG_EXP FOG_EXP2 DIRLIGHTMAP_COMBINED DIRLIGHTMAP_SEPARATE			
			#include "Mobile-VertexLit.cginc" 			
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}

		UsePass "Transparent/Cutout/VertexLit/CASTER" 

		/*Pass 
		{			
			ZWrite on
			ColorMask 0

			CGPROGRAM			
			#pragma exclude_renderers ps3 xbox360 flash xboxone ps4 psp2		
			#pragma fragmentoption ARB_precision_hint_fastest						
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Cutoff;

			struct v2f
			{
				float4 pos: POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);	
				return o;
			}

			fixed4 frag (v2f i) : SV_Target 
			{
				fixed4 c = tex2D(_MainTex, i.uv);
				clip(c.a - _Cutoff);
				return fixed4(0,0,0,0);
			}

			ENDCG
		}

		Pass 
		{			
			Tags { "LightMode" = "ForwardBase"}	
			ZWrite off
			Blend SrcAlpha OneMinusSrcAlpha
										
			CGPROGRAM			
			//#define HALF_LAMBERT 1	
			#pragma exclude_renderers ps3 xbox360 flash xboxone ps4 psp2		
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "Mobile-VertexLit.cginc" 			
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}*/
	}

	//Fallback "Transparent/Cutout/VertexLit"
}
