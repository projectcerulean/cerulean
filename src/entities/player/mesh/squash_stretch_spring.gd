# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name SquashStretchSpring
extends Node3D

@export var spring_constant: float = 500.0
@export var damping_constant: float = 15.0
@export var rest_length: float = 1.0

var velocity: float = 0.0
var is_initialized: bool = false

@onready var parent: Node3D = get_parent() as Node3D


func _ready() -> void:
	assert(parent != null, Errors.NULL_NODE)


func _physics_process(delta: float) -> void:
	if not is_initialized:
		global_position.y = parent.global_position.y + rest_length
		is_initialized = true
		return

	# Use physics process since spring simulation is unstable at large timesteps/low framerates.
	global_position.x = parent.global_position.x
	global_position.z = parent.global_position.z

	velocity -= velocity * damping_constant * delta
	velocity -= spring_constant * (global_position.y - parent.global_position.y - rest_length) * delta
	global_position.y += velocity * delta
