extends PauseMenuState


func get_transition() -> PauseMenuState:
	if pause_menu.game_state_resource.current_state == pause_menu.game_state_resource.states.PAUSE:
		if Input.is_action_just_pressed(&"pause"):
			Signals.emit_request_game_unpause(self)
		elif Input.is_action_just_pressed("ui_cancel"):
			Signals.emit_request_game_unpause(self)
		elif Input.is_action_just_pressed("ui_accept"):
			if menu_options[i_hovered_option].name == &"Resume":
				Signals.emit_request_game_unpause(self)
			elif menu_options[i_hovered_option].name == &"ReloadLevel":
				var scene_path: String = get_tree().current_scene.scene_file_path
				Signals.emit_request_scene_transition_start(self, scene_path, pause_menu.scene_transition_color, pause_menu.scene_transition_fade_duration)
			elif menu_options[i_hovered_option].name == &"ChangeLevel":
				return states.LEVELS
			elif menu_options[i_hovered_option].name == &"Settings":
				return states.SETTINGS
			elif menu_options[i_hovered_option].name == &"Quit":
				Signals.emit_request_game_quit(self)
	return null
