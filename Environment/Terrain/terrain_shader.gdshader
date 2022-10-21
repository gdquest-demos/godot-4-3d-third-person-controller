shader_type spatial;

uniform sampler2D wall_mask_sampler : source_color;

uniform sampler2D cliff_albedo_sampler : source_color;
uniform sampler2D grass_albedo_sampler : source_color;
uniform sampler2D dirt_albedo_sampler : source_color;

uniform sampler2D cliff_orm_sampler;
uniform sampler2D grass_orm_sampler;
uniform sampler2D dirt_orm_sampler;

uniform sampler2D cliff_normal_sampler : hint_normal;
uniform sampler2D grass_normal_sampler : hint_normal;
uniform sampler2D dirt_normal_sampler : hint_normal;

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
}

float motif_mask(float edge, float motif){
	float mask_neg = smoothstep(1.0, 0.5, edge);
	float result = (1.0 - (mask_neg * motif)) * edge;
	return smoothstep(0.2, 0.8, result);
}

void fragment(){
	vec3 cliff_albedo = triplanar_texture(cliff_albedo_sampler, triplanar_power_normal, triplanar_pos).rgb;
	vec3 grass_albedo = triplanar_texture(grass_albedo_sampler, triplanar_power_normal, triplanar_pos).rgb;
	vec3 dirt_albedo = triplanar_texture(dirt_albedo_sampler, triplanar_power_normal, triplanar_pos).rgb;
	
	float cliff_roughness = triplanar_texture(cliff_orm_sampler, triplanar_power_normal, triplanar_pos).g;
	float grass_roughnes = triplanar_texture(grass_orm_sampler, triplanar_power_normal, triplanar_pos).g;
	float dirt_roughnes = triplanar_texture(dirt_orm_sampler, triplanar_power_normal, triplanar_pos).g;
	
	vec3 cliff_normal = triplanar_texture(cliff_normal_sampler, triplanar_power_normal, triplanar_pos).rgb;
	vec3 grass_normal = triplanar_texture(grass_normal_sampler, triplanar_power_normal, triplanar_pos).rgb;
	vec3 dirt_normal = triplanar_texture(dirt_normal_sampler, triplanar_power_normal, triplanar_pos).rgb;
	
	float wall_motif = triplanar_texture(wall_mask_sampler, triplanar_power_normal, triplanar_pos).x;
	
	float wall_edge = object_normal.y * 1.5;
	float wall_mask = motif_mask(wall_edge, wall_motif);
	
	float path_edge = COLOR.x;
	float path_mask = motif_mask(path_edge, grass_roughnes);
	
	vec3 ground_albedo = mix(grass_albedo, dirt_albedo, path_mask);
	float ground_roughness = mix(grass_roughnes, dirt_roughnes, path_mask);
	vec3 ground_normal = mix(grass_normal, dirt_normal, path_mask);
	
	ALBEDO = mix(cliff_albedo, ground_albedo, wall_mask);
	ROUGHNESS = mix(cliff_roughness, ground_roughness, wall_mask);
	NORMAL_MAP = mix(cliff_normal, ground_normal, wall_mask);
	
}