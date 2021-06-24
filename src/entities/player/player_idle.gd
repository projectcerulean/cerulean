extends PlayerState


func enter(_data := {}) -> void:
	player.linear_velocity = Vector3.ZERO


func get_transition() -> String:
	var input: Vector3 = Vector3(player.thumbstick_left.value.x, 0, player.thumbstick_left.value.y)

	if not input.is_equal_approx(Vector3.ZERO):
		return "Run"
	else:
		return ""
