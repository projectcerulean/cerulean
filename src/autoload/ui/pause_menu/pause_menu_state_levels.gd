extends PauseMenuState


func get_transition() -> StringName:
	if pause_menu.game_state_resource.current_state == GameStates.PAUSE:
		if Input.is_action_just_pressed(&"pause"):
			Signals.emit_request_game_unpause(self)
			return PauseMenuStates.MAIN
		elif Input.is_action_just_pressed("ui_cancel"):
			return PauseMenuStates.MAIN
		elif Input.is_action_just_pressed("ui_accept"):
			var scene_path: String = Levels.LEVELS[menu_options[i_hovered_option].key_string][Levels.LEVEL_PATH]
			Signals.emit_request_scene_transition_start(self, scene_path, pause_menu.scene_transition_color, pause_menu.scene_transition_fade_duration)
			return PauseMenuStates.MAIN
	return StringName()
