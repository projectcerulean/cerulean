# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends PlayerState

@export var buoyancy_speed: float = 10.0
@export var buoyancy_acceleration_time: float = 2.0
@export var surface_level_check_leniency_factor: float = 2.0

@onready var state_enter_timer: Timer = get_node("StateEnterTimer") as Timer
@onready var buoyancy_friction_coefficient: float = calculate_friction_coefficient(buoyancy_acceleration_time)
@onready var buoyancy_force: float = calculate_move_force(buoyancy_speed, buoyancy_friction_coefficient)


func _ready() -> void:
	super._ready()
	assert(state_enter_timer != null, Errors.NULL_NODE)


func enter(data: Dictionary) -> void:
	super.enter(data)
	state_enter_timer.start()


func physics_process(delta: float) -> void:
	super.physics_process(delta)

	# Apply movement
	player.perform_planar_movement(player.planar_input_vector, delta)

	# Buoyancy
	if player.water_detector.is_in_water():
		var depth: float = player.water_detector.get_water_surface_height() - player.water_detector.global_position.y
		player.enqueue_force(Vector3.UP * (buoyancy_force * clampf(depth, 0.0, 1.0) - buoyancy_friction_coefficient*player.linear_velocity.y))

	# Coyote timer
	player.coyote_timer.start()

	# Jump buffering
	if Input.is_action_just_pressed(InputActions.JUMP):
		player.jump_buffer_timer.start()


func get_transition() -> StringName:
	var shape: Shape3D = player.collision_shape.shape
	var bottom_point_height: float = (
		player.collision_shape.global_position.y
		- surface_level_check_leniency_factor * ShapeUtils.get_shape_height(shape) / 2.0
	)
	var top_point_height: float = (
		player.collision_shape.global_position.y
		+ surface_level_check_leniency_factor * ShapeUtils.get_shape_height(shape) / 2.0
	)

	if player.is_on_floor() and player.global_position.y > player.water_detector.get_water_surface_height():
		return PlayerStates.RUN
	elif bottom_point_height > player.water_detector.get_water_surface_height():
		if Input.is_action_pressed(InputActions.JUMP):
			return PlayerStates.GLIDE
		else:
			return PlayerStates.FALL
	elif Input.is_action_just_pressed(InputActions.JUMP) or not player.jump_buffer_timer.is_stopped():
		if (
			state_enter_timer.is_stopped()
			and top_point_height > player.water_detector.get_water_surface_height()
			and bottom_point_height < player.water_detector.get_water_surface_height()
		):
			return PlayerStates.JUMP
	elif Input.is_action_just_pressed(InputActions.SWIM_DOWNWARDS):
		return PlayerStates.DIVE
	return StringName()
