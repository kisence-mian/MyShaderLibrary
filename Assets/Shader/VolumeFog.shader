Shader "MyShaderLib/VolumeFog"
{
	Properties
	{
		_fogColor("FOG Color",Color) = (1,1,1,1)

		kc("Facter to center",range(0,100)) = 1
		kf("Factor of Fog",range(0,30)) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry+600"}
		LOD 100

		Pass
		{
			Tags{"LightMode" = "ForwardBase"}
			Blend one OneMinusSrcAlpha      
			Zwrite off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct v2f
			{
				float4 pos : POSITION;
				float4 scr : TEXCOORD1;
				float4 cen : TEXCOORD2;
				float4 vp  : TEXCOORD3;
				float4 rim : TEXCOORD4;
				// UNITY_FOG_COORDS(1)
			};

			float kf;
			float kc;
			fixed4 _fogColor;
			
			v2f vert (appdata_full v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				o.scr = o.pos;
				o.cen = mul(UNITY_MATRIX_MVP,float4(0,0,0,1));
				o.vp = mul(UNITY_MATRIX_MVP,v.vertex);

				float3 viewDir = ObjSpaceViewDir(v.vertex);
				viewDir = normalize(viewDir);
				o.rim = max(0,dot(viewDir,v.normal));

				UNITY_TRANSFER_DEPTH(o.depth);
				return o;
			}

			sampler2D _CameraDepthTexture; //声明这个变量似乎会自动获得深度缓冲区域
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 cen = i.cen.xyz/i.cen.w;
				float3 vp = i.vp.xyz/i.vp.w;

				cen = vp - cen;
				float dc = 1 - length(cen);
				dc = pow(dc,6);
				dc = dc * kc;

				float4 scr = ComputeScreenPos(i.scr);
				scr.xy /= scr.w;

				float hd = scr.z/scr.w;
				// hd = Linear01Depth(hd);

				float d = tex2D(_CameraDepthTexture,scr.xy);

				float dif = d - hd; //dif 是高度差
				dif = d * kf;
				dc = dc /(1 + dc);
				dif =  dc * i.rim;

				float4 c = _fogColor;

				c = lerp(0,c, dif);
				return c;
			}
			ENDCG
		}
	}
}
