/*
作者: topameng 日期: 2016-10-31
作用: BlinnPhong + Bump + Fresnel + Reflection
*/
Shader "Topameng/Reflective/Bumped Specular" 
{
	Properties 
	{		
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB) Gloss (A)", 2D) = "white" {}
		_MaskTex ("Gloss (RGB)", 2D) = "grey" {}
		_BumpMap ("Normalmap", 2D) = "bump" {}		
		_SpecStrength("Specular Strength", Range(0.1, 10)) = 1
		_Shininess ("Shininess", Range (0.03, 1)) = 0.078125
		_ReflStrength("Reflction strength", Range(0.0, 2)) = 1
		_RimColor("Rim Color", Color) = (0.03,0.03,0.03,0.03)
		_RimWidth("Rim Width", float) = 0.5
	}

	SubShader 
	{ 
		Tags { "RenderType"="Opaque" }
		LOD 250
	
		CGPROGRAM		
		#pragma exclude_renderers ps3 xbox360 flash xboxone ps4 psp2
		#pragma fragmentoption ARB_precision_hint_fastest
		#pragma skip_variants FOG_EXP FOG_EXP2 DIRLIGHTMAP_COMBINED DIRLIGHTMAP_SEPARATE
		#pragma surface surf MobileBlinnPhong exclude_path:prepass nolightmap noforwardadd halfasview

		sampler2D _MainTex;
		sampler2D _MaskTex;
		sampler2D _BumpMap;
		samplerCUBE _EnvCube;
		half _Shininess;
		half _SpecStrength;		
		half _ReflStrength;
		half4 _RimColor;
		half _RimWidth;
		fixed4 _Color;

		struct Input 
		{
			float2 uv_MainTex;
			float3 worldRefl;
			float3 viewDir;
			INTERNAL_DATA
		};

		struct _SurfaceOutput 
		{
			fixed3 Albedo;
			fixed3 Normal;
			fixed3 Emission;
			half Specular;
			fixed3 Gloss;
			fixed Alpha;
		};

		inline fixed4 LightingMobileBlinnPhong (_SurfaceOutput s, fixed3 lightDir, fixed3 viewDir, fixed atten)
		{
			fixed3 halfDir = normalize(lightDir + viewDir);	
			fixed diff = max (0, dot (s.Normal, lightDir));
			fixed nh = max (0, dot (s.Normal, halfDir));
			fixed spec = pow (nh, s.Specular * 128) * s.Gloss * _SpecStrength;
	
			fixed4 c;
			c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * (atten);			
			half rim = 1.0 - saturate(dot (normalize(viewDir), s.Normal));
          	c.rgb += _RimColor.rgb * smoothstep(1.0 - _RimWidth, 1.0, rim);
			c.a = 0.0;
			return c;
		}

		void surf (Input IN, inout _SurfaceOutput o) 
		{
			fixed4 tex = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			fixed4 spec = tex2D(_MaskTex, IN.uv_MainTex);
			o.Albedo = tex.rgb;
			o.Gloss = spec.rgb;
			o.Alpha = tex.a;
			o.Specular = _Shininess;
			o.Normal = UnpackNormal (tex2D(_BumpMap, IN.uv_MainTex));
			float3 worldRefl = WorldReflectionVector (IN, o.Normal);
			fixed4 reflcol = texCUBE (_EnvCube, worldRefl);			
			o.Emission = reflcol.rgb * spec.rgb * _ReflStrength;					
		}

		ENDCG
	}

	FallBack "Mobile/VertexLit"
}
