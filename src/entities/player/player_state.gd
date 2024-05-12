# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name PlayerState extends State

@export var reset_double_jump: bool = false
@export var gravity_scale: float = 1.0
@export var hover_force_downwards_enabled: bool = true
@export var hover_force_upwards_enabled: bool = true
@export var planar_move_speed_max: float = 8.5
@export var planar_movement_pid_p_gain_factor: float = 12.0
@export_range(0.0, 1.0, 0.001) var planar_momentum_conservation_factor: float = 0.0

var gravity_scale_prev: bool = false
var hover_force_downwards_enabled_prev: bool = false
var hover_force_upwards_enabled_prev: bool = false
var planar_move_speed_max_prev: float = NAN
var planar_movement_pid_p_gain_factor_prev: float = NAN
var planar_momentum_conservation_factor_prev: float = NAN

# Reference to the player object so that it can be manipulated inside the states
@onready var player: Player = owner as Player


func _ready() -> void:
	assert(player != null, Errors.NULL_NODE)


func enter(data: Dictionary) -> void:
	super.enter(data)
	if reset_double_jump:
		player.can_double_jump = true
	gravity_scale_prev = player.gravity_scale
	player.gravity_scale = gravity_scale
	hover_force_downwards_enabled_prev = hover_force_downwards_enabled
	player.hover_force_downwards_enabled = hover_force_downwards_enabled
	hover_force_upwards_enabled_prev = player.hover_force_upwards_enabled
	player.hover_force_upwards_enabled = hover_force_upwards_enabled
	planar_move_speed_max_prev = player.planar_move_speed_max
	player.planar_move_speed_max = planar_move_speed_max
	planar_movement_pid_p_gain_factor_prev = player.planar_movement_pid_p_gain_factor
	player.planar_movement_pid_p_gain_factor = planar_movement_pid_p_gain_factor
	planar_momentum_conservation_factor_prev = player.planar_momentum_conservation_factor
	player.planar_momentum_conservation_factor = planar_momentum_conservation_factor


func exit(_data: Dictionary) -> void:
	player.gravity_scale = gravity_scale_prev
	player.hover_force_downwards_enabled = hover_force_downwards_enabled_prev
	player.hover_force_upwards_enabled = hover_force_upwards_enabled_prev
	player.planar_move_speed_max = planar_move_speed_max_prev
	player.planar_movement_pid_p_gain_factor = planar_movement_pid_p_gain_factor_prev
	player.planar_momentum_conservation_factor = planar_momentum_conservation_factor_prev


func calculate_friction_coefficient(acceleration_time: float):
	var body: RigidBody3D = owner as RigidBody3D
	return -body.mass/acceleration_time * log(0.01)


func calculate_move_force(move_speed: float, friction_coefficient: float):
	return move_speed * friction_coefficient
