# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node3D

@export var spring_constant: float = 500.0
@export var damping_constant: float = 0.25
@export var spring_length: float = 1.0

var velocity: float = 0.0

@onready var parent: Node3D = get_parent() as Node3D


func _ready() -> void:
	assert(parent != null, Errors.NULL_NODE)


func _process(delta: float) -> void:
	global_transform.origin.x = parent.global_transform.origin.x
	global_transform.origin.z = parent.global_transform.origin.z

	velocity -= velocity * damping_constant
	velocity -= spring_constant * (global_transform.origin.y - parent.global_transform.origin.y - spring_length) * delta
	global_transform.origin.y += velocity * delta
