Shader "Custom/EnvPhong" {
	Properties
	{
		_MainTex ("Diffuse (RGBA)", 2D) = "white" {}
		_SpecTex ("Specular (RGB)", 2D) = "white" {}
		_BumpMap ("Bumpmap", 2D) 	= "bump" {}
		_DIMCube ("DIM Cubemap", CUBE) = "" {}
		_SIMCube ("SIM Cubemap", CUBE) = "" {}
	}
	
	SubShader
	{
		Tags { "RenderType"="Opaque" "LightMode"="ForwardBase" }
		//ForwardBase renders only the main light and ambient with this shader, leaving everything else to the default
		//Pass { Tags { "LightMode"="ForwardBase" } }
		LOD 200
		
		CGPROGRAM	 	
		#pragma target 3.0
		#pragma surface surfaceFunc EnvPhongModel noambient
		
		#define ENV_STRENGH 0.5
		float3 DIM;
		float3 SIM;
		float4 specularColor;
	
		half4 LightingEnvPhongModel( SurfaceOutput s, half3 lightDir, half3 viewDir, half atten )
		{
			half3 diff = max(0,dot (s.Normal, lightDir));
			diff *= atten;
			diff *= _LightColor0.rgb;
				
			half3 h = normalize( lightDir + viewDir );
	        float nh = max(0, dot(s.Normal, h));
	        half3 spec = pow(nh, 48.0);
	        spec *= atten;			
			spec *= _LightColor0.rgb;
			
			half4 c;				
			c.rgb = (diff + DIM)*s.Albedo.rgb + (spec + SIM)*specularColor;
			c.a = s.Alpha;
			return c;
		}
		
		struct Input
		{
			float2 uv_MainTex;
			float2 uv_BumpMap;
			float3 worldNormal;
			float3 worldRefl;
			INTERNAL_DATA
		}; 
		
		sampler2D _MainTex;
		sampler2D _SpecTex;		
		sampler2D _BumpMap;		
		samplerCUBE _DIMCube;
		samplerCUBE _SIMCube;
		
		void surfaceFunc( Input IN, inout SurfaceOutput OUT )
		{
			half4 alb	  = tex2D( _MainTex, IN.uv_MainTex );
			specularColor = tex2D( _SpecTex, IN.uv_MainTex );
			OUT.Albedo = alb.rgb;
			OUT.Alpha = alb.a;
			OUT.Specular = specularColor.r;
			OUT.Normal = UnpackNormal( tex2D(_BumpMap, IN.uv_BumpMap) );			
			
			DIM = texCUBE(_DIMCube, WorldNormalVector(IN,OUT.Normal) ).rgb * ENV_STRENGH;
			SIM = texCUBE(_SIMCube, WorldReflectionVector(IN, OUT.Normal) ).rgb * ENV_STRENGH;
			
			OUT.Emission = DIM*alb + SIM*specularColor;
		}
		ENDCG
	}
	FallBack "Bumped Specular"
}
