# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends PlayerMeshState

@export var turn_lerp_weight: float = 0.1
@export var roll_lerp_weight: float = 2.0
@export var spin_rate: float = 0.0

var input_direction_planar: Vector3
var yaw_direction: Vector3 = Vector3.ZERO
var roll_angle: float = 0.0
var roll_angle_spin: float = 0.0
var spin_direction: float = 0.0


func enter(data: Dictionary) -> void:
	super.enter(data)
	roll_angle = data.get(ROLL_ANGLE, 0.0)
	roll_angle_spin = 0.0
	yaw_direction = data.get(YAW_DIRECTION, Vector3.ZERO)
	input_direction_planar = yaw_direction
	mesh_root.look_at(mesh_root.global_position + player.linear_velocity.normalized())
	spin_direction = 1.0 if randf() > 0.5 else -1.0
	process(get_process_delta_time())


func exit(data: Dictionary) -> void:
	super.exit(data)
	data[ROLL_ANGLE] = roll_angle + roll_angle_spin * spin_direction
	data[YAW_DIRECTION] = yaw_direction
	data[YAW_DIRECTION_TARGET] = yaw_direction


func process(delta: float) -> void:
	super.process(delta)
	roll_angle_spin += player.linear_velocity.y * spin_rate * delta
	var velocity_planar: Vector3 = Vector3(player.linear_velocity.x, 0.0, player.linear_velocity.z)

	var yaw_direction_new: Vector3 = velocity_planar.normalized()
	if yaw_direction_new.is_normalized():
		yaw_direction = yaw_direction_new

	if velocity_planar.is_equal_approx(Vector3.ZERO):
		if not is_zero_approx(player.linear_velocity.y):
			mesh_root.look_at(mesh_root.global_position + (Vector3.UP if player.linear_velocity.y > 0.0 else Vector3.DOWN), yaw_direction)
	else:
		var input_direction_planar_new: Vector3 = Vector3(player_input_vector_resource.value.x, 0.0, player_input_vector_resource.value.z).normalized()
		if input_direction_planar_new.is_normalized():
			input_direction_planar = input_direction_planar_new
		roll_angle = Lerp.delta_lerp_angle(
			roll_angle, velocity_planar.signed_angle_to(input_direction_planar, Vector3.UP), roll_lerp_weight, delta
		)

		var input_vector_spherical: Vector3 = player_input_vector_resource.value
		input_vector_spherical.y = -sqrt(1.0 - min(input_vector_spherical.length_squared(), 1.0))
		input_vector_spherical = input_vector_spherical.normalized()
		assert(input_vector_spherical.is_normalized(), Errors.CONSISTENCY_ERROR)
		var mesh_direction: Vector3 = player.linear_velocity.slerp(input_vector_spherical, turn_lerp_weight).normalized()
		mesh_root.look_at(mesh_root.global_position + mesh_direction, Vector3.UP.rotated(mesh_direction, -(roll_angle + roll_angle_spin * spin_direction)))
