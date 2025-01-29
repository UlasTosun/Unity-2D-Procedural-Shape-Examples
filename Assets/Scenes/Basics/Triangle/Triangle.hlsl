// TRIANGLE is defined, otherwise Shader Graph cannot compile this node.
// This definition should be unique to this function. So, it is recommended to define it smilar to the function name.
#ifndef TRIANGLE

    #define TRIANGLE

    #include "Assets/Common Shaders/Common.hlsl"



    // Returns the sign of the point p1 to the line defined by p2 and p3.
    float Sign(float2 p1, float2 p2, float2 p3) {
        return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
    }



    void Triangle_half(float2 uv, float2 p1, float2 p2, float2 p3, out half Out) {
        float sign1 = Sign(uv, p1, p2);
        float sign2 = Sign(uv, p2, p3);
        float sign3 = Sign(uv, p3, p1);

        float distance1 = DistanceToSegment(uv, p1, p2);
        float distance2 = DistanceToSegment(uv, p2, p3);
        float distance3 = DistanceToSegment(uv, p3, p1);

        bool allNegative = sign1 <= 0 && sign2 <= 0 && sign3 <= 0;
        bool allPositive = sign1 >= 0 && sign2 >= 0 && sign3 >= 0;

        float minDistance = min(distance1, min(distance2, distance3));
        float result = allNegative || allPositive ? minDistance : - minDistance;

        Out = AntiAliasingStep(result, -0.001);
    }



#endif