# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name PlayerState extends State

@export var reset_double_jump: bool = false
@export var gravity_scale: float = 1.0
@export var hover_spring_pull_downwards: bool = true
@export var hover_spring_pull_upwards: bool = true

var gravity_scale_prev: bool = false
var hover_spring_pull_downwards_prev: bool = false
var hover_spring_pull_upwards_prev: bool = false

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
	hover_spring_pull_downwards_prev = hover_spring_pull_downwards
	player.hover_spring_pull_downwards = hover_spring_pull_downwards
	hover_spring_pull_upwards_prev = player.hover_spring_pull_upwards
	player.hover_spring_pull_upwards = hover_spring_pull_upwards


func exit(data: Dictionary) -> void:
	player.gravity_scale = gravity_scale_prev
	player.hover_spring_pull_downwards = hover_spring_pull_downwards_prev
	player.hover_spring_pull_upwards = hover_spring_pull_upwards_prev


func calculate_friction_coefficient(acceleration_time: float):
	var body: RigidBody3D = owner as RigidBody3D
	return -body.mass/acceleration_time * log(0.01)


func calculate_move_force(move_speed: float, friction_coefficient: float):
	return move_speed * friction_coefficient
