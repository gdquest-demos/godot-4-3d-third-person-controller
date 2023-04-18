shader_type spatial;

uniform sampler2D face_texture : filter_nearest, repeat_disable;
uniform float intensity = 1.5;
uniform vec4 screen_color : source_color = vec4(1.0);

uniform vec2 screen_red_offset = vec2(0.0);
uniform vec2 screen_green_offset = vec2(0.0);
uniform vec2 screen_blue_offset = vec2(0.0);

uniform float pixel_size = 20.0;

void fragment() {
	
	vec2 scaled_uv = round(UV * pixel_size) / pixel_size;
	
	float face_red = 1.0 - texture(face_texture, screen_red_offset + scaled_uv).x;
	float face_green = 1.0 - texture(face_texture, screen_green_offset +  scaled_uv).x;
	float face_blue = 1.0 - texture(face_texture, screen_blue_offset + scaled_uv).x;
	
	vec2 grid_2d = sin(fract(UV * pixel_size + 0.5) * 3.14);
	float grid = grid_2d.x * grid_2d.y;
	grid = grid * 0.6 + 0.4;
	
	ALBEDO = vec3(0.0);
	SPECULAR = 0.25;
	ROUGHNESS = 0.45;
	
	vec3 iris = vec3(0.0);
	
	iris.r = ((screen_color.r * face_red) / 3.0);
	iris.g = ((screen_color.g * face_green)  / 3.0);
	iris.b = ((screen_color.b * face_blue)  / 3.0);
	iris.rgb *= 1.0 - screen_color.a;
	
	vec3 fill = screen_color.rgb * screen_color.a;
	
	EMISSION = (iris + fill) * grid * intensity;
	
}
