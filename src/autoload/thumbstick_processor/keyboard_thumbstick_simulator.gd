# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node

@export var thumbstick_resource: Vector2Resource


func _ready() -> void:
	assert(thumbstick_resource != null, Errors.NULL_RESOURCE)


func _process(_delta: float) -> void:
	var stick_value: Vector2 = process_stick_input(
		InputActions.LEFT_STICK_UP_DIGITAL,
		InputActions.LEFT_STICK_DOWN_DIGITAL,
		InputActions.LEFT_STICK_LEFT_DIGITAL,
		InputActions.LEFT_STICK_RIGHT_DIGITAL,
	)

	if stick_value.length_squared() > thumbstick_resource.value.length_squared():
		thumbstick_resource.value = stick_value


func process_stick_input(action_up: StringName, action_down: StringName, action_left: StringName, action_right: StringName) -> Vector2:
	var value: Vector2 = Vector2.ZERO
	var value_raw: Vector2 = Vector2.ZERO
	value_raw.x = Input.get_action_raw_strength(action_right) - Input.get_action_raw_strength(action_left)
	value_raw.y =  Input.get_action_raw_strength(action_down) - Input.get_action_raw_strength(action_up)
	value = value_raw.limit_length()
	if value.is_equal_approx(Vector2.ZERO):
		value = Vector2.ZERO

	return value
