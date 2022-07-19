# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends PlayerState

@export var move_speed: float = 8.5
@export var acceleration_time: float = 3.0
@export var _sfx_resource: Resource



@onready var move_friction_coefficient: float = calculate_friction_coefficient(acceleration_time)
@onready var move_force: float = calculate_move_force(move_speed, move_friction_coefficient)
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
	player.bounce_buffer_timer.stop()
	player.jump_buffer_timer.stop()

	# Apply movement
	player.force_vector = player.input_vector * move_force - move_friction_coefficient * player.linear_velocity * Vector3(1.0, 0.0, 1.0)


func get_transition() -> StringName:
	if state_enter_timer.is_stopped() and (player.linear_velocity.y < 0 or not Input.is_action_pressed(InputActions.JUMP)):
		return PlayerStates.FALL
	else:
		return StringName()
