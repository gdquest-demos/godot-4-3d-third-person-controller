shader_type sky;

uniform sampler2D clouds_sampler : filter_linear_mipmap;
uniform vec3 top_color : source_color = vec3(1.0);
uniform vec3 bottom_color : source_color = vec3(1.0);
const float sun_radius = 0.08;
uniform vec3 sun_scatter : source_color = vec3(1.0);
uniform float star_stength : hint_range(0.0, 5.0, 0.1) = 0.0;

// Voronoi method credit:
// The MIT License
// Copyright © 2013 Inigo Quilez
// https://www.shadertoy.com/view/ldl3Dl

vec3 hash( vec3 x ){
	x = vec3( dot(x,vec3(127.1,311.7, 74.7)),
			  dot(x,vec3(269.5,183.3,246.1)),
			  dot(x,vec3(113.5,271.9,124.6)));
	return fract(sin(x)*43758.5453123);
}

vec3 voronoi( in vec3 x ){
	vec3 p = floor( x );
	vec3 f = fract( x );
	
	float id = 0.0;
	vec2 res = vec2( 100.0 );
	for( int k=-1; k<=1; k++ )
	for( int j=-1; j<=1; j++ )
	for( int i=-1; i<=1; i++ ) {
		vec3 b = vec3( float(i), float(j), float(k) );
		vec3 r = vec3( b ) - f + hash( p + b );
		float d = dot( r, r );
		if( d < res.x ) {
			id = dot( p+b, vec3(1.0,57.0,113.0 ) );
			res = vec2( d, res.x );
		} else if( d < res.y ) {
			res.y = d;
		}
    }
    return vec3( sqrt( res ), abs(id) );
}

void sky() {
	float clamped_light_y = clamp(LIGHT0_DIRECTION.y, 0.0, 1.0);
	vec3 sky_gradient = mix(bottom_color.rgb, top_color.rgb, clamp(EYEDIR.y, 0.0, 1.0));
	float sun_position = distance(EYEDIR.xyz, LIGHT0_DIRECTION);
	float sun_mask_edge = smoothstep(sun_radius, sun_radius * 0.9, sun_position) * 0.2;
	float sun_mask = smoothstep(sun_radius * 0.7, sun_radius * 0.65, sun_position) * 0.8;
	float sun_color = (sun_mask_edge + sun_mask) * LIGHT0_ENERGY;
	float horizon_mask = abs(EYEDIR.y * 1.0);
	vec3 sunset_color = sun_scatter * (1.0 - horizon_mask);
	COLOR = sky_gradient + sunset_color + (sun_color * clamp(EYEDIR.y * 4.0, 0.0, 1.0));
	// Stars
	if(star_stength > 0.0){
		vec2 stars = voronoi(EYEDIR * 25.0).xz;
		COLOR.rgb += smoothstep(0.025 + ((1.0 + sin(TIME + stars.y)) / 2.0) * 0.05, 0.0, stars.x) * star_stength;
	}
	// Clouds
	vec2 cloud_uv = EYEDIR.xz / EYEDIR.y;
	float cloud_mask = texture(clouds_sampler, cloud_uv * 0.05 + TIME * 0.001).x;
	cloud_mask *= step(SKY_COORDS.y, 0.5);

	COLOR.rgb = mix(
		COLOR.rgb,
		vec3(1.0),
		smoothstep(0.75, 0.85, cloud_mask)
	);
}
