Shader "Custom/Lava"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
        _ScrollSpeed("Scroll Speed", Float) = 1
        [HDR] _GlowColor("Glow Color", Color) = (1,1,1,1)
        _GlowPower("Glow Power", Float) = 1
        _WaveScale("Wave Scale", Float) = 1
        _WaveFrequency("Wave Frequency", Float) = 1
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _BaseMap_ST;
                float _ScrollSpeed;
                half4 _GlowColor;
                half _GlowPower;
                half _WaveScale;
                half _WaveFrequency;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                
                //make the object wave
                float wave = sin((IN.positionOS.z + _WaveFrequency) * _Time.y) * _WaveScale;
                float3 posOS =  IN.positionOS.xyz;
                posOS.y += wave;
                
                OUT.positionHCS = TransformObjectToHClip(posOS);
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv) * _BaseColor;
                color *= _GlowColor * _GlowPower;
                return color;
            }
            ENDHLSL
        }
    }
}
