// LINEAR is defined, otherwise Shader Graph cannot compile this node.
// This definition should be unique to this function. So, it is recommended to define it smilar to the function name.
#ifndef CIRCLE

    #define CIRCLE



    void Circle_half(float2 uv, half2 c, half r, out half Out) {
        // f(x) = x^2 + y^2 - r^2

        half x = uv.x - c.x; // move the circle to the origin of the UV
        half y = uv.y - c.y; // move the circle to the origin of the UV
        half fx = x * x + y * y - r * r;
        
        Out = fx < 0 ? 1 : 0;

    }



#endif