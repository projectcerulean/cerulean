extends PlayerState

var roll_angle: float = 0.0


func enter(old_state: StringName, data := {}) -> void:
	super.enter(old_state, data)
	roll_angle = 0.0

	var velocity_direction: Vector3 = player.motion_velocity.normalized()
	if velocity_direction == Vector3.UP or velocity_direction == Vector3.DOWN:  # TODO: smoother transition
		joint1.look_at(joint1.get_global_transform().origin + player.facing_direction)
	else:
		joint1.look_at(joint1.get_global_transform().origin + velocity_direction)


func process(delta: float) -> void:
	super.process(delta)

	# Update mesh facing direction
	var input_direction_2d: Vector3 = Vector3(player.input_vector.x, 0.0, player.input_vector.z)
	var motion_velocity_2d: Vector3 = Vector3(player.motion_velocity.x, 0.0, player.motion_velocity.z)
	roll_angle = Lerp.delta_lerp_angle(
		roll_angle, motion_velocity_2d.signed_angle_to(input_direction_2d, Vector3.UP), player.underwater_roll_weight, delta
	)

	if not player.input_vector.is_equal_approx(Vector3.ZERO):
		player.facing_direction = Lerp.delta_slerp3(player.facing_direction, player.input_vector.normalized(), player.input_vector.length() * player.underwater_turn_weight, delta)

	var velocity_direction: Vector3 = player.motion_velocity.normalized()
	if velocity_direction == Vector3.UP or velocity_direction == Vector3.DOWN:  # TODO: smoother transition
		joint1.look_at(joint1.get_global_transform().origin + player.facing_direction)
	else:
		joint1.look_at(joint1.get_global_transform().origin + velocity_direction)
	joint2.rotation = Vector3(0.0, 0.0, roll_angle)


func physics_process(delta: float) -> void:
	super.physics_process(delta)

	# Apply movement
	var input_vector: Vector3 = (
		player.facing_direction * player.input_vector.length()
		+ Vector3.UP * (float(Input.is_action_pressed("player_move_jump")) - float(Input.is_action_pressed("player_move_dive")))
	)
	if input_vector.length_squared() > 1.0:
		input_vector = input_vector.normalized()
	player.motion_velocity += input_vector * player.underwater_move_acceleration * delta

	# Apply friction
	player.motion_velocity -= player.motion_velocity * player.underwater_resistance * delta

	# Go
	player.move_and_slide()


func get_transition() -> StringName:
	if not player.is_in_water():
		return PlayerStates.FALL
	elif player.motion_velocity.y > 0.0 and player.global_transform.origin.y > player.get_water_surface_height():
		return PlayerStates.SWIM
	else:
		return StringName()
