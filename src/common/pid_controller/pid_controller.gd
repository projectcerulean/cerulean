# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name PidController
extends RefCounted

var _p_gain: float = 0.0
var _i_gain: float = 0.0
var _d_gain: float = 0.0
var _error_integral_max: float = 0.0

var _error_prev: float = NAN
var _error_integral: float = 0.0


func _init(p_gain: float, i_gain: float, d_gain: float, error_integral_max: float) -> void:
	_p_gain = p_gain
	_i_gain = i_gain
	_d_gain = d_gain
	_error_integral_max = error_integral_max


func update(current_value: float, target_value: float, process_delta: float) -> float:
	var error: float = target_value - current_value

	var p_term: float = _p_gain * error

	_error_integral = clampf(
		_error_integral + error * process_delta,
		-_error_integral_max,
		_error_integral_max,
	)
	var i_term: float = _i_gain * _error_integral

	var d_term: float = 0.0
	if not is_nan(_error_prev):
		d_term = _d_gain * (error - _error_prev) / process_delta

	_error_prev = error

	return p_term + i_term + d_term


func reset() -> void:
	_error_prev = NAN
	_error_integral = 0.0
