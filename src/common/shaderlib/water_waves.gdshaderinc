// This file is part of Project Cerulean <https://projectcerulean.org>
// Copyright (C) 2021-2025 Martin Gulliksson
// SPDX-License-Identifier: GPL-3.0-or-later

float calculate_water_wave_height(vec2 position_xz, vec2 wave_strength, vec2 wave_period, float wave_time, vec2 wave_time_factor) {
	return wave_strength.x * sin(position_xz.x * TAU / wave_period.x + wave_time * wave_time_factor.x) +
		wave_strength.y * sin(position_xz.y * TAU / wave_period.y + wave_time * wave_time_factor.y);
}