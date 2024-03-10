// This file is part of Project Cerulean <https://projectcerulean.org>
// Copyright (C) 2021-2024 Martin Gulliksson
// SPDX-License-Identifier: GPL-3.0-or-later
shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.0);
uniform float center_dist_squared_max = 0.25;
uniform float center_dist_squared_min = 0.18;
uniform float speed = 5.0;


float wrapf(float value, float min_value, float max_value) {
	float range = max_value - min_value;
	return value - (range * floor((value - min_value) / range));
}


bool is_angle_between(float angle, float angle_min, float angle_max) {
	float angle_min_periods = floor(angle_min / TAU);
	float angle_shifted_low = wrapf(angle, 0.0, TAU) + angle_min_periods * TAU;
	float angle_shifted_high = angle_shifted_low + TAU;
	return (angle_shifted_low > angle_min && angle_shifted_low < angle_max)
		|| (angle_shifted_high > angle_min && angle_shifted_high < angle_max);
}


void fragment() {
	vec2 pixel_vector = vec2(UV.x - 0.5, UV.y - 0.5);
	float center_dist_squared = dot(pixel_vector, pixel_vector);
	if (center_dist_squared > center_dist_squared_max || center_dist_squared < center_dist_squared_min) {
		discard;
	}

	float spinner_angle_min = speed * TIME;
	float spinner_angle_max = spinner_angle_min + PI / 2.0;
	float pixel_angle = atan(pixel_vector.y, pixel_vector.x);
	if (is_angle_between(pixel_angle, spinner_angle_min, spinner_angle_max)) {
		discard;
	} else if (is_angle_between(pixel_angle + PI, spinner_angle_min, spinner_angle_max)) {
		discard;
	}

	COLOR = color;
}
