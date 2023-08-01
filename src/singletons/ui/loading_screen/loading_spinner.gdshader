// This file is part of Project Cerulean <https://projectcerulean.org>
// Copyright (C) 2021-2023 Martin Gulliksson
// SPDX-License-Identifier: GPL-3.0-or-later
shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.0);
uniform float center_dist_squared_max = 0.25;
uniform float center_dist_squared_min = 0.20;
uniform float speed = 5.0;


float wrapf(float value, float min_value, float max_value) {
	float range = max_value - min_value;
	return value - (range * floor((value - min_value) / range));
}


void fragment() {
	float center_dist_squared = (UV.x - 0.5) * (UV.x - 0.5) + (UV.y - 0.5) * (UV.y - 0.5);
	if (center_dist_squared > center_dist_squared_max || center_dist_squared < center_dist_squared_min) {
		discard;
	}

	float spinner_angle = wrapf(TIME * speed, 0.0, 2.0 * PI);
	vec2 spinner_target_vector = vec2(cos(spinner_angle), sin(spinner_angle));
	vec2 pixel_vector = vec2(2.0 * (UV.x - 0.5), 2.0 * (UV.y - 0.5));
	float dot_product = dot(pixel_vector, spinner_target_vector);
	float pixel_activation = abs(dot_product);
	if (pixel_activation < 0.5) {
		discard;
	}

	COLOR = color;
}
