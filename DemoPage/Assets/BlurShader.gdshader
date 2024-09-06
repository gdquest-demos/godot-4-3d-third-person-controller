shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float blur_size = 1.0;
uniform vec3 color_modulate: source_color = vec3(1.0);

void fragment() {
	const int SAMPLES = 9;
	const int SAMPLES_HALF = SAMPLES / 2;
	const float TOTAL_WEIGHT = 1.627038;
	const float WEIGHTS[8] = {
		0.05467,
		0.080657,
		0.106483,
		0.125794,
		0.132981,
		0.125794,
		0.106483,
		0.080657
	};

	vec2 scale = SCREEN_PIXEL_SIZE * blur_size;
	
	COLOR = vec4(0.0);

	vec2 blur_direction_1 = TEXTURE_PIXEL_SIZE * vec2(blur_size);
	vec2 blur_direction_2 = TEXTURE_PIXEL_SIZE * vec2(blur_size, -blur_size);

	for(int i = -SAMPLES_HALF; i < SAMPLES_HALF; ++i) {
		int w = i + SAMPLES_HALF;
		COLOR += texture(screen_texture, SCREEN_UV + blur_direction_1 * float(i) * scale) * WEIGHTS[w];
	}
	for(int i = -SAMPLES_HALF; i < SAMPLES_HALF; ++i) {
		int w = i + SAMPLES_HALF;
		COLOR += texture(screen_texture, SCREEN_UV + blur_direction_2 * float(i) * scale) * WEIGHTS[w];
	}

	COLOR /= TOTAL_WEIGHT;
	COLOR.rgb *= color_modulate;
}