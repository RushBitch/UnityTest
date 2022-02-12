Shader "Custom/shuimian"
{
    Properties
    {
        _MainColor("Main Color", Color) = (1.0,1.0,1.0,1.0)
        _NoiseTilling("NoiseTilling", Vector) = (18.0,15.0,0.0,0.0)
        _Speed("Speed",Vector) = (58,0,0,0)
	    _CellSpeed("Cell Speed", Range(0,50)) = 30
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

           
            float4 _MainColor;
            float4 _NoiseTilling;
            float4 _Speed;
            float _CellSpeed;
            float _Power1;
            float _Power2;

            inline float2 unity_voronoi_noise_randomVector (float2 UV, float offset)
            {
                float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
                UV = frac(sin(mul(UV, m)) * 46839.32);
                return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
            }

            void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
            {
                float2 g = floor(UV * CellDensity);
                float2 f = frac(UV * CellDensity);
                float t = 8.0;
                float3 res = float3(8.0, 0.0, 0.0);

                for(int y=-1; y<=1; y++)
                {
                    for(int x=-1; x<=1; x++)
                    {
                        float2 lattice = float2(x,y);
                        float2 offset = unity_voronoi_noise_randomVector(lattice + g, AngleOffset);
                        float d = distance(lattice + offset, f);
                        if(d < res.x)
                        {
                            res = float3(d, offset.x, offset.y);
                            Out = res.x;
                            Cells = res.y;
                        }
                    }
                }
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = _MainColor;
                float2 offset = _Time.x*_Speed;
                float2 uv = i.uv * _NoiseTilling + offset;

                float angleOffset = _CellSpeed * _Time.x;
                float cellDensity = 1.1;

                float voronoiOut =  0.0;
                float cells = 0.0;
                Unity_Voronoi_float(uv,angleOffset,cellDensity,voronoiOut,cells);

                float a = pow(voronoiOut,6.0);
                float b = smoothstep(0, 3.5, a);

                col += b*float4(1.0,1.0,1.0,1.0);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
