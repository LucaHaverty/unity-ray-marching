struct Camera
{
    float3 position;
    float4 rotation;
    float2 viewAngle;
};

struct Sphere
{
    float3 position;
    float radius;
};

struct Cube
{
    float3 position;
    float3 scale;
    float4 rotation;
};

struct BoxFrame
{
    float3 position;
    float3 scale;
    float4 rotation;
    float edgeThickness;
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
    p = opRotate(p, boxFrame.rotation);
    /*float xRot = -(boxFrame.rotation.x)*0.0174533;
    p = float3(p.x, p.y*cos(xRot) - p.z*sin(xRot), p.y*sin(xRot)+p.z*cos(xRot));*/
    
    p = abs(p)-boxFrame.scale/2.0;
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
    p = opRotate(p, cube.rotation);


    float3 q = abs(p) - cube.scale/2.0;
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

float opUnion( float d1, float d2 ) { return min(d1,d2); }
            
float opSubtraction( float a, float b ) { return max(-a,b); }

float opIntersection( float a, float b ) { return max(a,b); }

float opSmoothUnion( float d1, float d2, float k ) {
    float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
    return lerp( d2, d1, h ) - k*h*(1.0-h); }

float opSmoothSubtraction( float d1, float d2, float k ) {
    float h = clamp( 0.5 - 0.5*(d2+d1)/k, 0.0, 1.0 );
    return lerp( d2, -d1, h ) + k*h*(1.0-h); }

float opSmoothIntersection( float d1, float d2, float k ) {
    float h = clamp( 0.5 - 0.5*(d2-d1)/k, 0.0, 1.0 );
    return lerp( d2, d1, h ) + k*h*(1.0-h); }

float SDFTriangleFractal(float3 z, float4 rot)
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
}