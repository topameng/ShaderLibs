Shader "Topameng/Particles/Blend" 
{
	Properties 
	{
		_MainTex ("Particle Texture", 2D) = "white" {}		
	}

	SubShader 
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		Blend DstColor One		
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
			//#pragma multi_compile_fog

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			fixed4 _TintColor;
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
				//UNITY_FOG_COORDS(1)
			};					

			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.color = v.color;
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
				//UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}				
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = i.color * tex2D(_MainTex, i.texcoord);
				//UNITY_APPLY_FOG_COLOR(i.fogCoord, col, fixed4(0,0,0,0));
				return col;
			}
			ENDCG 
		}
	}
}
