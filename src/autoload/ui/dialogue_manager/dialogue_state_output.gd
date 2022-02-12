extends DialogueState


func enter(old_state: StringName, data := {}) -> void:
	super.enter(old_state, data)
	dialogue_manager.line_index += 1
	dialogue_manager.label.text = "  " + dialogue_manager.dialogue_resource.dialogue_lines[dialogue_manager.line_index] + "  "
	dialogue_manager.label.percent_visible = 0.0


func exit(new_state: StringName) -> void:
	super.exit(new_state)
	dialogue_manager.label.percent_visible = 1.0


func process(delta: float) -> void:
	super.process(delta)
	dialogue_manager.label.percent_visible = dialogue_manager.label.percent_visible + delta * dialogue_manager.text_reveal_speed / float(dialogue_manager.label.text.length())


func get_transition() -> StringName:
	if dialogue_manager.game_state_resource.current_state == GameStates.DIALOGUE:
		if dialogue_manager.label.percent_visible >= 1.0 or Input.is_action_just_pressed("ui_accept"):
			return DialogueStates.WAIT
	return StringName()
