// STAR is defined, otherwise Shader Graph cannot compile this node.
// This definition should be unique to this function. So, it is recommended to define it smilar to the function name.
#ifndef STAR

    #define STAR

    #include "Assets/Common Shaders/Common.hlsl"



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