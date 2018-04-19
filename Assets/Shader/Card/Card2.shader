Shader "MyShaderLib/Card2"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Mask ("Mask", 2D) = "white" {}

		_Light("Light",2D)  = "white" {}
		_LightSpeed("Light",Range(0,100)) = 0

		_Noise ("Noise", 2D) = "white" {}
		_NoiseIntensity("NoiseIntensity",Float) = 1
		_NoiseSpeed("NoiseSpeed",Float) = 1

		_RoTex ("RoTex", 2D) = "white" {}
		_RotateSpeed("RotateSpeed",Float) = 1

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
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _Mask;
			sampler2D _Light;
			float _LightSpeed;

			sampler2D _Noise;
			float4 _Noise_ST;
			float _NoiseIntensity;
			float _NoiseSpeed;

			sampler2D _RoTex;
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
				fixed4 Mask = tex2D(_Mask,i.uv);
				float2 noisetimer = float2(_Time.x,_Time.x);

				//扰动
				float2 noise = sampleFromNoise(i.uv + noisetimer * _NoiseSpeed);

				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv + noise * _NoiseIntensity * Mask.g);

				//流光
				float2 timer = float2(0,_Time.x);
				float2 uv =  i.uv;
				uv.y = uv.y/2;

				//旋转
				fixed2 pivot = fixed2(0.5,0.5);
				float degrees = -_Time.x * _RotateSpeed;
				fixed cs = cos(degrees);
				fixed sn = sin(degrees);
				fixed2 RUV = mul(float2x2(cs,-sn,sn,cs),i.uv - pivot) + pivot;

				fixed4 Rcol = tex2D(_RoTex, RUV);
				col = col + (Rcol * 0.5 ) * ( Mask.b);


				fixed4 lightCol = tex2D(_Light, uv  + timer * _LightSpeed);
				col = col + col * (lightCol.b/2) * Mask.r;

				return col;
			}
			ENDCG
		}
	}
}
