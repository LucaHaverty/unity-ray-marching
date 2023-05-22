Shader "Hidden/RayMarchingOld"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SphereX ("Sphere X", float) = 0
        _SphereY ("Sphere Y", float) = 0
        _SphereZ ("Sphere Z", float) = 0
        _SphereRadius ("Sphere Radius", float) = 0
        _MinDistance ("Min Distance", float) = 0
        _MaxDistance ("Max Distance", float) = 0
        _MaxSteps ("Max Steps", float) = 0
        _RayAngleX ("Ray Angle X", float) = 0
        _RayAngleY ("Ray Angle Y", float) = 0
        _RotationX ("X Rotation", float) = 0
    }
    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            // Upgrade NOTE: excluded shader from DX11 because it uses wrong array syntax (type[size] name)
            #pragma exclude_renderers d3d11
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
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            
            sampler2D _MainTex;
            float4 _SpherePos;
            float _SphereRadius;
            float _MinDistance;
            float _MaxDistance;
            float _MaxSteps ;
            float _RayAngleX;
            float _RayAngleY;
            float _RotationX;
            
            struct Sphere
            {
                float3 position;
                float radius;
            };
            StructuredBuffer<Sphere> Spheres;
            float NumSpheres;

            struct Cube
            {
                float3 position;
                float3 scale;
                float4 rotation;
            };
            StructuredBuffer<Cube> Cubes;
            float NumCubes;

            struct BoxFrame
            {
                float3 position;
                float3 scale;
                float4 rotation;
                float edgeThickness;
            };
            StructuredBuffer<BoxFrame> BoxFrames;
            float NumBoxFrames;

            int NumObjects;
            
            float3 ApplyRotation(float3 p, float4 r) {
                float num1 = r.x * 2;
                float num2 = r.y * 2;
                float num3 = r.z * 2;
                float num4 = r.x * num1;
                float num5 = r.y * num2;
                float num6 = r.z * num3;
                float num7 = r.x * num2;
                float num8 = r.x * num3;
                float num9 = r.y * num3;
                float num10 = r.w * num1;
                float num11 = r.w * num2;
                float num12 = r.w * num3;
                float3 result = float3(0, 0, 0);
                result.x =  ((1.0 - ( num5 +  num6)) *  p.x + ( num7 -  num12) *  p.y + ( num8 +  num11) *  p.z);
                result.y =  (( num7 +  num12) *  p.x + (1.0 - ( num4 +  num6)) *  p.y + ( num9 -  num10) *  p.z);
                result.z =  (( num8 -  num11) *  p.x + ( num9 +  num10) *  p.y + (1.0 - ( num4 +  num5)) *  p.z);
                return result;
            }

            float SphereSDF(float3 pointPos, Sphere sphere)
            {
                // Distance to center
                float3 p = sphere.position - pointPos;
                
                return (length(p)) - sphere.radius;
            }
            
            float BoxFrameSDF(float3 pointPos, BoxFrame boxFrame)
            {
                // Distance to center
                float3 p = boxFrame.position - pointPos;

                // Apply X rotation
                p = ApplyRotation(p, boxFrame.rotation);
                /*float xRot = -(boxFrame.rotation.x)*0.0174533;
                p = float3(p.x, p.y*cos(xRot) - p.z*sin(xRot), p.y*sin(xRot)+p.z*cos(xRot));*/
                
                p = abs(p)-boxFrame.scale;
                float3 q = abs(p+boxFrame.edgeThickness)-boxFrame.edgeThickness;
                return min(min(
                      length(max(float3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
                      length(max(float3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
                      length(max(float3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
            }

            float CubeSDF(float3 pointPos, Cube cube)
            {
                // Distance to center
                float3 p = cube.position - pointPos;

                // Apply X rotation
                p = ApplyRotation(p, cube.rotation);


                float3 q = abs(p) - cube.scale;
                return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
            }

            /*float SignedDistanceTorus(float3 pointPos, Cube cube)
            {
                float2 t = float2(3, 2);

                // Distance to center
                float3 p = cube.position - pointPos;

                // Apply X rotation
                float xRot = -(cube.rotation.x)*0.0174533;
                p = float3(p.x, p.y*cos(xRot) - p.z*sin(xRot), p.y*sin(xRot)+p.z*cos(xRot));

                float2 q = float2(length(p.xz)-t.x,p.y);
                return length(q)-t.y;
            }*/

            float SmoothMin(float3 pointPos, BoxFrame objA, BoxFrame objB)
            {
                float a = BoxFrameSDF(pointPos, objA);
                float b = BoxFrameSDF(pointPos, objB);
                float k = .2;
            
                float h = a - b;
    
                h = clamp(0.5 + 0.5*h/k, 0.0, 1.0);    
                return lerp(a, b, h) - k*h*(1.0-h);    
            }
            
            void GetDistancesToObjects()
            {
                /*float closeDist = 1*pow(10, 20);

                for (int i = 0; i < NumSpheres; i++)
                {
                    float dist = SignedDistanceSphere(pointPos, Spheres[i]);
                    if (dist < closeDist)
                        closeDist = dist;
                }
                for (int i = 0; i < NumCubes; i++)
                {
                    float dist = SignedDistanceCube(pointPos, Cubes[i]);
                    if (dist < closeDist)
                        closeDist = dist;
                }
                for (int i = 0; i < NumBoxFrames; i++)
                {
                    float dist = SignedDistanceBoxFrame(pointPos, BoxFrames[i]);
                    if (dist < closeDist)
                        closeDist = dist;
                }
                return closeDist;*/
            }

            float SceneSDF(float3 pointPos)
            {
                float closeDist = 1*pow(10, 20);

                for (int i = 0; i < NumSpheres; i++)
                {
                    float dist = SphereSDF(pointPos, Spheres[i]);
                    if (dist < closeDist)
                        closeDist = dist;
                }
                for (int i = 0; i < NumCubes; i++)
                {
                    float dist = CubeSDF(pointPos, Cubes[i]);
                    if (dist < closeDist)
                        closeDist = dist;
                }
                for (int i = 0; i < NumBoxFrames; i++)
                {
                    float dist = BoxFrameSDF(pointPos, BoxFrames[i]);
                    if (dist < closeDist)
                        closeDist = dist;
                }
                return closeDist;
            }

            struct RayHitInfo
            {
                bool hitTarget;
                float3 normal;
                int steps;
                float minDistFromObject;
            };

            RayHitInfo CastRay(float3 origin, float2 angle)
            {
                RayHitInfo hitInfo = (RayHitInfo)0;
                hitInfo.minDistFromObject = 1*pow(10, 20);
                
                float3 gain = float3(
                    cos(angle.x * 0.0174533),
                    sin(angle.x * 0.0174533) * sin(angle.y * 0.0174533),
                    sin(angle.x * 0.0174533) * cos(angle.y * 0.0174533));
                
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
                    
                    if (stepDistance > _MaxDistance)
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
                float2 rayAngle = float2(-(i.uv.x * 2 - 1) * _RayAngleX + 90, (i.uv.y * 2 - 1) * _RayAngleY);

                RayHitInfo hitInfo = CastRay(origin, rayAngle);
                
                float4 col;
                if (hitInfo.hitTarget)
                {
                    // Shading
                    float xnorm = hitInfo.normal.x+0.3*2;
                    float ynorm = hitInfo.normal.y+0.3*2;
                    float shading = xnorm*ynorm;
                    col = float4((1-abs(hitInfo.normal.x))*shading, (1-abs(hitInfo.normal.y))*shading, shading, 1);
                }
                else col = float4(0.3, 0.4, 0.8, 0); // Skybox

                /*if (hitInfo.steps > _MaxSteps)
                    col = float4(1, 0, 0, 1); // Red if passed max steps (for debugging)*/
                if (!hitInfo.hitTarget && hitInfo.minDistFromObject < 0.02) col = float4(1, 1, 1, 1);
                return col;
            }
            ENDCG
        }
    }
}
