# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends GutTest

const ERROR_INTERVAL: float = 0.001

const str_to_color_params = [
	["a", Color(0.9804, 0.9706, 0.5078, 1.0000)],
	["b", Color(0.6882, 0.9216, 0.7510, 1.0000)],
	["c", Color(0.9275, 0.8608, 0.5529, 1.0000)],
	["test", Color(0.7353, 0.9176, 0.8118, 1.0000)],
]


func test_str_to_color(params=use_parameters(str_to_color_params)) -> void:
	var color: Color = ColorUtils.str_to_color(params[0])
	var color_expected: Color = params[1]

	assert_almost_eq(color.r, color_expected.r, ERROR_INTERVAL)
	assert_almost_eq(color.b, color_expected.b, ERROR_INTERVAL)
	assert_almost_eq(color.g, color_expected.g, ERROR_INTERVAL)
	assert_almost_eq(color.a, color_expected.a, ERROR_INTERVAL)
