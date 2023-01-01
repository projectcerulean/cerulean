// This file is part of Project Cerulean <https://projectcerulean.org>
// Copyright (C) 2021-2023 Martin Gulliksson
// SPDX-License-Identifier: GPL-3.0-or-later
shader_type spatial;

uniform float activation: hint_range(0.0, 1.0) = 0.0;
uniform vec4 albedo: source_color = vec4(1.0, 0.27, 0.0, 1.0);
uniform float roughness: hint_range(0.0, 1.0) = 0.5;
uniform float specular: hint_range(0.0, 1.0) = 0.5;
uniform float metallic: hint_range(0.0, 1.0) = 1.0;
uniform float emission_energy = 1.0;


void fragment() {
	ALBEDO = albedo.rgb;
	EMISSION = albedo.rgb * emission_energy;

	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
}
