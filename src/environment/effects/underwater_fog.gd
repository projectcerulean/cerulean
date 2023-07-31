# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node

@export var _environment_resource: Resource

@onready var environment_resource: EnvironmentResource = _environment_resource as EnvironmentResource


func _ready() -> void:
	Signals.water_entered.connect(self._on_water_entered)
	Signals.water_exited.connect(self._on_water_exited)
	assert(environment_resource != null, Errors.NULL_RESOURCE)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		environment_resource.value.fog_enabled = false


func _on_water_entered(sender: NodePath) -> void:
	var sender_node: Node = get_node(sender)
	if is_instance_valid(sender_node):
		var sender_node_owner: Node = sender_node.owner
		if is_instance_valid(sender_node_owner) and sender_node_owner == get_viewport().get_camera_3d().owner:
			environment_resource.value.fog_enabled = true


func _on_water_exited(sender: NodePath) -> void:
	var sender_node: Node = get_node(sender)
	if is_instance_valid(sender_node):
		var sender_node_owner: Node = sender_node.owner
		if is_instance_valid(sender_node_owner) and sender_node_owner == get_viewport().get_camera_3d().owner:
			environment_resource.value.fog_enabled = false
