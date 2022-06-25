# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends PlayerState

@export var move_speed: float = 8.5
@export var move_speed_lerp_weight: float = 1.0
@export var jump_speed: float = 10.0
@export var jump_acceleration: float = 10.0


func enter(data: Dictionary) -> void:
	super.enter(data)
	player.velocity.y = jump_speed
	player.coyote_timer.stop()
	player.jump_buffer_timer.stop()


func physics_process(delta: float) -> void:
	super.physics_process(delta)

	# Apply movement
	var velocity_xz: Vector3 = Vector3(player.velocity.x, 0.0, player.velocity.z)
	var velocity_xz_target: Vector3

	if velocity_xz.is_equal_approx(Vector3.ZERO) or player.input_vector.is_equal_approx(Vector3.ZERO) or velocity_xz.length() < move_speed:
		velocity_xz_target = player.input_vector * move_speed
	else:
		var delta_angle: float = velocity_xz.angle_to(player.input_vector)
		if delta_angle < PI / 2.0:
			# We want ta maintain all speed while in the air, even if it is higher than move_speed
			var move_speed_extended: float = Math.ellipse(Vector2(velocity_xz.length(), move_speed), delta_angle)
			velocity_xz_target = player.input_vector.normalized() *  move_speed_extended
			pass
		else:
			velocity_xz_target = player.input_vector * move_speed

	var velocity_xz_new = Lerp.delta_lerp3(velocity_xz, velocity_xz_target, move_speed_lerp_weight, delta)
	player.velocity = Vector3(velocity_xz_new.x, player.velocity.y + (jump_acceleration - Physics.GRAVITY) * delta, velocity_xz_new.z)
	player.move_and_slide()


func get_transition() -> StringName:
	if player.is_in_water():
		return PlayerStates.SWIM
	elif player.is_on_floor():
		if is_equal_approx(player.velocity.x, 0.0) and is_equal_approx(player.velocity.z, 0.0):
			return PlayerStates.IDLE
		else:
			return PlayerStates.RUN
	elif player.velocity.y < 0 or not Input.is_action_pressed(InputActions.JUMP):
		return PlayerStates.FALL
	else:
		return StringName()
