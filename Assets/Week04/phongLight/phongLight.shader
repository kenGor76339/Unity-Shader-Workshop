Shader "MyShader/phongLight"
{
    Properties
    {
        _Color("Color",COLOR) = (1,1,1,1)
        _shininess("Specular Shininess", range(2,100)) = 49
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 100

            Pass
            {
                Cull Off

                CGPROGRAM

                #pragma vertex vert
                #pragma fragment frag


                #include "UnityCG.cginc"

                struct appdata
                {
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD0;
                    float3 normal : NORMAL;
                };

                struct v2f
                {
                    float2 uv : TEXCOORD0;
                    float4 vertex : SV_POSITION;
                    float3 normal : NORMAL;
                    float3 position : TEXCOORD1;
                };

                float4 _Color;
                float _shininess;
                int srclightAmount;
                float4 srclight_arr[8];// How to set the array size by srclightAmount?
                float intensity_arr[8];
                float range_arr[8];
                float4 color_arr[8];
                float angle_arr[8];
                float4 direction_arr[8];

                v2f vert(appdata v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = v.uv;
                    o.normal = mul((float3x3)UNITY_MATRIX_M, v.normal);
                    o.position = mul(UNITY_MATRIX_M, v.vertex).xyz;
                    return o;
                }


                float4 PhongLight(float3 sPos, float3 n, float4 srclight, float4 color) {
                    float3 surfacePos = sPos;
                    float3 N = normalize(n);
                    float3 L = normalize(srclight - surfacePos);
                    float4 ambient = color*0.5;
                    float4 diffuse = color * max(0, dot(N, L));
                    float3 R = reflect(L, N);
                    float3 V = normalize(surfacePos - _WorldSpaceCameraPos);
                    float angle = max(0, dot(R, V));
                    float4 specular = pow(angle , _shininess) * color;
                    float4 phong = ambient + diffuse + specular;

                    return phong;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    float4 Color = 0;
                    float3 position = i.position;
                    float3 normal = i.normal;
                    

                    for (int i = 0; i < srclightAmount; i++) {
                        float3 spotDir = direction_arr[i].xyz;
                        float spotAngle = angle_arr[i];
                        float3 length = srclight_arr[i] - position;
                        float L_distance;
                        L_distance = max(0, 1 - (clamp(sqrt(length.x * length.x + length.y * length.y + length.z * length.z), 0, range_arr[i]) / range_arr[i]));

                        float theta = dot(normalize(length), -spotDir);
                        
                        if (spotAngle == 0) {
                            Color += PhongLight(position, normal, srclight_arr[i], color_arr[i]) * L_distance * intensity_arr[i]; //why can not PhongLight(i.position, i.normal, srclight_arr[i])?
                        }
                        else {
                            if (theta > (180-spotAngle)/180) {
                                Color += PhongLight(position, normal, srclight_arr[i], color_arr[i])   * intensity_arr[i];
                            }
                        }
                    }

                    return Color;
                }
                ENDCG
            }
        }
}
