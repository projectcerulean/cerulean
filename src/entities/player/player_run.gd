# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends PlayerState

@export var move_speed: float = 8.5
@export var acceleration_time: float = 0.3

@onready var move_friction_coefficient: float = calculate_friction_coefficient(acceleration_time)
@onready var move_force: float = calculate_move_force(move_speed, move_friction_coefficient)


func physics_process(delta: float) -> void:
	super.physics_process(delta)

	# Apply movement
	player.force_vector = player.input_vector * move_force - move_friction_coefficient * player.linear_velocity * Vector3(1.0, 0.0, 1.0)

	# Coyote timer
	player.coyote_timer.start()


func get_transition() -> StringName:
	if player.global_position.y < player.water_detector.get_water_surface_height():
		return PlayerStates.SWIM
	elif not player.is_on_floor():
		return PlayerStates.FALL
	elif Input.is_action_just_pressed(InputActions.JUMP) or not player.jump_buffer_timer.is_stopped():
		return PlayerStates.JUMP
	elif player.linear_velocity.is_equal_approx(Vector3.ZERO):
		return PlayerStates.IDLE
	else:
		return StringName()
