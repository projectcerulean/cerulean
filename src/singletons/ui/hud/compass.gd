# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Control

@onready var scroll_container: ScrollContainer = get_node("ScrollContainer") as ScrollContainer
@onready var label_n1: Label = get_node("ScrollContainer/HBoxContainer/N") as Label
@onready var label_n2: Label = get_node("ScrollContainer/HBoxContainer/N2") as Label


func _ready() -> void:
	assert(scroll_container != null, Errors.NULL_NODE)
	assert(label_n1 != null, Errors.NULL_NODE)
	assert(label_n2 != null, Errors.NULL_NODE)


func _process(_delta: float) -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null:
		return

	var label_n1_scroll_pos: float = label_n1.position.x
	var label_n2_scroll_pos: float = label_n2.position.x
	var scroll_period_length: float = label_n2_scroll_pos - label_n1_scroll_pos

	var camera_vector: Vector3 = -camera.global_transform.basis.z
	camera_vector.y = 0.0
	camera_vector = camera_vector.normalized()

	var camera_angle: float = wrapf(camera_vector.signed_angle_to(Cardinal.NORTH, Vector3.UP), 0.0, TAU)
	var camera_angle_scroll_position: float = remap(camera_angle, 0.0, TAU, 0.0, scroll_period_length)

	var scroll_position_offset: float = scroll_container.size.x / 2.0 - label_n1.size.x / 2.0

	var scroll_position: float = wrapf(camera_angle_scroll_position - scroll_position_offset, 0.0, scroll_period_length)
	scroll_container.scroll_horizontal = roundi(scroll_position)
