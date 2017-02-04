/*
	折射率
	真空/空气 : 1.0/1.0003
	水        : 1.333
	玻璃      : 1.5 - 1.7
	钻石      : 2.417
	冰        : 1.309
*/
Shader "MyShaderLib/MagnifyingLens"
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
				float2 offset : TEXCOORD2;
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

				float offset_x = dot( UNITY_MATRIX_IT_MV[0].xyz,v.normal);
				float offset_y = dot( UNITY_MATRIX_IT_MV[1].xyz,v.normal);

				o.offset.x =  -asin(sin(offset_x ) );
				o.offset.y =   asin(sin(offset_y ) ) * (_ScreenParams.x/_ScreenParams.y);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{

				 // i.screenPos.xy *= 0.99;

				i.screenPos.xy += i.offset * _Scale;

				// sample the texture
				fixed4 col = tex2Dproj(_GrabTexture, i.screenPos);

				// if(i.screenPos.y > 0.5)
				// {
				// 	col = float4(0,0,0,0);
				// 	col.rg = i.screenPos.xy;
				// }
				// apply fog
				// UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
