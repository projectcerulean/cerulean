extends PlayerState

@export var move_speed: float = 8.5
@export var move_speed_lerp_weight: float = 1.0


func physics_process(delta: float) -> void:
	super.physics_process(delta)

	# Apply movement
	var motion_velocity_xz: Vector3 = Vector3(player.motion_velocity.x, 0.0, player.motion_velocity.z)
	var motion_velocity_xz_target: Vector3

	if motion_velocity_xz.is_equal_approx(Vector3.ZERO) or player.input_vector.is_equal_approx(Vector3.ZERO) or motion_velocity_xz.length() < move_speed:
		motion_velocity_xz_target = player.input_vector * move_speed
	else:
		var delta_angle: float = motion_velocity_xz.angle_to(player.input_vector)
		if delta_angle < PI / 2.0:
			# We want ta maintain all speed while in the air, even if it is higher than move_speed
			var move_speed_extended: float = Math.ellipse(Vector2(motion_velocity_xz.length(), move_speed), delta_angle)
			motion_velocity_xz_target = player.input_vector.normalized() *  move_speed_extended
			pass
		else:
			motion_velocity_xz_target = player.input_vector * move_speed

	var motion_velocity_xz_new = Lerp.delta_lerp3(motion_velocity_xz, motion_velocity_xz_target, move_speed_lerp_weight, delta)
	player.motion_velocity = Vector3(motion_velocity_xz_new.x, player.motion_velocity.y - Physics.GRAVITY * delta, motion_velocity_xz_new.z)
	player.move_and_slide()

	# Jump buffering
	if Input.is_action_just_pressed("player_move_jump") and player.coyote_timer.is_stopped():
		player.jump_buffer_timer.start()


func get_transition() -> StringName:
	if player.is_in_water() and player.global_transform.origin.y < player.get_water_surface_height() - water_state_enter_offset:
		return PlayerStates.SWIM
	elif Input.is_action_just_pressed("player_move_jump") and not player.coyote_timer.is_stopped():
		return PlayerStates.JUMP
	elif player.is_on_floor():
		if is_equal_approx(player.motion_velocity.x, 0.0) and is_equal_approx(player.motion_velocity.z, 0.0):
			return PlayerStates.IDLE
		else:
			return PlayerStates.RUN
	elif player.motion_velocity.y < 0.0 and Input.is_action_pressed("player_move_jump"):
		return PlayerStates.GLIDE
	else:
		return StringName()
