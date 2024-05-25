# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name MouseThumbstickSimulator
extends RefCounted

const SENSITIVITY: float = 0.1

var mouse_motion_amount: Vector2 = Vector2.ZERO


func input(event: InputEvent) -> void:
	var event_mouse_motion: InputEventMouseMotion = event as InputEventMouseMotion
	if event_mouse_motion != null:
		mouse_motion_amount = event_mouse_motion.relative
	else:
		mouse_motion_amount = Vector2.ZERO


func process_input() -> Vector2:
	var value: Vector2 = mouse_motion_amount * SENSITIVITY
	if value.is_equal_approx(Vector2.ZERO):
		value = Vector2.ZERO
	mouse_motion_amount = Vector2.ZERO
	return value
