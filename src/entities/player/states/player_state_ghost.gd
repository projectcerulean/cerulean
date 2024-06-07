# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends PlayerState

@export var move_speed: float = 12.0
@export var move_speed_fast: float = 25.0
@export var movement_p_gain_factor: float = 5.0

var movement_pid_controller: PidController3D
var collision_shape_disabled_prev: bool = false


func _ready() -> void:
	super._ready()
	movement_pid_controller = PidController3D.new(movement_p_gain_factor * player.mass, 0.0, 0.0, 0.0)


func enter(data: Dictionary) -> void:
	super.enter(data)
	collision_shape_disabled_prev = player.collision_shape.disabled
	player.collision_shape.disabled = true


func exit(data: Dictionary) -> void:
	super.exit(data)
	player.collision_shape.disabled = collision_shape_disabled_prev


func physics_process(delta: float) -> void:
	super.physics_process(delta)

	var shape: Shape3D = player.collision_shape.shape
	var top_point_height: float = player.collision_shape.global_position.y + ShapeUtils.get_shape_height(shape) / 2.0

	# Apply movement
	var input_strength_up: float = Input.get_action_strength(InputActions.SWIM_UPWARDS)
	var input_strength_down: float = Input.get_action_strength(InputActions.SWIM_DOWNWARDS)
	var input_strength_vertical: float = input_strength_up - input_strength_down
	var input_vector: Vector3 = (
		VectorUtils.vec2_to_vec3_xz(player.planar_input_vector) + Vector3.UP * input_strength_vertical
	).limit_length()
	var movement_force: Vector3 = movement_pid_controller.update(
		player.linear_velocity,
		move_speed_fast * input_vector if Input.is_action_pressed(InputActions.INTERACT) else move_speed * input_vector,
		delta,
	)
	player.enqueue_force(movement_force)


func get_transition() -> StringName:
	if Input.is_action_just_pressed(InputActions.JUMP):
		return PlayerStates.JUMP
	else:
		return StringName()
