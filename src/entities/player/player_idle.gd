extends PlayerState


func enter(old_state: PlayerState, data := {}) -> void:
	super.enter(old_state, data)
	player.linear_velocity = Vector3.ZERO

	# Update mesh facing direction
	player.mesh_joint_map[self][0].look_at(player.mesh_joint_map[self][0].get_global_transform().origin + player.facing_direction)


func get_transition() -> PlayerState:
	if player.is_in_water() and player.global_transform.origin.y < player.get_water_surface_height() - player.water_state_enter_offset:
		return player.state.states.SWIM
	elif not player.raycast.is_colliding():
		return player.state.states.FALL
	elif Input.is_action_just_pressed("player_move_jump") or not player.jump_buffer_timer.is_stopped():
		return player.state.states.JUMP
	elif not player.thumbstick_left.value.is_equal_approx(Vector2.ZERO):
		return player.state.states.RUN
	else:
		return null
