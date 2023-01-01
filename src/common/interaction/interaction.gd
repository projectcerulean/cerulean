# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name Interaction
extends Area3D

@onready var action: InteractionAction = get_node("Action") as InteractionAction


func _ready() -> void:
	assert(action as InteractionAction != null, Errors.NULL_NODE)


func interact() -> void:
	action.interact()


func _on_body_entered(body: Node3D) -> void:
	assert(body.name == &"Player", Errors.CONSISTENCY_ERROR)
	Signals.emit_request_interaction_highlight(self)


func _on_body_exited(body: Node3D) -> void:
	assert(body.name == &"Player", Errors.CONSISTENCY_ERROR)
	Signals.emit_request_interaction_unhighlight(self)
