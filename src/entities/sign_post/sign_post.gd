# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
@tool
extends StaticBody3D

@export var dialogue_resource: DialogueResource:
	set(value):
		if not is_same(value, dialogue_resource):
			dialogue_resource = value
			update_configuration_warnings()

@onready var dialogue_interactable: Interactable = get_node("Interactable") as Interactable


func _ready() -> void:
	if not Engine.is_editor_hint():
		assert(dialogue_interactable != null, Errors.NULL_NODE)
		var dialogue_interaction_action: DialogueInteractionAction = DialogueInteractionAction.new()
		dialogue_interaction_action.dialogue_resource = dialogue_resource
		dialogue_interactable.interaction_action = dialogue_interaction_action


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not is_instance_valid(dialogue_resource):
		warnings.append("No dialogue resource set")
	return warnings
