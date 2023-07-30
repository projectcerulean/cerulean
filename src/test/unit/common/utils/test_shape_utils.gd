# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends UnitTest

const ERROR_INTERVAL: float = 0.000001

const calculate_shape_volume_box_shape_params = [
	[Vector3(0.0, 0.0, 0.0), 0.0],
	[Vector3(1.0, 2.0, 3.0), 6.0],
	[Vector3(4.0, 5.0, 6.0), 120.0],
]

const get_shape_height_box_shape_params = [
	[Vector3(0.0, 0.0, 0.0), 0.0],
	[Vector3(1.0, 2.0, 3.0), 2.0],
	[Vector3(4.0, 5.0, 6.0), 5.0],
]

const get_shape_height_capsule_shape_params = [
	[Vector2(0.25, 1.0), 1.0],
	[Vector2(0.25, 2.0), 2.0],
	[Vector2(0.25, 3.0), 3.0],
]

const get_shape_scaled_xy_box_shape_params = [
	[Vector3(1.0, 2.0, 3.0), 0.0, Vector3(0.0, 2.0, 0.0)],
	[Vector3(1.0, 2.0, 3.0), 1.0, Vector3(1.0, 2.0, 3.0)],
	[Vector3(1.0, 2.0, 3.0), 0.5, Vector3(0.5, 2.0, 1.5)],
	[Vector3(1.0, 2.0, 3.0), 3.7, Vector3(3.7, 2.0, 11.1)],
]

const get_shape_scaled_xy_capsule_shape_params = [
	[Vector2(0.25, 1.0), 0.0, Vector2(0.0, 1.0)],
	[Vector2(0.25, 1.0), 0.5, Vector2(0.125, 1.0)],
	[Vector2(0.25, 1.0), 1.0, Vector2(0.25, 1.0)],
	[Vector2(0.25, 1.0), 1.25, Vector2(0.3125, 1.0)],
]


func test_calculate_shape_volume_box_shape(params=use_parameters(calculate_shape_volume_box_shape_params)) -> void:
	var box_shape: BoxShape3D = BoxShape3D.new()
	box_shape.size = params[0]
	assert_almost_eq(ShapeUtils.calculate_shape_volume(box_shape), params[1], ERROR_INTERVAL)


func test_get_shape_height_box_shape(params=use_parameters(get_shape_height_box_shape_params)) -> void:
	var box_shape: BoxShape3D = BoxShape3D.new()
	box_shape.size = params[0]
	assert_almost_eq(ShapeUtils.get_shape_height(box_shape), params[1], ERROR_INTERVAL)


func test_get_shape_height_capsule_shape(params=use_parameters(get_shape_height_capsule_shape_params)) -> void:
	var capsule_shape: CapsuleShape3D = CapsuleShape3D.new()
	capsule_shape.radius = params[0].x
	capsule_shape.height = params[0].y
	capsule_shape.radius = params[0].x
	capsule_shape.height = params[0].y
	assert_almost_eq(capsule_shape.radius, params[0].x, ERROR_INTERVAL)
	assert_almost_eq(capsule_shape.height, params[0].y, ERROR_INTERVAL)
	assert_almost_eq(ShapeUtils.get_shape_height(capsule_shape), params[1], ERROR_INTERVAL)


func test_get_shape_scaled_xz_box_shape(params=use_parameters(get_shape_scaled_xy_box_shape_params)):
	var original_size: Vector3 = params[0]
	var scale: float = params[1]
	var expected_scaled_size: Vector3 = params[2]
	var box_shape: BoxShape3D = BoxShape3D.new()
	box_shape.size = original_size

	var box_shape_scaled: BoxShape3D = ShapeUtils.get_shape_scaled_xz(box_shape, scale)
	assert_ne(box_shape_scaled, box_shape)
	assert_almost_eq(box_shape_scaled.size.x, expected_scaled_size.x, ERROR_INTERVAL)
	assert_almost_eq(box_shape_scaled.size.y, expected_scaled_size.y, ERROR_INTERVAL)
	assert_almost_eq(box_shape_scaled.size.z, expected_scaled_size.z, ERROR_INTERVAL)


func test_get_shape_scaled_xz_capsule_shape(params=use_parameters(get_shape_scaled_xy_capsule_shape_params)):
	var original_size: Vector2 = params[0]
	var scale: float = params[1]
	var expected_scaled_size: Vector2 = params[2]
	var capsule_shape: CapsuleShape3D = CapsuleShape3D.new()
	capsule_shape.height = original_size.y
	capsule_shape.radius = original_size.x
	capsule_shape.height = original_size.y
	capsule_shape.radius = original_size.x
	assert_almost_eq(capsule_shape.radius, original_size.x, ERROR_INTERVAL)
	assert_almost_eq(capsule_shape.height, original_size.y, ERROR_INTERVAL)

	var capsule_shape_scaled: CapsuleShape3D = ShapeUtils.get_shape_scaled_xz(capsule_shape, scale)
	assert_ne(capsule_shape_scaled, capsule_shape)
	assert_almost_eq(capsule_shape_scaled.radius, expected_scaled_size.x, ERROR_INTERVAL)
	assert_almost_eq(capsule_shape_scaled.height, expected_scaled_size.y, ERROR_INTERVAL)
