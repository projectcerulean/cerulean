# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
@tool
class_name Interaction
extends Area3D

@export var interaction_action: InteractionAction:
	set(value):
		if not is_same(value, interaction_action):
			interaction_action = value
			update_configuration_warnings()


func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		assert(interaction_action != null, Errors.NULL_RESOURCE)
		interaction_action.check(self)
		set_process(false)


func interact() -> void:
	if not Engine.is_editor_hint():
		interaction_action.interact(self)


func _on_body_entered(body: Node3D) -> void:
	if not Engine.is_editor_hint():
		assert(body.name == &"Player", Errors.CONSISTENCY_ERROR)
		Signals.emit_request_interaction_highlight(self)


func _on_body_exited(body: Node3D) -> void:
	if not Engine.is_editor_hint():
		assert(body.name == &"Player", Errors.CONSISTENCY_ERROR)
		Signals.emit_request_interaction_unhighlight(self)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not is_instance_valid(interaction_action):
		warnings.append("No interaction action set")
	return warnings
