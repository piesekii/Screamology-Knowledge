shader_type canvas_item;

// Uniforms allow you to edit these values in the Inspector
uniform vec2 scroll_speed = vec2(0.1, 0.0);
uniform vec4 tint_color : source_color = vec4(1.0);

void fragment() {
    // Offset the UV by time multiplied by speed
    vec2 shifted_uv = UV + (TIME * scroll_speed);
    
    // Sample the texture using the new UV
    // 'texture' is the built-in function, 'TEXTURE' is the node's main texture
    COLOR = texture(TEXTURE, shifted_uv * vec2(4,4)) * tint_color;
}