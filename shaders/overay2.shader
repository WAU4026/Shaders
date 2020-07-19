Shader "WAU/overlay2"
{
	Properties
	{
		_tex ("Texture", 2D) = "white" {}
		_sizeX ("ScaleX", float) = 1.0
		_sizeY ("ScaleY", float) = 1.0
		_Transparency("Transparency", Range(0, 1)) = 0
	}
	SubShader
	{
	
		Tags {"Queue"="Transparent" "RenderType"= "Transparent + 1000" }
		LOD 100
		//ZWrite Off
		
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			Cull Back
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			uniform sampler2D _tex;
			uniform float _Cutoff;
			uniform float _sizeX;
			uniform float _sizeY;
			uniform float _Transparency;
			
			struct vertexInPut {
				float4 position : POSITION;
				float4 texcoord : TEXCOORD0;
			};
			
			struct vertexOutput {
				float4 pos : SV_POSITION;
				float2 tex : TEXCOORD0;
			};
			
			vertexOutput vert(vertexInPut input)
			{
				vertexOutput output;
				
				output.pos = mul(UNITY_MATRIX_P, 
				mul(UNITY_MATRIX_V, float4(_WorldSpaceCameraPos.x , _WorldSpaceCameraPos.y, _WorldSpaceCameraPos.z , 1.0))
				+ float4(input.position.x, input.position.y, input.position.z, 1.0)
				* float4(_sizeX, _sizeY, 1.0, 1.0)
				);
				output.tex = float2(-input.texcoord.x + 1.0, -input.texcoord.y + 1.0);
				
				return output;
			}
			
			float4 frag(vertexOutput input) : COLOR
			{
				float2 coord = (input.tex.xy);
				float4 color = tex2D(_tex, coord);
				color.a -= _Transparency;
				color.a = max(0, color.a);

				return color;
			}
			
			ENDCG

		}
	}
}
