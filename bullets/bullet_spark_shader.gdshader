shader_type spatial;
render_mode unshaded;

uniform sampler2D sparks_sampler;

varying float rand_id;
varying float lifetime;
varying vec3 particle_color;

// Random function from : Patricio Gonzalez Vivo
// https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
float randF(float n){return fract(sin(n) * 43758.5453123);}


void vertex(){
	rand_id = randF(float(INSTANCE_ID));
	particle_color = COLOR.rgb;
	lifetime = COLOR.a;
}

void fragment() {
	// Place fragment code here.
	float frame_index = round(mod(rand_id + TIME * 8.0, 1.0)) / 2.0;
	float mask = texture(sparks_sampler, UV * vec2(0.5, 1.0) + vec2(frame_index, 1.0)).x;
	ALPHA = mask * lifetime;
	// ALPHA_SCISSOR_THRESHOLD = 0.5;
	ALBEDO = particle_color;
	EMISSION = particle_color * 1.0;
}
