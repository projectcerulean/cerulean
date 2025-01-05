# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name DialogueInteractionAction
extends InteractionAction

@export var dialogue_resource: DialogueResource


func check(caller: Node3D) -> void:
	super.check(caller)
	assert(dialogue_resource != null, Errors.NULL_RESOURCE)


func interact(caller: Node3D) -> void:
	super.interact(caller)
	Signals.emit_request_dialogue_start(caller, dialogue_resource)
