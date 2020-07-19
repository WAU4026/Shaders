// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "WAU/gif"
{
	Properties
	{
		_tex ("Main", 2D) = "white" {}
		_gif ("Gif", 2D) = "white" {}
		
		[Header(Gif)]
		_col ("    col", Float) = 20
		_row ("    row", Float) = 10
		_frame ("    frame", Float) = 10
		_last ("    last count", Float) = 3
		[Header(Gif Position)]
		_GifposX ("    x", Range(0.0, 1.0)) = 0.5
		_GifposY ("    y", Range(0.0, 1.0)) = 0.5
		
		[Header(Gif Size)]
		_GifSizeX ("    x", Range(0.0, 1.0)) = 0.5
		_GifSizeY ("    y", Range(0.0, 1.0)) = 0.5
	}
	SubShader
	{
	
		Tags {"Queue"="Transparent" "RenderType"= "Transparent + 1000" }
		LOD 100

		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			ZWrite On
			Cull off
			
			CGPROGRAM
			
			#pragma vertex vert // 버텍스 쉐이더 함수 이름
			#pragma fragment frag // 프래그먼트 쉐이더 함수 이름
			
			uniform sampler2D _tex;
			uniform sampler2D _gif;
			
			uniform float _col;
			uniform float _row;
			uniform float _frame;
			uniform float _last;
			uniform float _GifposX;
			uniform float _GifposY;
			uniform float _GifSizeX;
			uniform float _GifSizeY;
			
			struct vertexInPut {
				float4 position : POSITION;
				float2 texcoord : TEXCOORD0;
				float2 gifcoord : TEXCOORD1;
				float3 normal : NORMAL;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float2 tex : TEXCOORD0;
				float2 gif : TEXCOORD1;	
				float3 normal : NORMAL;
			};
			
			float rand(float2 xy){
				float res = frac(sin(dot(xy, float2(321.560,432.570))) * 423979.051);
				return res;
			}
			
			v2f vert(vertexInPut input)
			{
				v2f output;
				
				output.pos = UnityObjectToClipPos(input.position);
				output.tex = input.texcoord;
				output.gif = input.gifcoord;
				output.normal = input.normal;
				
				return output;
			}
			
			float4 frag(v2f input) : COLOR
			{
				
				
				float left = step(_GifposX, input.tex.x);
				float right = 1 - step(clamp(_GifposX + _GifSizeX, 0.0, 1.0), input.tex.x);
				float bottom = step(_GifposY, input.tex.y);
				float top = 1 - step(clamp(_GifposY + _GifSizeY, 0.0, 1.0), input.tex.y);
				
				float col = left * right * bottom * top;
				float4 color_gif = float4(1.0, 1.0, 1.0, 1.0);
				
				float yoffset = (_row - 1.0) - floor((_Time.y / (_col / _frame)) % _row);
				if(yoffset != 0){
					color_gif = float4(1.0, 1.0, 1.0, col) *
					tex2D(_gif, float2(
						(((input.tex.x - _GifposX) / _GifSizeX) + floor((_Time.y * _frame) % _col)) / _col,
						(((input.tex.y - _GifposY) / _GifSizeY) + yoffset) / _row));
				}else{
					color_gif = float4(1.0, 1.0, 1.0, col) *
					tex2D(_gif, float2(
						(((input.tex.x - _GifposX) / _GifSizeX) + floor((_Time.y * _frame) % _last)) / _col,
						(((input.tex.y - _GifposY) / _GifSizeY) + yoffset) / _row));
				}
				float4 color =
				tex2D(_tex, input.tex);
				
				float4 result = lerp(color, color_gif, color_gif.a);
				return result;
			}
			
			ENDCG

		}
	}
}
