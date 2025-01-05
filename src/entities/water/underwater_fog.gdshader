// This file is part of Project Cerulean <https://projectcerulean.org>
// Copyright (C) 2021-2025 Martin Gulliksson
// SPDX-License-Identifier: GPL-3.0-or-later
shader_type fog;

#include "res://src/common/shaderlib/water_waves.gdshaderinc"

const float FOG_Y_OFFSET = -0.5;

uniform float density;
uniform float emission_factor;
uniform vec4 color: source_color;

uniform float wave_time = 0.0;
uniform vec2 wave_period = vec2(16.0, 16.0);
uniform vec2 wave_strength = vec2(0.25, 0.125);
uniform vec2 wave_time_factor = vec2(0.5, 1.0);

void fog() {
	float water_wave_height = calculate_water_wave_height(
		WORLD_POSITION.xz,
		wave_strength,
		wave_period,
		wave_time,
		wave_time_factor
	);
	float water_wave_height_uvw = water_wave_height / SIZE.y;

	// The actual fog density does not follow the amount returned in DENSITY perfectly, but instead
	// increases/decreases more smoothly/smeared out. Move the fog volume down a bit to reduce the
	// visible fog amount above water.
	float fog_y_offset = FOG_Y_OFFSET / SIZE.y;

	ALBEDO = color.xyz;
	DENSITY =  UVW.y < 0.5 + fog_y_offset + water_wave_height_uvw ? density : 0.0;
	EMISSION = color.xyz * emission_factor;
}
