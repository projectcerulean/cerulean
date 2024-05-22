// This file is part of Project Cerulean <https://projectcerulean.org>
// Copyright (C) 2021-2024 Martin Gulliksson
// SPDX-License-Identifier: GPL-3.0-or-later

// Based on "Stylized WaterShader Tutorial" by Kmitt 91, https://www.youtube.com/watch?v=PgcMXPdQrLI
shader_type spatial;
render_mode unshaded, cull_disabled, world_vertex_coords;

#include "res://src/common/shaderlib/math.gdshaderinc"

uniform vec4 water_color: source_color;
uniform vec4 water_color_highlight: source_color;
uniform float water_color_highlight_threshold = 0.55;

uniform vec4 foam_color: source_color;
uniform float foam_width = 0.2;
uniform float foam_smooth = 0.01;

uniform float beer_factor = 0.2;

uniform bool player_blob_shadow_enabled = false;
uniform vec3 blob_shadow_player_position = vec3(0.0);
uniform float blob_shadow_visual_change_min_distance = 0.0;
uniform float blob_shadow_visual_change_max_distance = 25.0;
uniform float blob_shadow_min_size = 0.125;
uniform float blob_shadow_max_size = 2.0;
uniform float blob_shadow_min_albedo_mix = 0.2;
uniform float blob_shadow_max_albedo_mix = 0.25;
uniform float blob_shadow_smooth_size_factor = 0.5;

uniform sampler2D noise_sampler1;
uniform sampler2D noise_sampler2;
uniform vec2 noise_time_factor = vec2(0.01, 0.002);

uniform float wave_time = 0.0;

uniform vec2 wave_period = vec2(16.0, 16.0);
uniform vec2 wave_strength = vec2(0.25, 0.125);
uniform vec2 wave_time_factor = vec2(0.5, 1.0);

uniform sampler2D displacement_noise;
uniform float displacement_amount = 0.01;
uniform float displacement_time_factor = 0.015;

uniform sampler2D depth_texture : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;


float calculate_depth(vec2 screen_uv, vec3 vertex, mat4 inv_projection_matrix, mat4 inv_view_matrix) {
	float depth = texture(depth_texture, screen_uv).x;
	vec3 ndc = vec3(screen_uv * 2.0 - 1.0, depth);
	vec4 world = inv_view_matrix * inv_projection_matrix * vec4(ndc, 1.0);
	vec3 depth_world_position = world.xyz / world.w;
	vec3 vertex_world_position = (inv_view_matrix * vec4(vertex, 1.0)).xyz;
	vec3 camera_position = inv_view_matrix[3].xyz;
	return distance(depth_world_position, camera_position) - distance(vertex_world_position, camera_position);
}


void fragment() {
	vec3 noise_texture1 = texture(noise_sampler1, UV + TIME * noise_time_factor.x).rgb;
	vec3 noise_texture2 = texture(noise_sampler2, UV - TIME * noise_time_factor.y).rgb;
	float noise_sum = (noise_texture1.r + noise_texture2.r) / 2.0;
	vec4 color = (noise_sum > water_color_highlight_threshold) ? water_color_highlight : water_color;

	// Displacement
	float displacement1 = ((texture(displacement_noise, UV + vec2(0.0, TIME * displacement_time_factor)).rg - 0.5) * 2.0).r;
	float displacement2 = ((texture(displacement_noise, UV + vec2(TIME * displacement_time_factor), 0.0).rg - 0.5) * 2.0).r;
	vec2 displacement = vec2(displacement1, displacement2) * displacement_amount;

	// Get water depth
	float depth = calculate_depth(SCREEN_UV + displacement, VERTEX, INV_PROJECTION_MATRIX, INV_VIEW_MATRIX);

	if (depth < 0.0) {
		// Undo the displacement, don't want to grab pixels from objects which are above the water.
		displacement = vec2(0.0);
		depth = calculate_depth(SCREEN_UV + displacement, VERTEX, INV_PROJECTION_MATRIX, INV_VIEW_MATRIX);
	}

	// Depth fade
	color.a = clamp(1.0 - exp(-depth * beer_factor), color.a, 1.0);

	// Foam
	float foam_depth = calculate_depth(SCREEN_UV, VERTEX, INV_PROJECTION_MATRIX, INV_VIEW_MATRIX);
	if (foam_depth > 0.0) {
		float foam_factor = 1.0 - smoothstep(foam_width - foam_smooth, foam_width + foam_smooth, foam_depth);
		color = foam_factor * foam_color + (1.0 - foam_factor) * color;
	}

	// Player blob shadow
	if (player_blob_shadow_enabled) {
		vec3 vertex_world_position = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
		float player_distance = blob_shadow_player_position.y - vertex_world_position.y;
		if (player_distance > 0.0) {
			vec2 vertex_world_position_planar = vec2(vertex_world_position.x, vertex_world_position.z);
			vec2 player_position_planar = vec2(blob_shadow_player_position.x, blob_shadow_player_position.z);

			float shadow_size = clamp(
				remap(
					player_distance,
					blob_shadow_visual_change_min_distance,
					blob_shadow_visual_change_max_distance,
					blob_shadow_min_size,
					blob_shadow_max_size
				),
				blob_shadow_min_size,
				blob_shadow_max_size
			);

			float albedo_mix = clamp(
				remap(
					player_distance,
					blob_shadow_visual_change_min_distance,
					blob_shadow_visual_change_max_distance,
					blob_shadow_max_albedo_mix,
					blob_shadow_min_albedo_mix
				),
				blob_shadow_min_albedo_mix,
				blob_shadow_max_albedo_mix
			);

			float planar_distance = distance(vertex_world_position_planar, player_position_planar);

			vec3 color_new = mix(
				color.rgb,
				vec3(0.0),
				albedo_mix * (1.0 - smoothstep(
					shadow_size - blob_shadow_smooth_size_factor * shadow_size,
					shadow_size + blob_shadow_smooth_size_factor * shadow_size,
					planar_distance
				))
			);
			color = vec4(color_new, color.a);
		}
	}

	ALBEDO = mix(texture(screen_texture, SCREEN_UV + displacement).rgb, color.rgb, color.a);
	SPECULAR = 1.0;
	METALLIC = 0.25;
	ROUGHNESS = 0.0;
}


void vertex() {
	VERTEX.y += wave_strength.x * sin(VERTEX.x * TAU / wave_period.x + wave_time * wave_time_factor.x) +
		wave_strength.y * sin(VERTEX.z * TAU / wave_period.y + wave_time * wave_time_factor.y);
}
