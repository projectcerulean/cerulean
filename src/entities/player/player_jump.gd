extends PlayerState


func enter(_data := {}) -> void:
	player.linear_velocity.y = player.jump_speed


func physics_process(delta: float) -> void:
	# Get movement vectors
	var camera_vector: Vector3 = player.camera.global_transform.origin - player.global_transform.origin
	camera_vector.y = 0.0
	camera_vector = camera_vector.normalized()
	var forward_vector: Vector3 = camera_vector
	var right_vector: Vector3 = -camera_vector.cross(Vector3.UP)

	# Apply movement
	player.linear_velocity += right_vector * player.thumbstick_left.value.x * player.move_acceleration_air * delta
	player.linear_velocity += forward_vector * player.thumbstick_left.value.y * player.move_acceleration_air * delta

	# Apply friction
	player.linear_velocity.x = player.linear_velocity.x - player.move_friction_coefficient_air * player.linear_velocity.x * delta
	player.linear_velocity.z = player.linear_velocity.z - player.move_friction_coefficient_air * player.linear_velocity.z * delta

	# Apply jump acceleration
	player.linear_velocity.y = player.linear_velocity.y + player.jump_acceleration * delta

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
	elif player.linear_velocity.y < 0 or not Input.is_action_pressed("player_move_jump"):
		return "Fall"
	else:
		return ""
