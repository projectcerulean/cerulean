extends PlayerState

var glide_start_position: Vector3 = Vector3.ZERO
var glide_start_velocity: Vector3 = Vector3.ZERO
var roll_angle: float = 0.0


func enter(old_state: PlayerState, data := {}) -> void:
	super.enter(old_state, data)
	glide_start_position = player.position
	glide_start_velocity = player.motion_velocity
	roll_angle = 0.0

	var velocity_direction: Vector3 = player.motion_velocity.normalized()
	if velocity_direction == Vector3.UP or velocity_direction == Vector3.DOWN:  # TODO: smoother transition
		player.mesh_joint_map[self][0].look_at(player.mesh_joint_map[self][0].get_global_transform().origin + player.facing_direction)
	else:
		player.mesh_joint_map[self][0].look_at(player.mesh_joint_map[self][0].get_global_transform().origin + velocity_direction)


func process(delta: float) -> void:
	super.process(delta)

	# Update mesh facing direction
	var input_direction_2d: Vector3 = Vector3(player.input_vector.x, 0.0, player.input_vector.z)
	var motion_velocity_2d: Vector3 = Vector3(player.motion_velocity.x, 0.0, player.motion_velocity.z)
	roll_angle = Lerp.delta_lerp_angle(
		roll_angle, motion_velocity_2d.signed_angle_to(input_direction_2d, Vector3.UP), player.glide_roll_weight, delta
	)

	var velocity_direction: Vector3 = player.motion_velocity.normalized()
	if velocity_direction == Vector3.UP or velocity_direction == Vector3.DOWN:  # TODO: smoother transition
		player.mesh_joint_map[self][0].look_at(player.mesh_joint_map[self][0].get_global_transform().origin + player.facing_direction)
	else:
		player.mesh_joint_map[self][0].look_at(player.mesh_joint_map[self][0].get_global_transform().origin + velocity_direction)
	player.mesh_joint_map[self][1].rotation = Vector3(0.0, 0.0, roll_angle)


func physics_process(delta: float) -> void:
	super.physics_process(delta)

	# Apply movement
	var input_vector_spherical: Vector3 = player.input_vector
	input_vector_spherical.y = -sqrt(1.0 * 1.0 - min(input_vector_spherical.length_squared(), 1.0))
	input_vector_spherical = input_vector_spherical.normalized()
	assert(not input_vector_spherical.is_equal_approx(Vector3.ZERO), Errors.CONSISTENCY_ERROR)

	var velocity_direction_current: Vector3 = player.motion_velocity.normalized()
	var velocity_direction_new: Vector3 = Vector3.ZERO

	if velocity_direction_current == Vector3.ZERO:
		velocity_direction_new = Vector3.DOWN
	elif velocity_direction_current == input_vector_spherical:
		velocity_direction_new = input_vector_spherical
	elif velocity_direction_current == -input_vector_spherical:
		velocity_direction_new = -input_vector_spherical
		velocity_direction_new.y = -velocity_direction_new.y
	else:
		velocity_direction_new = Lerp.delta_slerp3(velocity_direction_current, input_vector_spherical, player.glide_smooth_weight, delta)
	assert(velocity_direction_new.is_normalized(), Errors.CONSISTENCY_ERROR)

	player.motion_velocity = velocity_direction_new * (
		Math.signed_sqrt(
			2.0 * Physics.GRAVITY * player.glide_gravity_modifier * (glide_start_position.y - player.position.y)
		) + glide_start_velocity.length()
	)

	# Update movement direction
	var direction_new: Vector3 = Vector3(player.motion_velocity.x, 0.0, player.motion_velocity.z).normalized()
	if not direction_new.is_equal_approx(Vector3.ZERO):
		player.facing_direction = direction_new.normalized()

	# Apply gravity
	player.motion_velocity.y = player.motion_velocity.y - Physics.GRAVITY * player.glide_gravity_modifier * delta

	# Go
	player.move_and_slide()

	# Jump buffering
	if Input.is_action_just_pressed("player_move_jump"):
		player.jump_buffer_timer.start()


func get_transition() -> PlayerState:
	if player.is_in_water() and player.global_transform.origin.y < player.get_water_surface_height() - player.water_state_enter_offset:
		return states.SWIM
	elif player.is_on_floor():
		if is_equal_approx(player.motion_velocity.x, 0.0) and is_equal_approx(player.motion_velocity.z, 0.0):
			return states.IDLE
		else:
			return states.RUN
	elif not Input.is_action_pressed("player_move_jump"):
		return states.FALL
	else:
		return null
