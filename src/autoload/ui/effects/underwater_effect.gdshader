// This file is part of Project Cerulean <https://projectcerulean.org>
// Copyright (C) 2021-2022 Martin Gulliksson
// SPDX-License-Identifier: GPL-3.0-or-later
shader_type canvas_item;

uniform vec4 color : hint_color = vec4(0.0);
uniform float distortion_scale = 0.5;
uniform float distortion_intensity = 0.01;
uniform float distortion_speed = 0.05;
uniform sampler2D noise;

vec2 wrapf(vec2 x) {
	return x - floor(x);
}

void fragment() {  // TODO: Compensate for screen aspect ratio?
	float distortion = texture(noise, wrapf(UV * distortion_scale + TIME * distortion_speed)).x * 2.0 - 1.0;
	vec3 screen_texture = textureLod(SCREEN_TEXTURE, vec2(SCREEN_UV.x - distortion_intensity * distortion, SCREEN_UV.y), 0.0).rgb;
	COLOR.rgb = screen_texture * color.rgb * color.a + screen_texture * (1.0 - color.a);
	COLOR.a = 1.0;
}
