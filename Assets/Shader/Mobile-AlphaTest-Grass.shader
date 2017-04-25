Shader "Topameng/Transparent/Cutout/Grass" 
{
	Properties 
	{		
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB) Gloss (A)", 2D) = "white" {}
		_Wind("Wind params",Vector) = (1,1,1,1)
		_WindEdgeFlutter("Wind edge fultter factor", float) = 0.5
		_WindEdgeFlutterFreqScale("Wind edge fultter freq scale",float) = 0.5
		_Cutoff ("Base Alpha cutoff", Range (0.01,.99)) = 0.01
	}

	SubShader 
	{
		Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout" "DisableBatching"="True"}
		LOD 200			
		Cull Off 		

		Pass 
		{
			Name "FORWARD"
			Tags { "LightMode" = "ForwardBase" }
			CGPROGRAM		
			#define ALPHA_CUTOFF 1 					
			#pragma exclude_renderers ps3 xbox360 flash xboxone ps4 psp2
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma skip_variants FOG_EXP FOG_EXP2 DIRLIGHTMAP_COMBINED DIRLIGHTMAP_SEPARATE
			#pragma multi_compile_fog
			#pragma multi_compile_fwdbase
			#include "Mobile-Grass.cginc"						
			#pragma vertex vert
			#pragma fragment frag						
			ENDCG 
		}

		Pass 
		{
			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }
		
			Fog {Mode Off}
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
			#include "Globals.cginc"
							
			sampler2D _MainTex;
			float4 _MainTex_ST;	
			float _Cutoff; 
			float _WindEdgeFlutter;
			float _WindEdgeFlutterFreqScale;
			float4 _Wind;

			struct v2f 
			{			
				V2F_SHADOW_CASTER;
				float2 uv: TEXCOORD1;				
			};			

			v2f vert( appdata_base v )
			{
				v2f o;					
				float4 wind;					

				wind.xyz = mul((float3x3)unity_WorldToObject,_Wind.xyz);
				wind.w	 = _Wind.w  * v.texcoord.y;
				
				float4	windParams = float4(0,_WindEdgeFlutter, v.texcoord.yy);
				float2 time = _Time.yy * float2(_WindEdgeFlutterFreqScale,1);
				float4	mdlPos = AnimateGrassVertex(v.vertex, v.normal, windParams, wind, time);
						
				o.pos = UnityClipSpaceShadowCasterPos(mdlPos.xyz, v.normal);
				o.pos = UnityApplyLinearShadowBias(o.pos);
				
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);				
				return o;
			}

			float4 frag(v2f i) : COLOR
			{
				fixed4 tex = tex2D( _MainTex, i.uv );															
				clip(tex.a - _Cutoff);
				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG
		}			
	}	

	//Fallback "Transparent/Cutout/VertexLit"	
}


