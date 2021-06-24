extends PlayerState

func physics_process(delta: float) -> void:
	# Apply movement
	player.linear_velocity.x = player.linear_velocity.x + player.thumbstick_left.value.x * player.move_acceleration * delta
	player.linear_velocity.z = player.linear_velocity.z + player.thumbstick_left.value.y * player.move_acceleration * delta

	# Apply friction
	player.linear_velocity.x = player.linear_velocity.x - player.move_friction_coefficient * player.linear_velocity.x * delta
	player.linear_velocity.z = player.linear_velocity.z - player.move_friction_coefficient * player.linear_velocity.z * delta

	# Apply gravity
	player.linear_velocity.y = player.linear_velocity.y - player.gravity * delta

	# Go
	player.move_and_slide()


func get_transition() -> String:
	if player.is_on_floor():
		if is_equal_approx(player.linear_velocity.x, 0.0) and is_equal_approx(player.linear_velocity.z, 0.0):
			return "Idle"
		else:
			return "Run"
	else:
		return ""
