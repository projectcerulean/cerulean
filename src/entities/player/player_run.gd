extends PlayerState


func enter(data := {}) -> void:
	super.enter(data)
	player.linear_velocity.y = 0.0


func exit() -> void:
	super.exit()
	player.coyote_timer.stop()


func process(delta: float) -> void:
	super.process(delta)

	# Update mesh facing direction
	player.mesh_joint_map[self.name][0].look_at(player.mesh_joint_map[self.name][0].get_global_transform().origin + player.facing_direction)


func physics_process(delta: float) -> void:
	super.physics_process(delta)

	# Apply movement
	if not player.input_vector.is_equal_approx(Vector3.ZERO):
		player.facing_direction = player.facing_direction.slerp(player.input_vector.normalized(), player.input_vector.length() * player.turn_weight)
		player.linear_velocity += player.facing_direction * player.input_vector.length() * player.move_acceleration * delta

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
