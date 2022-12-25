shader_type spatial;
render_mode ambient_light_disabled, cull_disabled;

uniform sampler2D arrow_sampler : source_color;
uniform vec3 fill_color : source_color = vec3(1.0);
uniform float arrow_scale = 1.0;

void fragment() {
	float y_ease = sin(UV.x * PI);
	float arrow_time = mod(TIME, 1.0);
	float band_time = mod(TIME * 0.2, 1.0);
	
	float arrows = y_ease * texture(arrow_sampler, UV * vec2(arrow_scale, 1.0) - vec2(arrow_time, 0.0)).x;
	float band_ease = y_ease * sin(UV.y * PI);
	float stripes = (1.0 + sin((UV.x * 6.0 - band_time) * TAU)) / 2.0 * 0.1 + 0.4;

	ALBEDO = fill_color;
	EMISSION = fill_color + arrows * fill_color * 5.0;
	ALPHA = clamp(band_ease * stripes + arrows, 0.0, 1.0);
}

