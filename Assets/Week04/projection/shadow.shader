Shader "Unlit/shadow"
{
    Properties
    {
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
                float4 color	: COLOR;
            };

            struct v2f
            {
                float depth : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD1;
                float4 color	: COLOR;
            };

            float4x4  MyShadowVP;

            v2f vert (appdata v)
            {
                v2f o;
                o.uv = v.uv;
                o.color = v.color;
            #if true
                float4 wpos = mul(unity_ObjectToWorld, v.vertex);
                o.vertex = mul(MyShadowVP, wpos);
                float d = o.vertex.z / o.vertex.w;
                d = d * 0.5 + 0.5;
            #else
                o.vertex = UnityObjectToClipPos(v.vertex);
                float d = o.vertex.z / o.vertex.w;
                if (UNITY_NEAR_CLIP_VALUE == -1) {
                    d = d * 0.5 + 0.5;
                }
                #if UNITY_REVERSED_Z
                d = 1 - d;
                #endif
            #endif
                o.depth = d;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //return i.color;
                return float4(i.depth, 0,0,0);
            }
            ENDCG
        }
       
    }
}
