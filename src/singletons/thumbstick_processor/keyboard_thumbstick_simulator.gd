# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name KeyboardThumbstickSimulator
extends RefCounted

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
	var value_raw: Vector2 = Vector2.ZERO
	value_raw.x = Input.get_action_raw_strength(_input_action_right) - Input.get_action_raw_strength(_input_action_left)
	value_raw.y =  Input.get_action_raw_strength(_input_action_down) - Input.get_action_raw_strength(_input_action_up)
	value = value_raw.limit_length()
	if value.is_equal_approx(Vector2.ZERO):
		value = Vector2.ZERO
	return value
