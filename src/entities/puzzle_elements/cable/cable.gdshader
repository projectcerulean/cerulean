// This file is part of Project Cerulean <https://projectcerulean.org>
// Copyright (C) 2021-2022 Martin Gulliksson
// SPDX-License-Identifier: GPL-3.0-or-later
shader_type spatial;

uniform float flow_position = 0.0;
uniform float smooth_range = 0.5;
uniform vec4 color_old: hint_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 color_new: hint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform bool flip_colors = false;

void fragment() {
	vec4 local_position = inverse(MODEL_MATRIX) * INV_VIEW_MATRIX * vec4(VERTEX, 1.0);
	float x = smoothstep(flow_position - smooth_range, flow_position + smooth_range, local_position.y - flow_position);
	if (flip_colors) {
		x = 1.0 - x;
	}
	ALBEDO = (x * color_old + (1.0 - x) * color_new).rgb;
}
