// QUADRATIC is defined, otherwise Shader Graph cannot compile this node.
// This definition should be unique to this function. So, it is recommended to define it smilar to the function name.
#ifndef QUADRATIC

    #define QUADRATIC



    void Quadratic_half(float2 uv, half2 c, half a, half b, out half Out) {
        // f(x) = a*x^2 + b*x + c

        half x = uv.x - c.x; // move to the center of the UV
        half fx = a * x * x + b * x + c.y;
        
        Out = uv.y > fx ? 1 : 0;

    }



#endif