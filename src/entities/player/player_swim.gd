extends PlayerState


func enter(old_state_name: StringName, data := {}) -> void:
	super.enter(old_state_name, data)


func exit(new_state_name: StringName) -> void:
	super.exit(new_state_name)
	if new_state_name == player.JUMP:
		player.is_in_water = false
		player.water_surface_height = NAN


func process(delta: float) -> void:
	super.process(delta)

	# Update mesh facing direction
	player.mesh_joint_map[self.name][0].look_at(player.mesh_joint_map[self.name][0].get_global_transform().origin + player.facing_direction)


func physics_process(delta: float) -> void:
	super.physics_process(delta)

	# Apply movement
	if not player.input_vector.is_equal_approx(Vector3.ZERO):
		player.facing_direction = player.facing_direction.slerp(player.input_vector.normalized(), player.input_vector.length() * player.water_turn_weight)
		player.linear_velocity += player.facing_direction * player.input_vector.length() * player.water_move_acceleration * delta

	if not is_nan(player.water_surface_height) and player.linear_velocity.y > 0.0 and player.global_transform.origin.y > player.water_surface_height:
		player.global_transform.origin.y = player.water_surface_height
		player.linear_velocity.y = 0.0
	else:
		player.linear_velocity.y = player.linear_velocity.y + player.water_buoyancy * delta

	# Apply friction
	player.linear_velocity -= player.linear_velocity * player.water_resistance * delta

	# Go
	player.move_and_slide()

	# Jump buffering
	if Input.is_action_just_pressed("player_move_jump"):
		player.jump_buffer_timer.start()


func get_transition() -> String:
	if not player.is_in_water:
		return "Fall"
	elif player.raycast.is_colliding() and player.global_transform.origin.y > player.water_surface_height + player.water_state_enter_offset:
		return "Run"
	elif is_equal_approx(player.water_surface_height, player.global_transform.origin.y) and (Input.is_action_just_pressed("player_move_jump") or not player.jump_buffer_timer.is_stopped()):
		return "Jump"
	elif Input.is_action_just_pressed("player_move_glide"):
		return "Dive"
	else:
		return ""
