Shader "Custom/MarmoPhong"
{
	Properties
	{
		_DiffClr ("Diffuse Color", Color) = (1,1,1,1)
		_SpecClr ("Specular Color", Color) = (1,1,1,1)
		_SpecInt ("Specular Intensity", Float) = 2.0
		_SpecExp ("Specular Sharpness", Float) = 40.0
		_FresnelExp ("Fresnel Exponent", Float) = 0.0
		_MainTex ("Diffuse (RGBA)", 2D) = "white" {}
		_SpecTex ("Specular (RGB)", 2D) = "white" {}
		_BumpMap ("Normalmap", 2D) 	= "bump" {}
		_DIMCube ("DIM Cubemap", CUBE) = "" {}
		_SIMCube ("SIM Cubemap", CUBE) = "" {}
	}
	
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM

		// seems to be required for mac
		#pragma glsl

		#pragma only_renderers d3d9 gles opengl
		#pragma target 3.0
		#pragma surface surfaceFunc MarmosetPhong addshadow
		#define ENV_STRENGTH 0.5
		
		sampler2D _MainTex;
		sampler2D _SpecTex;
		sampler2D _BumpMap;
		samplerCUBE _DIMCube;
		samplerCUBE _SIMCube;
		float4		_DiffClr;
		float4		_SpecClr;
		float		_SpecInt;
		float		_SpecExp;
		float		_FresnelExp;
		
		half3 OUT_specularRGB;
		
		float computeFresnel( float3 N, float3 E, float fresnelExp )
		{
			float factor = pow(1-clamp(dot(N,E),0,1),fresnelExp);
			return 0.1 + 0.9 * factor;	//matches marmoset
		}

		half4 LightingMarmosetPhong( SurfaceOutput s, half3 lightDir, half3 viewDir, half atten )
		{
			half3 diff = max(0,dot (s.Normal, lightDir));
			diff *= atten;
			diff *= _LightColor0.rgb;
			
			float3 E = normalize(viewDir);
			float3 L = normalize(lightDir);
			float3 N = normalize(s.Normal);
			
	        float3 R = reflect(-E,N);
	        float specRefl = clamp(dot(L,R),0,1);
	        half3 spec = pow(specRefl, s.Gloss);
	        
	        //half-angle equation
			//R = normalize(L+E);
	        //specRefl = clamp(dot(N,R),0,1);
	        //half3 spec = pow(specRefl, 4*s.Gloss);
	        //end temp
	        
	        //0.5*(gloss-1.0) divides out the integral of the lighting function and matches marmoset
	        spec *= 0.5*(s.Gloss+1.0);
	        spec *= atten;
			spec *= computeFresnel(N,E,_FresnelExp);
			spec *= _LightColor0.rgb;
			
			half4 frag;
			frag.rgb = diff*s.Albedo.rgb + spec*OUT_specularRGB;
			frag.a = s.Alpha;
			return frag;
		}

		struct Input
		{
			float2 uv_MainTex;
			float2 uv_SpecTex;
			float2 uv_BumpMap;
			float3 worldNormal;
			float3 worldRefl;
			float3 viewDir;
			INTERNAL_DATA
		};

		void surfaceFunc( Input IN, inout SurfaceOutput OUT )
		{
			half4 alb  = tex2D( _MainTex, IN.uv_MainTex );
			alb.rgb *= _DiffClr.rgb;
			OUT.Albedo = alb.rgb;
			OUT.Alpha = alb.a;
			
			half4 spec = tex2D( _SpecTex, IN.uv_SpecTex );
			OUT_specularRGB = spec.rgb * _SpecClr.rgb * _SpecInt;
			OUT.Specular = 0.3333*(OUT_specularRGB.r + OUT_specularRGB.g + OUT_specularRGB.b);
			OUT.Gloss = spec.a * max(1.0,_SpecExp);
			
			OUT.Normal = normalize( UnpackNormal( tex2D(_BumpMap, IN.uv_BumpMap) ) );			
			float3 E = normalize(IN.viewDir);
			float fresnel = computeFresnel(OUT.Normal,E,_FresnelExp);
						
			const float envStrength = 1.0;
			half3 DIM = texCUBE( _DIMCube, WorldNormalVector(IN,OUT.Normal) ).rgb * envStrength;
			
			float lod = 8.0*(1.1-clamp(_SpecExp/256.0,0.0,1.0));//1.0 - log2(clamp(_SpecExp,0.0,256.0));
			half4 lookup = half4( WorldReflectionVector(IN, OUT.Normal), lod );
			half3 SIM = texCUBElod( _SIMCube, lookup ).rgb * envStrength;
			//half3 SIM = texCUBE( _SIMCube, WorldReflectionVector(IN, OUT.Normal) ).rgb * envStrength;
			OUT.Emission = DIM*alb + SIM*OUT_specularRGB*fresnel;
		}
		ENDCG
	}
	FallBack "Bumped Specular"
}
