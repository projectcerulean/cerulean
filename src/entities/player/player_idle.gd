extends PlayerState


func enter(data := {}) -> void:
	player.linear_velocity = Vector3.ZERO


func get_transition() -> String:
	var input: Vector3 = Vector3.ZERO
	input.z = (
		Input.get_action_strength("player_move_backward")
		- Input.get_action_strength("player_move_forward")
	)
	input.x = (
		Input.get_action_strength("player_move_right")
		- Input.get_action_strength("player_move_left")
	)

	if not input.is_equal_approx(Vector3.ZERO):
		return "Run"
	else:
		return ""
