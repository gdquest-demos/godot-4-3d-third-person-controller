shader_type spatial;
uniform sampler2D noise_sampler;

uniform float progress : hint_range(0.0, 1.0, 0.1) = 0.0;
uniform float movement = 0.5;
uniform float uv_offset = 0.0;

float fresnel(vec3 normal, vec3 view, float intensity) {
	return pow(1.0 - clamp(dot(normal, view), 0.0, 1.0), intensity);
}

void vertex() {
		float noise = texture(noise_sampler, UV + vec2(0.0, uv_offset)).x;
		
		VERTEX *= movement * COLOR.r;
		VERTEX += NORMAL * noise * 0.2;
}

void fragment() {
	// Place fragment code here.
	float noise = texture(noise_sampler, UV + COLOR.g * 0.1).x;
	float mask = smoothstep(progress - 0.1, progress + 0.1, noise);

}
