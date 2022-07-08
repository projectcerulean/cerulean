# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends PlayerState

@export var turn_rate: float = 4.0

var glide_start_position: Vector3 = Vector3.ZERO
var glide_start_velocity: Vector3 = Vector3.ZERO


func enter(data: Dictionary) -> void:
	super.enter(data)
	glide_start_position = player.global_transform.origin
	glide_start_velocity = player.linear_velocity


func physics_process(delta: float) -> void:
	super.physics_process(delta)

	# Apply movement
	var input_vector_spherical: Vector3 = player.input_vector
	input_vector_spherical.y = -sqrt(1.0 - min(input_vector_spherical.length_squared(), 1.0))
	input_vector_spherical = input_vector_spherical.normalized()
	assert(input_vector_spherical.is_normalized(), Errors.CONSISTENCY_ERROR)
	var velocity_direction: Vector3 = player.linear_velocity.normalized()
	var turn_force_vector: Vector3 = Vector3.ZERO
	if input_vector_spherical.is_equal_approx(velocity_direction) or input_vector_spherical.is_equal_approx(-velocity_direction):
		player.force_vector = Vector3.ZERO
	else:
		var plane: Plane = Plane(Vector3.ZERO, input_vector_spherical, velocity_direction)
		var force_direction: Vector3 = velocity_direction.cross(plane.normal)
		var angle: float = input_vector_spherical.angle_to(velocity_direction)
		player.force_vector = -force_direction * turn_rate * player.mass * player.linear_velocity.length() * angle / PI

	# Energy conservation
	var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
	var velocity_length_target: float = glide_start_velocity.length() + Math.signed_sqrt(
		2.0 * gravity * player.gravity_scale * (glide_start_position.y - player.global_transform.origin.y)
	)
	var delta_velocity: float = velocity_length_target - player.linear_velocity.length()
	player.apply_central_impulse(velocity_direction * delta_velocity * player.mass)

	# Jump buffering
	if Input.is_action_just_pressed(InputActions.JUMP):
		player.jump_buffer_timer.start()


func get_transition() -> StringName:
	if player.water_detector.is_in_water():
		return PlayerStates.SWIM
	elif player.is_on_floor():
		if is_equal_approx(player.linear_velocity.x, 0.0) and is_equal_approx(player.linear_velocity.z, 0.0):
			return PlayerStates.IDLE
		else:
			return PlayerStates.RUN
	elif not Input.is_action_pressed(InputActions.JUMP):
		return PlayerStates.FALL
	else:
		return StringName()
