Shader "Topameng/Transparent/AnimWater" 
{
	Properties 
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_NumTexTiles("Num tex tiles",	Vector) = (4,4,0,0)
		_ReplaySpeed("Replay speed - FPS",float) = 4	
	}

	SubShader 
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }

		Blend SrcAlpha OneMinusSrcAlpha
		//Blend One One
		Cull Off 
		Lighting Off
		ZWrite Off 		

		CGINCLUDE
		ENDCG


		Pass 
		{
			CGPROGRAM
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment frag		
			#pragma multi_compile_fog

			#include "UnityCG.cginc"
			#include "Globals.cginc"
			sampler2D _MainTex;
		
			float4	_Color;
			float4	_NumTexTiles;
			float	_ReplaySpeed;
			float 	_Randomize;
		
			struct v2f 
			{
				float4 pos : SV_POSITION;						
				fixed4 col: COLOR;
				float4 uv : TEXCOORD0;			
				UNITY_FOG_COORDS(2)
			};
		
			v2f vert (appdata_color v)
			{
				v2f o;
			
				float	time 	= (v.color.a * 60 + _Time.y) * _ReplaySpeed;
				float	itime	= floor(time);
				float	ntime	= itime + 1;
				float	ftime	= time - itime;
				
				float2	texTileSize = 1.f / _NumTexTiles.xy;		
				float4	tile;
				
				tile.xy = float2(itime, floor(itime /_NumTexTiles.x));
				tile.zw = float2(ntime, floor(ntime /_NumTexTiles.x));		
				tile = fmod(tile, _NumTexTiles.xyxy);
				
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv	= (v.texcoord.xyxy + tile) * texTileSize.xyxy;
				o.col	= fixed4(_Color.xyz * v.color.xyz, ftime);			
						
				UNITY_TRANSFER_FOG(o, o.pos); 
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 c = lerp(tex2D(_MainTex, i.uv.xy), tex2D (_MainTex, i.uv.zw), i.col.a) * i.col;	
				c.a = i.col.r;					
				UNITY_APPLY_FOG(i.fogCoord, c);
				return c;
			}
			ENDCG 
		}	
	}
}