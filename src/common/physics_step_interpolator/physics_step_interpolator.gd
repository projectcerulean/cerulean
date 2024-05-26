# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
@tool
extends Node3D

@onready var parent: Node3D = get_parent() as Node3D
@onready var parent_transform: Transform3D
@onready var parent_transform_prev: Transform3D


func _ready() -> void:
	if Engine.is_editor_hint():
		get_tree().tree_changed.connect(update_configuration_warnings)
	else:
		top_level = false


func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		var fraction: float = Engine.get_physics_interpolation_fraction()
		global_transform = parent_transform_prev.interpolate_with(parent_transform, fraction)


func _physics_process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		parent_transform_prev = parent_transform
		parent_transform = parent.get_global_transform()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not is_instance_valid(get_parent() as Node3D):
		warnings.append("Parent is not a Node3D")
	return warnings
