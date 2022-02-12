extends PlayerState


func enter(old_state: StringName, data := {}) -> void:
	super.enter(old_state, data)
	player.motion_velocity.y = 0.0
	player.floor_snap_length = player.move_snap_distance

	# Update mesh facing direction
	joint1.look_at(joint1.get_global_transform().origin + player.facing_direction)


func exit(new_state: StringName) -> void:
	super.exit(new_state)
	player.floor_snap_length = 0.0


func process(delta: float) -> void:
	super.process(delta)

	# Update mesh facing direction
	joint1.look_at(joint1.get_global_transform().origin + player.facing_direction)


func physics_process(delta: float) -> void:
	super.physics_process(delta)

	# Apply movement
	if not player.input_vector.is_equal_approx(Vector3.ZERO):
		player.facing_direction = Lerp.delta_slerp3(player.facing_direction, player.input_vector.normalized(), player.input_vector.length() * player.turn_weight, delta)
		player.motion_velocity += player.facing_direction * player.input_vector.length() * player.move_acceleration * delta

	# Apply friction
	player.motion_velocity.x = player.motion_velocity.x - player.move_friction_coefficient * player.motion_velocity.x * delta
	player.motion_velocity.z = player.motion_velocity.z - player.move_friction_coefficient * player.motion_velocity.z * delta

	# Go
	player.move_and_slide()

	# Coyote timer
	player.coyote_timer.start()


func get_transition() -> StringName:
	if player.is_in_water() and player.global_transform.origin.y < player.get_water_surface_height() - player.water_state_enter_offset:
		return PlayerStates.SWIM
	elif not player.are_raycasts_colliding():
		return PlayerStates.FALL
	elif Input.is_action_just_pressed("player_move_jump") or not player.jump_buffer_timer.is_stopped():
		return PlayerStates.JUMP
	elif Vector3(player.motion_velocity.x, 0.0, player.motion_velocity.z).is_equal_approx(Vector3.ZERO):
		return PlayerStates.IDLE
	else:
		return StringName()
