// SINUSOIDAL is defined, otherwise Shader Graph cannot compile this node.
// This definition should be unique to this function. So, it is recommended to define it smilar to the function name.
#ifndef SINUSOIDAL

    #define SINUSOIDAL



    void Sinusoidal_half(float2 uv, half a, half f, half p, half c, out half Out) {
        // f(x) = a * sin(2 * PI * f + p) + c

        half x = uv.x;
        half fx = a * sin(2 * PI * f * x + p) + c;
        
        Out = uv.y > fx ? 1 : 0;

    }



#endif