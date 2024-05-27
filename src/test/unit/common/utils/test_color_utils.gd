# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends UnitTest

const ERROR_INTERVAL: float = 0.001

const variant_to_color_params: Array = [
	["string", Color(0.6471, 0.5196, 0.7176, 1.0000)],
	[&"stringname", Color(0.6196, 0.8216, 0.7333, 1.0000)],
	[Vector3.ONE, Color(0.6176, 0.8392, 0.6118, 1.0000)],
]


func test_variant_to_color(params: Array = use_parameters(variant_to_color_params)) -> void:
	var color: Color = ColorUtils.variant_to_color(params[0])
	var color_expected: Color = params[1]

	assert_almost_eq(color.r, color_expected.r, ERROR_INTERVAL)
	assert_almost_eq(color.b, color_expected.b, ERROR_INTERVAL)
	assert_almost_eq(color.g, color_expected.g, ERROR_INTERVAL)
	assert_almost_eq(color.a, color_expected.a, ERROR_INTERVAL)
