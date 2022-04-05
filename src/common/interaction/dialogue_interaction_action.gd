# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name DialogueInteractionAction
extends InteractionAction

@export var dialogue_resource: Resource


func _ready() -> void:
	assert(dialogue_resource as DialogueResource != null, Errors.NULL_RESOURCE)


func interact() -> void:
	super.interact()
	Signals.emit_request_dialogue_start(self, dialogue_resource)
