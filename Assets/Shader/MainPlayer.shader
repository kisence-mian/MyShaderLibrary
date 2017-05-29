// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//writed by Zsy 2016.12.15
Shader "CC/模型/主角(Diffuse)"
{
	Properties
	{
		//Pass 1
		_MaskColor ("MaskColor", Color) = (1, 1, 1, 1)

		//Pass 2
		_SelfIllumin ("IlluminColor", Color) = (0, 0, 0, 0)
		_MainTex ("Texture", 2D) = "white" {}
//		_HalfLambert ("HalfLambert", Range(0 , 1)) = 0
		_Specular ("SpecTexture", 2D) = "white" {}
		_SpecColor ("SpecColor", Color) = (0, 0, 0, 0)
		_Shining ("Shining", Float) = 32
		_SpecStr ("SpecStr", Range(0, 20)) = 1
		_Offset ("Offset", Vector) = (0, 0, 0, 0)
	}
	SubShader
	{
		LOD 400
		Tags { "RenderType"="Transparent" "Queue"="AlphaTest+1"}
		Pass
		{
			Name "MASK"
			ZTest Greater
			Zwrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			
			#include "UnityCG.cginc"

			struct appdata
			{
				fixed4 vertex : POSITION;
				half2 uv : TEXCOORD0;
				fixed3 normal : NORMAL;
			};

			struct v2f
			{
				half2 uv : TEXCOORD0;
				fixed mask : TEXCOORD1;
				fixed4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				fixed3 normal = normalize(v.normal);
				fixed3 viewdir = normalize(ObjSpaceViewDir(v.vertex));

				o.mask = 1 - saturate(dot(normal, viewdir));
				return o;
			}

			fixed4 _MaskColor;

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = _MaskColor * i.mask;
				return col;
			}
			ENDCG
		}
		Pass
		{
			Tags { "RenderType"="Opaque" "Queue"="Geometry" }
			Name "MAINPLAYER_D"

			CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f_mainplayer members vertex,normdir,viewdir,uv)
#pragma exclude_renderers d3d11
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"
			// #include "CCInclude.cginc"

			fixed4 _SelfIllumin;
			sampler2D _Specular;
			fixed3 _SpecColor;
			fixed _Shining;
			fixed _SpecStr;
			fixed3 _Offset;
//			fixed _HalfLambert;

			struct v2f_mainplayer
			{
				float4 vertex;
				float4 normdir;
				float4 viewdir
				float4 uv;
			}

			v2f_mainplayer vert (appdata_base v)
			{
				v2f_mainplayer o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				o.normdir = v.normal;
				o.viewdir = v.vertex;
//				o.col = DiffuseLight(v.normal, _HalfLambert, WorldSpaceLightDir(v.vertex));
				return o;
			}

			fixed4 frag (v2f_mainplayer i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv) + _SelfIllumin;
//				col.rgb *= i.col;
				if(_SpecColor.r > 0) {
					fixed3 speccol = tex2D(_Specular, i.uv);
					fixed3 viewdir = normalize(WorldSpaceViewDir(i.viewdir) + _Offset);
					fixed3 normdir = normalize(UnityObjectToWorldNormal(i.normdir));
					col.rgb += SpecLight(normdir, viewdir, _Shining) * _SpecStr * speccol * _SpecColor;
				}
				return col;
			}

			ENDCG
		}
	}

	SubShader
	{
		LOD 300
		Tags { "RenderType"="Transparent" "Queue"="AlphaTest+1"}
		Pass
		{
			ZTest Greater
			Zwrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			
			#include "UnityCG.cginc"

			struct appdata
			{
				fixed4 vertex : POSITION;
				half2 uv : TEXCOORD0;
				fixed3 normal : NORMAL;
			};

			struct v2f
			{
				half2 uv : TEXCOORD0;
				fixed mask : TEXCOORD1;
				fixed4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				fixed3 normal = normalize(v.normal);
				fixed3 viewdir = normalize(ObjSpaceViewDir(v.vertex));

				o.mask = 1 - saturate(dot(normal, viewdir));
				return o;
			}

			fixed4 _MaskColor;

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = _MaskColor * i.mask;
				return col;
			}
			ENDCG
		}
		Pass
		{
			Tags { "RenderType"="Opaque" "Queue"="Geometry" }
			Name "MAINPLAYER_D_LOW"

			CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f_mainplayer members vertex,normdir,viewdir,uv)
#pragma exclude_renderers d3d11
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"
			// #include "CCInclude.cginc"

			fixed4 _SelfIllumin;
			sampler2D _Specular;
			fixed3 _SpecColor;
			fixed _Shining;
			fixed _SpecStr;
			fixed3 _Offset;
//			fixed _HalfLambert;

			struct v2f_mainplayer
			{
				float4 vertex;
				float4 normdir;
				float4 viewdir
				float4 uv;
			}

			v2f_mainplayer vert (appdata_base v)
			{
				v2f_mainplayer o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				o.normdir = UnityObjectToWorldNormal(v.normal);
				o.viewdir.xyz = WorldSpaceViewDir(v.vertex) + _Offset;
				o.viewdir.w = 0;
//				o.col = fixed3(1, 1, 1);
				return o;
			}

			fixed4 frag (v2f_mainplayer i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv) + _SelfIllumin;
//				col.rgb *= i.col;
				if(_SpecColor.r > 0) {
					fixed3 speccol = tex2D(_Specular, i.uv);
					fixed3 viewdir = i.viewdir;
					fixed3 normdir = i.normdir;
					col.rgb += SpecLight(normdir, viewdir, _Shining) * _SpecStr * speccol * _SpecColor;
				}
				return col;
			}

			ENDCG
		}
	}

	SubShader
	{
		LOD 0
		Pass
		{
			Tags { "RenderType"="Opaque" "Queue"="Geometry" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"

			struct v2f
			{
				half2 uv : TEXCOORD;
				fixed4 vertex : SV_POSITION;
			};

			v2f vert(appdata_base v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				return o;
			}

			sampler2D _MainTex;

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}

			ENDCG
		}
	}
}
