shader_type spatial;

group_uniforms Textures;

uniform sampler2D grass_patch_pattern_sampler : filter_linear_mipmap, repeat_enable;


uniform sampler2D wall_mask_sampler : filter_linear_mipmap, source_color, repeat_enable;

uniform sampler2D cliff_albedo_sampler : filter_linear_mipmap, source_color, repeat_enable;
uniform sampler2D grass_albedo_sampler : filter_linear_mipmap, source_color, repeat_enable;
uniform sampler2D dirt_albedo_sampler : filter_linear_mipmap, source_color, repeat_enable;

uniform sampler2D cliff_orm_sampler : filter_linear_mipmap, hint_roughness_g, repeat_enable;
uniform sampler2D grass_orm_sampler : filter_linear_mipmap, hint_roughness_g, repeat_enable;
uniform sampler2D dirt_orm_sampler : filter_linear_mipmap, hint_roughness_g, repeat_enable;

uniform sampler2D cliff_normal_sampler : filter_linear_mipmap, hint_normal, repeat_enable;
uniform sampler2D grass_normal_sampler : filter_linear_mipmap, hint_normal, repeat_enable;
uniform sampler2D dirt_normal_sampler : filter_linear_mipmap, hint_normal, repeat_enable;

uniform float wall_edge_offset = 1.0;
uniform float cliff_scale = 1.0;

group_uniforms Triplanar;

uniform vec3 triplanar_scale = vec3(1.0, 1.0, 1.0);
uniform vec3 triplanar_offset = vec3(0.0);
uniform float triplanar_sharpness = 0.5;

varying vec3 triplanar_power_normal;
varying vec3 triplanar_pos;

varying vec3 object_normal;

// TextureUniformTriplanar
vec4 triplanar_texture(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos) {
	vec4 samp = vec4(0.0);
	samp += texture(p_sampler, p_triplanar_pos.xy) * p_weights.z;
	samp += texture(p_sampler, p_triplanar_pos.xz) * p_weights.y;
	samp += texture(p_sampler, p_triplanar_pos.zy * vec2(-1.0, 1.0)) * p_weights.x;
	return samp;
}

void vertex() {
	
	TANGENT = vec3(0.0,0.0,-1.0) * abs(NORMAL.x);
	TANGENT+= vec3(1.0,0.0,0.0) * abs(NORMAL.y);
	TANGENT+= vec3(1.0,0.0,0.0) * abs(NORMAL.z);
	TANGENT = normalize(TANGENT);
	BINORMAL = vec3(0.0,1.0,0.0) * abs(NORMAL.x);
	BINORMAL+= vec3(0.0,0.0,-1.0) * abs(NORMAL.y);
	BINORMAL+= vec3(0.0,1.0,0.0) * abs(NORMAL.z);
	BINORMAL = normalize(BINORMAL);
	
	object_normal = NORMAL;
	
	// TextureUniformTriplanar
	triplanar_power_normal = pow(abs(NORMAL), vec3(triplanar_sharpness));
	triplanar_power_normal /= dot(triplanar_power_normal, vec3(1.0));
	triplanar_pos = VERTEX * triplanar_scale + triplanar_offset;
	triplanar_pos *= vec3(1.0, -1.0, 1.0);
}

float motif_mask(float edge, float motif){
	float mask_neg = smoothstep(1.0, 0.5, edge);
	float result = (1.0 - (mask_neg * motif)) * edge;
	return smoothstep(0.2, 0.8, result);
}

void fragment(){
	vec3 cliff_albedo = triplanar_texture(cliff_albedo_sampler, triplanar_power_normal, triplanar_pos * cliff_scale).rgb;
	vec3 grass_albedo = triplanar_texture(grass_albedo_sampler, triplanar_power_normal, triplanar_pos).rgb;
	vec3 dirt_albedo = triplanar_texture(dirt_albedo_sampler, triplanar_power_normal, triplanar_pos).rgb;
	
	float cliff_roughness = triplanar_texture(cliff_orm_sampler, triplanar_power_normal, triplanar_pos * cliff_scale).g;
	float grass_roughnes = triplanar_texture(grass_orm_sampler, triplanar_power_normal, triplanar_pos).g;
	float dirt_roughnes = triplanar_texture(dirt_orm_sampler, triplanar_power_normal, triplanar_pos).g;
	
	vec3 cliff_normal = triplanar_texture(cliff_normal_sampler, triplanar_power_normal, triplanar_pos * cliff_scale).rgb;
	vec3 grass_normal = triplanar_texture(grass_normal_sampler, triplanar_power_normal, triplanar_pos).rgb;
	vec3 dirt_normal = triplanar_texture(dirt_normal_sampler, triplanar_power_normal, triplanar_pos).rgb;
	
	float wall_motif = triplanar_texture(wall_mask_sampler, triplanar_power_normal, triplanar_pos * cliff_scale).x;
	
	float wall_edge = object_normal.y * wall_edge_offset;
	float wall_mask = motif_mask(wall_edge, wall_motif);
	
	float path_edge = COLOR.x;
	float path_mask = motif_mask(path_edge + 0.5, grass_roughnes * 2.0);
	
	float grass_mix_noise_edge = triplanar_texture(grass_patch_pattern_sampler, triplanar_power_normal, triplanar_pos * 0.05).x;
	float grass_mix_mask = motif_mask(smoothstep(0.5, 0.6, grass_mix_noise_edge), grass_roughnes);
	
	vec3 grass_mixed_albedo = 
	mix(grass_albedo * vec3(0.85),
	grass_albedo * vec3(0.5),
	grass_mix_mask);
	
	vec3 ground_albedo = mix(grass_mixed_albedo, dirt_albedo, path_mask);
	float ground_roughness = mix(grass_roughnes, dirt_roughnes, path_mask);
	vec3 ground_normal = mix(grass_normal, dirt_normal, path_mask);
	
	ALBEDO = mix(cliff_albedo, ground_albedo, wall_mask);
	ROUGHNESS = mix(cliff_roughness, ground_roughness, wall_mask);
	NORMAL_MAP = mix(cliff_normal, ground_normal, wall_mask);
}