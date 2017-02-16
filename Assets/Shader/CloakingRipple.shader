//一种简易实现
Shader "MyShaderLib/CloakingRipple"
{
	Properties
	{
		// _MainTex ("Texture", 2D) = "white" {}
		_refractive("refractive",float) = 1.6
		_Scale("Scale",range(-0.1,0.1)) = 0.05
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue" = "Transparent"}
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

			sampler2D _GrabTexture;
			float _refractive;
			float _Scale;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal :NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 screenPos : TEXCOORD1;
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
				UNITY_TRANSFER_FOG(o,o.vertex);

				o.screenPos = ComputeGrabScreenPos(o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				i.screenPos.xy *= 0.99;

				fixed4 col = tex2Dproj(_GrabTexture, i.screenPos);

				return col;
			}
			ENDCG
		}
	}
}
