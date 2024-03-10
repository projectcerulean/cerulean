# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later

# Applies some basic processing to the raw thumbstick input values before they are used in the game.
# Values are updated each frame (_process callback) and can be queried using the Vector2 resources.
# Based on "How to Program the Perfect Controller" by Ombarus, https://www.youtube.com/watch?v=Q4aQiuJYZ2s
extends Node

enum Stick {
	LEFT_STICK,
	RIGHT_STICK,
}

const INPUT_ACTIONS: Dictionary = {
	Stick.LEFT_STICK: [
		InputActions.LEFT_STICK_UP,
		InputActions.LEFT_STICK_DOWN,
		InputActions.LEFT_STICK_LEFT,
		InputActions.LEFT_STICK_RIGHT,
	],
	Stick.RIGHT_STICK: [
		InputActions.RIGHT_STICK_UP,
		InputActions.RIGHT_STICK_DOWN,
		InputActions.RIGHT_STICK_LEFT,
		InputActions.RIGHT_STICK_RIGHT,
	],
}

@export var deadzone_inner: float = 0.1
@export var deadzone_outer: float = 0.9
@export var response_exponent: float = 4.0

@export var stick: Stick

@export var thumbstick_resource: Vector2Resource


func _ready() -> void:
	assert(thumbstick_resource != null, Errors.NULL_RESOURCE)


func _process(_delta: float) -> void:
	var stick_value: Vector2 = process_stick_input(
		INPUT_ACTIONS[stick][0],
		INPUT_ACTIONS[stick][1],
		INPUT_ACTIONS[stick][2],
		INPUT_ACTIONS[stick][3],
	)

	if stick_value.length_squared() > thumbstick_resource.value.length_squared():
		thumbstick_resource.value = stick_value


func process_stick_input(action_up: StringName, action_down: StringName, action_left: StringName, action_right: StringName) -> Vector2:
	var value: Vector2 = Vector2.ZERO
	var value_raw: Vector2 = Input.get_vector(action_left, action_right, action_up, action_down)

	# Dead zone
	var value_clamped: Vector2 = Vector2.ZERO
	value_clamped.x = clamp(abs(value_raw.x), deadzone_inner, deadzone_outer)
	value_clamped.y = clamp(abs(value_raw.y), deadzone_inner, deadzone_outer)
	var value_lerped: Vector2 = Vector2.ZERO
	value_lerped.x = remap(value_clamped.x, deadzone_inner, deadzone_outer, 0.0, 1.0)
	value_lerped.y = remap(value_clamped.y, deadzone_inner, deadzone_outer, 0.0, 1.0)
	value = Vector2(value_lerped.x * sign(value_raw.x), value_lerped.y * sign(value_raw.y))

	# Non-linear response
	var value_nonlinear: Vector2 = value.normalized() * pow(value.length_squared(), response_exponent / 2.0)
	value = value_nonlinear

	# Set to zero if close to zero
	if value.is_equal_approx(Vector2.ZERO):
		value = Vector2.ZERO

	return value
