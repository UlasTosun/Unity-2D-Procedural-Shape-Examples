// STAR is defined, otherwise Shader Graph cannot compile this node.
// This definition should be unique to this function. So, it is recommended to define it smilar to the function name.
#ifndef STAR

    #define STAR



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



    // Returns the sign of the point p1 to the line defined by p2 and p3.
    float Sign(float2 p1, float2 p2, float2 p3) {
        return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
    }



    // Returns the distance of the point uv to the triangle defined by p1, p2 and p3.
    float Triangle(float2 uv, float2 p1, float2 p2, float2 p3) {
        float sign1 = Sign(uv, p1, p2);
        float sign2 = Sign(uv, p2, p3);
        float sign3 = Sign(uv, p3, p1);

        float distance1 = DistanceToSegment(uv, p1, p2);
        float distance2 = DistanceToSegment(uv, p2, p3);
        float distance3 = DistanceToSegment(uv, p3, p1);

        bool allNegative = sign1 <= 0 && sign2 <= 0 && sign3 <= 0;
        bool allPositive = sign1 >= 0 && sign2 >= 0 && sign3 >= 0;

        float minDistance = min(distance1, min(distance2, distance3));
        float result = allNegative || allPositive ? minDistance : -minDistance;

        return AntiAliasingStep(result, -0.001);
    }



    // Returns the nearest corner of the polygon
    float GetNearestCornerAngle(float2 uv, int corners, float angleOffset = 0) {
        float anglePerCorner = 2 * PI / corners;
        float angle = atan2(uv.y, uv.x);

        float nearestCornerIndex = floor(0.5 + (angle + angleOffset) / anglePerCorner);
        float nearestCornerAngle = nearestCornerIndex * anglePerCorner - angleOffset;

        return nearestCornerAngle;
    }



    // Creates a fake light effect by using the anti-aliasing step
    float3 FakeLightEffect(float2 uv, float threshold) {
        float3 effect = AntiAliasingStep(float3(uv, 1), threshold); // create a fake light effect for each quadrant of the UV
        effect = dot(effect, float3(0.126, 0.7152, 0.0722)); // convert to grayscale
        return saturate(effect);
    }



    void Star_half(float2 uv, half4 mainColor, float radius, float innerRadius, int corners, out half4 color) {
        color = mainColor;
        float2 centeredUV = uv - 0.5; // move the center of the UV to the origin

        float nearestOuterCornerAngle = GetNearestCornerAngle(centeredUV, corners); // get the nearest outer corner angle
        float2 nearestOuterCorner = float2(cos(nearestOuterCornerAngle), sin(nearestOuterCornerAngle)) * radius; // get the nearest outer corner

        float nearestInnerCornerAngle = GetNearestCornerAngle(centeredUV, corners, 2 * PI / corners / 2); // get the nearest inner corner angle
        float2 nearestInnerCorner = float2(cos(nearestInnerCornerAngle), sin(nearestInnerCornerAngle)) * innerRadius; // get the nearest inner corner

        float tri = Triangle(centeredUV, float2(0, 0), nearestOuterCorner, nearestInnerCorner); // draw a triangle with the center, outer corner and inner corner
        color.a = tri;

        float angle = atan2(centeredUV.y, centeredUV.x);
        float angleDifference = angle - nearestInnerCornerAngle;
        float3 lightEffect = FakeLightEffect(angle - nearestInnerCornerAngle, 0); // create a fake light effect
        color.rgb *= lightEffect; // apply the fake light effect
    }




#endif