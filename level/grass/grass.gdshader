shader_type spatial;
render_mode cull_disabled, world_vertex_coords;

uniform sampler2D wind_noise_sampler;
uniform sampler2D gradient : source_color;

void vertex(){
	NORMAL = vec3(0.0, 1.0, 0.0);
	vec2 world_uv = VERTEX.xz / 20.0 + 0.5 * TIME * 0.1;

	float wind = texture(wind_noise_sampler, world_uv).x - 0.5;
	VERTEX.xz += wind * 0.1 * ( 1.0 - UV.y);
}

void fragment() {
	vec3 gradient_color = texture(gradient, vec2(UV.y, UV.x)).rgb;
	ALBEDO = gradient_color;
	NORMAL = NORMAL * (float(FRONT_FACING) * 2.0 - 1.0);
}
 