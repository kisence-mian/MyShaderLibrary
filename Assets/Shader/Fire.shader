Shader "MyShaderLib/Fire"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue" = "Transparent" }
		LOD 100

		GrabPass{}//昂贵的操作，执行后，可以直接使用sampler2D _GrabTexture 得到全屏截图的一个纹理

		Pass
		{
			CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members screenPos)
 			// #pragma exclude_renderers d3d11
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			// #pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			sampler2D _GrabTexture;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 screenPos: TEXCOORD1;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				o.screenPos = ComputeGrabScreenPos(o.vertex);


				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				 fixed4 col = tex2D(_MainTex, i.uv);

				i.screenPos.xy += col.r *0.01;

				fixed4 bg = tex2Dproj(_GrabTexture,i.screenPos);

				if(col.r < 0.2)
				{
					col = bg;
				}

				col.rgb = bg.rgb;

				// fixed4 col = float4(1,1,1,1);
				// apply fog
				// UNITY_APPLY_FOG(i.fogCoord, bg);
				return col;
			}
			ENDCG
		}
	}
}
