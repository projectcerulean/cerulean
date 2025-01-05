# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends UnitTest


func test_vec3_xz_to_vec2() -> void:
	var input: Vector3 = Vector3(3.0, 7.0, 13.0)
	var expected_output: Vector2 = Vector2(3.0, 13.0)
	assert_eq(VectorUtils.vec3_xz_to_vec2(input), expected_output)


func test_vec2_to_vec3_xz() -> void:
	var input: Vector2 = Vector2(3.0, 7.0)
	var expected_output: Vector3 = Vector3(3.0, 0.0, 7.0)
	assert_eq(VectorUtils.vec2_to_vec3_xz(input), expected_output)
