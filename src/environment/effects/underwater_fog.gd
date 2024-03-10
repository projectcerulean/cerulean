# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
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
	handle_water_entered_exited_signal(sender, true)


func _on_water_exited(sender: NodePath) -> void:
	handle_water_entered_exited_signal(sender, false)


func handle_water_entered_exited_signal(sender: NodePath, is_water_entered: bool) -> void:
	var sender_node: Node = get_node(sender)
	if is_instance_valid(sender_node):
		var sender_node_owner: Node = sender_node.owner
		if is_instance_valid(sender_node_owner):
			var viewport: Viewport = get_viewport()
			if is_instance_valid(viewport):
				var camera: Camera3D = viewport.get_camera_3d()
				if is_instance_valid(camera):
					var camera_owner: Node = camera.owner
					if is_instance_valid(camera_owner):
						if is_same(sender_node_owner, camera_owner):
							environment_resource.value.fog_enabled = is_water_entered
