extends PlayerState


func physics_process(delta: float) -> void:
	var input: Vector3 = Vector3(player.thumbstick_left.value.x, 0, player.thumbstick_left.value.y)
	player.linear_velocity += input * player.move_acceleration * delta
	player.linear_velocity -= player.move_friction_coefficient * player.linear_velocity * delta
	player.move_and_slide()


func get_transition() -> String:
	if player.linear_velocity.is_equal_approx(Vector3.ZERO):
		return "Idle"
	else:
		return ""
