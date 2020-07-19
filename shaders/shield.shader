// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "WAU/shield"
{
	Properties
	{
		_tex ("Texture", 2D) = "black" {}
		_color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_min ("min", float) = 0.0
		_max ("max", float) = 1.0
		_tile ("tile", float) = 2.0
		_speedX ("speedX", float) = 0.5
		_speedY ("speedY", float) = 0.5
	}
	SubShader
	{
	
		Tags {"Queue"="Transparent" "RenderType"= "Transparent + 1000" }
		LOD 100

		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			ZWrite Off
			Cull off
			
			CGPROGRAM
			
			#pragma vertex vert // 버텍스 쉐이더 함수 이름
			#pragma fragment frag // 프래그먼트 쉐이더 함수 이름
			
			uniform sampler2D _tex;
			uniform float4 _color;
			uniform float _min;
			uniform float _max;
			uniform float _tile;
			uniform float _speedX;
			uniform float _speedY;
			
			struct vertexInPut {
				float4 position : POSITION;
				float2 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float2 tex : TEXCOORD0;
				float3 normal : NORMAL;
				float3 dir : TEXCOORD1;	
			};
			
			float rand(float2 xy){
				float res = frac(sin(dot(xy, float2(321.560,432.570))) * 423979.051);
				return res;
			}
			
			v2f vert(vertexInPut input)
			{
				v2f output;
				
				float4 view_pos = mul(UNITY_MATRIX_MV, input.position);
				
				output.pos = UnityObjectToClipPos(input.position);
				output.tex = input.texcoord;
				
				output.normal = mul(UNITY_MATRIX_MV,float4(input.normal, 0.0)).xyz;
				output.dir = -view_pos.xyz;
				
				return output;
			}
			
			float4 frag(v2f input) : COLOR
			{
				float2 coord = (input.tex.xy);
				float4 color;
				
				coord *= _tile;
				
				color.xyz = _color + tex2D(_tex, float2(frac(coord.x + _Time.y * _speedX), frac(coord.y + _Time.y * _speedY)));
				color.a = 1 - smoothstep(_min, _max, abs(dot(normalize(input.dir), normalize(input.normal))));
				return color;
			}
			
			ENDCG

		}
	}
}
