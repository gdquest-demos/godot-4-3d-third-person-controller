shader_type spatial;
render_mode cull_disabled;

uniform sampler2D wing_pattern_sampler : repeat_disable;
uniform vec3 emission_color : source_color = vec3(1.0);
uniform float global_intensity = 1.0;

void fragment() {
	float wing_pattern = texture(wing_pattern_sampler, UV).x;
	float pulse = ((1.0 + sin(UV.y + TIME)) / 2.0) + 0.5;
	ALBEDO = vec3(0.0);
	EMISSION = emission_color * smoothstep(0.51, 0.49, wing_pattern) * pulse * global_intensity;
}
