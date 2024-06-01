# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node3D

@export var spring_constant: float = 500.0
@export var damping_constant: float = 15.0
@export var spring_length: float = 1.0

var velocity: float = 0.0

@onready var parent: Node3D = get_parent() as Node3D


func _ready() -> void:
	assert(parent != null, Errors.NULL_NODE)


func _physics_process(delta: float) -> void:
	# Use physics process since spring simulation is unstable at large timesteps/low framerates.
	global_position.x = parent.global_position.x
	global_position.z = parent.global_position.z

	velocity -= velocity * damping_constant * delta
	velocity -= spring_constant * (global_position.y - parent.global_position.y - spring_length) * delta
	global_position.y += velocity * delta
