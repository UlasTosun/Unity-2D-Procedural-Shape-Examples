// SHURIKEN is defined, otherwise Shader Graph cannot compile this node.
// This definition should be unique to this function. So, it is recommended to define it smilar to the function name.
#ifndef SHURIKEN

    #define SHURIKEN

    #include "Assets/Common Shaders/Common.hlsl"



    // Draws the axes of the coordinate system
    void DrawAxes_half(float2 uv, float thickness, half4 axisColor, inout half4 Color) {
        float x = uv.x;
        float y = uv.y;
        half4 oldColor = Color;

        bool axis = (x > - thickness && x < thickness) || (y > - thickness && y < thickness);
        Color = axis ? axisColor : oldColor;
    }



    // Returns true if the point is below the line
    float Line(float2 uv, float2 p1, float2 p2) {
        // y = mx + n -> line
        // p1 = (x1, y1) -> point 1
        // p2 = (x2, y2) -> point 2
        // m = (y2 - y1) / (x2 - x1) -> slope between p1 and p2
        // n = y1 - m * x1 -> y-intercept of the line

        float x = uv.x;
        float y = uv.y;
        float epsilon = 0.000000000001; // to avoid division by zero
        
        float m = (p2.y - p1.y) / (p2.x - p1.x + epsilon);
        float n = p1.y - m * p1.x;

        return AntiAliasingStep(m * x + n, y);
    }



    // Returns true if the point is inside the circle
    float Circle(float2 uv, float2 c, float r) {
        // f(x) = (x - c.x)^2 + (y - c.y)^2 - r^2

        float x = uv.x - c.x;
        float y = uv.y - c.y;
        
        return AntiAliasingStep(x * x + y * y, r * r);
    }



    float InFirstQuadrant(float2 uv) {
        return uv.x >= 0 && uv.y >= 0;
    }



    float DrawShurinken(float2 uv, float size, float innerSize, float radius, float innerRadius) {

        float2 absUV = abs(uv); // mirror the UV at the x-axis and y-axis to get the first quadrant

        float2 py = float2(0, size); // point on the y-axis
        float2 px = float2(size, 0); // point on the x-axis
        float2 pc = float2(innerSize, innerSize); // center of the circle

        float line1 = Line(absUV, py, pc); // first line
        float line2 = Line(absUV, px, pc); // second line
        float circle = Circle(absUV, pc, radius); // outer circle
        float innerCircle = Circle(absUV, 0, innerRadius); // inner circle
        bool inFirstQuadrant = InFirstQuadrant(absUV);
        
        float shurinken;
        shurinken = line1 + line2;
        shurinken *= circle;
        shurinken *= innerCircle;
        shurinken *= inFirstQuadrant;

        return saturate(shurinken);
    }



    void Shuriken_half(float2 uv, half4 innerColor, half4 edgeColor, float size, float innerSize, float radius, float innerRadius, float innerShapeScale, float2 innerOffset, bool drawAxes, out half4 Color) {

        float2 centeredUV = uv - 0.5; // move the center of the UV to the origin
        
        float outer = DrawShurinken(centeredUV, size, innerSize, radius, innerRadius); // draw outer shuriken
        float inner = DrawShurinken(centeredUV - innerOffset, size * innerShapeScale, innerSize * innerShapeScale, radius / innerShapeScale, innerRadius / innerShapeScale); // draw inner shuriken

        Color = half4(0, 0, 0, 0); // default color
        Color.rgb = lerp(edgeColor.rgb, innerColor.rgb, inner); // color the shuriken
        Color.a = outer; // set the alpha value

        float3 lightEffect = FakeLightEffect(centeredUV, 0);
        Color.rgb *= lightEffect;

        if (drawAxes)
            DrawAxes_half(centeredUV, 0.001, half4(1, 0, 1, 1), Color);
    }



#endif