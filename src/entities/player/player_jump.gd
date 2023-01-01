# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends PlayerState

@export var move_speed: float = 8.5
@export var acceleration_time: float = 3.0
@export var jump_speed: float = 10.0


func enter(data: Dictionary) -> void:
	super.enter(data)
	player.coyote_timer.stop()
	player.jump_buffer_timer.stop()

	var impulse: Vector3 = player.mass * (jump_speed - player.linear_velocity.y) * Vector3.UP
	player.apply_central_impulse(impulse)

	# Newton's third
	if player.floor_collision != null:
		var rigid_body: RigidBody3D = player.floor_collision.get_collider() as RigidBody3D
		if rigid_body != null:
			var impulse_position: Vector3 = player.floor_collision.get_position() - rigid_body.global_position
			rigid_body.apply_impulse(-impulse, impulse_position)


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


func get_transition() -> StringName:
	if player.linear_velocity.y < 0 or not Input.is_action_pressed(InputActions.JUMP):
		return PlayerStates.FALL
	else:
		return StringName()
