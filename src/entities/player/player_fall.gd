extends PlayerState


func enter(old_state: PlayerState, data := {}) -> void:
	super.enter(old_state, data)

	# Update mesh facing direction
	player.mesh_joint_map[self][0].look_at(player.mesh_joint_map[self][0].get_global_transform().origin + player.facing_direction)


func physics_process(delta: float) -> void:
	super.physics_process(delta)

	# Apply movement
	player.linear_velocity += player.input_vector * player.move_acceleration_air * delta

	# Apply friction
	player.linear_velocity.x = player.linear_velocity.x - player.move_friction_coefficient_air * player.linear_velocity.x * delta
	player.linear_velocity.z = player.linear_velocity.z - player.move_friction_coefficient_air * player.linear_velocity.z * delta

	# Apply gravity
	player.linear_velocity.y = player.linear_velocity.y - Physics.GRAVITY * delta

	# Go
	player.move_and_slide()

	# Jump buffering
	if Input.is_action_just_pressed("player_move_jump"):
		player.jump_buffer_timer.start()


func get_transition() -> PlayerState:
	if player.is_in_water() and player.global_transform.origin.y < player.get_water_surface_height() - player.water_state_enter_offset:
		return player.state.states.SWIM
	elif player.is_on_floor():
		if is_equal_approx(player.linear_velocity.x, 0.0) and is_equal_approx(player.linear_velocity.z, 0.0):
			return player.state.states.IDLE
		else:
			return player.state.states.RUN
	elif player.linear_velocity.y < 0.0 and Input.is_action_pressed("player_move_jump"):
		return player.state.states.GLIDE
	else:
		return null
