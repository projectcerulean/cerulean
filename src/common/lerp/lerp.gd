# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name Lerp
extends Node

const rotation_epsilon: float = 0.001


static func delta_lerp(from: float, to: float, weight: float, process_delta: float) -> float:
	if is_equal_approx(from, to):
		return to
	else:
		return lerp(from, to, calculate_delta_weight(weight, process_delta))


static func delta_lerp_angle(from: float, to: float, weight: float, process_delta: float) -> float:
	if is_equal_approx(from, to):
		return to
	else:
		return lerp_angle(from, to, calculate_delta_weight(weight, process_delta))


static func delta_lerp2(from: Vector2, to: Vector2, weight: float, process_delta: float) -> Vector2:
	if from.is_equal_approx(to):
		return to
	else:
		return from.lerp(to, calculate_delta_weight(weight, process_delta))


static func delta_lerp3(from: Vector3, to: Vector3, weight: float, process_delta: float) -> Vector3:
	if from.is_equal_approx(to):
		return to
	else:
		return from.lerp(to, calculate_delta_weight(weight, process_delta))


static func delta_slerp3(from: Vector3, to: Vector3, weight: float, process_delta: float) -> Vector3:
	from = from.normalized()
	to = to.normalized()
	assert(from.is_normalized(), Errors.INVALID_ARGUMENT)
	assert(to.is_normalized(), Errors.INVALID_ARGUMENT)
	if from.is_equal_approx(to):
		return to
	if from.is_equal_approx(-to):
		if not to.is_equal_approx(Vector3.UP) and not to.is_equal_approx(-Vector3.UP):
			to = to.rotated(Vector3.UP, rotation_epsilon)
		else:
			to = to.rotated(Vector3.RIGHT, rotation_epsilon)
	var new: Vector3 = from.slerp(to, calculate_delta_weight(weight, process_delta))
	assert(new.is_normalized(), Errors.CONSISTENCY_ERROR)
	return new


static func calculate_delta_weight(weight: float, process_delta: float) -> float:
	return 1.0 - pow(10.0, -weight * process_delta)
