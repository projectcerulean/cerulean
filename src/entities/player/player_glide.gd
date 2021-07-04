extends PlayerState


func enter(data := {}) -> void:
	super.enter(data)
	player.glide_start_position = player.position
	player.glide_start_velocity = player.linear_velocity
	player.glide_roll_angle = 0.0


func process(delta: float) -> void:
	super.process(delta)

	# Update mesh facing direction
	var input_direction_2d: Vector3 = Vector3(player.input_vector.x, 0.0, player.input_vector.z)
	var linear_velocity_2d: Vector3 = Vector3(player.linear_velocity.x, 0.0, player.linear_velocity.z)
	player.glide_roll_angle = lerp(player.glide_roll_angle, linear_velocity_2d.signed_angle_to(input_direction_2d, Vector3.UP), player.glide_roll_weight)

	player.mesh_joint_map[self.name][0].look_at(player.mesh_joint_map[self.name][0].get_global_transform().origin + player.linear_velocity)
	player.mesh_joint_map[self.name][1].rotation = Vector3(0.0, 0.0, player.glide_roll_angle)


func physics_process(delta: float) -> void:
	super.physics_process(delta)

	# Apply movement
	var input_vector_spherical: Vector3 = player.input_vector
	input_vector_spherical.y = -sqrt(1.0 * 1.0 - min(input_vector_spherical.length_squared(), 1.0))
	input_vector_spherical = input_vector_spherical.normalized()

	player.linear_velocity = player.linear_velocity.normalized().slerp(input_vector_spherical, player.glide_smooth_weight) * (  # TODO: fails sometimes? Non-normalized Vector3?
		Math.signed_sqrt(2.0 * Physics.gravity * player.glide_gravity_modifier * (player.glide_start_position.y - player.position.y)) + player.glide_start_velocity.length()
	)

	# Update movement direction
	var direction_new: Vector3 = Vector3(player.linear_velocity.x, 0.0, player.linear_velocity.z).normalized()
	if not direction_new.is_equal_approx(Vector3.ZERO):
		player.direction = direction_new.normalized()

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
