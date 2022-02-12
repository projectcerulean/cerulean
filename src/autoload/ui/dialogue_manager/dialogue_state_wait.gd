extends DialogueState


func get_transition() -> StringName:
	if dialogue_manager.game_state_resource.current_state == GameStates.DIALOGUE and Input.is_action_just_pressed("ui_accept"):
			if dialogue_manager.line_index < dialogue_manager.dialogue_resource.dialogue_lines.size() - 1:
				return DialogueStates.OUTPUT
			else:
				Signals.emit_request_dialogue_finish(self)
	return StringName()
