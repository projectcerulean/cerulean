extends PlayerState

var roll_angle: float = 0.0


func enter(old_state_name: StringName, data := {}) -> void:
	super.enter(old_state_name, data)
	roll_angle = 0.0


func process(delta: float) -> void:
	super.process(delta)

	# Update mesh facing direction
	var input_direction_2d: Vector3 = Vector3(player.input_vector.x, 0.0, player.input_vector.z)
	var linear_velocity_2d: Vector3 = Vector3(player.linear_velocity.x, 0.0, player.linear_velocity.z)
	roll_angle = lerp(
		roll_angle, linear_velocity_2d.signed_angle_to(input_direction_2d, Vector3.UP), player.underwater_roll_weight
	)

	if not player.input_vector.is_equal_approx(Vector3.ZERO):
		player.facing_direction = player.facing_direction.slerp(player.input_vector.normalized(), player.input_vector.length() * player.underwater_turn_weight)

	var velocity_direction: Vector3 = player.linear_velocity.normalized()
	if velocity_direction == Vector3.UP or velocity_direction == Vector3.DOWN:  # TODO: smoother transition
		player.mesh_joint_map[self.name][0].look_at(player.mesh_joint_map[self.name][0].get_global_transform().origin + player.facing_direction)
	else:
		player.mesh_joint_map[self.name][0].look_at(player.mesh_joint_map[self.name][0].get_global_transform().origin + velocity_direction)
	player.mesh_joint_map[self.name][1].rotation = Vector3(0.0, 0.0, roll_angle)


func physics_process(delta: float) -> void:
	super.physics_process(delta)

	# Apply movement
	var input_vector: Vector3 = (
		player.facing_direction * player.input_vector.length()
		+ Vector3.UP * (float(Input.is_action_pressed("player_move_jump")) - float(Input.is_action_pressed("player_move_glide")))
	)
	if input_vector.length_squared() > 1.0:
		input_vector = input_vector.normalized()
	player.linear_velocity += input_vector * player.underwater_move_acceleration * delta

	# Apply friction
	player.linear_velocity -= player.linear_velocity * player.underwater_resistance * delta

	# Go
	player.move_and_slide()


func get_transition() -> StringName:
	if not player.is_in_water:
		return player.FALL
	elif player.linear_velocity.y > 0.0 and player.global_transform.origin.y > player.get_water_surface_height():
		return player.SWIM
	else:
		return &""
