class_name Lerp
extends Node


static func delta_lerp(from: float, to: float, weight: float, process_delta: float) -> float:
	if is_equal_approx(from, to):
		return to
	else:
		return lerp(from, to, 1.0 - pow(10.0, -weight * process_delta))


static func delta_lerp_angle(from: float, to: float, weight: float, process_delta: float) -> float:
	if is_equal_approx(from, to):
		return to
	else:
		return lerp_angle(from, to, 1.0 - pow(10.0, -weight * process_delta))


static func delta_lerp2(from: Vector2, to: Vector2, weight: float, process_delta: float) -> Vector2:
	if from.is_equal_approx(to):
		return to
	else:
		return from.lerp(to, 1.0 - pow(10.0, -weight * process_delta))


static func delta_lerp3(from: Vector3, to: Vector3, weight: float, process_delta: float) -> Vector3:
	if from.is_equal_approx(to):
		return to
	else:
		return from.lerp(to, 1.0 - pow(10.0, -weight * process_delta))


static func delta_slerp3(from: Vector3, to: Vector3, weight: float, process_delta: float) -> Vector3:
	assert(from.is_normalized(), Errors.INVALID_ARGUMENT)
	assert(to.is_normalized(), Errors.INVALID_ARGUMENT)
	if from.is_equal_approx(to):
		return to
	else:
		var new: Vector3 = from.slerp(to, 1.0 - pow(10.0, -weight * process_delta))
		assert(new.is_normalized(), Errors.CONSISTENCY_ERROR)
		return new
