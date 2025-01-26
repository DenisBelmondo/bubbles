shader_type canvas_item;

uniform sampler2D overlay;
varying vec2 vertex_pos;

void vertex() {
	vertex_pos = VERTEX;
}

void fragment() {
	vec2 tex_size = vec2(textureSize(overlay, 0));
	vec2 real_uv = vertex_pos / tex_size;

	COLOR.rgb *= texture(overlay, real_uv).rgb;
}
