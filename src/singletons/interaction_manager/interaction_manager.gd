# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node

@export var _player_transform_resource: Resource

var interactables: Array[NodePath] = []

@onready var player_transform_resource: TransformResource = _player_transform_resource as TransformResource


func _ready() -> void:
	Signals.request_interaction.connect(self._on_request_interaction)
	Signals.request_interaction_highlight.connect(self._on_request_interaction_highlight)
	Signals.request_interaction_unhighlight.connect(self._on_request_interaction_unhighlight)
	Signals.scene_changed.connect(self._on_scene_changed)
	assert(player_transform_resource != null, Errors.NULL_RESOURCE)


func _process(_delta: float) -> void:
	if interactables.size() > 1:
		var hash_value: int = interactables.hash()
		interactables.sort_custom(interactables_sort)
		if not interactables.hash() == hash_value:
			Signals.emit_interaction_highlight_set(self, interactables.front())


func _on_request_interaction(_sender: NodePath) -> void:
	if interactables.size() > 0:
		var interactable: Interaction = get_node(interactables.front()) as Interaction
		if interactable != null:
			interactable.interact()


func _on_request_interaction_highlight(sender: NodePath) -> void:
	# TODO: prevent interactions through walls
	if sender not in interactables:
		interactables.append(sender)
		interactables.sort_custom(interactables_sort)
		Signals.emit_interaction_highlight_set(self, interactables.front())


func _on_request_interaction_unhighlight(sender: NodePath) -> void:
	if sender in interactables:
		interactables.erase(sender)
		interactables.sort_custom(interactables_sort)
		var target: NodePath = interactables.front() if interactables.size() > 0 else NodePath()
		Signals.emit_interaction_highlight_set(self, target)


func _on_scene_changed(_sender: NodePath) -> void:
	interactables.clear()
	Signals.emit_interaction_highlight_set(self, NodePath())


func interactables_sort(interactable: NodePath, interactable_other: NodePath) -> bool:
	var interactable_node: Node3D = get_node(interactable) as Node3D
	var interactable_node_other: Node3D = get_node(interactable_other) as Node3D
	if is_instance_valid(interactable_node) and is_instance_valid(interactable_node_other):
		var dist_squared: float = (interactable_node.global_position - player_transform_resource.get_value().origin).length_squared()
		var dist_squared_other: float = (interactable_node_other.global_position - player_transform_resource.get_value().origin).length_squared()
		return dist_squared < dist_squared_other
	elif is_instance_valid(interactable_node):
		return true
	elif is_instance_valid(interactable_node_other):
		return false
	else:
		# Should never happen, but whatever.
		return false

