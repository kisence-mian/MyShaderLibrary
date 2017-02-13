//writed by Zsy 2016.12.15
Shader "CC/场景/湖面"
{
	Properties
	{
		_Color ("水体颜色", Color) = (1, 1, 1, 1)
		_BumpMap ("波浪法线图", 2D) = "gray" {}
		_WaveSpeed ("流速(xz横 yw竖)", Vector) = (5, 5, -5, -5)
		_WaveSize ("波浪大小", Float) = 0.5
		_ViewDir ("视角(W为0不要动)", Vector) = (0, 0, 0, 0)
		_SpecParam ("高光系数", Float) = 16
		_SpecColor ("高光颜色", Color) = (1, 1, 1, 1)
		_BlendParam ("边缘渐隐参数", Range(0.01, 2)) = 0.25
	}
	SubShader
	{
		Tags { "Queue"="Transparent" "RenderType"="Transparent+1"}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Back

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile WATER_EDGEBLEND_ON WATER_EDGEBLEND_OFF
			#pragma fragmentoption ARB_precision_hint_fastest
			
			#include "UnityCG.cginc"

			struct appdata
			{
				fixed4 vertex : POSITION;
				fixed3 norm : NORMAL;
				half2 uv : TEXCOORD;

			};

			struct v2f
			{
				half4 bump : TEXCOORD0;
				half3 h : TEXCOORD1;
				half2 uv : TEXCOORD2;
				#ifdef WATER_EDGEBLEND_ON
				fixed4 projPos : TEXCOORD3;
				#endif
				fixed4 vertex : SV_POSITION;
			};

			fixed4 _WaveSpeed;
			fixed _WaveSize;
			fixed3 _ViewDir;
			fixed _SpecParam;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);

				fixed3 worldSpaceVertex = mul(unity_ObjectToWorld,(v.vertex)).xyz;
				fixed2 waveUv = worldSpaceVertex.xz;
				o.bump = (waveUv.xyxy + _Time.xxxx * _WaveSpeed.xyzw) * _WaveSize;
				o.h = normalize (_ViewDir).xyz;
				o.uv = v.uv;

				#ifdef WATER_EDGEBLEND_ON
				o.projPos = ComputeScreenPos (o.vertex);
				//COMPUTE_EYEDEPTH(o.projPos.z);
				#endif

				return o;
			}

			fixed4 _Color;
			sampler2D _BumpMap;
			fixed3 _SpecColor;
			sampler2D _CameraDepthTexture;
			fixed _BlendParam;

			fixed4 frag (v2f i) : SV_Target
			{
				half3 bump = (UnpackNormal(tex2D(_BumpMap, i.bump.xy)) + UnpackNormal(tex2D(_BumpMap, i.bump.zw))) * 0.5;
				half3 worldNormal = fixed3(0, 1, 0) + bump.xxy * 20 * half3(1,0,1);
				worldNormal = normalize(worldNormal);
				fixed3 spec = max (0, dot (worldNormal, -i.h));
				spec = spec / (_SpecParam - (_SpecParam - 1) * spec) * _SpecColor;
//				spec = max(0, pow(spec, _SpecParam)) *_SpecColor;

				fixed3 normcol = saturate(dot(fixed3(0, 1, 1), bump));
				fixed4 col = _Color;
				col.rgb *= normcol;
				col.rgb += spec;
				col.a = (spec.x + spec.y + spec.z) * 0.2 + col.a;

				#ifdef WATER_EDGEBLEND_ON
				fixed edgeBlendFactors = 1;
				half depth = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos));
				depth = LinearEyeDepth(depth);
				edgeBlendFactors = saturate(_BlendParam * (depth - i.projPos.z));
				col.a *= edgeBlendFactors;
				#endif

				return col;
			}
			ENDCG
		}
	}
}
