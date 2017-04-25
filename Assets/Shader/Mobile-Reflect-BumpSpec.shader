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
	}

	SubShader 
	{ 
		Tags {"Queue"="Geometry" "RenderType"="Opaque"}
		LOD 250
	
		CGPROGRAM
		#pragma exclude_renderers ps3 xbox360 flash xboxone ps4 psp2
		#pragma fragmentoption ARB_precision_hint_fastest
		#pragma surface surf MobileBlinnPhong exclude_path:prepass nolightmap halfasview noforwardadd		

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

		inline fixed4 LightingMobileBlinnPhong (_SurfaceOutput s, fixed3 lightDir, fixed3 halfDir, fixed atten)
		{
			fixed diff = max (0, dot (s.Normal, lightDir));
			fixed nh = max (0, dot (s.Normal, halfDir));
			fixed spec = pow (nh, s.Specular * 128) * s.Gloss * _SpecStrength;
	
			fixed4 c;
			c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * (atten);	
			c.a = s.Alpha;		
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
			fixed4 reflcol = texCUBE (_EnvCube, IN.worldRefl);			
			o.Emission = reflcol.rgb * spec.rgb * _ReflStrength;					
		}

		ENDCG
	}

	FallBack "Topameng/Diffuse"
}
