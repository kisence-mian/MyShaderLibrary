Shader "MyShaderLib/Water2"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue" = "Transparent" }//
		LOD 100

		GrabPass{}

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
				float4 proj : TEXCOORD1;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				
			};

			sampler2D _GrabTexture;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.proj = ComputeGrabScreenPos(v.vertex);

				// UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col1 = tex2D(_MainTex, i.uv +  float2(1,0) *_Time.x);
				half4 col2 = tex2D(_MainTex, i.uv +  float2(0,2) *_Time.x);
				half4 col = lerp(col1,col2,0.5);

				float3 N = normalize(UnpackNormal(col));
				float offset_xy = dot(N,float3(0,1,0));

				// i.screenPos += offset_xy;

				half4 a = tex2D(_GrabTexture,i.proj);
				fixed4 finalColor = col;

				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, finalColor);
				return finalColor;
			}
			ENDCG
		}
	}
}
