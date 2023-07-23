# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name TransformResourceManager
extends Node3D

@export var _transform_resource: Resource

@onready var transform_resource: TransformResource = _transform_resource as TransformResource


func _ready() -> void:
	Signals.scene_changed.connect(self._on_scene_changed)
	assert(transform_resource != null, Errors.NULL_RESOURCE)
	assert(transform_resource.value == Transform3D(), Errors.RESOURCE_BUSY)
	update_resource()


func _process(_delta: float) -> void:
	update_resource()


func _on_scene_changed(_sender: Node) -> void:
	update_resource()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		transform_resource.value = Transform3D()


func update_resource() -> void:
	transform_resource.value = global_transform
