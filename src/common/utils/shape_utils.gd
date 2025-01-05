# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name ShapeUtils
extends Node


static func calculate_shape_volume(shape: Shape3D) -> float:
	if shape is BoxShape3D:
		var box_shape: BoxShape3D = shape as BoxShape3D
		return box_shape.size.x * box_shape.size.y * box_shape.size.z
	else:
		assert(false, Errors.NOT_IMPLEMENTED)
		return NAN


static func get_shape_height(shape: Shape3D) -> float:
	var box_shape: BoxShape3D = shape as BoxShape3D
	var capsule_shape: CapsuleShape3D = shape as CapsuleShape3D

	if box_shape != null:
		return box_shape.size.y
	elif capsule_shape != null:
		return capsule_shape.height
	else:
		assert(false, Errors.NOT_IMPLEMENTED)
		return 0.0


static func get_shape_scaled_xz(shape: Shape3D, scale: float) -> Shape3D:
	var box_shape: BoxShape3D = shape as BoxShape3D
	var capsule_shape: CapsuleShape3D = shape as CapsuleShape3D

	if box_shape != null:
		var shape_scaled: BoxShape3D = shape.duplicate() as BoxShape3D
		shape_scaled.size.x *= scale
		shape_scaled.size.z *= scale
		return shape_scaled
	elif capsule_shape != null:
		var shape_scaled: CapsuleShape3D = shape.duplicate() as CapsuleShape3D
		shape_scaled.radius *= scale
		assert(is_equal_approx(shape_scaled.radius, capsule_shape.radius * scale), Errors.INVALID_ARGUMENT)
		assert(is_equal_approx(shape_scaled.height, capsule_shape.height), Errors.INVALID_ARGUMENT)
		return shape_scaled
	else:
		assert(false, Errors.NOT_IMPLEMENTED)
		return null
