# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends CanvasLayer

@export var game_state_resource: StateResource


func _ready() -> void:
	Signals.state_entered.connect(self._on_state_entered)
	assert(game_state_resource != null, Errors.NULL_RESOURCE)


func _on_state_entered(sender: NodePath, state: StringName, _data: Dictionary) -> void:
	if (
		game_state_resource.is_owned()
		and sender == game_state_resource.get_state_machine()
	):
		self.visible = state == GameStates.GAMEPLAY
