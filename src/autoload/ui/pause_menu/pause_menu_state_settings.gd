extends PauseMenuState


func process(delta: float) -> void:
	super.process(delta)
	if pause_menu.game_state.state == pause_menu.game_state.states.PAUSE:
		if Input.is_action_just_pressed(&"ui_left"):
			menu_options[i_hovered_option].adjust_option(-1)
		elif Input.is_action_just_pressed(&"ui_right"):
			menu_options[i_hovered_option].adjust_option(1)


func get_transition() -> PauseMenuState:
	if pause_menu.game_state.state == pause_menu.game_state.states.PAUSE:
		if Input.is_action_just_pressed(&"pause"):
			SignalsGetter.get_signals().emit_request_game_unpause(self)
			return state.states.MAIN
		elif Input.is_action_just_pressed("ui_cancel"):
			return state.states.MAIN
	return null
