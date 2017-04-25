Shader "Topameng/FadeOut/Diffuse" 
{
	Properties 
	{		
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_NoiseTex ("Noise tex", 2D) = "white" {}
		_FXColor("FXColor", Color) = (0,0.97,0.89,1)
		_TimeOffs("Time offs",float) = 0
		_Duration("Duration",float) = 2
		_Invert("Invert",float) = 0
	}

	SubShader 
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }		
		LOD 350

		Pass 
		{
			Tags { "LightMode" = "ForwardBase" }			
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM			
			#define FADEOUT_FX 1
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

		Pass 
		{
			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }
					
			ZWrite On 
			ZTest Less 
			Cull Off			

			CGPROGRAM
			#pragma exclude_renderers ps3 xbox360 flash xboxone ps4 psp2
			#pragma fragmentoption ARB_precision_hint_fastest	
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster			
			#include "UnityCG.cginc"
			
			sampler2D _NoiseTex;			
			float4 _MainTex_ST;
			float _TimeOffs;
			float _Duration;			
			float _GlobalTime;
			float _Invert;

			struct v2f 
			{			
				V2F_SHADOW_CASTER;
				float2 uv: TEXCOORD1;
				fixed threshold: TEXCOORD2;
			};

			v2f vert( appdata_base v )
			{
				v2f o;
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.threshold = saturate((_TimeOffs + _GlobalTime) / _Duration); 	
				o.threshold = _Invert;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)				
				return o;
			}

			float4 frag( v2f i ) : COLOR
			{
				fixed noise = tex2D(_NoiseTex, i.uv * 2).r;																	
				clip(noise - i.threshold);
				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG
		}
		
	}//subshader	

	Fallback "Mobile/VertexLit"
}
