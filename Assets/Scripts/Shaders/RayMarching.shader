Shader "Hidden/RayMarching"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MinDistance ("Min Distance", float) = 0
        _MaxDistance ("Max Distance", float) = 0
        _MaxSteps ("Max Steps", float) = 0
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
            
            sampler2D _MainTex;
            float _MinDistance;
            float _MaxDistance;
            float _MaxSteps;

            StructuredBuffer<PrimitiveData> Primitives;
            int ObjectCount;

            StructuredBuffer<Camera> Cam;

            struct RayHitInfo
            {
                bool hitTarget;
                float3 normal;
                int steps;
                float minDistFromObject;
            };

            RayHitInfo CastRay(float3 origin, float3 gain)
            {
                RayHitInfo hitInfo = (RayHitInfo)0;
                hitInfo.minDistFromObject = 1*pow(10, 20);
                
                float3 currentPosition = origin;

                while(true)
                {
                    float stepDistance = CalculateSceneSDF(Primitives, ObjectCount, currentPosition);
                    if (stepDistance < hitInfo.minDistFromObject) hitInfo.minDistFromObject = stepDistance;
                    
                    if (stepDistance < _MinDistance)
                    {
                        hitInfo.hitTarget = true;

                        // Calculate Normal
                        const float STEP = 0.001;
                        float3 v1 = float3(
                            CalculateSceneSDF(Primitives, ObjectCount, currentPosition + float3(STEP, 0, 0)),
                            CalculateSceneSDF(Primitives, ObjectCount, currentPosition + float3(0, STEP, 0)),
                            CalculateSceneSDF(Primitives, ObjectCount, currentPosition + float3(0, 0, STEP))
                        );
                        float3 v2 = float3(
                            CalculateSceneSDF(Primitives, ObjectCount, currentPosition - float3(STEP, 0, 0)),
                            CalculateSceneSDF(Primitives, ObjectCount, currentPosition - float3(0, STEP, 0)),
                            CalculateSceneSDF(Primitives, ObjectCount, currentPosition - float3(0, 0, STEP))
                        );
                        hitInfo.normal = normalize(v1 - v2);
                        break;
                    }
                    
                    if (distance(origin, currentPosition) > _MaxDistance)
                    {
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
                Camera cam = Cam[0];
                float3 origin = float3(cam.position.x, cam.position.y, cam.position.z);
                //float2 rayAngle = float2(-(i.uv.x * 2 - 1) * _RayAngleX + 90, (i.uv.y * 2 - 1) * _RayAngleY);
                //rayAngle = normalize(rayAngle);

                float3 gain = normalize(float3((i.uv.x*2 - 1) * tan(cam.viewAngle.x*0.0174533), (i.uv.y*2 - 1) * tan(cam.viewAngle.y*0.0174533), 1));
                gain = opRotate(gain, cam.rotation);
                
                RayHitInfo hitInfo = CastRay(origin, gain);
                
                float4 col;
                if (hitInfo.hitTarget)
                {
                    // Simple normal shading
                    float xnormal = hitInfo.normal.x+0.3*2;
                    float ynormal = hitInfo.normal.y+0.3*2;
                    float shading = pow(xnormal*ynormal, .8);
                    //col = float4((1-abs(hitInfo.normal.x))*shading, (1-abs(hitInfo.normal.y))*shading, shading, 1);

                    col = float4(shading, shading, shading, 1);
                }
                else // Skybox
                {
                    float darkness = ((float)1 / i.uv.y);
                    darkness = min(darkness, 3.5);
                    col = float4(0.3*darkness-0.2, 0.45*darkness-0.2, 0.8*darkness-0.2, 0);
                }

                // Outline Shading
                if (!hitInfo.hitTarget && hitInfo.minDistFromObject < 0.03) col = float4(.5, 0, 1, 1);
                return col;
            }
            ENDCG
        }
    }
}
