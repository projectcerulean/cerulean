# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends DialogueState


func enter(data: Dictionary) -> void:
	super.enter(data)
	dialogue_manager.line_index += 1
	dialogue_manager.label.text = "  " + dialogue_manager.dialogue_resource.dialogue_lines[dialogue_manager.line_index] + "  "
	dialogue_manager.label.visible_characters = 0


func exit(data: Dictionary) -> void:
	super.exit(data)
	dialogue_manager.label.visible_characters = dialogue_manager.label.text.length()


func process(delta: float) -> void:
	super.process(delta)
	dialogue_manager.label.visible_characters += int(dialogue_manager.text_reveal_speed * delta)


func get_transition() -> StringName:
	if dialogue_manager.game_state_resource.get_current_state() == GameStates.DIALOGUE:
		if dialogue_manager.label.visible_characters >= dialogue_manager.label.text.length() or Input.is_action_just_pressed(InputActions.UI_ACCEPT):
			return DialogueStates.WAIT
	return StringName()
