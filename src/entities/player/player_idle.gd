extends PlayerState


func enter(data := {}) -> void:
	super.enter(data)
	player.linear_velocity = Vector3.ZERO

	# Update mesh facing direction
	player.mesh_joint_map[self.name][0].look_at(player.mesh_joint_map[self.name][0].get_global_transform().origin + player.facing_direction)


func get_transition() -> String:
	if player.is_in_water:
		return "Swim"
	elif not player.raycast.is_colliding():
		return "Fall"
	elif Input.is_action_just_pressed("player_move_jump") or not player.jump_buffer_timer.is_stopped():
		return "Jump"
	elif not player.thumbstick_left.value.is_equal_approx(Vector2.ZERO):
		return "Run"
	else:
		return ""
