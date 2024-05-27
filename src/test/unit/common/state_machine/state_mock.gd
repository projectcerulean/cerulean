# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name StateMock
extends State

var _next_transition: StringName = StringName()
var _called_methods: PackedStringArray = []


func set_next_transition(new_state_name: StringName) -> void:
	_next_transition = new_state_name


func get_called_methods() -> PackedStringArray:
	return PackedStringArray(_called_methods)


func enter(data: Dictionary) -> void:
	super.enter(data)
	_called_methods.append(enter.get_method())


func exit(data: Dictionary) -> void:
	super.exit(data)
	_called_methods.append(exit.get_method())


func process(delta: float) -> void:
	super.process(delta)
	_called_methods.append(process.get_method())


func physics_process(delta: float) -> void:
	super.physics_process(delta)
	_called_methods.append(physics_process.get_method())


func get_transition() -> StringName:
	var transition: StringName = _next_transition
	_next_transition = StringName()
	return transition
