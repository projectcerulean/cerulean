// This file is part of Project Cerulean <https://projectcerulean.org>
// Copyright (C) 2021-2024 Martin Gulliksson
// SPDX-License-Identifier: GPL-3.0-or-later
shader_type spatial;
render_mode depth_test_disabled;

uniform vec4 albedo : source_color;
uniform float fade = 0.5;


void fragment() {
	const vec3 magic = vec3(0.06711056f, 0.00583715f, 52.9829189f);
	if (fade < 0.001 || fade < fract(magic.z * fract(dot(FRAGCOORD.xy, magic.xy)))) {
		discard;
	}

	ALBEDO = albedo.rgb;
	ALPHA = albedo.a;
}
