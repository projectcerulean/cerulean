# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends PlayerState

@export var move_speed: float = 6.0
@export var acceleration_time: float = 3.0

@onready var move_friction_coefficient: float = calculate_friction_coefficient(acceleration_time)
@onready var move_force: float = calculate_move_force(move_speed, move_friction_coefficient)
@onready var state_enter_timer: Timer = get_node("StateEnterTimer") as Timer


func _ready() -> void:
	super._ready()
	assert(state_enter_timer != null, Errors.NULL_NODE)


func enter(data: Dictionary) -> void:
	super.enter(data)
	state_enter_timer.start()
	player.apply_central_impulse(2.5 * Vector3.DOWN)


func physics_process(delta: float) -> void:
	super.physics_process(delta)

	# Apply movement
	var input_vector: Vector3 = (
		player.input_vector + Vector3.UP * (
			float(Input.is_action_pressed(InputActions.JUMP) and player.top_point_height < player.water_detector.get_water_surface_height())
			- float(Input.is_action_pressed(InputActions.DIVE))
		)
	).limit_length()

	# Apply movement
	player.force_vector = input_vector * move_force - move_friction_coefficient * player.linear_velocity


func get_transition() -> StringName:
	if player.top_point_height > player.water_detector.get_water_surface_height() and state_enter_timer.is_stopped():
		return PlayerStates.SWIM
	else:
		return StringName()
