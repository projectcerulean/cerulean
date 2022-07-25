# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node3D

@export var _transform_resource: Resource

@onready var transform_resource: TransformResource = _transform_resource as TransformResource


func _ready() -> void:
	assert(transform_resource != null, Errors.NULL_RESOURCE)
	assert(transform_resource.value == Transform3D(), Errors.RESOURCE_BUSY)
	transform_resource.value = global_transform


func _process(_delta: float) -> void:
	transform_resource.value = global_transform


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		transform_resource.value = Transform3D()
