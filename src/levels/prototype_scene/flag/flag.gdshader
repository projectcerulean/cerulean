// This file is part of Project Cerulean <https://projectcerulean.org>
// Copyright (C) 2021-2024 Martin Gulliksson
// SPDX-License-Identifier: GPL-3.0-or-later

// Based on "Create an Animated 3D Flag Shader in Godot" by GDQuest, https://www.youtube.com/watch?v=sxdBwv384Ic
shader_type spatial;
render_mode cull_disabled;

uniform sampler2D uv_offset_texture : hint_default_black;
uniform vec2 uv_offset_scale = vec2(-0.2, -0.1);
uniform float vertex_offset_scale = 1.0;
uniform vec2 time_scale = vec2(0.25, 0.0);
uniform float face_distortion = 1.0;
uniform float curvature = 5.0;
uniform vec4 albedo : source_color;

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
