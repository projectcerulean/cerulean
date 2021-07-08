extends PlayerState


func enter(old_state_name: StringName, data := {}) -> void:
	super.enter(old_state_name, data)
	player.linear_velocity.y = player.jump_speed
	player.jump_buffer_timer.stop()

	# Update mesh facing direction
	player.mesh_joint_map[self.name][0].look_at(player.mesh_joint_map[self.name][0].get_global_transform().origin + player.facing_direction)


func physics_process(delta: float) -> void:
	super.physics_process(delta)

	# Apply movement
	player.linear_velocity += player.input_vector * player.move_acceleration_air * delta

	# Apply friction
	player.linear_velocity.x = player.linear_velocity.x - player.move_friction_coefficient_air * player.linear_velocity.x * delta
	player.linear_velocity.z = player.linear_velocity.z - player.move_friction_coefficient_air * player.linear_velocity.z * delta

	# Apply jump acceleration
	player.linear_velocity.y = player.linear_velocity.y + player.jump_acceleration * delta

	# Apply gravity
	player.linear_velocity.y = player.linear_velocity.y - Physics.gravity * delta

	# Go
	player.move_and_slide()


func get_transition() -> StringName:
	if player.is_in_water:
		return player.SWIM
	elif player.is_on_floor():
		if is_equal_approx(player.linear_velocity.x, 0.0) and is_equal_approx(player.linear_velocity.z, 0.0):
			return player.IDLE
		else:
			return player.RUN
	elif player.linear_velocity.y < 0 or not Input.is_action_pressed("player_move_jump"):
		return player.FALL
	else:
		return &""
