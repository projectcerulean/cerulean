# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends PlayerState


func physics_process(delta: float) -> void:
	super.physics_process(delta)
	player.perform_planar_movement(player.planar_input_vector, delta)
	player.coyote_timer.start()


func get_transition() -> StringName:
	if player.global_position.y < player.water_detector.get_water_surface_height():
		return PlayerStates.SWIM
	elif not player.is_on_floor():
		if Input.is_action_pressed(InputActions.GLIDE):
			return PlayerStates.GLIDE
		else:
			return PlayerStates.FALL
	elif Input.is_action_just_pressed(InputActions.JUMP) or not player.jump_buffer_timer.is_stopped():
		return PlayerStates.JUMP
	elif not player.linear_velocity.is_equal_approx(Vector3.ZERO):
		return PlayerStates.RUN
	else:
		return StringName()
