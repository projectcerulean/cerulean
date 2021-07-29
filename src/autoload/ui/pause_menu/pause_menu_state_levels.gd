extends PauseMenuState


func get_transition() -> PauseMenuState:
	if pause_menu.game_state.state == pause_menu.game_state.states.PAUSE:
		if Input.is_action_just_pressed(&"pause"):
			SignalsGetter.get_signals().emit_request_game_unpause(self)
			return state.states.MAIN
		elif Input.is_action_just_pressed("ui_cancel"):
			return state.states.MAIN
		elif Input.is_action_just_pressed("ui_accept"):
			SignalsGetter.get_signals().emit_request_scene_change(self, menu_options[i_hovered_option].key_string)
			return state.states.MAIN
	return null
