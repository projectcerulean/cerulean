# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends UnitTest

const ERROR_INTERVAL: float = 0.000001


func test_is_even() -> void:
	assert_true(Math.is_even(0))
	assert_true(Math.is_even(-0))
	assert_true(Math.is_even(2))
	assert_true(Math.is_even(4))
	assert_true(Math.is_even(-2))
	assert_true(Math.is_even(-4))
	assert_false(Math.is_even(1))
	assert_false(Math.is_even(3))
	assert_false(Math.is_even(-1))
	assert_false(Math.is_even(-3))


func test_is_odd() -> void:
	assert_false(Math.is_odd(0))
	assert_false(Math.is_odd(-0))
	assert_false(Math.is_odd(2))
	assert_false(Math.is_odd(4))
	assert_false(Math.is_odd(-2))
	assert_false(Math.is_odd(-4))
	assert_true(Math.is_odd(1))
	assert_true(Math.is_odd(3))
	assert_true(Math.is_odd(-1))
	assert_true(Math.is_odd(-3))


func test_signed_sqrt_positive() -> void:
	assert_almost_eq(Math.signed_sqrt(4.0), 2.0, ERROR_INTERVAL)


func test_signed_sqrt_negative() -> void:
	assert_almost_eq(Math.signed_sqrt(-4.0), -2.0, ERROR_INTERVAL)


func test_signed_sqrt_zero() -> void:
	assert_almost_eq(Math.signed_sqrt(0.0), 0.0, ERROR_INTERVAL)


func test_ellipse_circular() -> void:
	var radius: float = 1234.0
	var n_points: int = 100
	for i: int in range(n_points):
		var angle: float = TAU * float(i) / n_points
		assert_almost_eq(Math.ellipse(Vector2(radius, radius), angle), radius, ERROR_INTERVAL)


func test_ellipse_vertices() -> void:
	var radius_x: float = 3.0
	var radius_y: float = 7.0
	var radii: Vector2 = Vector2(radius_x, radius_y)

	assert_almost_eq(Math.ellipse(radii, 0.00 * TAU), radius_x, ERROR_INTERVAL)
	assert_almost_eq(Math.ellipse(radii, 0.25 * TAU), radius_y, ERROR_INTERVAL)
	assert_almost_eq(Math.ellipse(radii, 0.50 * TAU), radius_x, ERROR_INTERVAL)
	assert_almost_eq(Math.ellipse(radii, 0.75 * TAU), radius_y, ERROR_INTERVAL)
	assert_almost_eq(Math.ellipse(radii, 1.00 * TAU), radius_x, ERROR_INTERVAL)


func test_ellipse_quadrant_1() -> void:
	var n_points: int = 100
	var radius_x: float = 3.0
	var radius_y: float = 7.0
	var radii: Vector2 = Vector2(radius_x, radius_y)

	for i: int in range(n_points - 1):
		var angle_smaller: float = float(i) * 0.25 * TAU / float(n_points)
		var angle_larger: float = float(i + 1) * 0.25 * TAU / float(n_points)
		assert_gt(Math.ellipse(radii, angle_larger), Math.ellipse(radii, angle_smaller))


func test_ellipse_quadrant_2() -> void:
	var n_points: int = 100
	var radius_x: float = 3.0
	var radius_y: float = 7.0
	var radii: Vector2 = Vector2(radius_x, radius_y)

	for i: int in range(n_points - 1):
		var angle_smaller: float = 0.25 * TAU + float(i) * 0.25 * TAU / float(n_points)
		var angle_larger: float = 0.25 * TAU + float(i + 1) * 0.25 * TAU / float(n_points)
		assert_gt(Math.ellipse(radii, angle_smaller), Math.ellipse(radii, angle_larger))


func test_ellipse_quadrant_3() -> void:
	var n_points: int = 100
	var radius_x: float = 3.0
	var radius_y: float = 7.0
	var radii: Vector2 = Vector2(radius_x, radius_y)

	for i: int in range(n_points - 1):
		var angle_smaller: float = 0.5 * TAU + float(i) * 0.25 * TAU / float(n_points)
		var angle_larger: float = 0.5 * TAU + float(i + 1) * 0.25 * TAU / float(n_points)
		assert_gt(Math.ellipse(radii, angle_larger), Math.ellipse(radii, angle_smaller))


func test_ellipse_quadrant_4() -> void:
	var n_points: int = 100
	var radius_x: float = 3.0
	var radius_y: float = 7.0
	var radii: Vector2 = Vector2(radius_x, radius_y)

	for i: int in range(n_points - 1):
		var angle_smaller: float = 0.75 * TAU + float(i) * 0.25 * TAU / float(n_points)
		var angle_larger: float = 0.75 * TAU + float(i + 1) * 0.25 * TAU / float(n_points)
		assert_gt(Math.ellipse(radii, angle_smaller), Math.ellipse(radii, angle_larger))
