# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends ColorRect

@export var environment_resource: EnvironmentResource

@onready var shader_material: ShaderMaterial = material as ShaderMaterial


func _ready() -> void:
	Signals.water_entered.connect(self._on_water_entered)
	Signals.water_exited.connect(self._on_water_exited)
	Signals.scene_changed.connect(self._on_scene_changed)
	assert(environment_resource != null, Errors.NULL_RESOURCE)
	assert(shader_material != null, Errors.NULL_RESOURCE)


func _process(_delta: float) -> void:
	shader_material.set_shader_parameter(&"color", environment_resource.value.water_screen_effect_color)


func _on_water_entered(sender: NodePath) -> void:
	var sender_node: Node = get_node(sender)
	if is_instance_valid(sender_node):
		var sender_node_owner: Node = sender_node.owner
		if is_instance_valid(sender_node_owner) and sender_node_owner == get_viewport().get_camera_3d().owner:
			visible = true


func _on_water_exited(sender: NodePath) -> void:
	var sender_node: Node = get_node(sender)
	if is_instance_valid(sender_node):
		var sender_node_owner: Node = sender_node.owner
		if is_instance_valid(sender_node_owner) and sender_node_owner == get_viewport().get_camera_3d().owner:
			visible = false


func _on_scene_changed(_sender: NodePath) -> void:
	visible = false
