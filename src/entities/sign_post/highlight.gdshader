shader_type spatial;
render_mode unshaded, cull_front;

uniform vec4 albedo: hint_color = vec4(1.0);
uniform float grow = 0.05;


void vertex() {
	VERTEX += NORMAL * grow;
}


void fragment() {
	ALBEDO = albedo.rgb;
}
