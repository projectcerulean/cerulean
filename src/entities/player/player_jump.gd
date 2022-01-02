extends PlayerState


func enter(old_state: PlayerState, data := {}) -> void:
	super.enter(old_state, data)
	player.motion_velocity.y = player.jump_speed
	player.jump_buffer_timer.stop()

	# Update mesh facing direction
	player.mesh_joint_map[self][0].look_at(player.mesh_joint_map[self][0].get_global_transform().origin + player.facing_direction)


func physics_process(delta: float) -> void:
	super.physics_process(delta)

	# Apply movement
	player.motion_velocity += player.input_vector * player.move_acceleration_air * delta

	# Apply friction
	player.motion_velocity.x = player.motion_velocity.x - player.move_friction_coefficient_air * player.motion_velocity.x * delta
	player.motion_velocity.z = player.motion_velocity.z - player.move_friction_coefficient_air * player.motion_velocity.z * delta

	# Apply jump acceleration
	player.motion_velocity.y = player.motion_velocity.y + player.jump_acceleration * delta

	# Apply gravity
	player.motion_velocity.y = player.motion_velocity.y - Physics.GRAVITY * delta

	# Go
	player.move_and_slide()


func get_transition() -> PlayerState:
	if player.is_in_water() and player.global_transform.origin.y < player.get_water_surface_height() - player.water_state_enter_offset:
		return state_resource.states.SWIM
	elif player.is_on_floor():
		if is_equal_approx(player.motion_velocity.x, 0.0) and is_equal_approx(player.motion_velocity.z, 0.0):
			return state_resource.states.IDLE
		else:
			return state_resource.states.RUN
	elif player.motion_velocity.y < 0 or not Input.is_action_pressed("player_move_jump"):
		return state_resource.states.FALL
	else:
		return null
