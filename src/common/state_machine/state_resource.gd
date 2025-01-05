# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name StateResource
extends DependencyInjectionResource

const STATE_MACHINE_DEFAULT: NodePath = NodePath()
const CURRENT_STATE_DEFAULT: StringName = StringName()

var _state_machine: NodePath = STATE_MACHINE_DEFAULT
var _current_state: StringName = CURRENT_STATE_DEFAULT


func get_state_machine() -> NodePath:
	_validate_read("state_machine")
	return _state_machine


func set_state_machine(caller: Node, value: NodePath) -> void:
	_validate_write(caller, "state_machine")
	_state_machine = value


func get_current_state() -> StringName:
	_validate_read("current_state")
	return _current_state


func set_current_state(caller: Node, value: StringName) -> void:
	_validate_write(caller, "current_state")
	_current_state = value


func release_ownership(caller: Node) -> void:
	super.release_ownership(caller)
	_state_machine = STATE_MACHINE_DEFAULT
	_current_state = CURRENT_STATE_DEFAULT
