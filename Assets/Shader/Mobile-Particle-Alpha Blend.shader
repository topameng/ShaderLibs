Shader "Topameng/Particles/Alpha Blended" 
{
	Properties 
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
 		_MainTex ("Particle Texture", 2D) = "white" { }
	}

	SubShader 
	{ 
 		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
 		LOD 200

 		Pass 
 		{  
 			ZWrite Off
 			Cull Off
 			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma exclude_renderers ps3 xbox360 flash xboxone ps4 psp2
			#pragma fragmentoption ARB_precision_hint_fastest	
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"			

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _TintColor;
			
			struct appdata 
			{
  				float4 vertex : POSITION;
  				half4 color : COLOR;
  				float2 texcoord : TEXCOORD0;
			};

			struct v2f 
			{
				fixed4 color : COLOR0;
				float2 uv : TEXCOORD0;
				float4 pos : SV_POSITION;
			};

			v2f vert (appdata v) 
			{
				v2f o;				
  				o.color = v.color;
  				o.uv =  TRANSFORM_TEX(v.texcoord, _MainTex);
  				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
  				return o;
			}	

			fixed4 frag (v2f IN) : SV_Target 
			{				
				fixed4 tex = 2 * _TintColor * tex2D(_MainTex, IN.uv.xy) * IN.color;
				return tex;				
			}
			ENDCG
	 	}
	}
}

