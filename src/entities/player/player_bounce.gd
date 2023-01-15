# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends PlayerState

@export var move_speed: float = 8.5
@export var acceleration_time: float = 3.0
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
	var linear_velocity_planar: Vector3 = player.linear_velocity * Vector3(1.0, 0.0, 1.0)
	if (linear_velocity_planar).length() < move_speed:
		var move_friction_coefficient: float = calculate_friction_coefficient(acceleration_time)
		var move_force: float = calculate_move_force(move_speed, move_friction_coefficient)
		player.enqueue_force(player.input_vector * move_force - move_friction_coefficient * linear_velocity_planar)
	else:
		var move_friction_coefficient_parallel: float = calculate_friction_coefficient(acceleration_time * linear_velocity_planar.length() / move_speed)
		var move_friction_coefficient_perpendicular: float = calculate_friction_coefficient(acceleration_time)
		var move_force_parallel: float = calculate_move_force(linear_velocity_planar.length(), move_friction_coefficient_parallel)
		var move_force_perpendicular: float = calculate_move_force(move_speed, move_friction_coefficient_perpendicular)

		var input_vector_parallel = player.input_vector.project(linear_velocity_planar)
		var input_vector_perpendicular = player.input_vector.project(linear_velocity_planar.cross(Vector3.UP))

		player.enqueue_force(
			input_vector_parallel * move_force_parallel - move_friction_coefficient_parallel * linear_velocity_planar
			+ input_vector_perpendicular * move_force_perpendicular
		)


func get_transition() -> StringName:
	if not Input.is_action_pressed(InputActions.JUMP):
		return PlayerStates.FALL
	elif state_enter_timer.is_stopped() and player.linear_velocity.y < 0.0:
		if Input.is_action_pressed(InputActions.JUMP):
			return PlayerStates.GLIDE
		else:
			return PlayerStates.FALL
	else:
		return StringName()
