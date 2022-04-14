# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends PlayerState

@export var move_speed: float = 5.0
@export var move_speed_lerp_weight: float = 1.0


func physics_process(delta: float) -> void:
	super.physics_process(delta)

	# Apply movement
	var input_vector: Vector3 = (
		player.input_vector + Vector3.UP * (
			float(Input.is_action_pressed(InputActions.JUMP))
			- float(Input.is_action_pressed(InputActions.DIVE))
		)
	)
	if input_vector.length_squared() > 1.0:
		input_vector = input_vector.normalized()
	player.velocity = Lerp.delta_lerp3(player.velocity, move_speed * input_vector, move_speed_lerp_weight, delta)
	player.move_and_slide()


func get_transition() -> StringName:
	if not player.is_in_water():
		return PlayerStates.FALL
	elif player.velocity.y > 0.0 and player.global_transform.origin.y > player.get_water_surface_height():
		return PlayerStates.SWIM
	else:
		return StringName()
