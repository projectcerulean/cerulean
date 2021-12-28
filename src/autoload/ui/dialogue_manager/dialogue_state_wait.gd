extends DialogueState


func get_transition() -> DialogueState:
	if dialogue_manager.game_state.state == dialogue_manager.game_state.states.DIALOGUE and Input.is_action_just_pressed("ui_accept"):
			if dialogue_manager.line_index < dialogue_manager.dialogue_resource.dialogue_lines.size() - 1:
				return state.states.OUTPUT
			else:
				Signals.emit_request_dialogue_finish(self)
	return null
