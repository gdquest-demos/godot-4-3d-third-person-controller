shader_type spatial;
render_mode ambient_light_disabled;

uniform sampler2D target_mask_sampler : source_color, repeat_disable, filter_linear_mipmap_anisotropic;
uniform sampler2D target_frame_mask_sampler : source_color, repeat_disable;
uniform vec3 fill_color : source_color = vec3(1.0);

vec2 rotateUV(vec2 uv, float rotation)
{
    float mid = 0.5;
    return vec2(
        cos(rotation) * (uv.x - mid) + sin(rotation) * (uv.y - mid) + mid,
        cos(rotation) * (uv.y - mid) - sin(rotation) * (uv.x - mid) + mid
    );
}

void fragment() {
	float dist = 1.0 - distance(vec2(0.5, 0.5), UV);
	ALBEDO = fill_color;
	EMISSION = fill_color * 1.0;
	float circle = texture(target_mask_sampler, rotateUV(UV, mod(TIME, PI))).x;
	float frame = texture(target_frame_mask_sampler, UV).x;
	ALPHA = circle + frame;
	ALPHA += (1.0 + sin((dist * 15.0) + TIME)) / 2.0  * smoothstep(0.5,1.0, dist) * 0.1;
	ALPHA = clamp(ALPHA, 0.0, 1.0);
}