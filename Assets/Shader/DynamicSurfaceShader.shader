Shader "Custom/LitWithNormalMap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        #pragma surface surf Lambert
        
        struct Input
        {
            float2 uv_MainTex;
        };
        
        sampler2D _MainTex;
        sampler2D _BumpMap;
        
        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
            
            // Extract normal from the normal map
            fixed3 normalMap = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
            
            // Transform the normal to world space
            fixed3 worldNormal = normalize(mul(normalMap.rgb * 2.0 - 1.0, (float3x3)unity_WorldToObject));
            
            // Calculate lighting using the world-normal
            o.Normal = worldNormal;
        }
        ENDCG
    }

    FallBack "Diffuse"
}