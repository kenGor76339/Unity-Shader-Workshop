

Shader "MyShader/003"
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
					float2 uv_MainTex : TEXCOORD0;
				};

				struct v2f {
					float4 vertex : SV_POSITION;
					float2 uv_MainTex : TEXCOORD0;
				};

				v2f vert(appdata v) {
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv_MainTex = v.uv_MainTex;
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

				float4 frag(v2f i) : SV_Target {

					fixed4 c = tex2D(_MainTex, i.uv_MainTex);
					float dissolve_value = tex2D(_DissolveTexture, i.uv_MainTex).r;
					float4 b = tex2D(_EffectTexture, i.uv_MainTex);
					float edge = 0;
					float hardEdge = 0;

					//cut off
					if (step(1-dissolve_value, _Amount) && _Cutoff)discard;

					hardEdge = edge = dissolve_value + _Amount ;

					//Hard Edge handle
					float lowerbound = (1 - _EdgeWidth / 2);
					float upperbound = (1 + _EdgeWidth / 2);
					if (hardEdge >= lowerbound && hardEdge <= upperbound && _Amount != 0 && _Amount != 1) {
						hardEdge = 1;
					}
					else hardEdge = 0;
					//Soft Edge handle
					float lowerboundForSoft = (1 - _SoftEdge / 2);
					float upperboundForSoft = (1 + _SoftEdge / 2);
					if (edge >= lowerboundForSoft && edge <= upperboundForSoft && _Amount != 0 && _Amount != 1) {
						//_SoftEdge = smoothstep(1,0,_SoftEdge) *  _EdgeWidth/2 ;
						if (edge >= lowerboundForSoft && edge < 1) {
							edge = smoothstep(lowerboundForSoft , 1 , edge);
						}
						else {
							edge = smoothstep(upperboundForSoft , 1 , edge);
						}
						
					}
					else edge = 0;
					//dissolve area
					dissolve_value = step(1-dissolve_value, _Amount);
					
					c = lerp(lerp(lerp(c,b, dissolve_value), _Color,edge), _Color , hardEdge);//blend together
					//c = c * (1 - dissolve_value) * (1 - edge) + b * dissolve_value * (1 - edge) + _Color * edge;
					
					return c;
			}
			ENDCG
		}

	}
			
}
