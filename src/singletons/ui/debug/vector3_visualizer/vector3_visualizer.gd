# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Control

@export var line_width: float = 10.0

var vectors_from: Dictionary
var vectors_to: Dictionary
var colors: Dictionary


func _ready() -> void:
	Signals.scene_changed.connect(_on_scene_changed)
	Signals.visualize_vector3.connect(_on_visualize_vector3)


func _draw() -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if is_instance_valid(camera):
		for sender: NodePath in vectors_from:
			var point_from: Vector3 = vectors_from[sender]
			var point_to: Vector3 = vectors_to[sender]
			if not camera.is_position_behind(point_from) and not camera.is_position_behind(point_to):
				@warning_ignore("unsafe_cast")
				var color: Color = colors[sender] as Color
				draw_line(camera.unproject_position(point_from), camera.unproject_position(point_to), color, line_width, true)


func _on_scene_changed(_sender: NodePath) -> void:
	vectors_from.clear()
	vectors_to.clear()
	colors.clear()


func _on_visualize_vector3(sender: NodePath, from: Vector3, to: Vector3) -> void:
	vectors_from[sender] = from
	vectors_to[sender] = to
	if not colors.has(sender):
		var sender_name: StringName = NodePathUtils.get_node_name(sender)
		colors[sender] = ColorUtils.variant_to_color(sender_name)
	queue_redraw()
