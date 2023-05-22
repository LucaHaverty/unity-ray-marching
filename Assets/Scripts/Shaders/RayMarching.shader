Shader "Hidden/RayMarching"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MinDistance ("Min Distance", float) = 0
        _MaxDistance ("Max Distance", float) = 0
        _MaxSteps ("Max Steps", float) = 0
        _RayAngleX ("Ray Angle X", float) = 0
        _RayAngleY ("Ray Angle Y", float) = 0
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
            float _RayAngleX;
            float _RayAngleY;
            
            StructuredBuffer<Sphere> Spheres;
            float NumSpheres;
            
            StructuredBuffer<Cube> Cubes;
            float NumCubes;
           
            StructuredBuffer<BoxFrame> BoxFrames;
            float NumBoxFrames;

            int NumObjects;

            float SceneSDF(float3 pointPos)
            {
                // pointPos = float3(abs(pointPos.x % 1), abs(pointPos.y % 1), abs(pointPos.z % 1)); INFINITE REPETITIONS
                float closeDist = 1*pow(10, 20);

                for (int i = 0; i < NumSpheres; i++)
                {
                    float dist = SphereSDF(pointPos, Spheres[i]);
                    closeDist = opSmoothUnion(closeDist, dist, 0.2);
                }
                for (int i = 0; i < NumCubes; i++)
                {
                    float dist = CubeSDF(pointPos, Cubes[i]);
                    closeDist = opSmoothSubtraction(closeDist, dist, 0.1);
                }
                for (int i = 0; i < NumBoxFrames; i++)
                {
                    float dist = BoxFrameSDF(pointPos, BoxFrames[i]);
                    closeDist = opSmoothUnion(closeDist, dist, 0.2);
                }
                return closeDist;
                //return SmoothMin(SphereSDF(pointPos, Spheres[0]), CubeSDF(pointPos, Cubes[0]));
                //return opSmoothIntersection(SphereSDF(pointPos, Spheres[0]), CubeSDF(pointPos, Cubes[0]), .2);
            }

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
                
                float3 currentPos = origin;

                while(true)
                {
                    float stepDistance = SceneSDF(currentPos);
                    if (stepDistance < hitInfo.minDistFromObject) hitInfo.minDistFromObject = stepDistance;
                    
                    if (stepDistance < _MinDistance)
                    {
                        hitInfo.hitTarget = true;

                        // Calculate Normal
                        const float STEP = 0.001;
                        float3 v1 = float3(
                            SceneSDF(currentPos + float3(STEP, 0, 0)),
                            SceneSDF(currentPos + float3(0, STEP, 0)),
                            SceneSDF(currentPos + float3(0, 0, STEP))
                        );
                        float3 v2 = float3(
                            SceneSDF(currentPos - float3(STEP, 0, 0)),
                            SceneSDF(currentPos - float3(0, STEP, 0)),
                            SceneSDF(currentPos - float3(0, 0, STEP))
                        );
                        hitInfo.normal = normalize(v1 - v2);
                        break;
                    }
                    
                    if (distance(origin, currentPos) > _MaxDistance)
                    {
                        break;
                    }
                    
                    hitInfo.steps++;
                    currentPos += gain * stepDistance;

                    if (hitInfo.steps > _MaxSteps)
                    {
                        break;
                    }
                }
                return hitInfo;
            }
            
            float4 frag (v2f i) : SV_Target
            {
                float3 origin = float3(0, 0, 0);
                //float2 rayAngle = float2(-(i.uv.x * 2 - 1) * _RayAngleX + 90, (i.uv.y * 2 - 1) * _RayAngleY);
                //rayAngle = normalize(rayAngle);

                float3 gain = normalize(float3((i.uv.x*2 - 1) * tan(_RayAngleX*0.0174533), (i.uv.y*2 - 1) * tan(_RayAngleY*0.0174533), 1));

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
                //else col = float4(0.3, 0.4, 0.8, 0); // Skybox
                else
                {
                    float darkness = ((float)1 / i.uv.y);
                    darkness = min(darkness, 3.5);
                    col = float4(0.3*darkness-0.2, 0.45*darkness-0.2, 0.8*darkness-0.2, 0); // Skybox
                }

                /*if (hitInfo.steps > _MaxSteps)
                    col = float4(1, 0, 0, 1); // Red if passed max steps (for debugging)*/
                if (!hitInfo.hitTarget && hitInfo.minDistFromObject < 0.03) col = float4(.5, 0, 1, 1);
                return col;
            }
            ENDCG
        }
    }
}
