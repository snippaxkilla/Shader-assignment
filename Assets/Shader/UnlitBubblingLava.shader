Shader "Custom/BubblingLavaPit"
{
    Properties
    {
        _RockTex ("Rock Texture", 2D) = "white" {}
        _LavaTex ("Lava Texture", 2D) = "white" {}
        _BlendMap ("Blend Map", 2D) = "white" {} 
        _ThirdTex ("Blend Texture", 2D) = "white" {} 
        _PitDepth ("Pit Depth", Float) = -5
        _PitRadius ("Pit Radius", Float) = 0.4
        _LavaFlowSpeed ("Lava Flow Speed", Float) = 0.01
        _LavaFlowDirection ("Lava Flow Direction", Vector) = (1,1,0,0)
        _BubbleIntensity ("Bubble Intensity", Float) = 1.0
        _BubbleFrequency ("Bubble Frequency", Float) = 2.0
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float pitFactor : TEXCOORD1;
            };

            sampler2D _RockTex, _LavaTex, _BlendMap, _BlendTex;
            float4 _RockTex_ST, _LavaTex_ST, _BlendMap_ST, _BlendTex_ST;
            uniform float _PitDepth, _PitRadius, _LavaFlowSpeed, _BubbleIntensity, _BubbleFrequency;
            uniform float4 _LavaFlowDirection;

            // Vertex Shader
 v2f vert (appdata v)
 {
     v2f o;
     o.vertex = UnityObjectToClipPos(v.vertex);
     float dist = distance(v.uv, float2(0.5, 0.5));
     float bubbleEffect = 0.0;
     
     if(dist < _PitRadius)
     {
         float heightAdjust = _PitDepth * (1.0 - dist / _PitRadius);
         o.vertex.y -= heightAdjust;
         o.pitFactor = 1.0;

         // Bubble effect
         bubbleEffect = sin(_Time.y * _BubbleFrequency + dist * 20.0) * _BubbleIntensity * (1.0 - dist / _PitRadius);
         o.vertex.y += bubbleEffect * heightAdjust; // Apply bubble effect based on distance from center
     }
     else
     {
         o.pitFactor = 0.0;
     }

     o.uv = v.uv;
     return o;
 }

            // Fragment Shader
            fixed4 frag (v2f i) : SV_Target
            {
                float2 flowUV = i.uv + (_LavaFlowDirection.xy * _Time.y * _LavaFlowSpeed);
                flowUV = frac(flowUV);
                fixed4 blendCol = tex2D(_BlendMap, i.uv); 
                fixed4 rockCol = tex2D(_RockTex, i.uv);
                fixed4 lavaCol = tex2D(_LavaTex, flowUV);
                fixed4 lavaRockCol = tex2D(_BlendTex, i.uv);

                // Determine blending based on blend map's channels
                fixed4 color;
                if(blendCol.r > blendCol.g && blendCol.r > blendCol.b) 
                {
                    color = lerp(rockCol, lavaCol, lavaRockCol.r); 
                }
                else
                {
                    color = lerp(rockCol * blendCol.b, lavaCol * blendCol.g, i.pitFactor);
                }
                return color;
            }
            ENDCG
        }
    }
}
