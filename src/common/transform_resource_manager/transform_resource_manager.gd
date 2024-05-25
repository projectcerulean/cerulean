# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name TransformResourceManager
extends Node3D

@export var transform_resource: TransformResource


func _ready() -> void:
	Signals.scene_changed.connect(self._on_scene_changed)
	assert(transform_resource != null, Errors.NULL_RESOURCE)
	transform_resource.claim_ownership(self)
	update_resource()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		transform_resource.release_ownership(self)


func _process(_delta: float) -> void:
	update_resource()


func _on_scene_changed(_sender: NodePath) -> void:
	update_resource()


func update_resource() -> void:
	transform_resource.set_value(self, global_transform)
