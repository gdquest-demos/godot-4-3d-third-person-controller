shader_type spatial;
render_mode cull_disabled;

uniform sampler2D grass_mask_sampler : repeat_disable;
uniform sampler2D gradient : source_color;

void vertex(){
	NORMAL = vec3(0.0, 1.0, 0.0);
	VERTEX.x += sin(NODE_POSITION_WORLD.x + TIME + UV.y) * ( 1.0 - UV.y) * 0.1;
	VERTEX.z += cos(NODE_POSITION_WORLD.z + TIME * 0.45 + UV.y) * ( 1.0 - UV.y) * 0.1;
}

void fragment() {
	float mask = texture(grass_mask_sampler, UV).x;
	vec3 gradient_color = texture(gradient, vec2(UV.y, UV.x)).rgb;
	ALBEDO = gradient_color;
	// ALPHA = mask;
	// ALPHA_SCISSOR_THRESHOLD = 0.5;
	NORMAL = NORMAL * (float(FRONT_FACING) * 2.0 - 1.0);
}
 