shader_type spatial;
render_mode depth_draw_always;

uniform sampler2D main_noise_sampler : hint_normal;
uniform sampler2D caustic_sampler : hint_normal, filter_linear;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform vec3 water_color : source_color = vec3(1.0);
uniform vec3 water_depth_color : source_color = vec3(1.0);

uniform float water_edge_distance = 0.1;
uniform float water_depth_distance = 0.3;

uniform float water_texture_scale = 20.0;

varying vec2 base_offset;

float get_noise(vec2 offset){
	return texture(main_noise_sampler, offset).x;
}

void vertex(){
	base_offset = (UV * 0.5) + TIME * 0.01;
	float h = get_noise(base_offset);
	VERTEX.y += h;
	vec3 normal = normalize(vec3(
		h - get_noise(base_offset + vec2(0.8, 0.0)),
		8.0,
		h - get_noise(base_offset + vec2(0.0, 0.8))
	));
	NORMAL = normal;
}

float fresnel(vec3 normal, vec3 view, float power){
	return pow(1.0 - clamp(dot(normal, view), 0.0, 1.0), power);
}

void fragment() {
	
	float caustic_1 = texture(caustic_sampler, UV * water_texture_scale + TIME * 0.05).x;
	float final_caustic = caustic_1 * (1.0 - fresnel(NORMAL, VIEW, 1.0)) * 0.25;
	
	float depth_tex = textureLod(DEPTH_TEXTURE,SCREEN_UV,0.0).r;
	vec4 world_pos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV*2.0-1.0,depth_tex,1.0);
	world_pos.xyz /= world_pos.w;
	
	float water_edge = world_pos.z + water_edge_distance;
	float water_edge_mask = clamp(1.0 - smoothstep(water_edge, water_edge + (caustic_1 * 0.5), VERTEX.z),0.0,1.0);
	float water_depth_mask = clamp(1.0 - smoothstep(world_pos.z, world_pos.z + water_depth_distance, VERTEX.z),0.0,1.0);
	
	vec3 screen_texture = texture(SCREEN_TEXTURE, SCREEN_UV, 2.0).rgb;
	vec3 final_water_color = mix(water_color, screen_texture * water_depth_color, water_depth_mask * 0.75);
	
 	ROUGHNESS = 0.95;
	SPECULAR = 0.5;
	ALBEDO.rgb = final_water_color;
	ALBEDO += clamp(water_edge_mask + final_caustic, 0.0, 1.0);
	ALPHA *= smoothstep(0.5, 0.25, distance(UV, vec2(0.5)));
}
