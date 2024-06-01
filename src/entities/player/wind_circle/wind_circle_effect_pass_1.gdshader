// This file is part of Project Cerulean <https://projectcerulean.org>
// Copyright (C) 2021-2024 Martin Gulliksson
// SPDX-License-Identifier: GPL-3.0-or-later
shader_type spatial;
render_mode unshaded, cull_disabled;

uniform float inner_radius: hint_range(0.0, 0.5) = 0.25;
uniform float outer_radius: hint_range(0.0, 0.5) = 0.75;
uniform vec3 albedo_color: source_color = vec3(1.0);

void fragment() {
	float radius_squared = (UV.x - 0.5) * (UV.x - 0.5) + (UV.y - 0.5) * (UV.y - 0.5);
	float inner_radius_squared = inner_radius * inner_radius;
	float outer_radius_squared = outer_radius * outer_radius;
	if (radius_squared < inner_radius_squared || radius_squared > outer_radius_squared) {
		discard;
	}
	ALBEDO = albedo_color;
}
