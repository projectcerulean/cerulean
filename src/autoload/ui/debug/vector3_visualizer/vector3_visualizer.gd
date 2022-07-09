# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Control

@export var line_width: float = 10.0
@export var max_length: float = 5.0

var vectors_from: Dictionary
var vectors_to: Dictionary
var colors: Dictionary

@onready var camera: Camera3D = get_viewport().get_camera_3d()


func _ready() -> void:
	Signals.scene_changed.connect(_on_scene_changed)
	Signals.visualize_vector3.connect(_on_visualize_vector3)
	assert(camera != null, Errors.NULL_NODE)


func _draw() -> void:
	for sender in vectors_from:
		var p1: Vector3 = vectors_from[sender]
		var p2: Vector3 = p1 + vectors_to[sender].limit_length(max_length)
		if not camera.is_position_behind(p1) and not camera.is_position_behind(p2):
			draw_line(camera.unproject_position(p1), camera.unproject_position(p2), colors[sender], line_width, true)


func _on_scene_changed(sender: Node):
	vectors_from.clear()
	vectors_to.clear()
	colors.clear()


func _on_visualize_vector3(sender: Node3D, vector: Vector3):
	vectors_from[sender] = sender.global_transform.origin
	vectors_to[sender] = vector
	if not colors.has(sender):
		colors[sender] = Utils.str_to_color(sender.name)
	update()
