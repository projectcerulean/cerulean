# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name InteractionManager
extends Node3D

var _closest_interactable_prev: Interactable
var _should_perform_interaction: bool

@onready var _area_3d: Area3D = get_node("Area3D") as Area3D
@onready var _raycast: RayCast3D = get_node("RayCast3D") as RayCast3D


func _ready() -> void:
	assert(_area_3d != null, Errors.NULL_NODE)
	assert(_raycast != null, Errors.NULL_NODE)


func _process(_delta: float) -> void:
	var closest_interactable: Interactable = null
	var distance_squared_min: float = INF

	# Want to find the closest interactable that's not behind a wall or other solid object
	for overlapping_area: Area3D in _area_3d.get_overlapping_areas():
		var interactable: Interactable = overlapping_area as Interactable
		assert(interactable != null, Errors.NULL_NODE)

		var distance_squared: float = interactable.global_position.distance_squared_to(global_position)

		_raycast.target_position = interactable.global_position - _raycast.global_position
		_raycast.force_raycast_update()

		if distance_squared < distance_squared_min and not _raycast.is_colliding():
			closest_interactable = interactable
			distance_squared_min = distance_squared

	if closest_interactable != _closest_interactable_prev:
		var closest_interactable_path: NodePath = closest_interactable.get_path() if closest_interactable != null else NodePath()
		Signals.emit_closest_interactable_changed(self, closest_interactable_path)

	if _should_perform_interaction:
		if closest_interactable != null:
			closest_interactable.interact()
			var closest_interactable_path: NodePath = closest_interactable.get_path()
			Signals.emit_interaction_performed(self, closest_interactable_path)
		_should_perform_interaction = false

	_closest_interactable_prev = closest_interactable


func perform_interaction() -> void:
	_should_perform_interaction = true
