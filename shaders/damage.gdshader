shader_type canvas_item;

uniform bool effect_enabled = false;
uniform vec3 flash_color : source_color = vec3(1.0,0.0,0.0);

void fragment(){
    vec4 t = texture(TEXTURE, UV);
    if (effect_enabled) {
        COLOR = mix(t, vec4(flash_color, t.a), 0.7);
    } else {
        COLOR = t;
    }
}
