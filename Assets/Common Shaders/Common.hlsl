// This file contains common functions that can be used in any shader.

// Returns the step value for the anti-aliasing
// Without using anti-aliasing, the edges of the shapes will be jagged, so you can see the pixels (especially when  you rotate the shapes).
float3 AntiAliasingStep(float3 gradiend, float threshold) {
    // For delta calculation we can use both of the following methods.
    // Sum of the absolute values of the derivatives in x and y axis or maximum of the absolute values of the derivatives in x and y axis.
    
    //float3 delta = fwidth(gradiend); // abs(ddx(gradiend)) + abs(ddy(gradiend)) -> sum of the absolute values of the derivatives in x and y axis
    float3 delta = max(abs(ddx(gradiend)), abs(ddy(gradiend)));

    float3 lower = threshold - delta;
    float3 upper = threshold + delta;

    float3 step = (gradiend - lower) / (upper - lower);
    return saturate(step);
}



// Returns the projected vector of vector1 onto vector2.
float2 Project(float2 vector1, float2 vector2) {
    // Poor performance version
    //return (dot(vector1, vector2) / dot(vector2, vector2)) * vector2;

    // Better performance version
    // Projection magnitude -> v1.v2 / |v2|
    // Projection direction -> a / |v2|
    // Projection vector -> (v1.v2 / |v2|) * (v2 / |v2|)
    // Lets split it into two parts (scalar and vectoral)
    // scalar -> (v1.v2) / (|v2|^2)
    // vectoral (direction) -> v2
    // |v2| = sqrt(v2.x^2 + v2.y^2)
    // |v2|^2 = v2.x^2 + v2.y^2
    // so, scalar -> (v1.v2) / (a.x^2 + a.y^2)

    float scalar = dot(vector1, vector2) / (vector2.x * vector2.x + vector2.y * vector2.y);
    scalar = saturate(scalar);
    return scalar * vector2;
}



// Returns the distance of the point uv to the line segment defined by point1 and point2.
float DistanceToSegment(float2 uv, float2 point1, float2 point2) {
    float2 vector1 = uv - point1;
    float2 vector2 = point2 - point1;
    float2 projection = Project(vector1, vector2);
    float2 projectedPoint = point1 + projection;
    return distance(uv, projectedPoint);
}



// Creates a fake light effect by using the anti-aliasing step
float3 FakeLightEffect(float2 uv, float threshold) {
    float3 effect = AntiAliasingStep(float3(uv, 1), threshold); // create a fake light effect for each quadrant of the UV
    effect = dot(effect, float3(0.126, 0.7152, 0.0722)); // convert to grayscale
    return saturate(effect);
}
