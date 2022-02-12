Shader "Custom/cj_qz" {
	Properties{
		// Surface shader parameters
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
         _NoiseTex("Noise Texture", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
        _Cutoff("Alpha Cutoff", Range(0,1)) = 0.5

         _factor("factor", Range(0,2)) = 1.7
         _A("A", Range(0,1)) = 0.1
         _Freq("Frequency", Range(0,50)) = 36
         _NoiseScale("Noise Scale", Range(0,20)) = 2.5
	}
		SubShader{
		Tags { "Queue" = "Transparent"
		"RenderType" = "TransparentCutout"
		}
		LOD 200
		Cull off
		CGPROGRAM

		#pragma surface surf Standard vertex:vert alpha:Cutout
			//#pragma target 3.0
			
			sampler2D _MainTex;
             sampler2D _NoiseTex;
			struct Input {
			float2 uv_MainTex;
			};

			half _Glossiness;
			half _Metallic;
			fixed4 _Color;
            half _Cutoff;
            half _factor;
            half _NoiseScale;
            half _A;
            half _Freq;
			// our vert modification function
			void vert(inout appdata_full v)
			{
			float4 localSpaceVertex = v.vertex;
            float4 worldSpaceVertex = mul(unity_ObjectToWorld, localSpaceVertex);
            float2 xz = float2(worldSpaceVertex.x,worldSpaceVertex.z);
            float noise = tex2Dlod(_NoiseTex,float4(xz,0,0)).r*_NoiseScale;  
            localSpaceVertex.x += sin(_Time.x*_Freq+noise)*pow(abs(localSpaceVertex.y-2.0)*_A,_factor);
            v.vertex = localSpaceVertex;

			}

			void surf(Input IN, inout SurfaceOutputStandard o) {
				// Albedo comes from a texture tinted by color
				fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
				//o.Albedo = c.rgb;
				// Metallic and smoothness come from slider variables
				o.Metallic = _Metallic;
				o.Smoothness = _Glossiness;
				o.Emission = c; 
                clip (c.a - _Cutoff + 0.0001);
				o.Alpha = c.a;
				}
				ENDCG

		}
			FallBack "Diffuse"
}