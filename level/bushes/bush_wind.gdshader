shader_type spatial;
render_mode cull_disabled;
uniform sampler2D wind_noise_sampler;

uniform sampler2D albedo_sampler : source_color;
uniform sampler2D orm_sampler;
uniform sampler2D normal_sampler;

void vertex() {
	float wind_value = texture(wind_noise_sampler, (UV.y) + VERTEX.y + NODE_POSITION_WORLD.xz + vec2(0.0, (TIME * 0.2))).x;
	VERTEX.xz += (wind_value) * 0.05 * UV.y;
}

void fragment() {
	vec4 albedo = texture(albedo_sampler, UV);
	vec3 orm = texture(orm_sampler, UV).rgb;
	vec3 normal_map = texture(normal_sampler, UV).rgb;
	
	ALBEDO = albedo.rgb * orm.r;
	ROUGHNESS = orm.g;
	NORMAL_MAP = normal_map;
	ALPHA = albedo.a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}
