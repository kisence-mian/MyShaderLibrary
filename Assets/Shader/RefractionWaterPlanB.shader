//利用导数计算水面折射
Shader "MyShaderLib/RefractionWaterDiff"
{
	Properties
	{
		// _MainTex ("Texture", 2D) = "white" {}
		_L("L",float) = 1.61
		_S("S",float) = 21
		_A("A",float) = 0.14
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue" = "Transparent" }
		LOD 100

		GrabPass{} //昂贵的操作，执行后，可以直接使用sampler2D _GrabTexture 得到全屏截图的一个纹理

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			sampler2D _GrabTexture;
			float _L;
			float _S;
			float _A;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 proj:TEXCOORD1;
				float4 vertex : SV_POSITION;

				float3 N : NORMAL;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				float w = 2 * 3.14159/_L;
				float f = _S * w;

				v.vertex.y += _A * sin( -length( v.vertex.xz) * w + _Time.x * f );

				//x分量偏导数
				float dx = _A * v.vertex.x * w * cos(-length(v.vertex.xz) * w + _Time.x * f);
				//z分量偏导数
				float dz = _A * v.vertex.z * w * cos(-length(v.vertex.xz) * w + _Time.x * f);

				float3 B = normalize(float3(1,dx,0));
				float3 T = normalize(float3(0,dz,1));

				v2f o;

				o.N = cross(B,T);

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.proj = ComputeGrabScreenPos(o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float d = dot(i.N,float3(0,1,0));
				i.proj.xy += d *0.3;

				fixed4 col = tex2Dproj(_GrabTexture, i.proj) ;//* 0.5;
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
