# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends PlayerState

@export var jump_speed: float = 10.0

@onready var state_enter_timer: Timer = get_node("StateEnterTimer") as Timer

func _ready() -> void:
	super._ready()
	assert(state_enter_timer != null, Errors.NULL_NODE)


func enter(data: Dictionary) -> void:
	super.enter(data)
	state_enter_timer.start()
	player.coyote_timer.stop()
	player.jump_buffer_timer.stop()

	player.enqueue_minimum_velocity(jump_speed * Vector3.UP)

	# Newton's third
	var rigid_body: RigidBody3D = player.get_floor_collider() as RigidBody3D
	if rigid_body != null:
		var impulse: Vector3 = player.mass * (jump_speed - player.linear_velocity.y) * Vector3.UP
		var impulse_position: Vector3 = player.get_floor_collision_position() - rigid_body.global_position
		rigid_body.apply_impulse(-impulse, impulse_position)


func physics_process(delta: float) -> void:
	super.physics_process(delta)
	player.perform_planar_movement(player.planar_input_vector, delta)


func get_transition() -> StringName:
	if not Input.is_action_pressed(InputActions.JUMP):
		return PlayerStates.FALL
	elif player.linear_velocity.y < 0.0 and state_enter_timer.is_stopped():
		if Input.is_action_pressed(InputActions.GLIDE):
			return PlayerStates.GLIDE
		else:
			return PlayerStates.FALL
	else:
		return StringName()
