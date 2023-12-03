Shader "Hidden/RayMarching"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MinDistance ("Min Distance", float) = 0
        _MaxDistance ("Max Distance", float) = 0
        _MaxSteps ("Max Steps", float) = 0
        
        _GridWidth ("Grid Width", Range(0.1, 1)) = 0
        _GridColor("Grid Color", Color) = (0,0,0,0)
        
        _OutlineWidth("Outline Width", Range(0, 1)) = 0
        _OutlineColor("Outline Color", Color) = (0,0,0,0)
        
        _RenderSkybox ("Render Skybox", Range(0, 1)) = 0
    }
    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "SDFFunctions.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            const float4 UnknownColor = float4(1,0,0,1);
            
            sampler2D _MainTex;
            float _MinDistance;
            float _MaxDistance;
            float _MaxSteps;
            float _GridWidth;
            bool _RenderSkybox;
            float4 _GridColor;

            float _OutlineWidth;
            float4 _OutlineColor;

            StructuredBuffer<PrimitiveData> Primitives;
            int ObjectCount;

            float Time;

            StructuredBuffer<Camera> Cam;

            struct RayHitInfo
            {
                bool hitTarget;
                float3 position;
                float3 normal;
                int steps;
                float minDistFromObject;
                bool test;
            };

            RayHitInfo CastRay(float3 origin, float3 gain)
            {
                RayHitInfo hitInfo = (RayHitInfo)0;
                hitInfo.minDistFromObject = 1*pow(10, 20);
                
                float3 currentPosition = origin;

                while(true)
                {
                    float stepDistance = CalculateSceneSDF(currentPosition);
                    if (stepDistance < hitInfo.minDistFromObject) hitInfo.minDistFromObject = stepDistance;
                    
                    if (stepDistance < _MinDistance)
                    {
                        hitInfo.hitTarget = true;

                        // Calculate Normal
                        const float STEP = 0.001;
                        float3 v1 = float3(
                            CalculateSceneSDF(currentPosition + float3(STEP, 0, 0)),
                            CalculateSceneSDF(currentPosition + float3(0, STEP, 0)),
                            CalculateSceneSDF(currentPosition + float3(0, 0, STEP))
                        );
                        float3 v2 = float3(
                            CalculateSceneSDF(currentPosition - float3(STEP, 0, 0)),
                            CalculateSceneSDF(currentPosition - float3(0, STEP, 0)),
                            CalculateSceneSDF(currentPosition - float3(0, 0, STEP))
                        );

                        hitInfo.position = currentPosition;
                        hitInfo.normal = normalize(v1 - v2);
                        break;
                    }
                    
                    if (distance(origin, currentPosition) > _MaxDistance)
                    {
                        hitInfo.test = true;
                        break;
                    }
                    
                    hitInfo.steps++;
                    currentPosition += gain * stepDistance;

                    if (hitInfo.steps > _MaxSteps)
                    {
                        break;
                    }
                }
                return hitInfo;
            }
            
            float4 frag (v2f i) : SV_Target
            {
                const float4 unknownColor = float4(.9,0.1,1,1);
                
                Camera cam = Cam[0];
                float3 origin = float3(cam.position.x, cam.position.y, cam.position.z);

                float3 gain = normalize(float3((i.uv.x*2 - 1) * tan(cam.viewAngle.x*0.0174533), (i.uv.y*2 - 1) * tan(cam.viewAngle.y*0.0174533), 1));
                gain = opRotate(gain, cam.rotation);
                
                RayHitInfo hitInfo = CastRay(origin, gain);
                
                float4 col;
                if (hitInfo.hitTarget)
                {
                    // Simple normal shading
                    float xnormal = hitInfo.normal.x+0.3*2;
                    float ynormal = hitInfo.normal.y+0.3*2;
                    
                    float shading = clamp(pow(max(xnormal*ynormal,0), .8),0,1);
                    
                    col = float4(shading, shading, shading, 1);

                    // Grid
                    if (_GridColor.a > 0)
                    {
                        if (abs(hitInfo.position.x) % 1 < _GridWidth
                            || abs(hitInfo.position.y) % 1 < _GridWidth
                            || abs(hitInfo.position.z) % 1 < _GridWidth)
                            col = lerp(col, _GridColor, _GridColor.a);        
                    }
                }
                else if (_RenderSkybox) // Skybox
                {
                    float darkness = ((float)1 / i.uv.y);
                    darkness = min(darkness, 3.5); 
                    col = float4(0.3*darkness-0.2, 0.45*darkness-0.2, 0.8*darkness-0.2, 0);
                }
                else col = unknownColor;
                
                // Outline Shading
                if (_OutlineWidth > 0)
                {
                    if (!hitInfo.hitTarget && hitInfo.minDistFromObject < _OutlineWidth) col =
                        lerp(col, _OutlineColor, _OutlineColor.a);
                }
                return col;
            }
            ENDCG
        }
    }
}