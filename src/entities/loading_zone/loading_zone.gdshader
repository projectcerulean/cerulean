// This file is part of Project Cerulean <https://projectcerulean.org>
// Copyright (C) 2021-2025 Martin Gulliksson
// SPDX-License-Identifier: GPL-3.0-or-later
shader_type spatial;

uniform vec4 color: source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float beer_factor = 2.0;
uniform sampler2D depth_texture : hint_depth_texture, filter_linear_mipmap;

varying mat4 camera;


void fragment() {
	float depth = texture(depth_texture, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 world = camera * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	vec3 depth_world_position = world.xyz / world.w;
	vec3 vertex_world_position = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float depth_world = distance(depth_world_position, vertex_world_position);
	ALBEDO = color.rgb;
	ALPHA = clamp(1.0 - exp(-depth_world * beer_factor), 0.0, 1.0);
}


void vertex() {
	camera = INV_VIEW_MATRIX;
}
