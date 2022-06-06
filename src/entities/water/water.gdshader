// This file is part of Project Cerulean <https://projectcerulean.org>
// Copyright (C) 2021-2022 Martin Gulliksson
// SPDX-License-Identifier: GPL-3.0-or-later

// Based on "Stylized WaterShader Tutorial" by Kmitt 91, https://www.youtube.com/watch?v=PgcMXPdQrLI
shader_type spatial;
render_mode unshaded, cull_disabled;

uniform int mesh_size_x = 64;
uniform int mesh_size_y = 64;
uniform vec4 water_color: source_color;
uniform vec4 water_color_highlight: source_color;
uniform float water_color_highlight_threshold = 0.55;

uniform vec4 foam_color: source_color;
uniform float foam_width = 0.2;
uniform float foam_smooth = 0.01;

uniform float beer_factor = 0.2;

uniform sampler2D noise_sampler1;
uniform sampler2D noise_sampler2;
uniform vec2 noise_time_factor = vec2(0.01, 0.002);

uniform int wave_periods_x = 4;
uniform int wave_periods_y = 4;
uniform vec2 wave_strengh = vec2(0.25, 0.125);
uniform vec2 wave_time_factor = vec2(0.5, 1.0);

varying mat4 camera;


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

	// Get water depth
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 world = camera * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	vec3 depth_world_position = world.xyz / world.w;
	vec3 vertex_world_position = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float depth_world = distance(depth_world_position, vertex_world_position);

	// Foam
	float foam_factor = 1.0 - smoothstep(foam_width - foam_smooth, foam_width + foam_smooth, depth_world);
	ALBEDO = foam_factor * foam_color.rgb + (1.0 - foam_factor) * ALBEDO;
	ALPHA = foam_factor * foam_color.a + (1.0 - foam_factor) * ALPHA;

	// Depth fade
	ALPHA = clamp(1.0 - exp(-depth_world * beer_factor), ALPHA, 1.0);

	SPECULAR = 1.0;
	METALLIC = 0.25;
	ROUGHNESS = 0.0;
}


void vertex() {
	float angular_velocity_x = float(wave_periods_x) * 2.0 * PI / float(mesh_size_x);
	float angular_velocity_y = float(wave_periods_y) * 2.0 * PI / float(mesh_size_y);
	VERTEX.y += wave_strengh.y * sin(VERTEX.y * angular_velocity_y + TIME * wave_time_factor.y) +
		wave_strengh.x * sin(VERTEX.x * angular_velocity_x + TIME * wave_time_factor.x);

	camera = INV_VIEW_MATRIX;
}
