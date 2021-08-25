class_name Lerp
extends Node


static func delta_lerp(from: float, to: float, weight: float, process_delta: float) -> float:
	assert(weight > 0.0, Errors.INVALID_ARGUMENT)
	return lerp(from, to, 1.0 - pow(10.0, -weight * process_delta))


static func delta_lerp3(from: Vector3, to: Vector3, weight: float, process_delta: float) -> Vector3:
	assert(weight > 0.0, Errors.INVALID_ARGUMENT)
	return from.lerp(to, 1.0 - pow(10.0, -weight * process_delta))


static func delta_slerp3(from: Vector3, to: Vector3, weight: float, process_delta: float) -> Vector3:
	assert(weight > 0.0, Errors.INVALID_ARGUMENT)
	assert(from.is_normalized(), Errors.INVALID_ARGUMENT)
	assert(to.is_normalized(), Errors.INVALID_ARGUMENT)
	return from.slerp(to, 1.0 - pow(10.0, -weight * process_delta))
