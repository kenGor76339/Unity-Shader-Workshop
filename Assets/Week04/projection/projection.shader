
Shader "MyShader/projection"
{
    Properties
    {
        ambientColor("Ambient Color", Color) = (0,0,0,0)
        diffuseColor("Diffuse Color", Color) = (1,1,1,1)
        specularColor("Specular Color", Color) = (1,1,1,1)
        _shininess("shininess",range(2,128)) = 10
        _TestFloat("float",range(0,1)) = 0
        shadowBias("shadow bias", Range(0, 0.1)) = 0.05

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
                float3 normal	: NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 wpos : TEXCOORD1;
                float4 color	: COLOR;
                float3 normal	: NORMAL;
                float4 shadowPos : TEXCOORD2;
            };

            float4x4 MyShadowVP;
            

            v2f vert(appdata v)
            {
                v2f o;
                o.uv = v.uv;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.wpos = mul(UNITY_MATRIX_M, v.vertex).xyz;

                o.color = v.color;
                o.uv = v.uv;
                o.normal = mul((float3x3)UNITY_MATRIX_M, v.normal);

                float4 wpos = mul(unity_ObjectToWorld, v.vertex);
                o.shadowPos = mul(MyShadowVP, wpos);
                o.shadowPos.xyz /= o.shadowPos.w;
                return o;
            }

            float4 MyLightDir;

            float4 ambientColor;
            float4 diffuseColor;
            float4 specularColor;
            float _shininess;

            sampler2D uvChecker;
            sampler2D MyShadowMap;
            sampler2D ABC;
            float shadowBias;


            float4 basicLighting(float3 wpos, float3 normal)
            {
                float3 N = normalize(normal);
                float3 L = normalize(-MyLightDir.xyz);
                float3 V = normalize(wpos - _WorldSpaceCameraPos);

                float3 R = reflect(L, N);

                float4 ambient = ambientColor;
                float4 diffuse = diffuseColor * max(0, dot(N, L));

                float  specularAngle = max(0, dot(R, V));
                float4 specular = specularColor * pow(specularAngle, _shininess);

                float4 color = 0;
                color += ambient;
                color += diffuse;
                color += specular;

                return color;
            }

            float4 shadow(v2f i) {
                float4 s = i.shadowPos;
                float3 uv = s.xyz * 0.5 + 0.5;
                float d = uv.z;

                if (true) {
                    float3 N = normalize(i.normal);
                    float3 L = normalize(-MyLightDir.xyz);
                    float slope = tan(acos(dot(N, L)));

                    d -= shadowBias * slope;
                }
                else {
                    d -= shadowBias;
                }

                // depth checking
                if (false) {
                    if (d < 0) return float4(1, 0, 0, 1);
                    if (d > 1) return float4(0, 1, 0, 1);
                    return float4(0, 0, d, 1);
                }

                //return tex2D(uvChecker, uv); // projection checking

                float m = tex2D(MyShadowMap, uv).r;
                //return float4(m,m,m,1); // shadowMap checking
                //return float4(d, m, 0, 1);

                float4 c = tex2D(ABC, uv);
                if (d > m.r)
                    return c;
                return float4(1, 1, 1, 1);
            }

            float4 frag(v2f i) : SV_Target
            {
                float4 s = shadow(i);
                float4 c = basicLighting(i.wpos, i.normal);
                return c * s;
            }
            ENDCG
        }
    }
}
