shader_type spatial;

uniform vec3 shallow_color : source_color;
uniform vec3 deep_color : source_color;
uniform vec3 foam_color : source_color;
uniform float water_scale = 1.0;
uniform float time_scale = 100.0;
uniform sampler2D noise_sampler : hint_normal;
uniform sampler2D small_waves_sampler : hint_normal;

uniform sampler2D foam_noise : hint_normal;


float fresnel(vec3 normal, vec3 view, float intensity){
	return pow(1.0 - clamp(dot(normal, view), 0.0, 1.0), intensity);
}

void fragment() {
	// Linear Depth
	
	vec2 scaled_uv = UV * water_scale;
	float scaled_time = TIME / time_scale;
	
	
	float _log_depth = textureLod(DEPTH_TEXTURE, SCREEN_UV, 0.0).x;
	vec3 _depth_ndc = vec3(SCREEN_UV * 2.0 - 1.0, _log_depth);
	vec4 _depth_view = INV_PROJECTION_MATRIX * vec4(_depth_ndc, 1.0);
	_depth_view.xyz /= _depth_view.w;
	float linear_depth = -_depth_view.z;
	
	float depth = VERTEX.z + linear_depth;
 	depth *= 0.2;
	depth = clamp(depth, 0.0, 1.0);
	
	float foam_n = texture(foam_noise, scaled_uv + scaled_time).x;
	
	float foam_mask = smoothstep(0.0, 0.5 * foam_n, depth);
	
	vec3 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	
	vec3 screen_color_depth = mix(screen_color * shallow_color, deep_color, depth);
	
	vec3 water_color = mix(screen_color_depth, deep_color, fresnel(NORMAL, VIEW, 2.0));
	
	ALBEDO = mix(foam_color, water_color, foam_mask);
	ROUGHNESS = 0.02;
	SPECULAR = 1.0;
	
	
	vec3 normal_map = texture(noise_sampler, scaled_uv + scaled_time).rgb;
	vec3 small_waves = texture(small_waves_sampler, scaled_uv - scaled_time).rgb;
	
	NORMAL_MAP = mix(normal_map, small_waves, 0.5);
	NORMAL_MAP_DEPTH = 0.25;
}
