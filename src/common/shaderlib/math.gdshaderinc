// This file is part of Project Cerulean <https://projectcerulean.org>
// Copyright (C) 2021-2025 Martin Gulliksson
// SPDX-License-Identifier: GPL-3.0-or-later

float inverse_mix(float from, float to, float value) {
	return (value - from) / (to - from);
}


float remap(float value, float istart, float istop, float ostart, float ostop) {
	return mix(ostart, ostop, inverse_mix(istart, istop, value));
}


float snapped(float value, float step_size) {
	return floor(value / step_size + 0.5) * step_size;
}


float wrap(float value, float range_min, float range_max) {
	float range_size = range_max - range_min;
	return clamp(value - (range_size * floor((value - range_min) / range_size)), range_min, range_max);
}


vec2 wrap_vec2(vec2 value, vec2 range_min, vec2 range_max) {
	return vec2(
		wrap(value.x, range_min.x, range_max.x),
		wrap(value.y, range_min.y, range_max.y)
	);
}
