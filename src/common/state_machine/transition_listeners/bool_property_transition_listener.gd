# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name BoolPropertyTransitionListener
extends StateTransitionListener

@export var target_node: Node
@export var property: StringName
@export var invert_value: bool = false


func _ready() -> void:
	super._ready()
	assert(target_node != null, Errors.NULL_NODE)
	assert(property != null and not property.is_empty(), Errors.INVALID_ARGUMENT)


func _on_target_state_entered(data: Dictionary) -> void:
	super._on_target_state_entered(data)
	target_node.set(property, false if invert_value else true)


func _on_target_state_exited(data: Dictionary) -> void:
	super._on_target_state_exited(data)
	target_node.set(property, true if invert_value else false)
