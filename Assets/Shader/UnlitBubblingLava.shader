Shader "Custom/UnlitBubblingLava" {
    Properties {
        _MainTex ("Lava Texture", 2D) = "white" {}
        _RockTex ("Rock Texture", 2D) = "white" {}
        _BlendMap ("Blend Map", 2D) = "white" {}
        _BubblingSpeed ("Bubbling Speed", Float) = 1.0
        _BubblingIntensity ("Bubbling Intensity", Float) = 1.0
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex, _RockTex, _BlendMap;
            float _BubblingSpeed, _BubblingIntensity;

            fixed4 frag (v2f i) : SV_Target {
                // Time-based UV adjustment for bubbling effect
                float2 bubblingUV = i.uv;
                bubblingUV.x += sin(_Time.y * _BubblingSpeed) * _BubblingIntensity;
                bubblingUV.y += cos(_Time.y * _BubblingSpeed) * _BubblingIntensity;

                // Sample textures
                fixed4 lavaTex = tex2D(_MainTex, bubblingUV);
                fixed4 rockTex = tex2D(_RockTex, i.uv);
                fixed4 blendMap = tex2D(_BlendMap, i.uv);

                // Blend based on blend map
                fixed4 color = lerp(rockTex, lavaTex, blendMap.r);

                return color;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
