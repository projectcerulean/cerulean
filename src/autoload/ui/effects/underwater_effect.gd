# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends ColorRect

@export var _environment_resource: Resource

@onready var environment_resource: EnvironmentResource = _environment_resource as EnvironmentResource
@onready var shader_material: ShaderMaterial = material as ShaderMaterial


func _ready() -> void:
	Signals.water_entered.connect(self._on_water_entered)
	Signals.water_exited.connect(self._on_water_exited)
	Signals.scene_changed.connect(self._on_scene_changed)
	assert(environment_resource != null, Errors.NULL_RESOURCE)
	assert(shader_material != null, Errors.NULL_RESOURCE)


func _process(_delta: float) -> void:
	shader_material.set_shader_parameter(&"color", environment_resource.value.water_screen_effect_color)


func _on_water_entered(sender: Area3D) -> void:
	if sender.owner == get_viewport().get_camera_3d().owner:
		visible = true


func _on_water_exited(sender: Area3D) -> void:
	if sender.owner == get_viewport().get_camera_3d().owner:
		visible = false


func _on_scene_changed(_sender: Node) -> void:
	visible = false
