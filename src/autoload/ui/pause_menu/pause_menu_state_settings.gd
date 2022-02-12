extends PauseMenuState


func exit(new_state: StringName) -> void:
	super.exit(new_state)
	Signals.emit_request_settings_save(self)


func process(delta: float) -> void:
	super.process(delta)
	if pause_menu.game_state_resource.current_state == GameStates.PAUSE:
		if Input.is_action_just_pressed(&"ui_left"):
			Signals.emit_request_sfx_play_non_diegetic(self, pause_menu.sfx_resource_select)
			menu_options[i_hovered_option].adjust_option(-1)
		elif Input.is_action_just_pressed(&"ui_right"):
			Signals.emit_request_sfx_play_non_diegetic(self, pause_menu.sfx_resource_select)
			menu_options[i_hovered_option].adjust_option(1)


func get_transition() -> StringName:
	if pause_menu.game_state_resource.current_state == GameStates.PAUSE:
		if Input.is_action_just_pressed(&"pause"):
			Signals.emit_request_game_unpause(self)
			return PauseMenuStates.MAIN
		elif Input.is_action_just_pressed("ui_cancel"):
			return PauseMenuStates.MAIN
	return StringName()
