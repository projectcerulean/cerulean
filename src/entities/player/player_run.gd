extends PlayerState


func physics_process(delta: float) -> void:
	# Apply movement
	player.linear_velocity.x = player.linear_velocity.x + player.thumbstick_left.value.x * player.move_acceleration * delta
	player.linear_velocity.z = player.linear_velocity.z + player.thumbstick_left.value.y * player.move_acceleration * delta

	# Apply friction
	player.linear_velocity.x = player.linear_velocity.x - player.move_friction_coefficient * player.linear_velocity.x * delta
	player.linear_velocity.z = player.linear_velocity.z - player.move_friction_coefficient * player.linear_velocity.z * delta

	# Go
	player.move_and_slide()


func get_transition() -> String:
	if not player.raycast.is_colliding():
		return "Fall"
	elif Input.is_action_just_pressed("player_move_jump"):
		return "Jump"
	elif player.linear_velocity.is_equal_approx(Vector3.ZERO):
		return "Idle"
	else:
		return ""
