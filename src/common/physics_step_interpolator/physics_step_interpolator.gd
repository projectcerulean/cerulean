# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node3D

@onready var parent: Node3D = get_parent() as Node3D
@onready var parent_transform: Transform3D
@onready var parent_transform_prev: Transform3D


func _ready() -> void:
	top_level = false


func _process(delta: float) -> void:
	var fraction: float = Engine.get_physics_interpolation_fraction()
	global_transform = parent_transform_prev.interpolate_with(parent_transform, fraction)


func _physics_process(_delta: float) -> void:
	parent_transform_prev = parent_transform
	parent_transform = parent.get_global_transform()
