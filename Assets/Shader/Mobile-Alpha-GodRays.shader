Shader "Topameng/Transparent/GodRays" 
{
	Properties 
	{
		_MainTex ("Base texture", 2D) = "white" {}
		_FadeOutDistNear ("Near fadeout dist", float) = 10	
		_FadeOutDistFar ("Far fadeout dist", float) = 10000	
		_Multiplier("Multiplier", float) = 1
		_ContractionAmount("Near contraction amount", float) = 5
	}
	
	SubShader 
	{	
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
	
		Blend One One		
		Cull Off 
		Lighting Off 
		ZWrite Off 			
		LOD 100

		Pass 
		{
			CGPROGRAM
			#pragma exclude_renderers ps3 xbox360 flash xboxone ps4 psp2
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment frag		

			#include "UnityCG.cginc"
			#include "Globals.cginc"			
			
			sampler2D _MainTex;
			float _FadeOutDistNear;
			float _FadeOutDistFar;
			float _Multiplier;
			float _ContractionAmount;
	
	
			struct v2f 
			{
				float4	pos		: SV_POSITION;
				float2	uv		: TEXCOORD0;
				fixed4	color	: TEXCOORD1;
			};

			v2f vert (appdata_color v)
			{
				v2f o;
				float3 viewPos	= mul(UNITY_MATRIX_MV, v.vertex);
				float dist		= length(viewPos);
				float nfadeout	= CalcFadeOutFactor(dist, _FadeOutDistNear, _FadeOutDistFar);		
				float4 vpos = v.vertex;		
				vpos.xyz -=   v.normal * saturate(1 - nfadeout) * v.color.a * _ContractionAmount;
						
				o.uv 	= v.texcoord.xy;
				o.pos	= mul(UNITY_MATRIX_MVP, vpos);
				o.color	= nfadeout * v.color * _Multiplier;
						
				return o;
			}	

			fixed4 frag (v2f i) : COLOR
			{			
				return tex2D (_MainTex, i.uv.xy) * i.color;
			}

			ENDCG 
		}	
	}
}

