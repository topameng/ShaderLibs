Shader "Topameng/Particles/Multiply"
{
	Properties 
	{
		_MainTex ("Particle Texture", 2D) = "white" { }
	}

	SubShader 
	{ 
		Tags { "Queue"="Transparent" "IgnoreProjector"="true" "RenderType"="Transparent" }

		Pass 
		{  
			ZWrite Off
			Cull Off
			Blend Zero SrcColor

			CGPROGRAM
			#pragma exclude_renderers ps3 xbox360 flash xboxone ps4 psp2
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment frag
			//#pragma multi_compile_fog
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;

			struct appdata 
			{
  				float4 pos : POSITION;
  				half4 color : COLOR;
  				float3 uv : TEXCOORD0;
			};

			struct v2f 
			{
				float4 pos : SV_POSITION;
				fixed4 color : COLOR0;
				float2 uv : TEXCOORD0;						      				
			};

			v2f vert(appdata v) 
			{
				v2f o;  	
				UNITY_INITIALIZE_OUTPUT(v2f, o);
  				o.color = saturate(v.color);  
  				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
  				o.pos = mul(UNITY_MATRIX_MVP, v.pos);
  				return o;
			}

			fixed4 frag(v2f IN) : SV_Target 
			{
				fixed4 col = tex2D (_MainTex, IN.uv) * IN.color;				
				col = lerp(fixed4(1,1,1,1), col, col.a);
				return col;
			}
			ENDCG
 		}
	}
}