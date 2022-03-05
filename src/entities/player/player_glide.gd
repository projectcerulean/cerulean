extends PlayerState

@export var glide_gravity_modifier: float = 0.05
@export var glide_turn_lerp_weight: float = 0.5238

var glide_start_position: Vector3 = Vector3.ZERO
var glide_start_velocity: Vector3 = Vector3.ZERO
var roll_angle: float = 0.0


func enter(data: Dictionary) -> void:
	super.enter(data)
	glide_start_position = player.position
	glide_start_velocity = player.motion_velocity


func physics_process(delta: float) -> void:
	super.physics_process(delta)

	# Apply movement
	var input_vector_spherical: Vector3 = player.input_vector
	input_vector_spherical.y = -sqrt(1.0 - min(input_vector_spherical.length_squared(), 1.0))
	input_vector_spherical = input_vector_spherical.normalized()
	assert(input_vector_spherical.is_normalized(), Errors.CONSISTENCY_ERROR)

	var velocity_direction_current: Vector3 = player.motion_velocity.normalized()
	var velocity_direction_new: Vector3 = Vector3.ZERO

	if velocity_direction_current == Vector3.ZERO:
		velocity_direction_new = Vector3.DOWN
	else:
		velocity_direction_new = Lerp.delta_slerp3(velocity_direction_current, input_vector_spherical, glide_turn_lerp_weight, delta)

	player.motion_velocity = velocity_direction_new * (
		Math.signed_sqrt(
			2.0 * Physics.GRAVITY * glide_gravity_modifier * (glide_start_position.y - player.position.y)
		) + glide_start_velocity.length()
	)

	player.motion_velocity.y = player.motion_velocity.y - Physics.GRAVITY * glide_gravity_modifier * delta
	player.move_and_slide()

	# Jump buffering
	if Input.is_action_just_pressed("player_move_jump"):
		player.jump_buffer_timer.start()


func get_transition() -> StringName:
	if player.is_in_water() and player.global_transform.origin.y < player.get_water_surface_height() - water_state_enter_offset:
		return PlayerStates.SWIM
	elif player.is_on_floor():
		if is_equal_approx(player.motion_velocity.x, 0.0) and is_equal_approx(player.motion_velocity.z, 0.0):
			return PlayerStates.IDLE
		else:
			return PlayerStates.RUN
	elif not Input.is_action_pressed("player_move_jump"):
		return PlayerStates.FALL
	else:
		return StringName()
