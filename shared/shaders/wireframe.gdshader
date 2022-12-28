shader_type spatial;

uniform float wire_width : hint_range(0.0, 40.0) = 5.0;
uniform float wire_smoothness : hint_range(0.0, 0.1) = 0.01;
uniform bool flat_shading = true;

varying vec3 barys;

void vertex() {
    int index = VERTEX_ID % 3;
    switch (index) {
        case 0:
            barys = vec3(1.0, 0.0, 0.0);
            break;
        case 1:
            barys = vec3(0.0, 1.0, 0.0);
            break;
        case 2:
            barys = vec3(0.0, 0.0, 1.0);
            break;
    }
}

void fragment() {
    if (flat_shading)
        NORMAL = normalize(cross(dFdy(VERTEX), dFdx(VERTEX)));
    vec3 deltas = fwidth(barys);
    vec3 barys_s = smoothstep(deltas * wire_width - wire_smoothness, deltas * wire_width + wire_smoothness, barys);
    float min_bary = min(barys_s.x, min(barys_s.y, barys_s.z));
    ALBEDO = vec3(min_bary);
}