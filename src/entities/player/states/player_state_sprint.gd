# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends PlayerState

@export var turn_rate: float = 4.0
@export var sprint_min_speed: float = 5.0
@export var sprint_max_speed: float = 13.0
@export var sprint_target_speed: float = 12.0

var initial_height: float = NAN

var acceleration_pid: PidController = PidController.new(5.0, 0.0, 0.0, 0.0)


func enter(data: Dictionary) -> void:
	super.enter(data)

	initial_height = player.global_position.y


func exit(data: Dictionary) -> void:
	super.exit(data)
	initial_height = NAN


func physics_process(delta: float) -> void:
	super.physics_process(delta)

	var planar_velocity: Vector2 = VectorUtils.vec3_xz_to_vec2(player.linear_velocity)
	var planar_velocity_length: float = planar_velocity.length()

	# Apply movement
	var input_direction: Vector3 = VectorUtils.vec2_to_vec3_xz(player.planar_input_vector).normalized()
	if input_direction.is_normalized():
		var velocity_direction: Vector3 = player.linear_velocity.normalized()
		if not input_direction.is_equal_approx(velocity_direction) and not input_direction.is_equal_approx(-velocity_direction):
			var plane: Plane = Plane(Vector3.ZERO, input_direction, velocity_direction)
			var force_direction: Vector3 = velocity_direction.cross(plane.normal)
			var angle: float = input_direction.angle_to(velocity_direction)
			player.enqueue_force(-force_direction * turn_rate * player.mass * player.linear_velocity.length() * angle / PI)

	var current_height: float = player.global_position.y
	if current_height > initial_height:
		initial_height = current_height

	var target_kinetic_energy: float = 0.5 * player.mass * sprint_target_speed * sprint_target_speed
	var potential_energy_conversion: float = player.mass * player.total_gravity.y * (current_height - initial_height)
	var current_kinetic_energy: float = target_kinetic_energy + potential_energy_conversion
	var target_speed: float = Math.signed_sqrt(
		2.0 * current_kinetic_energy / player.mass
	)
	var pid_output: float = acceleration_pid.update(planar_velocity_length, target_speed, delta)
	player.enqueue_force(player.mass * player.linear_velocity.normalized() * pid_output)

	# Jump buffering
	if Input.is_action_just_pressed(InputActions.JUMP):
		player.jump_buffer_timer.start()

	# Coyote time
	player.coyote_timer.start()


func get_transition() -> StringName:
	var planar_velocity: Vector2 = VectorUtils.vec3_xz_to_vec2(player.linear_velocity)
	var planar_velocity_length: float = planar_velocity.length()

	if player.global_position.y < player.water_detector.get_water_surface_height():
		return PlayerStates.SWIM
	elif not player.is_on_floor():
		if Input.is_action_pressed(InputActions.GLIDE):
			return PlayerStates.GLIDE
		else:
			return PlayerStates.FALL
	elif Input.is_action_just_pressed(InputActions.JUMP) or not player.jump_buffer_timer.is_stopped():
		return PlayerStates.JUMP
	elif (
		not Input.is_action_pressed(InputActions.GLIDE)
		or not VectorUtils.vec2_to_vec3_xz(player.planar_input_vector).normalized().is_normalized()
		or not planar_velocity_length >= sprint_min_speed
	):
		return PlayerStates.RUN
	elif planar_velocity_length > sprint_max_speed:
		return PlayerStates.ROLL
	else:
		return StringName()
