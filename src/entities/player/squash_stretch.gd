# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node3D

@export var stretch_factor: float = 1.0
@export var stretch_min: float = 0.5
@export var stretch_max: float = 2.0

@onready var spring: Node3D = get_node("Spring") as Node3D
@onready var spring_length: float = spring.global_transform.origin.y - global_transform.origin.y


func _ready() -> void:
	assert(spring != null, Errors.NULL_NODE)


func _process(delta: float) -> void:
	var stretch: float = (spring.global_transform.origin.y - global_transform.origin.y) / spring_length
	stretch = 1.0 - stretch_factor * (1.0 - stretch)
	stretch = clamp(stretch, stretch_min, stretch_max)
	scale.x = 1.0 / sqrt(stretch)
	scale.y = stretch
	scale.z = 1.0 / sqrt(stretch)
