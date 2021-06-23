extends CharacterBody3D


func _physics_process(delta: float) -> void:
	linear_velocity.z = Input.get_action_strength("player_move_backward") - Input.get_action_strength("player_move_forward")
	linear_velocity.x = Input.get_action_strength("player_move_right") - Input.get_action_strength("player_move_left")
	move_and_slide()
