#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

namespace Craziness {
    matrix_float2x2 m(float a){
        float c = cos(a), s = sin(a);
        return matrix_float2x2(c, -s, s, c);
    }

    float map(float3 p, float t){
        p.xz = p.xz * m(t * 0.4);
        p.xy = p.xy * m(t * 0.3);
        float3 q = p * 2. + t;
        return length(p + float3(sin(t * 0.7))) * log(length(p) + 1.) + sin(q.x + sin(q.z + sin(q.y))) * 5.5 - 1.;
    }

    float4 crazy_color(float2 position, float time) {
        float2 P = position - float2(0.9, 0.5);
        float3 cl = float3(0);
        float d = 0.9;
        for(int i = 0; i <= 5; i++)    {
            float3 p = float3(0, 0, 5.0) + normalize(float3(P.x, P.y, -1.0)) * d;
            float rz = map(p, time);
            float f =  clamp((rz - map(p + 0.1, time)) * 0.5, -0.1, 1.0);
            float3 l = float3(0.1, 0.3, 0.4) + float3(5.0, 2.5, 3.0)*f;
            cl = cl * l + (1.0 - smoothstep(0.0, 2.5, rz)) * 0.7 * l;
            d += min(rz, 1.0);
        }
        return float4(cl, 1.0);
    }

    struct VertexOut {
        float4 position [[ position ]];
        float time;
        float2 canvasSize;
    };
};

vertex Craziness::VertexOut craziness_vertex(uint id [[ vertex_id ]],
                                             constant float2 *vertices [[ buffer(0) ]],
                                             constant float *time [[ buffer(1) ]],
                                             constant float2 *canvasSize [[ buffer(2) ]]) {
    return {
        .position = float4(vertices[id], 0, 1),
        .time = *time,
        .canvasSize = *canvasSize
    };
}

fragment float4 craziness_fragment(Craziness::VertexOut in [[ stage_in ]]) {
    return Craziness::crazy_color(in.position.xy / in.canvasSize.y, in.time);
}
