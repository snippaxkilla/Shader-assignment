Shader "Unlit/WavingFlag"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _WaveAmplitude ("Wave Amplitude", Float) = 0.7
        _WaveFrequency ("Wave Frequency", Float) = 5.5
        _WaveSpeed ("Wave Speed", Float) = 1.8
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
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _WaveAmplitude;
            float _WaveFrequency;
            float _WaveSpeed;

            v2f vert (appdata v)
            {
                v2f o;
                // Apply waving effect
                float wave = sin(_WaveFrequency * v.vertex.x + _Time.y * _WaveSpeed) * _WaveAmplitude;
                // Modify vertex position for waving effect
                float4 vertexModified = v.vertex;
                vertexModified.y += wave;

                o.vertex = UnityObjectToClipPos(vertexModified);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
