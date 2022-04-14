# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends PauseMenuState


func get_transition() -> StringName:
	if pause_menu.game_state_resource.current_state == GameStates.PAUSE:
		var hovered_option: PauseMenuOption = menu.get_child(i_hovered_option) as PauseMenuOption
		if Input.is_action_just_pressed(InputActions.PAUSE):
			Signals.emit_request_game_unpause(self)
		elif Input.is_action_just_pressed(InputActions.UI_CANCEL):
			Signals.emit_request_game_unpause(self)
		elif Input.is_action_just_pressed(InputActions.UI_ACCEPT):
			if hovered_option.name == &"Resume":
				Signals.emit_request_game_unpause(self)
			elif hovered_option.name == &"ReloadLevel":
				var scene_path: String = get_tree().current_scene.scene_file_path
				Signals.emit_request_scene_transition_start(self, scene_path, pause_menu.scene_transition_color, pause_menu.scene_transition_fade_duration)
			elif hovered_option.name == &"ChangeLevel":
				return PauseMenuStates.LEVELS
			elif hovered_option.name == &"Settings":
				return PauseMenuStates.SETTINGS
			elif hovered_option.name == &"Quit":
				Signals.emit_request_game_quit(self)
	return StringName()
