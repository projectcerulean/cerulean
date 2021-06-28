extends PlayerState


func enter(_data := {}) -> void:
	player.linear_velocity.y = 0.0


func exit() -> void:
	player.coyote_timer.stop()


func physics_process(delta: float) -> void:
	# Get movement vectors
	var camera_vector: Vector3 = player.camera.global_transform.origin - player.global_transform.origin
	camera_vector.y = 0.0
	camera_vector = camera_vector.normalized()
	var forward_vector: Vector3 = camera_vector
	var right_vector: Vector3 = -camera_vector.cross(Vector3.UP)

	# Apply movement
	player.linear_velocity += right_vector * player.thumbstick_left.value.x * player.move_acceleration * delta
	player.linear_velocity += forward_vector * player.thumbstick_left.value.y * player.move_acceleration * delta

	# Apply friction
	player.linear_velocity.x = player.linear_velocity.x - player.move_friction_coefficient * player.linear_velocity.x * delta
	player.linear_velocity.z = player.linear_velocity.z - player.move_friction_coefficient * player.linear_velocity.z * delta

	# Go
	player.move_and_slide()

	# Coyote timer
	if player.raycast.is_colliding():
		player.coyote_timer.start()


func get_transition() -> String:
	if not player.raycast.is_colliding() and player.coyote_timer.is_stopped():
		return "Fall"
	elif Input.is_action_just_pressed("player_move_jump") or not player.jump_buffer_timer.is_stopped():
		return "Jump"
	elif player.linear_velocity.is_equal_approx(Vector3.ZERO):
		return "Idle"
	else:
		return ""
