
Shader "Topameng/Transparent/Blinking GodRays" 
{
	Properties 
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex ("Base texture", 2D) = "white" {}
		_FadeOutDistNear ("Near fadeout dist", float) = 10	
		_FadeOutDistFar ("Far fadeout dist", float) = 10000	
		_Multiplier("Color multiplier", float) = 1
		_Bias("Bias",float) = 0
		_TimeOnDuration("ON duration",float) = 0.5
		_TimeOffDuration("OFF duration",float) = 0.5
		_BlinkingTimeOffsScale("Blinking time offset scale (seconds)",float) = 5
		_SizeGrowStartDist("Size grow start dist",float) = 5
		_SizeGrowEndDist("Size grow end dist",float) = 50
		_MaxGrowSize("Max grow size",float) = 2.5
		_NoiseAmount("Noise amount (when zero, pulse wave is used)", Range(0,0.5)) = 0		
	}

	
	SubShader 
	{	
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		LOD 100
	
		Blend One One
		//Blend One OneMinusSrcColor
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
			#include "Globals.cginc"
			sampler2D _MainTex;
		
			float _FadeOutDistNear;
			float _FadeOutDistFar;
			float _Multiplier;
			float _Bias;
			float _TimeOnDuration;
			float _TimeOffDuration;
			float _BlinkingTimeOffsScale;
			float _SizeGrowStartDist;
			float _SizeGrowEndDist;
			float _MaxGrowSize;
			float _NoiseAmount;
			float4 _Color;		
		
			struct v2f 
			{
				float4	pos	: SV_POSITION;
				float2	uv		: TEXCOORD0;
				fixed4	color	: TEXCOORD1;
			};
		
			v2f vert (appdata_color v)
			{
				v2f 		o;
			
				float	time		= _Time.y + _BlinkingTimeOffsScale * v.color.b;		
				float3	viewPos		= mul(UNITY_MATRIX_MV,v.vertex);
				float	dist		= length(viewPos);
				float	nfadeout	= CalcFadeOutFactor(dist, _FadeOutDistNear, _FadeOutDistFar);			
				float	fracTime	= fmod(time,_TimeOnDuration + _TimeOffDuration);
				float	wave		= smoothstep(0,_TimeOnDuration * 0.25,fracTime)  * (1 - smoothstep(_TimeOnDuration * 0.75,_TimeOnDuration,fracTime));
				float	noiseTime	= time *  (6.2831853f / _TimeOnDuration);
				float	noise		= sin(noiseTime) * (0.5f * cos(noiseTime * 0.6366f + 56.7272f) + 0.5f);
				float	noiseWave	= _NoiseAmount * noise + (1 - _NoiseAmount);
				float	distScale	= min(max(dist - _SizeGrowStartDist,0) / _SizeGrowEndDist,1);
						
				wave = _NoiseAmount < 0.01f ? wave : noiseWave;		
				distScale = distScale * distScale * _MaxGrowSize * v.color.a;		
				wave += _Bias;		

				float4	mdlPos = v.vertex;		
				mdlPos.xyz += distScale * v.normal;
					
				o.uv	= v.texcoord.xy;
				o.pos	= mul(UNITY_MATRIX_MVP, mdlPos);
				o.color	= nfadeout * _Color * _Multiplier * wave;
							
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{		
				return tex2D (_MainTex, i.uv.xy) * i.color;
			}

			ENDCG 
		}	
	}
}

