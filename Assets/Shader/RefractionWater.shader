Shader "MyShaderLib/RefractionWater"
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
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				float w = 2 * 3.14159/_L;
				float f = _S * w;

				v.vertex.y += _A * sin( -length( v.vertex.xz) * w + _Time.x * f );

				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.proj = ComputeGrabScreenPos(o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//Plan A 纯粹使用纹理采样形成的波纹效果
				i.proj.xy += sin(_Time.y + i.proj.xy *3.14) * 0.1;

				fixed4 col = tex2Dproj(_GrabTexture, i.proj) ;//* 0.5;
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
