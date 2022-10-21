shader_type spatial;
 

uniform sampler2D noise_sampler;
uniform sampler2D gradient_1D : source_color;

void vertex(){
	float v = sin((TIME * 4.0 + UV.y) * 10.0) - 0.5;
 
	VERTEX.xz += v * NORMAL.xz * 0.02;
}

void fragment() {
	float n = texture(noise_sampler, UV * vec2(1.0, 0.2) + vec2(0.0, TIME)).x;
	float edge = smoothstep(0.0, 0.8, UV.y);
	// Place fragment code here.
	ALPHA = smoothstep(0.0, 0.15, edge * (n + smoothstep(0.6, 1.0, UV.y)));
	
	
	vec3 color = texture(gradient_1D, vec2(n, 0.0)).rgb;
	ALBEDO = color;
	EMISSION = color  * 1.4;
	ROUGHNESS = 0.0;
	SPECULAR = 0.0;
}
