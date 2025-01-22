shader_type spatial;
render_mode cull_front, unshaded;

void vertex() {
	VERTEX *= 1.025;
}

void fragment() {
	ALBEDO = vec3(1.0);
}
