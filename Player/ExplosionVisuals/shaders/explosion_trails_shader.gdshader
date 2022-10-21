shader_type spatial;
render_mode particle_trails, cull_disabled;

uniform sampler2D noise_sampler;
uniform sampler2D gradient_1D : source_color;

void fragment() {
	float n = texture(noise_sampler, (UV * vec2(0.5, 1.0)) - vec2(0, TIME * 4.0)).x;
	float edge = sin(UV.x * PI) * sin(UV.y * PI) ;
	float clamped_noise = smoothstep(0.6, 0.2, UV.y * n);
	ALPHA = smoothstep(0.2, 0.4, edge) * clamped_noise;
	
	vec3 color = texture(gradient_1D, vec2(clamped_noise, 0.0)).rgb;
	// ALBEDO = color;
	EMISSION = color * 1.2;
}
