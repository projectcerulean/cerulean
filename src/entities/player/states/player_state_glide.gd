# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends PlayerState

@export var turn_rate: float = 4.0
@export var air_brake_strength: float = 1.0
@export var air_brake_min_speed: float = 5.0

var glide_start_position: Vector3 = Vector3.ZERO
var glide_start_velocity: Vector3 = Vector3.ZERO


func enter(data: Dictionary) -> void:
	super.enter(data)
	glide_start_position = player.global_position
	glide_start_velocity = player.linear_velocity


func physics_process(delta: float) -> void:
	super.physics_process(delta)

	# Apply movement
	var input_vector_spherical: Vector3 = VectorUtils.vec2_to_vec3_xz(player.planar_input_vector)
	input_vector_spherical.y = -sqrt(1.0 - minf(input_vector_spherical.length_squared(), 1.0))
	input_vector_spherical = input_vector_spherical.normalized()
	assert(input_vector_spherical.is_normalized(), Errors.CONSISTENCY_ERROR)
	var velocity_direction: Vector3 = player.linear_velocity.normalized()
	if not input_vector_spherical.is_equal_approx(velocity_direction) and not input_vector_spherical.is_equal_approx(-velocity_direction):
		var plane: Plane = Plane(Vector3.ZERO, input_vector_spherical, velocity_direction)
		var force_direction: Vector3 = velocity_direction.cross(plane.normal)
		var angle: float = input_vector_spherical.angle_to(velocity_direction)
		player.enqueue_force(-force_direction * turn_rate * player.mass * player.linear_velocity.length() * angle / PI)

	if Input.is_action_pressed(InputActions.AIR_BRAKE):
		glide_start_position = player.global_position
		glide_start_velocity = player.linear_velocity
		var velocity_length: float = player.linear_velocity.length()
		if velocity_length > air_brake_min_speed:
			player.enqueue_force(
				-air_brake_strength * player.linear_velocity.normalized() * (velocity_length - air_brake_min_speed) * player.mass
			)
	elif not player.is_near_floor():
		# Energy conservation
		var velocity_length_target: float = glide_start_velocity.length() + Math.signed_sqrt(
			2.0 * player.total_gravity.y * (player.global_position.y - glide_start_position.y)
		)
		player.enqueue_exact_velocity(velocity_direction * velocity_length_target)

	# Jump buffering
	if Input.is_action_just_pressed(InputActions.JUMP):
		player.jump_buffer_timer.start()


func get_transition() -> StringName:
	if player.global_position.y < player.water_detector.get_water_surface_height():
		return PlayerStates.SWIM
	elif player.is_on_floor():
		if Input.is_action_pressed(InputActions.GLIDE):
			if VectorUtils.vec3_xz_to_vec2(player.linear_velocity).length() > player.roll_min_speed:
				return PlayerStates.ROLL
			else:
				return PlayerStates.SPRINT
		elif is_equal_approx(player.linear_velocity.x, 0.0) and is_equal_approx(player.linear_velocity.z, 0.0):
			return PlayerStates.IDLE
		else:
			return PlayerStates.RUN
	elif not Input.is_action_pressed(InputActions.GLIDE) or player.linear_velocity.y > 0.0:
		return PlayerStates.FALL
	elif Input.is_action_just_pressed(InputActions.JUMP):
		if not player.coyote_timer.is_stopped():
			return PlayerStates.JUMP
		elif player.can_double_jump:
			return PlayerStates.DOUBLE_JUMP
	return StringName()
