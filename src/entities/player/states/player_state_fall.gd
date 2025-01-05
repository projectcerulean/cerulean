# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends PlayerState

var _floor_distance_squared: float = NAN
var _floor_distance_squared_prev: float = NAN


func exit(data: Dictionary) -> void:
	super.exit(data)
	_floor_distance_squared = NAN
	_floor_distance_squared_prev = NAN


func physics_process(delta: float) -> void:
	super.physics_process(delta)
	player.perform_planar_movement(player.planar_input_vector, delta)
	_floor_distance_squared_prev = _floor_distance_squared
	_floor_distance_squared = (player.get_floor_collision_position() - player.global_position).length_squared()


func get_transition() -> StringName:
	if player.global_position.y < player.water_detector.get_water_surface_height():
		return PlayerStates.SWIM
	elif Input.is_action_just_pressed(InputActions.JUMP):
		if not player.coyote_timer.is_stopped():
			return PlayerStates.JUMP
		elif player.can_double_jump:
			return PlayerStates.DOUBLE_JUMP
	elif (
		player.is_on_floor()
		and not is_nan(_floor_distance_squared)
		and not is_nan(_floor_distance_squared_prev)
		and _floor_distance_squared < _floor_distance_squared_prev
	):
		if Input.is_action_pressed(InputActions.GLIDE):
			if VectorUtils.vec3_xz_to_vec2(player.linear_velocity).length() > player.roll_min_speed:
				return PlayerStates.ROLL
			else:
				return PlayerStates.SPRINT
		elif is_equal_approx(player.linear_velocity.x, 0.0) and is_equal_approx(player.linear_velocity.z, 0.0):
			return PlayerStates.IDLE
		else:
			return PlayerStates.RUN
	elif player.linear_velocity.y <= 0.0 and Input.is_action_pressed(InputActions.GLIDE):
		return PlayerStates.GLIDE
	return StringName()
