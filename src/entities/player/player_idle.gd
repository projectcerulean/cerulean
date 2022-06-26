# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends PlayerState


func enter(data: Dictionary) -> void:
	super.enter(data)
	player.velocity = Vector3.ZERO
	player.floor_snap_length = floor_snap_length


func exit(data: Dictionary) -> void:
	super.exit(data)
	player.floor_snap_length = 0.0


func physics_process(delta: float) -> void:
	super.physics_process(delta)

	# Apply movement
	player.move_and_slide()

	# Coyote timer
	player.coyote_timer.start()


func get_transition() -> StringName:
	if player.is_in_water():
		return PlayerStates.SWIM
	elif not player.are_raycasts_colliding():
		return PlayerStates.FALL
	elif Input.is_action_just_pressed(InputActions.JUMP) or not player.jump_buffer_timer.is_stopped():
		return PlayerStates.JUMP
	elif not player.thumbstick_resource_left.value.is_equal_approx(Vector2.ZERO):
		return PlayerStates.RUN
	else:
		return StringName()
