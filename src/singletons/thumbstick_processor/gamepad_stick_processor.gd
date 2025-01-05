# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later

# Applies some basic processing to the raw thumbstick input values before they are used in the game.
# Based on "How to Program the Perfect Controller" by Ombarus, https://www.youtube.com/watch?v=Q4aQiuJYZ2s
class_name GamepadStickProcessor
extends RefCounted

const DEAD_ZONE_INNER: float = 0.1
const DEAD_ZONE_OUTER: float = 0.9
const RESPONSE_EXPONENT: float = 4.0

var _input_action_up: StringName
var _input_action_down: StringName
var _input_action_left: StringName
var _input_action_right: StringName


func _init(
	input_action_up: StringName,
	input_action_down: StringName,
	input_action_left: StringName,
	input_action_right: StringName,
) -> void:
	_input_action_up = input_action_up
	_input_action_down = input_action_down
	_input_action_left = input_action_left
	_input_action_right = input_action_right


func process_input() -> Vector2:
	var value: Vector2 = Vector2.ZERO
	var value_raw: Vector2 = Input.get_vector(_input_action_left, _input_action_right, _input_action_up, _input_action_down)

	# Dead zone
	var value_clamped: Vector2 = Vector2.ZERO
	value_clamped.x = clamp(abs(value_raw.x), DEAD_ZONE_INNER, DEAD_ZONE_OUTER)
	value_clamped.y = clamp(abs(value_raw.y), DEAD_ZONE_INNER, DEAD_ZONE_OUTER)
	var value_lerped: Vector2 = Vector2.ZERO
	value_lerped.x = remap(value_clamped.x, DEAD_ZONE_INNER, DEAD_ZONE_OUTER, 0.0, 1.0)
	value_lerped.y = remap(value_clamped.y, DEAD_ZONE_INNER, DEAD_ZONE_OUTER, 0.0, 1.0)
	value = Vector2(value_lerped.x * signf(value_raw.x), value_lerped.y * signf(value_raw.y))

	# Non-linear response
	var value_nonlinear: Vector2 = value.normalized() * pow(value.length_squared(), RESPONSE_EXPONENT / 2.0)
	value = value_nonlinear

	# Set to zero if close to zero
	if value.is_equal_approx(Vector2.ZERO):
		value = Vector2.ZERO

	return value
