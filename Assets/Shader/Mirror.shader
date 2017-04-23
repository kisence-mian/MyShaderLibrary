Shader "MyShaderLib/Mirror"
{
	Properties
	{
		_MainTex ("Reflection", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Tags{"LightMode"="Always" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct v2f
			{
				// float2 uv : TEXCOORD0;
				// // UNITY_FOG_COORDS(1)
				// float4 vertex : SV_POSITION;

				float4 pos:SV_POSITION;
				// float4 texc:TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata_base v)
			{
				// float4x4 proj;
				// proj = mul(_projMat,_object2Wrold);

				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				// o.texc = mul(proj,v.vertex);
				// UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2Dproj(_MainTex, i.pos);
				// apply fog

				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
