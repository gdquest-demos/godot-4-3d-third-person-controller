shader_type spatial;
render_mode cull_disabled;

uniform float intensity;
uniform vec4 shell_color : source_color;
uniform sampler2D voronoi_sampler;
uniform float edge = 0.05;
uniform float progress : hint_range(0.0, 1.0, 0.01) = 0.5;
void fragment() {
	float voronoi = texture(voronoi_sampler, UV * vec2(1.0, 0.6) + TIME * 0.06).x;
	float mask = smoothstep(progress - edge, progress + edge, voronoi);
	ALPHA = mask * shell_color.a;
	ALBEDO = shell_color.rgb;
	EMISSION = shell_color.rgb * intensity;
}
