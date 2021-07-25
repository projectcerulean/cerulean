extends PauseMenuState


func get_transition() -> PauseMenuState:
	if pause_menu.game_state.state == pause_menu.game_state.states.PAUSE:
		if Input.is_action_just_pressed(&"pause"):
			SignalsGetter.get_signals().emit_request_game_unpause(self)
		elif Input.is_action_just_pressed("ui_cancel"):
			SignalsGetter.get_signals().emit_request_game_unpause(self)
		elif Input.is_action_just_pressed("ui_accept"):
			if menu_options[i_hovered_option].name == &"Resume":
				SignalsGetter.get_signals().emit_request_game_unpause(self)
			elif menu_options[i_hovered_option].name == &"ReloadLevel":
				SignalsGetter.get_signals().emit_request_game_unpause(self)
				get_tree().call_deferred(get_tree().reload_current_scene.get_method())
			elif menu_options[i_hovered_option].name == &"Settings":
				return state.states.SETTINGS
			elif menu_options[i_hovered_option].name == &"Quit":
				get_tree().call_deferred(get_tree().quit.get_method())
	return null
