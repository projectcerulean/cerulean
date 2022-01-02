shader_type spatial;
render_mode unshaded, cull_disabled;

uniform vec4 color: hint_color;
uniform float noise_threshold = 0.55;

uniform float alpha_factor: hint_range(0.0, 1.0) = 1.0;
uniform float alpha_min: hint_range(0.0, 1.0) = 0.3;
uniform float alpha_max: hint_range(0.0, 1.0) = 0.6;

uniform sampler2D noise_sampler1;
uniform sampler2D noise_sampler2;
uniform vec2 noise_time_factor = vec2(0.1, 0.02);


void fragment() {
	// TODO: clean this up a bit
	vec3 noise_texture1 = texture(noise_sampler1, 0.5*(vec2(UV.x, 5.0*UV.y) + TIME * noise_time_factor.x)).rgb;
	vec3 noise_texture2 = texture(noise_sampler2, 5.0*(vec2(UV.x, 5.0*UV.y) - TIME * noise_time_factor.y)).rgb;
	float noise_sum = (noise_texture1.r + noise_texture2.r) / 2.0;
	if (noise_sum > noise_threshold) {
		ALPHA = alpha_min;
	}
	else {
		ALPHA = alpha_max;
	}
	ALPHA *= alpha_factor;

	ALBEDO = color.rgb + 0.025*vec3((pow(sin(2.5*UV.y + 0.5*TIME), 4.0)));

	SPECULAR = 1.0;
	METALLIC = 0.25;
	ROUGHNESS = 0.0;
}
