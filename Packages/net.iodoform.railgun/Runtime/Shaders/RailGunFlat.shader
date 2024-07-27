/*
Copyright (c) 2024 iodoform
Released under the MIT license
https://opensource.org/licenses/mit-license.php
*/
Shader "Custom/RailGunFlat"
{
    Properties
    {
        _EmissionColor ("Emission Color", Color) = (1,1,1,1)
        _Strength("Strength", Float) = 1.0
        _RedHeatStrength("Red Heat Strength", Float) = 1.0
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _RedHeatTex ("Red Heat (RGB)", 2D) = "white" {}
        _GlossinessTex("Smoothness", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _MetallicTex("Metallic", 2D) = "white" {}
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _ShotPoint ("Shot Point", Vector) = (0,0,0,0)
        _ShotDirection("Shot Direction", Vector) = (0,0,0,0)
        _Radius("Radius", Float) = 0.5
        _AttenuationRate("Attenuation Rate",Float) = 2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"}
        LOD 200
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        sampler2D _RedHeatTex;
        sampler2D _GlossinessTex;
        sampler2D _MetallicTex;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_GlossinessTex;
            float2 uv_MetallicTex;
            float3 worldPos;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _EmissionColor;
        float3 _ShotPoint;
        float3 _ShotDirection;
        float _Radius;
        float _Strength;
        float _RedHeatStrength;
        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)
        float4 quaternion(float rad, float3 axis)
        {
            return float4(normalize(axis) * sin(rad * 0.5), cos(rad * 0.5));
        }
        //inline fixed4 LightingNoLighting (SurfaceOutput s, fixed3 lightDir, fixed atten)
        //{
        //    return fixed4(s.Albedo, s.Alpha);
        //}

        float3 rotateQuaternion(float rad, float3 axis, float3 pos)
        {
            float4 q = quaternion(rad, axis);
            return (q.w*q.w - dot(q.xyz, q.xyz)) * pos + 2.0 * q.xyz * dot(q.xyz, pos) + 2 * q.w * cross(q.xyz, pos);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            o.Metallic = tex2D(_MetallicTex, IN.uv_MetallicTex)*_Metallic;
            o.Smoothness = tex2D(_GlossinessTex,IN.uv_GlossinessTex)*_Glossiness;
            fixed4 color = tex2D (_MainTex, IN.uv_MainTex);
            if (length(_ShotDirection)==0)
            {
                o.Albedo = color.rgb;
                return;
            }
            o.Alpha = 1;

            // 対象となる円筒の中心軸がz軸に沿うように，ワールド座標を変換する
            float tmp = _ShotDirection.z/length(_ShotDirection.xyz);
            float theta = acos(tmp);
            float3 axis = length(cross(_ShotDirection,float3(0,0,1.0)))==0 ? float3(0,0,1) : normalize(cross(_ShotDirection,float3(0,0,1.0)));
            float3 convertedShotPoint = rotateQuaternion(theta,axis,_ShotPoint.xyz);
            float3 convertedPos = rotateQuaternion(theta,axis,IN.worldPos);
            if (convertedPos.z < convertedShotPoint.z)
            {
                o.Albedo = color.rgb;
                return;
            }

            // 円筒と視線の交点を投影する
            float3 convertedCameraPos = rotateQuaternion(theta,axis,_WorldSpaceCameraPos);
            float2 v = convertedPos.xy;
            float2 p = convertedCameraPos.xy;
            float2 c = convertedShotPoint.xy;
            float tmpdot = dot(v-p,p-c);
            float t = (-tmpdot+sqrt(pow(tmpdot,2)-dot(p-c,p-c)*dot(v-p,v-p)+pow(_Radius,2)*dot(v-p,v-p)))/dot(v-p,v-p);
            float3 intersection = t*(convertedPos-convertedCameraPos) + convertedCameraPos;
            float2 circle_coord = intersection.xy-c;
            float2 cylinder_uv = float2(atan2(circle_coord.y,circle_coord.x + UNITY_PI)/(2*UNITY_PI),intersection.z/(2*UNITY_PI*_Radius));
            o.Albedo = tex2D (_RedHeatTex, cylinder_uv);
            o.Emission = o.Albedo * pow(o.Albedo.x,2) * _RedHeatStrength;
            // 変換後の座標で円筒の中に入っているか判定する
            
            if (pow(convertedPos.x-convertedShotPoint.x,2.0)+pow(convertedPos.y-convertedShotPoint.y,2)>=pow(_Radius,2.0))
            {
                o.Albedo = color.rgb;
                o.Emission = 0;
            }
            
        }
        
        ENDCG
    }
    FallBack "Diffuse"
}
