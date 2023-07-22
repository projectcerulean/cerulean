# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node

@export var sensitivity: float = 0.1
@export var thumbstick_resource: Vector2Resource

var mouse_motion_amount: Vector2 = Vector2.ZERO


func _ready() -> void:
	assert(thumbstick_resource != null, Errors.NULL_RESOURCE)


func _input(event: InputEvent) -> void:
	var event_mouse_motion: InputEventMouseMotion = event as InputEventMouseMotion
	if event_mouse_motion != null:
		mouse_motion_amount = event_mouse_motion.relative
	else:
		mouse_motion_amount = Vector2.ZERO


func _process(_delta: float) -> void:
	var stick_value: Vector2 = mouse_motion_amount * sensitivity
	if stick_value.is_equal_approx(Vector2.ZERO):
		stick_value = Vector2.ZERO

	if stick_value.length_squared() > thumbstick_resource.value.length_squared():
		thumbstick_resource.value = stick_value
