// This file is part of Project Cerulean <https://projectcerulean.org>
// Copyright (C) 2021-2024 Martin Gulliksson
// SPDX-License-Identifier: GPL-3.0-or-later
shader_type canvas_item;

uniform int kernel_size: hint_range(1, 25) = 11;  // Should be an odd number!
uniform float blur_strength: hint_range(0.0, 10.0) = 2.5;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec4 color = vec4(0.0);
	for (int i = -kernel_size / 2; i < kernel_size / 2 + 1; i++) {
		for (int j = -kernel_size / 2; j < kernel_size / 2 + 1; j++) {
			vec2 position = SCREEN_UV + vec2(float(i) * blur_strength * SCREEN_PIXEL_SIZE.x, float(j) * blur_strength * SCREEN_PIXEL_SIZE.y);
			color += texture(screen_texture, position, 0.0) / (float(kernel_size) * float(kernel_size));
		}
	}
	color.a = 1.0;
	COLOR = color;
}
