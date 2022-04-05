# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends PlayerState


func enter(data: Dictionary) -> void:
	super.enter(data)
	player.velocity = Vector3.ZERO


func get_transition() -> StringName:
	if player.is_in_water() and player.global_transform.origin.y < player.get_water_surface_height() - water_state_enter_offset:
		return PlayerStates.SWIM
	elif not player.are_raycasts_colliding():
		return PlayerStates.FALL
	elif Input.is_action_just_pressed("player_move_jump") or not player.jump_buffer_timer.is_stopped():
		return PlayerStates.JUMP
	elif not player.thumbstick_resource_left.value.is_equal_approx(Vector2.ZERO):
		return PlayerStates.RUN
	else:
		return StringName()
