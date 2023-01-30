shader_type canvas_item;

uniform vec4 modulate: source_color;
uniform float blur_amount : hint_range(0, 5);

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

void fragment() {
	vec4 col = textureLod(screen_texture, SCREEN_UV, blur_amount);
	COLOR = textureLod(screen_texture, SCREEN_UV, blur_amount) * modulate;
}