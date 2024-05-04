# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name PidController2D
extends RefCounted

var _pid_x: PidController
var _pid_y: PidController


func _init(p_gain: float, i_gain: float, d_gain: float, error_integral_max: float) -> void:
	_pid_x = PidController.new(p_gain, i_gain, d_gain, error_integral_max)
	_pid_y = PidController.new(p_gain, i_gain, d_gain, error_integral_max)


func update(current_value: Vector2, target_value: Vector2, process_delta: float) -> Vector2:
	return Vector2 (
		_pid_x.update(current_value.x, target_value.x, process_delta),
		_pid_y.update(current_value.y, target_value.y, process_delta),
	)


func reset() -> void:
	_pid_x.reset()
	_pid_y.reset()
