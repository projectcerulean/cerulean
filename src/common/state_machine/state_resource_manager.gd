# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
@tool
class_name StateResourceManager
extends Node

@export var _state_machine: NodePath:
	set(value):
		if value != _state_machine:
			_state_machine = value
			update_configuration_warnings()
@export var state_resource: StateResource:
	set(value):
		if not is_same(value, state_resource):
			state_resource = value
			update_configuration_warnings()

var state_machine: NodePath


func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		if _state_machine.is_absolute():
			state_machine = _state_machine
		else:
			state_machine = NodePathUtils.concatenate_paths(self.get_path(), _state_machine)

		assert(state_machine != null, Errors.NULL_NODE)
		assert(state_resource != null, Errors.NULL_RESOURCE)

		state_resource.claim_ownership(self)
		state_resource.set_state_machine(self, state_machine)


func _exit_tree() -> void:
	if not Engine.is_editor_hint():
		state_resource.release_ownership(self)


func _ready() -> void:
	if not Engine.is_editor_hint():
		Signals.state_entered.connect(_on_state_entered)
		Signals.state_exited.connect(_on_state_exited)


func _on_state_entered(sender: NodePath, state: StringName, _data: Dictionary):
	if not Engine.is_editor_hint():
		if sender == state_machine:
			state_resource.set_current_state(self, state)


func _on_state_exited(sender: NodePath, state: StringName, _data: Dictionary):
	if not Engine.is_editor_hint():
		if sender == state_machine:
			assert(state_resource.get_current_state() == state, Errors.CONSISTENCY_ERROR)
			state_resource.set_current_state(self, StringName())


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if _state_machine.is_empty():
		warnings.append("No state machine set")
	if not is_instance_valid(state_resource):
		warnings.append("No state resource set")
	return warnings
