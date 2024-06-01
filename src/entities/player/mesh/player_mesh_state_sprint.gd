# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends PlayerMeshState

@export var turn_lerp_weight_min: float = 2.0
@export var turn_lerp_weight_max: float = 10.0
@export var mesh_radius: float = 0.5

var yaw_direction_target: Vector3 = Vector3.ZERO


func enter(data: Dictionary) -> void:
	super.enter(data)
	var yaw_direction: Vector3 = data.get(YAW_DIRECTION, Vector3.ZERO)
	if not yaw_direction.is_equal_approx(Vector3.ZERO):
		mesh_root.look_at(mesh_root.global_position + yaw_direction)
	yaw_direction_target = data.get(YAW_DIRECTION_TARGET, Vector3.ZERO)
	process(get_process_delta_time())


func exit(data: Dictionary) -> void:
	super.exit(data)
	data[YAW_DIRECTION] = -mesh_root.get_global_transform().basis.z
	data[YAW_DIRECTION_TARGET] = yaw_direction_target


func process(delta: float) -> void:
	super.process(delta)
	var player_input_vector_normalized: Vector2 = VectorUtils.vec3_xz_to_vec2(player.linear_velocity).normalized()
	if not player_input_vector_normalized.is_equal_approx(Vector2.ZERO):
		yaw_direction_target = VectorUtils.vec2_to_vec3_xz(player_input_vector_normalized)

	if not yaw_direction_target.is_equal_approx(Vector3.ZERO):
		var turn_lerp_weight: float = remap(player_input_vector_resource.get_value().length(), 0.0, 1.0, turn_lerp_weight_min, turn_lerp_weight_max)
		var yaw_direction: Vector3 = Lerp.delta_slerp3(-mesh_root.get_global_transform().basis.z, yaw_direction_target, turn_lerp_weight, delta)
		mesh_root.look_at(mesh_root.global_position + yaw_direction)
