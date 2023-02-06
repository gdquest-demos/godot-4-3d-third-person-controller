shader_type spatial;

uniform sampler2D voronoi_sampler;
uniform vec3 water_color_top : source_color;
uniform vec3 water_color_bottom : source_color;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void vertex(){
	float voronoi = 1.0 - texture(voronoi_sampler, UV + vec2(TIME * 0.1, TIME)).x;
	VERTEX += NORMAL * voronoi * (1.0 - UV.y);
}

void fragment() {
	float voronoi = texture(voronoi_sampler, (UV * vec2(4.0, 1.0) * 0.5) + vec2(TIME * 0.1, TIME)).x;
	
	float water_edge = 1.0 - smoothstep(0.84, 0.86, voronoi + UV.y);
	ALBEDO = mix(mix(water_color_bottom , water_color_top, UV.y), vec3(1.0), water_edge);
	// ALBEDO *= texture(SCREEN_TEXTURE, SCREEN_UV, 2.0).rgb;
	// ALPHA = smoothstep(0.6, 0.65, voronoi + UV.y);
	// ALPHA_SCISSOR_THRESHOLD = 0.5;
	NORMAL_MAP = normalize(vec3(0.5, voronoi, 0.5));
	NORMAL_MAP_DEPTH = 0.5;
	ROUGHNESS = 0.05;

}
