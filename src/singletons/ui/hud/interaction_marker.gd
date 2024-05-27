# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Control

@export var color: Color = Color.WHITE
@export var lfo_value_resource: FloatResource
@export var game_state_resource: StateResource
@export var oscillation_amplitude: float = 128.0
@export var scale_factor_min: float = 0.25
@export var tween_time: float = 1.0
@export var polygon_shape: PackedVector2Array = PackedVector2Array([
	Vector2(-128.0, -128.0),
	Vector2(128.0, -128.0),
	Vector2(0.0, 0.0),
])

var scale_factor: float = 1.0
var target: NodePath = NodePath()

@onready var color_default: Color = color
@onready var tween: Tween


func _ready() -> void:
	Signals.interaction_highlight_set.connect(self._on_interaction_highlight_set)
	Signals.request_interaction.connect(self._on_request_interaction)
	assert(lfo_value_resource != null, Errors.NULL_RESOURCE)
	assert(game_state_resource != null, Errors.NULL_RESOURCE)


func _draw() -> void:
	if (
		not game_state_resource.is_owned()
		or game_state_resource.get_current_state() != GameStates.GAMEPLAY
	):
		return

	if target == null:
		return

	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null:
		return

	var target_node: Node3D = get_node_or_null(target) as Node3D
	if is_instance_valid(target_node):
		var position3d: Vector3 = target_node.global_position
		if not camera.is_position_behind(position3d):
			var position2d: Vector2 = camera.unproject_position(position3d)
			var camera_distance: float = (camera.global_position - position3d).length()
			var vertex_positions: PackedVector2Array = PackedVector2Array(polygon_shape)
			for i: int in range(vertex_positions.size()):
				vertex_positions[i] *= scale_factor
				vertex_positions[i] /= camera_distance
				vertex_positions[i] += position2d - Vector2(0.0, oscillation_amplitude * absf(lfo_value_resource.get_value()) / camera_distance)
			draw_polygon(vertex_positions, PackedColorArray([color, color, color]))


func _process(_delta: float) -> void:
	queue_redraw()


func _on_interaction_highlight_set(_sender: NodePath, highlight_target: NodePath) -> void:
	if highlight_target != NodePath() and highlight_target != target:
		animate()
	target = highlight_target


func _on_request_interaction(_sender: NodePath) -> void:
	if target != NodePath():
		animate()


func animate() -> void:
	scale_factor = scale_factor_min
	color = Color.WHITE
	if tween != null:
		tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale_factor", 1.0, tween_time)
	tween.parallel().set_trans(Tween.TRANS_QUINT)
	tween.parallel().set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "color", color_default, tween_time)
