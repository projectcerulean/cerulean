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
				Signals.emit_request_scene_reload(self)
			elif menu_options[i_hovered_option].name == &"ChangeLevel":
				return state_resource.states.LEVELS
			elif menu_options[i_hovered_option].name == &"Settings":
				return state_resource.states.SETTINGS
			elif menu_options[i_hovered_option].name == &"Quit":
				Signals.emit_request_game_quit(self)
	return null
