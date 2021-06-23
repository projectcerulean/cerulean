extends PlayerState


func physics_process(_delta: float) -> void:
	var input: Vector3 = Vector3.ZERO
	input.z = (
		Input.get_action_strength("player_move_backward")
		- Input.get_action_strength("player_move_forward")
	)
	input.x = (
		Input.get_action_strength("player_move_right")
		- Input.get_action_strength("player_move_left")
	)
	player.linear_velocity = input
	player.move_and_slide()


func get_transition() -> String:
	if player.linear_velocity.is_equal_approx(Vector3.ZERO):
		return "Idle"
	else:
		return ""
