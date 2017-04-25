Shader "Topameng/Particles/Alpha Blended Premultiply" 
{
	Properties 
	{
		_MainTex ("Particle Texture", 2D) = "white" {}	
	}

	SubShader 
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }

		Blend One OneMinusSrcAlpha 		
		Cull Off 
		Lighting Off 
		ZWrite Off

		Pass 
		{		
			CGPROGRAM
			#pragma exclude_renderers ps3 xbox360 flash xboxone ps4 psp2
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment frag			
			#include "UnityCG.cginc"

			sampler2D _MainTex;	
			float4 _MainTex_ST;		
			
			struct appdata_t 
			{
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f 
			{
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};					

			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.color = v.color;
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			}					
			
			fixed4 frag (v2f i) : SV_Target
			{
				return i.color * tex2D(_MainTex, i.texcoord) * i.color.a;
			}
			ENDCG 
		}
	}
}
