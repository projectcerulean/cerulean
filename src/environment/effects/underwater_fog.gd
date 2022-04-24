# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node

@export var _environment_resource: Resource

@onready var environment_resource: EnvironmentResource = _environment_resource as EnvironmentResource


func _ready() -> void:
	Signals.camera_water_entered.connect(self._on_camera_water_entered)
	Signals.camera_water_exited.connect(self._on_camera_water_exited)
	assert(environment_resource != null, Errors.NULL_RESOURCE)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		environment_resource.value.fog_enabled = false


func _on_camera_water_entered(sender: Camera3D) -> void:
	if get_viewport().get_camera_3d() == sender:
		environment_resource.value.fog_enabled = true


func _on_camera_water_exited(sender: Camera3D) -> void:
	if get_viewport().get_camera_3d() == sender:
		environment_resource.value.fog_enabled = false
