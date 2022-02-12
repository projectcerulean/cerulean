extends PlayerState


func enter(old_state: StringName, data := {}) -> void:
	super.enter(old_state, data)

	# Update mesh facing direction
	player.mesh_joint_map[name][0].look_at(player.mesh_joint_map[name][0].get_global_transform().origin + player.facing_direction)


func exit(new_state: StringName) -> void:
	super.exit(new_state)
	if new_state == PlayerStates.JUMP:
		player.global_transform.origin.y = player.get_water_surface_height()


func process(delta: float) -> void:
	super.process(delta)

	# Update mesh facing direction
	player.mesh_joint_map[name][0].look_at(player.mesh_joint_map[name][0].get_global_transform().origin + player.facing_direction)


func physics_process(delta: float) -> void:
	super.physics_process(delta)

	# Apply movement
	if not player.input_vector.is_equal_approx(Vector3.ZERO):
		player.facing_direction = Lerp.delta_slerp3(player.facing_direction, player.input_vector.normalized(), player.input_vector.length() * player.water_turn_weight, delta)
		player.motion_velocity += player.facing_direction * player.input_vector.length() * player.water_move_acceleration * delta

	if not is_nan(player.get_water_surface_height()) and player.motion_velocity.y > 0.0 and player.global_transform.origin.y > player.get_water_surface_height():
		player.global_transform.origin.y = player.get_water_surface_height()
		player.motion_velocity.y = 0.0
	else:
		player.motion_velocity.y = player.motion_velocity.y + player.water_buoyancy * delta

	# Apply friction
	player.motion_velocity -= player.motion_velocity * player.water_resistance * delta

	# Go
	player.move_and_slide()

	# Jump buffering
	if Input.is_action_just_pressed("player_move_jump"):
		player.jump_buffer_timer.start()


func get_transition() -> StringName:
	if not player.is_in_water():
		return PlayerStates.FALL
	elif player.raycast.is_colliding() and player.global_transform.origin.y > player.get_water_surface_height() + player.water_state_enter_offset:
		return PlayerStates.RUN
	elif Input.is_action_just_pressed("player_move_jump") or not player.jump_buffer_timer.is_stopped():
		if player.get_water_surface_height() - player.global_transform.origin.y < player.water_jump_max_surface_distance:
			return PlayerStates.JUMP
	elif Input.is_action_just_pressed("player_move_dive"):
		return PlayerStates.DIVE
	else:
		return StringName()
