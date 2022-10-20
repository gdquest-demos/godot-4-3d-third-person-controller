shader_type spatial;
uniform sampler2D noise_sampler; 
uniform sampler2D noise_2_sampler; 

uniform float uv_y_offset = 0.0;
uniform float uv_y_scale = 0.0;
uniform float coverage : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float intensity = 1.0;
uniform sampler2D blast_gradient_sampler_1D : source_color;

void vertex()
{
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	VERTEX *= 5.0;
}

void fragment() {
	float noise = texture(noise_sampler, UV * vec2(2.0, 0.01) + vec2(0.0, uv_y_offset)).x;
	float noise_2 = texture(noise_2_sampler, UV * vec2(1.0, 0.1) - vec2(0.0, TIME * 0.1)).x;
	
	float n = noise * noise_2;
	
	float edge_ease = sin((UV.y + uv_y_scale) * PI);
	
	
	float mask = smoothstep(coverage - 0.01, coverage + 0.01, n * edge_ease) * sin(UV.y * PI) ;
	vec3 blast_color = texture(blast_gradient_sampler_1D, vec2(n,0.0)).rgb;
	
	ALPHA = mask;
	ALBEDO = blast_color;
	EMISSION = blast_color * intensity;
}
