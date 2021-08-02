

Shader "MyShader/MagicCircleShader"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _Glossiness("Smoothness", Range(0,1)) = 0.5
        _Metallic("Metallic", Range(0,1)) = 0.0

        //Dissolve properties
        _DissolveTexture("Dissolve Texutre", 2D) = "white" {}
		[Toggle]_Cutoff("Cut off ?", Int) = 0
        _Amount("Amount", Range(0,1)) = 0
		_SoftEdge("SoftEdge", Range(0,1)) = 0
		_EdgeWidth("EdgeWidth", Range(0,1)) = 0

		_EffectTexture("Effect Texutre", 2D) = "white" {}
    }
		SubShader{
			Tags { "RenderType" = "Opaque" }
			

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				sampler2D _MainTex;

				struct appdata {
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};

				struct v2f {
					float4 vertex : SV_POSITION;
					float2 uv : TEXCOORD0;
				};

				v2f vert(appdata v) {
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = v.uv;
					return o;
				}

				float _Glossiness;
				float _Metallic;
				fixed4 _Color;

				//Dissolve properties
				sampler2D _DissolveTexture;
				float _Amount;
				float _SoftEdge;
				float _EdgeWidth;
				int _Cutoff;
				
				sampler2D _EffectTexture;

				float4 frag(v2f i) : SV_Target{

					float4 noise = tex2D(_DissolveTexture, i.uv);
					float4 mainTex = tex2D(_MainTex, i.uv);
					float4 effectTex = tex2D(_EffectTexture,i.uv);
					float hardEdge = 0;
					float x = i.uv.x;
					float y = i.uv.y;

					float a = i.uv.x * i.uv.x;
					float b = i.uv.y * i.uv.y;
					float c = sqrt(a+b);
					
					float edge = (x - y)+1;
					float edge3 = (x + y) ;
					float edge2 = edge3 - 1;


					float max = (_EdgeWidth + 1) * _Amount;
					float min = max - _EdgeWidth;
					hardEdge = 1-smoothstep(min,max, edge3/2);


					float mask = (noise.r + edge) / 3;
					float mask2 = ((1-noise.r) + edge) / 3;

					float cutOff = step(_Amount, mask ) ;


					hardEdge = 1-step(_Amount, mask2 );







					//if (x+y > 0.2 && x-y < 0.3 && x - y > -0.2 && x + y < 1.5)a = 1;
					if (x + y > 1.5)a = 1;
					else a = 0;
					
					
					//if (edge2 >= -_Amount+0.01 && edge2 < _Amount)discard;
					if (cutOff == 0)discard;
					//if (step(0.34+(edge - noise.r) / 3, 1-_Amount))discard;
					//if (1 - step((edge3 + noise.r) / 3, ( _Amount)*1))discard;
					//if (1 - step((edge + noise.r) / 3, ( _Amount)*1))discard;

					

					return lerp(mainTex,_Color,hardEdge);
			}
			ENDCG
		}

	}
			
}
