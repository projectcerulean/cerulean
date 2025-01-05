# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends PlayerState

@export var _sfx_resource: Resource

@onready var state_enter_timer: Timer = get_node("StateEnterTimer") as Timer
@onready var sfx_resource: SfxResource = _sfx_resource as SfxResource


func _ready() -> void:
	super._ready()
	assert(state_enter_timer != null, Errors.NULL_NODE)


func enter(data: Dictionary) -> void:
	super.enter(data)
	state_enter_timer.start()
	Signals.emit_request_sfx_play(self, sfx_resource, player.global_position)


func physics_process(delta: float) -> void:
	super.physics_process(delta)
	player.coyote_timer.stop()
	player.jump_buffer_timer.stop()

	# Apply movement
	player.perform_planar_movement(player.planar_input_vector, delta)


func get_transition() -> StringName:
	if not Input.is_action_pressed(InputActions.GLIDE):
		return PlayerStates.FALL
	elif state_enter_timer.is_stopped() and player.linear_velocity.y < 0.0:
		if Input.is_action_pressed(InputActions.GLIDE):
			return PlayerStates.GLIDE
		else:
			return PlayerStates.FALL
	elif Input.is_action_just_pressed(InputActions.JUMP) and player.can_double_jump:
		return PlayerStates.DOUBLE_JUMP
	else:
		return StringName()
