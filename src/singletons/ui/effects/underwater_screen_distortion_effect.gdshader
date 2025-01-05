// This file is part of Project Cerulean <https://projectcerulean.org>
// Copyright (C) 2021-2025 Martin Gulliksson
// SPDX-License-Identifier: GPL-3.0-or-later
shader_type canvas_item;

#include "res://src/common/shaderlib/math.gdshaderinc"
#include "res://src/common/shaderlib/water_waves.gdshaderinc"

uniform vec4 color : source_color = vec4(0.0);
uniform float distortion_scale = 0.5;
uniform float distortion_intensity = 0.01;
uniform float distortion_speed = 0.05;
uniform sampler2D noise;

uniform float wave_time = 0.0;

uniform vec2 wave_period = vec2(16.0, 16.0);
uniform vec2 wave_strength = vec2(0.25, 0.125);
uniform vec2 wave_time_factor = vec2(0.5, 1.0);

uniform float camera_water_volume_height = 0.0;

uniform vec3 top_left_near_plane_vertex = vec3(0.0);
uniform vec3 top_right_near_plane_vertex = vec3(0.0);
uniform vec3 bottom_right_near_plane_vertex = vec3(0.0);
uniform vec3 bottom_left_near_plane_vertex = vec3(0.0);

uniform vec2 water_mesh_face_size = vec2(0.0);

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;


void fragment() {
	vec3 top_edge_position = mix(top_left_near_plane_vertex, top_right_near_plane_vertex, UV.x);
	vec3 bottom_edge_position = mix(bottom_left_near_plane_vertex, bottom_right_near_plane_vertex, UV.x);
	vec3 pixel_world_position = mix(top_edge_position, bottom_edge_position, UV.y);

	// Here, we want to determine whether the current fragment is below or above the water surface
	// mesh. Since the water surface mesh consists of discrete points and faces, it does not
	// perfectly follow the value returned by calculate_water_wave_haight(). Instead, it's slightly
	// jagged, forcing us to jump through some hoops in order to get the result.
	vec2 water_vertex_world_position_xz_1 = vec2(
		snapped(pixel_world_position.x - 0.5 * water_mesh_face_size.x, water_mesh_face_size.x),
		snapped(pixel_world_position.z - 0.5 * water_mesh_face_size.y, water_mesh_face_size.y)
	);
	vec2 water_vertex_world_position_xz_2 = water_vertex_world_position_xz_1 + vec2(water_mesh_face_size.x, 0.0);
	vec2 water_vertex_world_position_xz_3 = water_vertex_world_position_xz_1 + vec2(0.0, water_mesh_face_size.y);
	vec2 water_vertex_world_position_xz_4 = water_vertex_world_position_xz_1 + water_mesh_face_size;

	float water_wave_height_1 = calculate_water_wave_height(water_vertex_world_position_xz_1, wave_strength, wave_period, wave_time, wave_time_factor);
	float water_wave_height_2 = calculate_water_wave_height(water_vertex_world_position_xz_2, wave_strength, wave_period, wave_time, wave_time_factor);
	float water_wave_height_3 = calculate_water_wave_height(water_vertex_world_position_xz_3, wave_strength, wave_period, wave_time, wave_time_factor);
	float water_wave_height_4 = calculate_water_wave_height(water_vertex_world_position_xz_4, wave_strength, wave_period, wave_time, wave_time_factor);

	float x_fraction = wrap(pixel_world_position.x, 0.0, water_mesh_face_size.x) / water_mesh_face_size.x;
	float z_fraction = wrap(pixel_world_position.z, 0.0, water_mesh_face_size.y) / water_mesh_face_size.y;

	float interpolated_water_wave_height = mix(
		mix(water_wave_height_1, water_wave_height_2, x_fraction),
		mix(water_wave_height_3, water_wave_height_4, x_fraction),
		z_fraction
	);

	if (pixel_world_position.y < interpolated_water_wave_height + camera_water_volume_height) {
		COLOR = vec4(0.0, 0.0, 0.5, 0.5);
		float distortion = texture(noise, wrap_vec2(UV * distortion_scale + TIME * distortion_speed, vec2(0.0), vec2(1.0))).x * 2.0 - 1.0;
		float screen_aspect_ratio = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
		vec3 screen_texture_sample = textureLod(
			screen_texture,
			vec2(SCREEN_UV.x - distortion_intensity * distortion / screen_aspect_ratio, SCREEN_UV.y),
			0.0
		).rgb;
		COLOR.rgb = screen_texture_sample * color.rgb * color.a + screen_texture_sample * (1.0 - color.a);
		COLOR.a = 1.0;
	} else {
		discard;
	}
}
