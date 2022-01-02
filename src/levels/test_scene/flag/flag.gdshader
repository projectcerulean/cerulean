// Reference: https://www.youtube.com/watch?v=sxdBwv384Ic
shader_type spatial;
render_mode cull_disabled;

uniform sampler2D uv_offset_texture : hint_black;
uniform vec2 uv_offset_scale = vec2(-0.2, -0.1);
uniform float vertex_offset_scale = 2.0;
uniform vec2 time_scale = vec2(0.25, 0.0);
uniform float face_distortion = 1.0;
uniform float curvature = 5.0;
uniform vec4 albedo : hint_color;

void vertex() {
	vec2 base_uv_offset = UV * uv_offset_scale;
	base_uv_offset += TIME * time_scale;
	float noise = texture(uv_offset_texture, base_uv_offset).r;
	float texture_based_offset = noise * 2.0 - 1.0;
	texture_based_offset *= UV.x;

	VERTEX.y += texture_based_offset * vertex_offset_scale;
	VERTEX.x += texture_based_offset * face_distortion;
	VERTEX.z -= texture_based_offset * face_distortion - pow(UV.x, noise * curvature);
}

void fragment() {
	ALBEDO = albedo.rgb;
}