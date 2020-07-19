Shader "WAU/waterDrop"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Distortion ("Distortion", range(-5, 5)) = 1
		_resX("resolution_x", float) = 1
		_resY("resolution_y", float) = 1
		_offset("offset", float) = 0
		_t("time", float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex, _GrabTexture;
            float4 _MainTex_ST;
	    float _Distortion;
	    float _resX;
	    float _resY;
	    float _offset;
	    float _t;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
		o.grab_uv = UNITY_PROJ_COORD(ComputeGrabScreenPos(o.vertex));
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
	        float2 res = float2(_resX, _resY);
	        float t = _Time.y + _offset;
	        //float t = _t;
	        float4 col = 0.0f;
				
	        float2 uv = i.uv;
	        uv.y += t * 0.5;
	        float2 gv = frac(uv) - 0.5;
			
	        float x = 0.;
	        float y = 0.;
				
	        float w = uv.y;
	        x = sin(2 * w) * sin(w + cos(w)) * 0.2;
	        y -= (gv.x - x) * (gv.x - x) * 0.2;
	       			
	        float2 drop_pos = (gv - float2(x, y)) / res;
	        float drop = 1 - smoothstep(0,0.1,length(drop_pos));
				
	        float2 trail_pos = (gv - float2(x, t * 0.25)) / res;
	        trail_pos.y = (frac(trail_pos.y * 8) - 0.5) / 8;
	        float trail = 1 - smoothstep(0,0.02,length(trail_pos));
	        trail *= smoothstep(-0.05, 0.05, drop_pos.y);
	        trail *= smoothstep(0.5, y, gv.y);
				
	        col += trail;
	        col += drop;
				
	        //col = tex2D(_MainTex, i.uv + (drop + trail)* _Distortion);
	        col = tex2Dproj(_GrabTexture, i.grab_uv + (drop + trail)* _Distortion);
	        //if(gv.y > .49) col += float4(1, 0, 0, 0);
                return col;
            }
            ENDCG
        }
    }
}
