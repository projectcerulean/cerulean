// Reference: https://www.youtube.com/watch?v=PgcMXPdQrLI
shader_type spatial;
render_mode unshaded, cull_disabled;

uniform int mesh_size_x = 64;
uniform int mesh_size_y = 64;
uniform vec4 water_color: hint_color;
uniform vec4 water_color_highlight: hint_color;
uniform float water_color_highlight_threshold = 0.55;

uniform sampler2D noise_sampler1;
uniform sampler2D noise_sampler2;
uniform vec2 noise_time_factor = vec2(0.01, 0.002);

uniform int wave_periods_x = 4;
uniform int wave_periods_y = 4;
uniform vec2 wave_strengh = vec2(0.25, 0.125);
uniform vec2 wave_time_factor = vec2(0.5, 1.0);


void fragment() {
	vec3 noise_texture1 = texture(noise_sampler1, UV + TIME * noise_time_factor.x).rgb;
	vec3 noise_texture2 = texture(noise_sampler2, UV - TIME * noise_time_factor.y).rgb;
	float noise_sum = (noise_texture1.r + noise_texture2.r) / 2.0;
	if (noise_sum > water_color_highlight_threshold) {
		ALBEDO = water_color_highlight.rgb;
		ALPHA = water_color_highlight.a;
	}
	else {
		ALBEDO = water_color.rgb;
		ALPHA = water_color.a;
	}

	SPECULAR = 1.0;
	METALLIC = 0.25;
	ROUGHNESS = 0.0;
}


void vertex() {
	float angular_velocity_x = float(wave_periods_x) * 2.0 * PI / float(mesh_size_x);
	float angular_velocity_y = float(wave_periods_y) * 2.0 * PI / float(mesh_size_y);
	VERTEX.y += wave_strengh.y * sin(VERTEX.y * angular_velocity_y + TIME * wave_time_factor.y) +
		wave_strengh.x * sin(VERTEX.x * angular_velocity_x + TIME * wave_time_factor.x);
}