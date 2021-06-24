extends PlayerState


func physics_process(_delta: float) -> void:
	var input: Vector3 = Vector3(player.thumbstickLeft.value.x, 0, player.thumbstickLeft.value.y)
	player.linear_velocity = input
	player.move_and_slide()


func get_transition() -> String:
	if player.linear_velocity.is_equal_approx(Vector3.ZERO):
		return "Idle"
	else:
		return ""
