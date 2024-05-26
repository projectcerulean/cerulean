# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
@tool
class_name TransformResourceManager
extends Node3D

@export var transform_resource: TransformResource:
	set(value):
		if not is_same(value, transform_resource):
			transform_resource = value
			update_configuration_warnings()


func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		assert(transform_resource != null, Errors.NULL_RESOURCE)
		transform_resource.claim_ownership(self)


func _exit_tree() -> void:
	if not Engine.is_editor_hint():
		transform_resource.release_ownership(self)


func _ready() -> void:
	if not Engine.is_editor_hint():
		Signals.scene_changed.connect(self._on_scene_changed)
		update_resource()


func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		update_resource()


func _on_scene_changed(_sender: NodePath) -> void:
	if not Engine.is_editor_hint():
		update_resource()


func update_resource() -> void:
	if not Engine.is_editor_hint():
		transform_resource.set_value(self, global_transform)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not is_instance_valid(transform_resource):
		warnings.append("Transform resource not set")
	return warnings
