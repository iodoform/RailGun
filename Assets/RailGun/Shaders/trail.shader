/*
Copyright (c) 2024 iodoform
Released under the MIT license
https://opensource.org/licenses/mit-license.php
*/
Shader "Custom/trail"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Strength("Strength", Float) = 10000
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Transparent"}
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows alpha:fade

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        struct Input
        {
            float3 viewDir;
        };
        fixed4 _Color;
        float _Strength;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            float f = dot(IN.viewDir, o.Normal);
            o.Albedo = _Color;
            o.Alpha = (1-cos(f*f))/2;
            o.Emission = _Color*_Strength*abs(f);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
