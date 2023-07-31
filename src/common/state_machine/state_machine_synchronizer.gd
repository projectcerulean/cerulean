# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node

@export var _state_machine_parent: NodePath
@export var _state_machine_child: NodePath

@onready var state_machine_parent: NodePath = NodePathUtils.get_absolute_path(self, _state_machine_parent)
@onready var state_machine_child: NodePath = NodePathUtils.get_absolute_path(self, _state_machine_child)


func _ready() -> void:
	Signals.state_entered.connect(_on_state_entered)

	assert(state_machine_parent != null, Errors.NULL_NODE)
	assert(state_machine_child != null, Errors.NULL_NODE)
	assert(get_node(state_machine_parent).get_child_count() > 0, Errors.CONSISTENCY_ERROR)
	assert(get_node(state_machine_child).get_child_count() == get_node(state_machine_parent).get_child_count(), Errors.CONSISTENCY_ERROR)
	for i in range(get_node(state_machine_parent).get_child_count()):
		assert(get_node(state_machine_child).get_child(i).name == get_node(state_machine_parent).get_child(i).name, Errors.CONSISTENCY_ERROR)


func _on_state_entered(sender: NodePath, state: StringName, data: Dictionary):
	if sender == state_machine_parent:
		Signals.emit_request_state_change(self, state_machine_child, state, data)
