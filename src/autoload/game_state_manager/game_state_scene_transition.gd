extends GameState


func enter(old_state: StringName, data := {}) -> void:
	super.enter(old_state, data)
	get_tree().paused = true


func exit(new_state: StringName) -> void:
	super.exit(new_state)
	get_tree().paused = false
