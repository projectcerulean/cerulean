extends Node


# Reference: https://www.youtube.com/watch?v=Q4aQiuJYZ2s
# Apply some basic processing to the raw thumbstick input values before they are used in the game.
# Values are updated each frame (_process callback) and can be queried using the `value` variable.
class Thumbstick:
	const deadzone_inner: float = 0.1
	const deadzone_outer: float = 0.9
	const response_exponent: float = 4.0

	var action_up: String
	var action_down: String
	var action_left: String
	var action_right: String

	var value: Vector2 = Vector2.ZERO


	func _init(which_stick: String):
		assert(which_stick in ["left", "right"])
		action_up = which_stick + "_stick_up"
		action_down = which_stick + "_stick_down"
		action_left = which_stick + "_stick_left"
		action_right = which_stick + "_stick_right"


	func update() -> void:
		var value_raw: Vector2 = Vector2.ZERO
		value_raw.x = Input.get_action_strength(action_right) - Input.get_action_strength(action_left)
		value_raw.y =  Input.get_action_strength(action_down) - Input.get_action_strength(action_up)

		# Dead zone
		var value_clamped: Vector2 = Vector2.ZERO
		value_clamped.x = clamp(abs(value_raw.x), deadzone_inner, deadzone_outer)
		value_clamped.y = clamp(abs(value_raw.y), deadzone_inner, deadzone_outer)
		var value_lerped: Vector2 = Vector2.ZERO
		value_lerped.x = range_lerp(value_clamped.x, deadzone_inner, deadzone_outer, 0.0, 1.0)
		value_lerped.y = range_lerp(value_clamped.y, deadzone_inner, deadzone_outer, 0.0, 1.0)
		value = Vector2(value_lerped.x * sign(value_raw.x), value_lerped.y * sign(value_raw.y))

		# Remap square input to circle
		var value_circle: Vector2 = Vector2.ZERO
		value_circle.x = value.x * sqrt(1.0 - value.y * value.y / 2.0)
		value_circle.y = value.y * sqrt(1.0 - value.x * value.x / 2.0)
		if value_circle.length() > 1.0:
			value_circle = value_circle.normalized()
		value = value_circle

		# Non-linear response
		var value_nonlinear: Vector2 = value.normalized() * pow(value.length_squared(), response_exponent / 2.0)
		value = value_nonlinear

		# Set to zero if close to zero
		if value.is_equal_approx(Vector2.ZERO):
			value = Vector2.ZERO


var thumbsticks: Dictionary


func _ready() -> void:
	for which_stick in ["left", "right"]:
		thumbsticks[which_stick] = Thumbstick.new(which_stick)


func _process(_delta: float) -> void:
	for which_stick in ["left", "right"]:
		thumbsticks[which_stick].update()
