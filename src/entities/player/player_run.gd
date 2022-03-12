extends PlayerState

@export var move_speed: float = 8.5
@export var move_speed_lerp_weight: float = 7.0
@export var move_snap_distance: float = 0.25


func enter(data: Dictionary) -> void:
	super.enter(data)
	player.velocity.y = 0.0
	player.floor_snap_length = move_snap_distance


func exit(data: Dictionary) -> void:
	super.exit(data)
	player.floor_snap_length = 0.0


func physics_process(delta: float) -> void:
	super.physics_process(delta)

	# Apply movement
	player.velocity = Lerp.delta_lerp3(player.velocity, player.input_vector * move_speed, move_speed_lerp_weight, delta)
	player.move_and_slide()

	# Coyote timer
	player.coyote_timer.start()


func get_transition() -> StringName:
	if player.is_in_water() and player.global_transform.origin.y < player.get_water_surface_height() - water_state_enter_offset:
		return PlayerStates.SWIM
	elif not player.are_raycasts_colliding():
		return PlayerStates.FALL
	elif Input.is_action_just_pressed("player_move_jump") or not player.jump_buffer_timer.is_stopped():
		return PlayerStates.JUMP
	elif Vector3(player.velocity.x, 0.0, player.velocity.z).is_equal_approx(Vector3.ZERO):
		return PlayerStates.IDLE
	else:
		return StringName()
