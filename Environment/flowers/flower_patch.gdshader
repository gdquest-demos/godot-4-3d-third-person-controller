shader_type spatial;
render_mode cull_disabled;
uniform sampler2D flower_albedo_sampler : repeat_disable, source_color;
uniform sampler2D flower_normal_sampler : repeat_disable;

void vertex(){
	float Y = 1.0 - VERTEX.y;
	VERTEX.x += sin(NODE_POSITION_WORLD.x + TIME + Y) * ( 1.0 - Y) * 0.1;
	VERTEX.z += cos(NODE_POSITION_WORLD.z + TIME * 0.45 + Y) * ( 1.0 - Y) * 0.1;
}

void fragment() {
	vec4 albedo = texture(flower_albedo_sampler, UV);
	vec3 normal = texture(flower_normal_sampler, UV).rgb;
	ALBEDO = albedo.rgb;
	NORMAL_MAP = normal;
	ALPHA = albedo.a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}
