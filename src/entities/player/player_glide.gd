extends PlayerState


func enter(_data := {}) -> void:
	player.glide_start_position = player.position
	player.glide_start_velocity = player.linear_velocity


func physics_process(delta: float) -> void:
	# Get movement vectors
	var camera_vector: Vector3 = player.camera.global_transform.origin - player.global_transform.origin
	camera_vector.y = 0.0
	camera_vector = camera_vector.normalized()
	var forward_vector: Vector3 = camera_vector
	var right_vector: Vector3 = -camera_vector.cross(Vector3.UP)

	# Apply movement
	var input_direction: Vector3 = right_vector * player.thumbstick_left.value.x + forward_vector * player.thumbstick_left.value.y
	input_direction.y = -sqrt(1.0 * 1.0 - min(input_direction.length_squared(), 1.0))
	input_direction = input_direction.normalized()

	player.linear_velocity = player.linear_velocity.normalized().slerp(input_direction, player.glide_smooth_weight) * (
		sqrt(2.0 * Physics.gravity * player.glide_gravity_modifier * (player.glide_start_position.y - player.position.y)) + player.glide_start_velocity.length()
	)

	# Update mesh facing direction
	var direction_new: Vector3 = Vector3(player.linear_velocity.x, 0.0, player.linear_velocity.z).normalized()
	if direction_new.is_normalized():
		player.direction = direction_new

	# Apply gravity
	player.linear_velocity.y = player.linear_velocity.y - Physics.gravity * player.glide_gravity_modifier * delta

	# Go
	player.move_and_slide()

	# Jump buffering
	if Input.is_action_just_pressed("player_move_jump"):
		player.jump_buffer_timer.start()


func get_transition() -> String:
	if player.is_on_floor():
		if is_equal_approx(player.linear_velocity.x, 0.0) and is_equal_approx(player.linear_velocity.z, 0.0):
			return "Idle"
		else:
			return "Run"
	elif not Input.is_action_pressed("player_move_glide"):
		return "Fall"
	else:
		return ""
