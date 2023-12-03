struct Camera
{
    float3 position;
    float4 rotation;
    float2 viewAngle;
};

struct PrimitiveData
{
    int primitveType;
    
    int combinationType;
    float smoothAmount;
    
    float3 position;
    float3 scale;
    float4 rotation;

    float4 color;

    // Properties: use varies depending on objectType
    float p1;
    float p2;
    float p3;
};

float3 opRotate(float3 p, float4 r) {
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

float opUnion( float a, float b ) { return min(a, b); }

float opIntersection( float a, float b ) { return max(a,b); }

float opSubtraction( float a, float b ) { return max(-a,b); }

float opSmoothUnion( float d1, float d2, float k ) {
    float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
    return lerp( d2, d1, h ) - k*h*(1.0-h); }

float opSmoothIntersection( float d1, float d2, float k ) {
    float h = clamp( 0.5 - 0.5*(d2-d1)/k, 0.0, 1.0 );
    return lerp( d2, d1, h ) + k*h*(1.0-h); }

float opSmoothSubtraction( float d1, float d2, float k ) {
    float h = clamp( 0.5 - 0.5*(d2+d1)/k, 0.0, 1.0 );
    return lerp( d2, -d1, h ) + k*h*(1.0-h); }

float combineDistances(float a, float b, PrimitiveData primitive)
{
    switch(primitive.combinationType)
    {
    case 0:
        return opUnion(a, b);
    case 1:
        return opIntersection(a, b);
    case 2:
        return opSubtraction(a, b);
    case 3:
        return opSmoothUnion(a, b, primitive.smoothAmount);
    case 4:
        return opSmoothIntersection(a, b, primitive.smoothAmount);
    case 5:
        return opSmoothSubtraction(a, b, primitive.smoothAmount);
    default: return opUnion(a, b);
    }
}

float SphereSDF(float3 p, float radius)
{
    return length(p) - radius;
}

float BoxSDF(float3 p, float3 scale)
{
    float3 q = abs(p) - scale/2.0;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float CalculatePrimitiveSDF(PrimitiveData primitive, float3 pointPosition)
{
    // Distance to center
    float3 p = primitive.position - pointPosition;

    // Apply X rotation
    p = opRotate(p, primitive.rotation);

    switch(primitive.primitveType)
    {
    case 0: // Sphere (p1 = radius)
        {
            return (length(p)) - primitive.p1;
        }
    case 1: // Cube
        {
            float3 q = abs(p) - primitive.scale/2.0;
            return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
        }
    case 2: // Box Frame (p1 = edgeThickness)
        {
            p = abs(p)-primitive.scale/2.0;
            float3 q2 = abs(p+primitive.p1)-primitive.p1;
            return min(min(
                  length(max(float3(p.x,q2.y,q2.z),0.0))+min(max(p.x,max(q2.y,q2.z)),0.0),
                  length(max(float3(q2.x,p.y,q2.z),0.0))+min(max(q2.x,max(p.y,q2.z)),0.0)),
                  length(max(float3(q2.x,q2.y,p.z),0.0))+min(max(q2.x,max(q2.y,p.z)),0.0));
        }
    case 3: // Torus (scale.x = radius, scale.y = thickness)
        {
            float2 q = float2(length(p.xz)-primitive.scale.x,p.y);
            return length(q)-primitive.scale.y;
        }
    case 4: // Octahedron (p1 = size)
        {
            p = abs(p);
            float size = primitive.p1;
            
            float m = p.x+p.y+p.z-size;
            float3 q;
            if( 3.0*p.x < m ) q = p.xyz;
            else if( 3.0*p.y < m ) { q = p.yzx; }
            else if( 3.0*p.z < m ) { q = p.zxy; }
            else return m*0.57735027;
    
            float k = clamp(0.5*(q.z-q.y+size),0.0,size); 
            return length(float3(q.x,q.y-size+k,q.z-k));
        }
    default: // Default to sphere
        return (length(p)) - primitive.p1;
    }
}

/*// Define your 3D function. For example, a simple paraboloid.
float3 Function(float2 xz)
{
    return float3(xz.x, sin(xz.y), xz.y);
}

// Function to calculate the distance between two points.
float Distance(float3 point1, float3 point2)
{
    return length(point1 - point2);
}

float3 targetPoint;
float DistToFunc(float2 xz, float3 target)
{
    return Distance(targetPoint, Function(xz));
}

float2 CalcGradient(float2 xz, float3 target)
{
    const float step = 0.001;

    float mx = (DistToFunc(xz + float2(step, 0), target) - DistToFunc(xz, target)) / step;
    float mz = (DistToFunc(xz + float2(0, step), target) - DistToFunc(xz, target)) / step;

    return float2(mx, mz);
}

// Function to find the closest point on the function's surface to the target point.
float FindClosestPoint(float3 p)
{
    const float iterations = 10;
    const float descentStep = 0.0001;
    
    targetPoint = p;
    
    // Define initial values for the closest point and minimum distance.
    float2 closestPoint = float2(p.x, p.z);

    float initialDist = DistToFunc(closestPoint, targetPoint);
    float minDistance = initialDist;

    for (int i = 0; i < iterations; i++)
    {
        float2 gradient = CalcGradient(closestPoint, targetPoint);
        closestPoint += -gradient*descentStep;
        minDistance = DistToFunc(closestPoint, targetPoint);
    }

    return minDistance;
    //return initialDist;
    //return p.y + pow(p.x,1.8) + pow(p.z,1.8);
}*/
float Func(float2 p)
{
    return sin(p.x)*1.5;
}

float DistToFunc(float3 p, float2 funcEval)
{
    float3 delta = p-float3(funcEval.x, Func(funcEval), funcEval.y);
    return length(delta)*sign(delta.y);
}

float FindClosestPoint(float3 p)
{
    //return p.y+p.z;
    float minDist = DistToFunc(p, p.xz);

    float2 currFuncEval = p.xz;
    
    for (int i = 0; i < 1000; i++)
    {
        float h = .00001;
        float gradient = (DistToFunc(p, currFuncEval+h) - DistToFunc(p, currFuncEval)) / h;
        /*float2 gradient = float2(
            (distToFunc(p, currFuncEval + float2(h, 0)) - distToFunc(p, currFuncEval)) / h,
            (distToFunc(p, currFuncEval + float2(0, h)) - distToFunc(p, currFuncEval)) / h
        );*/

        currFuncEval.x -= gradient * .005;

        minDist = min(minDist, DistToFunc(p, currFuncEval));
    }
    return minDist;
}

float CalculateSceneSDF(float3 p)
{
    //return min(FindClosestPoint(p), SphereSDF(p-float3(5,5,0), 2));
    return opSmoothUnion(BoxSDF(p, float3(1,1,1)),
    SphereSDF(p-float3(0.5,-0.5,0), 1)
,0.5);
    //return SphereSDF(p - float3(5,5,0), 2);
}

/*float SDFTriangleFractal(float3 z, float4 rot)
{
    z = opRotate(z, rot);
    float iterations = 62;
    float scale = 2;
    float offset = 3;
    
    float r;
    int n = 0;
    while (n < iterations) {
        if(z.x+z.y<0) z.xy = -z.yx; // fold 1
        if(z.x+z.z<0) z.xz = -z.zx; // fold 2
        if(z.y+z.z<0) z.zy = -z.yz; // fold 3	
        z = z*scale - offset*(scale-1.0);
        n++;
    }
    return (length(z) ) * pow(scale, -float(n));
}*/