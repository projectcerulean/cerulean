# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends PlayerState

@export var move_speed: float = 7.0
@export var move_speed_lerp_weight: float = 1.0
@export var water_buoyancy_speed: float = 4.0
@export var water_bouyancy_speed_lerp_weight: float = 1.0

var surfaced: bool


func enter(data: Dictionary) -> void:
	super.enter(data)
	if data[OLD_STATE] == PlayerStates.DIVE:
		surfaced = true
	else:
		surfaced = false


func physics_process(delta: float) -> void:
	super.physics_process(delta)

	# Apply movement
	var velocity_xz: Vector3 = Vector3(player.velocity.x, 0.0, player.velocity.z)
	velocity_xz = Lerp.delta_lerp3(velocity_xz, player.input_vector * move_speed, move_speed_lerp_weight, delta)
	var velocity_y: float = player.velocity.y
	if surfaced:
		velocity_y = 0.0
		if not is_inf(player.get_water_surface_height()):
			player.global_transform.origin.y = player.get_water_surface_height()
	else:
		velocity_y = Lerp.delta_lerp(velocity_y, water_buoyancy_speed, water_bouyancy_speed_lerp_weight, delta)
		player.velocity = Lerp.delta_lerp3(player.velocity, player.input_vector * move_speed, move_speed_lerp_weight, delta)
		if not is_inf(player.get_water_surface_height()) and player.velocity.y > 0.0 and player.global_transform.origin.y > player.get_water_surface_height():
			surfaced = true
	player.velocity = Vector3(velocity_xz.x, velocity_y, velocity_xz.z)
	player.move_and_slide()

	# Coyote timer
	player.coyote_timer.start()

	# Jump buffering
	if Input.is_action_just_pressed(InputActions.JUMP):
		player.jump_buffer_timer.start()


func get_transition() -> StringName:
	if not player.is_in_water() and player.are_raycasts_colliding():
		return PlayerStates.RUN
	elif not player.is_in_water() and is_inf(player.get_water_surface_height()):
		return PlayerStates.FALL
	elif Input.is_action_just_pressed(InputActions.JUMP) or not player.jump_buffer_timer.is_stopped():
		if surfaced:
			return PlayerStates.JUMP
	elif Input.is_action_just_pressed(InputActions.DIVE):
		return PlayerStates.DIVE
	else:
		return StringName()
