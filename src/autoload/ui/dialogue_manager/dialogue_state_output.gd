# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends DialogueState


func enter(data: Dictionary) -> void:
	super.enter(data)
	dialogue_manager.line_index += 1
	dialogue_manager.label.text = "  " + dialogue_manager.dialogue_resource.dialogue_lines[dialogue_manager.line_index] + "  "
	dialogue_manager.label.percent_visible = 0.0


func exit(data: Dictionary) -> void:
	super.exit(data)
	dialogue_manager.label.percent_visible = 1.0


func process(delta: float) -> void:
	super.process(delta)
	dialogue_manager.label.percent_visible = dialogue_manager.label.percent_visible + delta * dialogue_manager.text_reveal_speed / float(dialogue_manager.label.text.length())


func get_transition() -> StringName:
	if dialogue_manager.game_state_resource.current_state == GameStates.DIALOGUE:
		if dialogue_manager.label.percent_visible >= 1.0 or Input.is_action_just_pressed("ui_accept"):
			return DialogueStates.WAIT
	return StringName()
