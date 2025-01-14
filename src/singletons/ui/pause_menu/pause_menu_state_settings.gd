# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends PauseMenuState


func exit(data: Dictionary) -> void:
	super.exit(data)
	Signals.emit_request_settings_save(self)


func process(delta: float) -> void:
	super.process(delta)
	if get_game_state() == GameStates.PAUSE:
		var hovered_option: PauseMenuOption = menu.get_child(i_hovered_option) as PauseMenuOption
		if Input.is_action_just_pressed(InputActions.UI_LEFT):
			Signals.emit_request_sfx_play_non_diegetic(self, pause_menu.sfx_resource_select)
			hovered_option.adjust_option(-1)
		elif Input.is_action_just_pressed(InputActions.UI_RIGHT) or Input.is_action_just_pressed(InputActions.UI_ACCEPT):
			Signals.emit_request_sfx_play_non_diegetic(self, pause_menu.sfx_resource_select)
			hovered_option.adjust_option(1)


func get_transition() -> StringName:
	if get_game_state() == GameStates.PAUSE:
		if Input.is_action_just_pressed(InputActions.PAUSE):
			Signals.emit_request_game_unpause(self)
			return PauseMenuStates.MAIN
		elif Input.is_action_just_pressed(InputActions.UI_CANCEL):
			return PauseMenuStates.MAIN
	return StringName()
