extends PlayerState


func enter(_data := {}) -> void:
	player.linear_velocity = Vector3.ZERO


func get_transition() -> String:
	if not player.thumbstick_left.value.is_equal_approx(Vector2.ZERO):
		return "Run"
	else:
		return ""
