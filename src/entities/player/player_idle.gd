extends PlayerState


func enter(_data := {}) -> void:
	player.linear_velocity = Vector3.ZERO


func get_transition() -> String:
	if not player.raycast.is_colliding():
		return "Fall"
	elif Input.is_action_just_pressed("player_move_jump"):
		return "Jump"
	elif not player.thumbstick_left.value.is_equal_approx(Vector2.ZERO):
		return "Run"
	else:
		return ""
