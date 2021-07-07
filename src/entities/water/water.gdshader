// Reference: https://www.youtube.com/watch?v=PgcMXPdQrLI
shader_type spatial;
render_mode unshaded, cull_disabled;

uniform vec4 water_color: hint_color;
uniform float water_color_boost_threshold = 0.45;
uniform float water_color_boost_amount = 0.1;

uniform sampler2D noise_sampler1;
uniform sampler2D noise_sampler2;
uniform vec2 noise_time_factor = vec2(0.01, 0.002);

uniform vec2 wave_strengh = vec2(0.25, 0.125);
uniform vec2 wave_frequency = vec2(6.0, 6.0);
uniform vec2 wave_time_factor = vec2(0.5, 1.0);


void fragment() {
	vec3 noise_texture1 = texture(noise_sampler1, UV + TIME * noise_time_factor.x).rgb;
	vec3 noise_texture2 = texture(noise_sampler2, UV - TIME * noise_time_factor.y).rgb;
	float noise_sum = (noise_texture1.r + noise_texture2.r) / 2.0;
	float color_boost = (noise_sum < water_color_boost_threshold) ? water_color_boost_amount : 0.0;

	ALBEDO = water_color.rgb + color_boost;
	ALPHA = water_color.a;
	SPECULAR = 1.0;
	METALLIC = 0.25;
	ROUGHNESS = 0.0;
}


void vertex() {
	VERTEX.y += wave_strengh.y * sin(VERTEX.y * wave_frequency.y + TIME * wave_time_factor.y) +
		wave_strengh.x * sin(VERTEX.x * wave_frequency.x + TIME * wave_time_factor.x);
}