extends PlayerState


func enter(old_state_name: StringName, data := {}) -> void:
	super.enter(old_state_name, data)
	player.linear_velocity = Vector3.ZERO

	# Update mesh facing direction
	player.mesh_joint_map[self.name][0].look_at(player.mesh_joint_map[self.name][0].get_global_transform().origin + player.facing_direction)


func get_transition() -> StringName:
	if player.is_in_water:
		return player.SWIM
	elif not player.raycast.is_colliding():
		return player.FALL
	elif Input.is_action_just_pressed("player_move_jump") or not player.jump_buffer_timer.is_stopped():
		return player.JUMP
	elif not player.thumbstick_left.value.is_equal_approx(Vector2.ZERO):
		return player.RUN
	else:
		return &""
