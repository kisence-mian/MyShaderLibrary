Shader "Toon/Basic" {
	Properties {
		_Color ("Main Color", Color) = (.5,.5,.5,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_ToonShade ("ToonShader Cubemap(RGB)", CUBE) = "" { }  //一个产生卡通颜色分层的Cubemap
	}


	SubShader {
		//Tags { "RenderType"="Opaque"} // 渲染队列 - 不透明物体

        //Pass
        //{
        //    tags{"LightMode" = "ShadowCaster"}
        //}
		Tags { "RenderType"="ForwardBase" }
		LOD 100
		Pass {
			Tags { "LightMode" = "ForwardBase" "Queue" = "2500"}
			Name "BASE" // 通道名称
			//Cull Off
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#pragma multi_compile_fwdbase
            #include "AutoLight.cginc"

			#include "UnityCG.cginc"
            #include "Lighting.cginc"

			sampler2D _MainTex;
			samplerCUBE _ToonShade;
			float4 _MainTex_ST;
			float4 _Color;

			struct appdata {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float2 texcoord : TEXCOORD0;
				float3 cubenormal : TEXCOORD1;
				UNITY_FOG_COORDS(2)
				LIGHTING_COORDS(2,3)
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.cubenormal = mul (UNITY_MATRIX_MV, float4(v.normal,0)); // 对法线进行mv变换，然后去Cubemap中采样，得到卡通颜色分层的效果
				TRANSFER_VERTEX_TO_FRAGMENT(o)
				UNITY_TRANSFER_FOG(o,o.pos);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float atten = LIGHT_ATTENUATION(i);
				fixed4 col = _Color * tex2D(_MainTex, i.texcoord);
				fixed4 cube = texCUBE(_ToonShade, i.cubenormal);
				fixed4 c = fixed4(2.0f * cube.rgb * col.rgb, col.a);
		
				UNITY_APPLY_FOG(i.fogCoord, c);
				c.rgb *= atten;
				return c;
			}
			ENDCG			
		}
	} 

	Fallback "Diffuse"
}
