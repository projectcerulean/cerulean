# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends PlayerState

@export var turn_rate: float = 4.0
@export var roll_resistance_coefficient: float = 2.5

@export var dodge_initial_speed: float = 10.0
@export var dodge_acceleration_target_speed: float = 12.0

var initial_height: float = NAN
var initial_speed: float = NAN
var roll_resistance_energy_loss: float = NAN
var planar_position_prev: Vector2 = Vector2(NAN, NAN)

var acceleration_pid: PidController = PidController.new(5.0, 0.0, 0.0, 0.0)

@onready var dodge_min_speed: float = dodge_initial_speed - 0.01
@onready var dodge_acceleration_timer: Timer = get_node("DodgeAccelerationTimer") as Timer


func enter(data: Dictionary) -> void:
	super.enter(data)

	initial_height = player.global_position.y
	initial_speed = dodge_initial_speed
	roll_resistance_energy_loss = 0.0
	planar_position_prev = VectorUtils.vec3_xz_to_vec2(player.global_position)

	dodge_acceleration_timer.start()
	var input_direction: Vector3 = VectorUtils.vec2_to_vec3_xz(player.planar_input_vector).normalized()
	if input_direction.is_normalized():
		player.enqueue_minimum_velocity(initial_speed * input_direction)


func exit(data: Dictionary) -> void:
	super.exit(data)
	initial_height = NAN
	initial_speed = NAN
	roll_resistance_energy_loss = NAN
	planar_position_prev = Vector2(NAN, NAN)


func physics_process(delta: float) -> void:
	super.physics_process(delta)

	var planar_velocity: Vector2 = VectorUtils.vec3_xz_to_vec2(player.linear_velocity)
	var planar_velocity_length: float = planar_velocity.length()
	var planar_translation_update: Vector2 = VectorUtils.vec3_xz_to_vec2(player.global_position) - planar_position_prev
	var planar_translation_update_length: float = planar_translation_update.length()

	# Apply movement
	var input_direction: Vector3 = VectorUtils.vec2_to_vec3_xz(player.planar_input_vector).normalized()
	if input_direction.is_normalized():
		var velocity_direction: Vector3 = player.linear_velocity.normalized()
		if not input_direction.is_equal_approx(velocity_direction) and not input_direction.is_equal_approx(-velocity_direction):
			var plane: Plane = Plane(Vector3.ZERO, input_direction, velocity_direction)
			var force_direction: Vector3 = velocity_direction.cross(plane.normal)
			var angle: float = input_direction.angle_to(velocity_direction)
			player.enqueue_force(-force_direction * turn_rate * player.mass * player.linear_velocity.length() * angle / PI)

	if dodge_acceleration_timer.is_stopped():
		roll_resistance_energy_loss += roll_resistance_coefficient * planar_velocity_length * planar_translation_update_length
		var current_height: float = player.global_position.y
		var initial_kinetic_energy: float = 0.5 * player.mass * initial_speed * initial_speed
		var potential_energy_conversion: float = player.mass * player.total_gravity.y * (current_height - initial_height)
		var current_kinetic_energy: float = initial_kinetic_energy + potential_energy_conversion - roll_resistance_energy_loss
		var target_speed: float = Math.signed_sqrt(
			2.0 * current_kinetic_energy / player.mass
		)
		var pid_output: float = acceleration_pid.update(planar_velocity_length, target_speed, delta)
		player.enqueue_force(player.mass * player.linear_velocity.normalized() * pid_output)
	else:
		var dodge_speed: float = remap(
			dodge_acceleration_timer.time_left,
			dodge_acceleration_timer.wait_time, 0.0,
			dodge_initial_speed, dodge_acceleration_target_speed,
		)
		player.enqueue_minimum_velocity(dodge_speed * input_direction)

	planar_position_prev = VectorUtils.vec3_xz_to_vec2(player.global_position)

	# Jump buffering
	if Input.is_action_just_pressed(InputActions.JUMP):
		player.jump_buffer_timer.start()


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
	):
		return PlayerStates.RUN
	elif (planar_velocity_length > player.roll_min_speed + 1.0):
		return PlayerStates.ROLL
	elif (
		dodge_acceleration_timer.is_stopped()
		and planar_velocity_length < dodge_min_speed
	):
		return PlayerStates.SPRINT
	else:
		return StringName()
