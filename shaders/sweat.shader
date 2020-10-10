Shader "WAU/sweat"
{
    Properties
    {
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Distortion ("Distortion", range(-0.1, 0.1)) = 0.01
		_Lighting ("Lighting", range(0.0, 1.0)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent"}
        LOD 100
		ZWrite Off

		GrabPass{"_GrabTexture"}
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
				float4 grab_uv : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _GrabTexture;
			float _Distortion;
			float4 _Color;
			float _Lighting;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
				o.grab_uv = UNITY_PROJ_COORD(ComputeGrabScreenPos(o.vertex));
                return o;
            }
			
            float4 frag (v2f i) : SV_Target
            {
				float dist;
				
				dist = smoothstep(0.02, 1, i.uv.y) * smoothstep(1, 0.02, i.uv.y) 
				* smoothstep(0.01, 0.5, i.uv.x) * smoothstep(0.5, 0.01, i.uv.x) + 0.01;
				
				float4 col;
				col = dist;
				col = tex2Dproj(_GrabTexture, i.grab_uv + dist * _Distortion);
				col += (dist + _Lighting) * _Color;
				//col.a = 0;
				//col *= 1 - dist * (1 - _Color);
				//col += water * 1;
				//col.a = 0;
				//col *= 1 - water * (1 - _Color);
                return col;
            }
            ENDCG
        }
    }
}
