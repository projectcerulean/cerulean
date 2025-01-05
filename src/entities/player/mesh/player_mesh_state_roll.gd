# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends PlayerMeshState

const ROLL_TILT_ANGLE: StringName = &"ROLL_TILT_ANGLE"

@export var turn_lerp_weight_min: float = 2.0
@export var turn_lerp_weight_max: float = 10.0
@export var mesh_radius: float = 0.5
@export var max_tilt_angle: float = PI / 3.0
@export var tilt_lerp_weight: float = 1.0
@export var roll_pivot: Node3D
@export var tilt_pivot: Node3D

var yaw_direction_target: Vector3 = Vector3(NAN, NAN, NAN)
var tilt_angle: float = NAN


func _ready() -> void:
	super._ready()
	assert(roll_pivot != null, Errors.NULL_NODE)
	assert(tilt_pivot != null, Errors.NULL_NODE)


func enter(data: Dictionary) -> void:
	super.enter(data)
	tilt_angle = data.get(ROLL_TILT_ANGLE, 0.0)
	var yaw_direction: Vector3
	var input_direction_planar: Vector2 = player_input_vector_resource.get_value().normalized()
	if input_direction_planar.is_normalized():
		yaw_direction = VectorUtils.vec2_to_vec3_xz(input_direction_planar)
	else:
		yaw_direction = data.get(YAW_DIRECTION, Vector3.ZERO)
	if not yaw_direction.is_equal_approx(Vector3.ZERO):
		mesh_root.look_at(mesh_root.global_position + yaw_direction)
	yaw_direction_target = data.get(YAW_DIRECTION_TARGET, Vector3.ZERO)
	process(get_process_delta_time())


func exit(data: Dictionary) -> void:
	super.exit(data)
	data[ROLL_TILT_ANGLE] = tilt_angle
	tilt_angle = NAN
	data[YAW_DIRECTION] = -mesh_root.get_global_transform().basis.z
	data[YAW_DIRECTION_TARGET] = yaw_direction_target
	yaw_direction_target = Vector3(NAN, NAN, NAN)


func process(delta: float) -> void:
	super.process(delta)
	var player_velocity_direction: Vector2 = VectorUtils.vec3_xz_to_vec2(player.linear_velocity).normalized()
	if player_velocity_direction.is_normalized():
		yaw_direction_target = VectorUtils.vec2_to_vec3_xz(player_velocity_direction)

	if not yaw_direction_target.is_equal_approx(Vector3.ZERO):
		var turn_lerp_weight: float = remap(player_input_vector_resource.get_value().length(), 0.0, 1.0, turn_lerp_weight_min, turn_lerp_weight_max)
		var yaw_direction: Vector3 = Lerp.delta_slerp3(-mesh_root.get_global_transform().basis.z, yaw_direction_target, turn_lerp_weight, delta)
		mesh_root.look_at(mesh_root.global_position + yaw_direction)

		var planar_velocity: float = Vector3(player.linear_velocity.x, 0.0, player.linear_velocity.z).length()
		roll_pivot.rotate_y(-(planar_velocity / mesh_radius) * delta)

		var input_direction_planar: Vector2 = player_input_vector_resource.get_value().normalized()
		if input_direction_planar.is_normalized() and player_velocity_direction.is_normalized():
			tilt_angle = Lerp.delta_lerp_angle(
				tilt_angle,
				VectorUtils.vec2_to_vec3_xz(
					player_velocity_direction).signed_angle_to(VectorUtils.vec2_to_vec3_xz(input_direction_planar),
					Vector3.UP,
				),
				tilt_lerp_weight,
				delta,
			)
		else:
			tilt_angle = Lerp.delta_lerp_angle(
				tilt_angle, 0.0, tilt_lerp_weight, delta
			)
		tilt_pivot.rotation.x = remap(tilt_angle, -PI, PI, max_tilt_angle, -max_tilt_angle)
