Shader "WAU/tear"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Distortion ("Distortion", range(-5, 5)) = 1
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

            sampler2D _MainTex, _GrabTexture;
            float4 _MainTex_ST;
			float _Distortion;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
		o.grab_uv = UNITY_PROJ_COORD(ComputeGrabScreenPos(o.vertex));
                return o;
            }
			
	    float2 random2(float2 st){
		st = float2(dot(st, float2(127.1, 311.7)),
			    dot(st, float2(269.5, 183.3)));
						
		return -1 + 2 * frac(sin(st) * 43758.5453123);
	    }
			
	    float noise(float2 st){
		float2 i = floor(st);
		float2 f = frac(st);
				
		float2 u = f * f * (3.0 - 2.0 * f);
				
		return lerp(lerp(dot(random2(i + float2(0.0, 0.0)), f - float2(0.0, 0.0)),
				 dot(random2(i + float2(1.0, 0.0)), f - float2(1.0, 0.0)), u.x),
			    lerp(dot(random2(i + float2(0.0, 1.0)), f - float2(0.0, 1.0)),
				 dot(random2(i + float2(1.0, 1.0)), f - float2(1.0, 1.0)), u.x), u.y);
	    }
			
            float4 frag (v2f i) : SV_Target
            {
		float t = _Time.y;
		float2 uv = i.uv;
		float2 gv = (i.uv - .5);

		float4 col = float4(.0, .0, .0, 1.0);
				
		float x = 0;
		float y = 0;
				
		float part1 = (sin(t) * 0.4) * smoothstep(-.15, .15, gv.y) * smoothstep(.15, -.15, gv.y);
		float part2 = -(sin(t * 3) * 0.3) * smoothstep(.15, .3, gv.y) * smoothstep(.3, .15, gv.y);
		float part3 = -(sin(t) * 0.3) * smoothstep(-.15, -.3, gv.y) * smoothstep(-.3, -.15, gv.y);
		x += part1;
		x += part2;
		x += part3;
				
		float2 pos = gv - float2(x, y);
				
		float water = 1 - smoothstep(0, .3, length(pos));
		//float4 col = float4(noise(gv), noise(gv), noise(gv), 1);
				
		col = tex2Dproj(_GrabTexture, i.grab_uv + water * _Distortion);
		col += water * 1;
		col.a = 0;
                return col;
            }
            ENDCG
        }
    }
}
