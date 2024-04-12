# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name PlayerState extends State

@export var gravity_scale: float = 1.0
@export var floor_snapping_enabled: bool = false

# Reference to the player object so that it can be manipulated inside the states
@onready var player: Player = owner as Player


func _ready() -> void:
	assert(player != null, Errors.NULL_NODE)


func enter(data: Dictionary) -> void:
	super.enter(data)
	print("Enter player state: ", name)
	player.gravity_scale = gravity_scale
	#player.floor_snapping_enabled = floor_snapping_enabled


func exit(data: Dictionary) -> void:
	super.exit(data)
	print("Exit player state: ", name)


func calculate_friction_coefficient(acceleration_time: float):
	var body: RigidBody3D = owner as RigidBody3D
	return -body.mass/acceleration_time * log(0.01)


func calculate_move_force(move_speed: float, friction_coefficient: float):
	return move_speed * friction_coefficient
