# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends PlayerState

@export var move_speed: float = 8.5
@export var acceleration_time: float = 3.0
@export var jump_speed: float = 10.0

@onready var move_friction_coefficient: float = calculate_friction_coefficient(acceleration_time)
@onready var move_force: float = calculate_move_force(move_speed, move_friction_coefficient)


func enter(data: Dictionary) -> void:
	super.enter(data)
	player.coyote_timer.stop()
	player.jump_buffer_timer.stop()

	var impulse: Vector3 = player.mass * (jump_speed - player.linear_velocity.y) * Vector3.UP
	player.apply_central_impulse(impulse)

	# Newton's third
	for _collision in player.floor_collisions:
		var collision: KinematicCollision3D = _collision as KinematicCollision3D
		for i in range(collision.get_collision_count()):
			var rigid_body: RigidDynamicBody3D = collision.get_collider(i) as RigidDynamicBody3D
			if rigid_body != null:
				var impulse_position: Vector3 = collision.get_position(i) - rigid_body.global_position
				rigid_body.apply_impulse(-impulse, impulse_position)


func physics_process(delta: float) -> void:
	super.physics_process(delta)

	# Apply movement
	player.force_vector = player.input_vector * move_force - move_friction_coefficient * player.linear_velocity * Vector3(1.0, 0.0, 1.0)


func get_transition() -> StringName:
	if player.linear_velocity.y < 0 or not Input.is_action_pressed(InputActions.JUMP):
		return PlayerStates.FALL
	else:
		return StringName()
