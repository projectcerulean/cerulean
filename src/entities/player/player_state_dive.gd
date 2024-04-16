# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends PlayerState

@export var move_speed: float = 7.0
@export var acceleration_time: float = 3.0
@export var surface_level_check_leniency_factor: float = 2.0

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

	var shape: Shape3D = player.collision_shape.shape
	var top_point_height: float = player.collision_shape.global_position.y + ShapeUtils.get_shape_height(shape) / 2.0

	# Apply movement
	var input_strength_up: float = Input.get_action_strength(InputActions.SWIM_UPWARDS) if top_point_height < player.water_detector.get_water_surface_height() else 0.0
	var input_strength_down: float = Input.get_action_strength(InputActions.SWIM_DOWNWARDS)
	var input_strength_vertical: float = input_strength_up - input_strength_down
	if input_strength_vertical < 0.0 and player.is_on_floor():
		input_strength_vertical = 0.0
	var input_vector: Vector3 = (
		player.input_vector + Vector3.UP * input_strength_vertical
	).limit_length()

	# Apply movement
	player.enqueue_force(input_vector * move_force - move_friction_coefficient * player.linear_velocity)


func get_transition() -> StringName:
	var shape: Shape3D = player.collision_shape.shape
	var top_point_height: float = (
		player.collision_shape.global_position.y
		+ surface_level_check_leniency_factor * ShapeUtils.get_shape_height(shape) / 2.0
	)

	if top_point_height > player.water_detector.get_water_surface_height() and state_enter_timer.is_stopped():
		return PlayerStates.SWIM
	else:
		return StringName()
