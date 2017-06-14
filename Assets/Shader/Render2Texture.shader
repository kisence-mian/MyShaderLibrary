Shader "MyShaderLib/Render2Texture"
{
	Properties
	{

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
				float2 depth:TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				// o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.depth = o.vertex.zw;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float d = i.depth.x / i.depth.y; //介于0到1之间

				// sample the texture
				fixed4 col = EncodeFloatRGBA(d);

				return col;
			}
			ENDCG
		}
	}
}
