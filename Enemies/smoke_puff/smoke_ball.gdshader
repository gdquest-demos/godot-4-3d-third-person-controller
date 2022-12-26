shader_type spatial;
render_mode shadows_disabled, cull_disabled;
uniform sampler2D voronoi_sampler;
varying float voronoi;

uniform float progress = 0.0;
uniform float smoothness = 0.01;

uniform float ease = 2.0;
uniform float base_scale = 1.0;
uniform float deformation_scale = 1.0;

uniform float texture_offset = 0.0;

void vertex() {
	float smooth_df = deformation_scale * (1.0 - distance(UV, vec2(0.5)) * 2.0);
	voronoi = texture(voronoi_sampler, UV + vec2(0.0, texture_offset)).x;
	VERTEX += NORMAL * (1.0 - pow(voronoi, ease)) * smooth_df;
	VERTEX *= base_scale;
}

void fragment(){
	ALPHA = smoothstep(progress - smoothness, progress + smoothness, voronoi);
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}
