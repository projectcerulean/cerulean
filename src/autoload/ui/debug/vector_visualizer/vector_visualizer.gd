# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends ColorRect

var vectors: Dictionary
var colors: Dictionary


func _ready() -> void:
	Signals.visualize_vector.connect(self._on_visualize_vector)
	assert(size.x == size.y, Errors.INVALID_ARGUMENT)
	assert(size.x > 0, Errors.INVALID_ARGUMENT)


func _draw() -> void:
	var center_point: Vector2 = size / 2.0
	var radius: float = size.x / 2.0
	draw_circle(center_point, 16.0, Color.LIGHT_SLATE_GRAY)
	draw_arc(center_point, radius, 0, 2 * PI, 128, Color.LIGHT_SLATE_GRAY, 2.0, true)
	for sender in vectors:
		var vector: Vector2 = vectors[sender]
		if vector.length_squared() > 1.0:
			vector = vector.normalized()
		draw_line(center_point, center_point + vector * radius, colors[sender], 8.0)


func _on_visualize_vector(sender: Node, vector: Vector2) -> void:
	visible = true
	vectors[sender] = vector
	if not colors.has(sender):
		colors[sender] = Utils.str_to_color(sender.name)
	update()
