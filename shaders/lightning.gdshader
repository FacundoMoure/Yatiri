shader_type canvas_item;

uniform bool effect_enabled = true;   // 🔥 Toggle ON/OFF
uniform vec3 effect_color: source_color = vec3(0.8, 0.8, 0.4);
uniform float radius = 0.5;     // tamaño del halo
uniform float softness = 0.3;   // borde difuso
uniform float flicker_strength = 0.1; // cuánto fluctúa la luz
uniform float speed = 1.0;      // velocidad del parpadeo

float hash12(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
    if (!effect_enabled) {
        discard; // no dibuja nada si está apagado
    }

    vec2 uv = 2.0 * UV - 1.0;   // coords normalizadas [-1,1]
    float dist = length(uv);    // distancia radial al centro

    // borde circular suave
    float alpha = smoothstep(radius, radius + softness, dist);
    alpha = 1.0 - alpha; // centro = opaco, afuera = transparente

    // 🔥 efecto de flicker sutil
    float flicker = 1.0 + flicker_strength * sin(TIME * speed + hash12(uv) * 6.2831);

    vec3 color = effect_color * flicker;
    COLOR = vec4(color, alpha);
}
