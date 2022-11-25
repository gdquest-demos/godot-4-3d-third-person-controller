shader_type canvas_item;

uniform vec4 modulate: source_color;
uniform float blur_amount : hint_range(0, 5);

void fragment() {
	vec4 col = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_amount);
	COLOR = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_amount) * modulate;
}