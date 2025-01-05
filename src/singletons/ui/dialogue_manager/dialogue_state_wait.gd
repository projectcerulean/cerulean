# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends DialogueState


func get_transition() -> StringName:
	if (
		dialogue_manager.game_state_resource.is_owned()
		and dialogue_manager.game_state_resource.get_current_state() == GameStates.DIALOGUE
		and Input.is_action_just_pressed(InputActions.UI_ACCEPT)
	):
			if dialogue_manager.line_index < dialogue_manager.dialogue_resource.dialogue_lines.size() - 1:
				return DialogueStates.OUTPUT
			else:
				Signals.emit_request_dialogue_finish(self)
	return StringName()
