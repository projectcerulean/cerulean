# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends PlayerState

@export var move_speed: float = 8.5
@export var acceleration_time: float = 3.0


func physics_process(delta: float) -> void:
	super.physics_process(delta)

	# Apply movement
	var linear_velocity_planar: Vector3 = player.linear_velocity * Vector3(1.0, 0.0, 1.0)
	if (linear_velocity_planar).length() < move_speed:
		var move_friction_coefficient: float = calculate_friction_coefficient(acceleration_time)
		var move_force: float = calculate_move_force(move_speed, move_friction_coefficient)
		player.force_vector = player.input_vector * move_force - move_friction_coefficient * linear_velocity_planar
	else:
		var move_friction_coefficient_parallel: float = calculate_friction_coefficient(acceleration_time * linear_velocity_planar.length() / move_speed)
		var move_friction_coefficient_perpendicular: float = calculate_friction_coefficient(acceleration_time)
		var move_force_parallel: float = calculate_move_force(linear_velocity_planar.length(), move_friction_coefficient_parallel)
		var move_force_perpendicular: float = calculate_move_force(move_speed, move_friction_coefficient_perpendicular)

		var input_vector_parallel = player.input_vector.project(linear_velocity_planar)
		var input_vector_perpendicular = player.input_vector.project(linear_velocity_planar.cross(Vector3.UP))

		player.force_vector = (
			input_vector_parallel * move_force_parallel - move_friction_coefficient_parallel * linear_velocity_planar
			+ input_vector_perpendicular * move_force_perpendicular
		)

	# Jump buffering
	if Input.is_action_just_pressed(InputActions.JUMP) and player.coyote_timer.is_stopped():
		player.jump_buffer_timer.start()


func get_transition() -> StringName:
	if player.global_position.y < player.water_detector.get_water_surface_height():
		return PlayerStates.SWIM
	elif Input.is_action_just_pressed(InputActions.JUMP) and not player.coyote_timer.is_stopped():
		return PlayerStates.JUMP
	elif player.is_on_floor():
		if is_equal_approx(player.linear_velocity.x, 0.0) and is_equal_approx(player.linear_velocity.z, 0.0):
			return PlayerStates.IDLE
		else:
			return PlayerStates.RUN
	elif player.linear_velocity.y < 0.0 and Input.is_action_pressed(InputActions.JUMP):
		return PlayerStates.GLIDE
	else:
		return StringName()
