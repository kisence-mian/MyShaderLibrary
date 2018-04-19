Shader "MyShaderLib/Card"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Noise ("Noise", 2D) = "white" {}
		_Mask ("Mask", 2D) = "white" {}
		_Mask2 ("Mask2", 2D) = "white" {}

		_NoiseIntensity("NoiseIntensity",Float) = 1
		_speed("speed",Float) = 1

		_EffectTex1 ("_EffectTex1", 2D) = "white" {}
		_RotateSpeed("RotateSpeed",Float) = 1

		_ScrollTex1 ("_EffectTex1", 2D) = "white" {}
		_ScrollSpeed("RotateSpeed",Float) = 1
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

			sampler2D _MainTex;
			sampler2D _Noise;
			sampler2D _Mask;
			sampler2D _Mask2;

			float4 _MainTex_ST;
			float4 _Noise_ST;
			float _speed;
			float _NoiseIntensity;

			sampler2D _EffectTex1;
			float _RotateSpeed;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			fixed2 sampleFromNoise(float2 uv)
			{
				float2 newUV = uv * _Noise_ST.xy + _Noise_ST.zw;
				fixed4 NoiseColor = tex2D(_Noise,newUV);
				NoiseColor = (NoiseColor * 2 - 1) * 0.01;

				return NoiseColor;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{

				//扰动
				fixed4 mask = tex2D(_Mask,i.uv.xy);
				fixed4 mask2 = tex2D(_Mask2,i.uv.xy);
				float2 timer = float2(_Time.x,_Time.x);
				float2 noiseOffset = fixed2(0,0.5);

				noiseOffset = sampleFromNoise(i.uv.xy + timer * _speed );

				float2 newUV = i.uv + noiseOffset * mask.r * _NoiseIntensity;
				// sample the texture
				fixed4 col = tex2D(_MainTex, newUV);


				//旋转
				fixed2 pivot = fixed2(0.5,0.5);
				float degrees = _Time.x * _RotateSpeed;
				fixed cs = cos(degrees);
				fixed sn = sin(degrees);
				fixed2 RUV = mul(float2x2(cs,-sn,sn,cs),i.uv - pivot) + pivot;

				fixed4 Rcol = tex2D(_EffectTex1, RUV);
				col = col + (Rcol * 0.3 ) * ( mask2.r);

				//滚动


				return col;
			}

			ENDCG
		}
	}
}
