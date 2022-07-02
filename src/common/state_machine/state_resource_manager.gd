# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node

@export var state_machine: Node
@export var _state_resource: Resource

@onready var state_resource: StateResource = _state_resource as StateResource


func _ready() -> void:
	Signals.state_entered.connect(_on_state_entered)
	Signals.state_exited.connect(_on_state_exited)

	assert(state_machine != null, Errors.NULL_NODE)
	assert(state_resource != null, Errors.NULL_RESOURCE)

	assert(state_resource.state_machine == null, Errors.RESOURCE_BUSY)
	assert(state_resource.current_state == StringName(), Errors.RESOURCE_BUSY)

	state_resource.state_machine = state_machine


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		state_resource.state_machine = null
		state_resource.current_state = StringName()


func _on_state_entered(sender: Node, state: StringName, _data: Dictionary):
	if sender == state_machine:
		state_resource.current_state = state


func _on_state_exited(sender: Node, _state: StringName, _data: Dictionary):
	if sender == state_machine:
		state_resource.current_state = StringName()
