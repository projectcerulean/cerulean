extends PlayerState

@export var move_speed: float = 7.0
@export var move_speed_lerp_weight: float = 1.0
@export var water_buoyancy_speed: float = 4.0
@export var water_bouyancy_speed_lerp_weight: float = 1.0

var surfaced: bool


func enter(data: Dictionary) -> void:
	super.enter(data)
	surfaced = false


func physics_process(delta: float) -> void:
	super.physics_process(delta)

	# Apply movement
	var motion_velocity_xz: Vector3 = Vector3(player.motion_velocity.x, 0.0, player.motion_velocity.z)
	motion_velocity_xz = Lerp.delta_lerp3(motion_velocity_xz, player.input_vector * move_speed, move_speed_lerp_weight, delta)
	var motion_velocity_y: float = player.motion_velocity.y
	if surfaced:
		motion_velocity_y = 0.0
		if not is_nan(player.get_water_surface_height()):
			player.global_transform.origin.y = player.get_water_surface_height()
	else:
		motion_velocity_y = Lerp.delta_lerp(motion_velocity_y, water_buoyancy_speed, water_bouyancy_speed_lerp_weight, delta)
		player.motion_velocity = Lerp.delta_lerp3(player.motion_velocity, player.input_vector * move_speed, move_speed_lerp_weight, delta)
		if not is_nan(player.get_water_surface_height()) and player.motion_velocity.y > 0.0 and player.global_transform.origin.y > player.get_water_surface_height():
			surfaced = true
	player.motion_velocity = Vector3(motion_velocity_xz.x, motion_velocity_y, motion_velocity_xz.z)
	player.move_and_slide()

	# Coyote timer
	player.coyote_timer.start()

	# Jump buffering
	if Input.is_action_just_pressed("player_move_jump"):
		player.jump_buffer_timer.start()


func get_transition() -> StringName:
	if not player.is_in_water():
		return PlayerStates.FALL
	elif player.are_raycasts_colliding() and player.global_transform.origin.y > player.get_water_surface_height() + water_state_enter_offset:
		return PlayerStates.RUN
	elif Input.is_action_just_pressed("player_move_jump") or not player.jump_buffer_timer.is_stopped():
		if surfaced:
			return PlayerStates.JUMP
	elif Input.is_action_just_pressed("player_move_dive"):
		return PlayerStates.DIVE
	else:
		return StringName()
