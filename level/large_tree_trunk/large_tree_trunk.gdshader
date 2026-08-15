shader_type spatial;

uniform sampler2D bark_albedo_sampler : source_color;
uniform sampler2D trunk_top_albedo_sampler : source_color;
uniform sampler2D moss_albedo_sampler : source_color;

uniform sampler2D bark_orm_sampler;
uniform sampler2D trunk_top_orm_sampler;
uniform sampler2D moss_orm_sampler;

uniform sampler2D bark_normal_sampler;
uniform sampler2D trunk_top_normal_sampler;
uniform sampler2D moss_normal_sampler;


uniform sampler2D bark_mask_sampler : source_color;

// TextureUniformTriplanar
vec4 triplanar_texture(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos) {
	vec4 samp = vec4(0.0);
	samp += texture(p_sampler, p_triplanar_pos.xy) * p_weights.z;
	samp += texture(p_sampler, p_triplanar_pos.xz) * p_weights.y;
	samp += texture(p_sampler, p_triplanar_pos.zy * vec2(-1.0, 1.0)) * p_weights.x;
	return samp;
}

uniform vec3 triplanar_scale = vec3(1.0, 1.0, 1.0);
uniform vec3 triplanar_offset;
uniform float triplanar_sharpness = 0.5;

varying vec3 triplanar_power_normal;
varying vec3 triplanar_pos;

varying vec3 object_normal;

void vertex() {
	
	object_normal = NORMAL;
	
	// TextureUniformTriplanar
	triplanar_power_normal = pow(abs(NORMAL), vec3(triplanar_sharpness));
	triplanar_power_normal /= dot(triplanar_power_normal, vec3(1.0));
	triplanar_pos = VERTEX * triplanar_scale + triplanar_offset;
	triplanar_pos *= vec3(1.0, -1.0, 1.0);
	triplanar_pos += NODE_POSITION_WORLD;
}

float motif_mask(float edge, float motif){
	float mask_neg = smoothstep(1.0, 0.5, edge);
	float result = (1.0 - (mask_neg * motif)) * edge;
	return smoothstep(0.2, 0.3, result);
}

void fragment() {
	vec3 bark_albedo = triplanar_texture(bark_albedo_sampler, triplanar_power_normal, triplanar_pos).rgb;
	float bark_roughness = triplanar_texture(bark_orm_sampler, triplanar_power_normal, triplanar_pos).x;
	vec3 bark_normal = triplanar_texture(bark_normal_sampler, triplanar_power_normal, triplanar_pos).rgb;
		
		
	vec3 trunk_top_albedo = triplanar_texture(trunk_top_albedo_sampler, triplanar_power_normal, triplanar_pos).rgb;
	float trunk_top_roughness = triplanar_texture(trunk_top_albedo_sampler, triplanar_power_normal, triplanar_pos).x;
	vec3 trunk_top_normal = triplanar_texture(trunk_top_normal_sampler, triplanar_power_normal, triplanar_pos).rgb;
	
	float bark_motif = triplanar_texture(bark_mask_sampler, triplanar_power_normal, triplanar_pos).x;

	float wall_edge = object_normal.y * 1.0;
	float wall_mask = motif_mask(wall_edge, bark_motif);
	
	ALBEDO = mix(bark_albedo, trunk_top_albedo, wall_mask);
	ROUGHNESS = mix(bark_roughness, trunk_top_roughness, wall_mask);
	NORMAL_MAP = mix(bark_normal, trunk_top_normal, wall_mask);
}
