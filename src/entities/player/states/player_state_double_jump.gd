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
	assert(player.can_double_jump, Errors.CONSISTENCY_ERROR)
	player.can_double_jump = false

	player.enqueue_minimum_velocity(jump_speed * Vector3.UP)


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
