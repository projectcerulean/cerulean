# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later

# Applies some basic processing to the raw thumbstick input values before they are used in the game.
# Values are updated each frame (_process callback) and can be queried using the Vector2 resources.
# Based on "How to Program the Perfect Controller" by Ombarus, https://www.youtube.com/watch?v=Q4aQiuJYZ2s
extends Node

@export var deadzone_inner: float = 0.1
@export var deadzone_outer: float = 0.9
@export var response_exponent: float = 4.0

@export var _thumbstick_resource_left: Resource
@export var _thumbstick_resource_right: Resource

@onready var thumbstick_resource_left: Vector2Resource = _thumbstick_resource_left as Vector2Resource
@onready var thumbstick_resource_right: Vector2Resource = _thumbstick_resource_right as Vector2Resource


func _ready() -> void:
	assert(thumbstick_resource_left != null, Errors.NULL_RESOURCE)
	assert(thumbstick_resource_right != null, Errors.NULL_RESOURCE)


func _process(_delta: float) -> void:
	thumbstick_resource_left.value = process_stick_input(
		InputActions.LEFT_STICK_UP,
		InputActions.LEFT_STICK_DOWN,
		InputActions.LEFT_STICK_LEFT,
		InputActions.LEFT_STICK_RIGHT,
	)
	thumbstick_resource_right.value = process_stick_input(
		InputActions.RIGHT_STICK_UP,
		InputActions.RIGHT_STICK_DOWN,
		InputActions.RIGHT_STICK_LEFT,
		InputActions.RIGHT_STICK_RIGHT,
	)


func process_stick_input(action_up: StringName, action_down: StringName, action_left: StringName, action_right: StringName) -> Vector2:
	var value: Vector2 = Vector2.ZERO
	var value_raw: Vector2 = Vector2.ZERO
	value_raw.x = Input.get_action_strength(action_right) - Input.get_action_strength(action_left)
	value_raw.y =  Input.get_action_strength(action_down) - Input.get_action_strength(action_up)

	# Dead zone
	var value_clamped: Vector2 = Vector2.ZERO
	value_clamped.x = clamp(abs(value_raw.x), deadzone_inner, deadzone_outer)
	value_clamped.y = clamp(abs(value_raw.y), deadzone_inner, deadzone_outer)
	var value_lerped: Vector2 = Vector2.ZERO
	value_lerped.x = remap(value_clamped.x, deadzone_inner, deadzone_outer, 0.0, 1.0)
	value_lerped.y = remap(value_clamped.y, deadzone_inner, deadzone_outer, 0.0, 1.0)
	value = Vector2(value_lerped.x * sign(value_raw.x), value_lerped.y * sign(value_raw.y))

	# Remap square input to circle
	var value_circle: Vector2 = Vector2.ZERO
	value_circle.x = value.x * sqrt(1.0 - value.y * value.y / 2.0)
	value_circle.y = value.y * sqrt(1.0 - value.x * value.x / 2.0)
	if value_circle.length() > 1.0:
		value_circle = value_circle.normalized()
	value = value_circle

	# Non-linear response
	var value_nonlinear: Vector2 = value.normalized() * pow(value.length_squared(), response_exponent / 2.0)
	value = value_nonlinear

	# Set to zero if close to zero
	if value.is_equal_approx(Vector2.ZERO):
		value = Vector2.ZERO

	return value
