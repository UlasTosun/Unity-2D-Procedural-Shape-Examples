// LINEAR is defined, otherwise Shader Graph cannot compile this node.
// This definition should be unique to this function. So, it is recommended to define it smilar to the function name.
#ifndef LINEAR

    #define LINEAR



    void Linear_half(float2 uv, half a, half b, half c, out half Out) {
        // f(x) = a(x - b) + c

        half x = uv.x - b; // move to the center of the UV
        half fx = a * x + c;
        
        Out = uv.y > fx ? 1 : 0;

    }



#endif