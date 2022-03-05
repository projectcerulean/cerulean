extends PlayerState

@export var move_speed: float = 5.0
@export var move_speed_lerp_weight: float = 1.0


func physics_process(delta: float) -> void:
	super.physics_process(delta)

	# Apply movement
	var input_vector: Vector3 = (
		player.input_vector + Vector3.UP * (float(Input.is_action_pressed("player_move_jump")) - float(Input.is_action_pressed("player_move_dive")))
	)
	if input_vector.length_squared() > 1.0:
		input_vector = input_vector.normalized()
	player.motion_velocity = Lerp.delta_lerp3(player.motion_velocity, move_speed * input_vector, move_speed_lerp_weight, delta)
	player.move_and_slide()


func get_transition() -> StringName:
	if not player.is_in_water():
		return PlayerStates.FALL
	elif player.motion_velocity.y > 0.0 and player.global_transform.origin.y > player.get_water_surface_height():
		return PlayerStates.SWIM
	else:
		return StringName()
