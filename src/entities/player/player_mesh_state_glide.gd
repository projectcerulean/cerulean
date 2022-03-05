extends PlayerMeshState

@export var turn_lerp_weight: float = 2.0
@export var roll_lerp_weight: float = 2.0

var yaw_direction: Vector3 = Vector3.ZERO
var roll_angle: float = 0.0


func enter(data: Dictionary) -> void:
	super.enter(data)
	roll_angle = 0.0
	yaw_direction = data.get(YAW_DIRECTION, Vector3.ZERO)
	process(get_process_delta_time())


func exit(data: Dictionary) -> void:
	super.exit(data)
	data[YAW_DIRECTION] = yaw_direction
	data[YAW_DIRECTION_TARGET] = yaw_direction


func process(delta: float) -> void:
	super.process(delta)
	var yaw_direction_new: Vector3 = Vector3(player.motion_velocity.x, 0.0, player.motion_velocity.z).normalized()
	if yaw_direction_new.is_normalized():
		yaw_direction = yaw_direction_new

	if is_zero_approx(player.motion_velocity.x) and is_zero_approx(player.motion_velocity.z):
		mesh_root.look_at(mesh_root.get_global_transform().origin + (Vector3.UP if player.motion_velocity.y > 0.0 else Vector3.DOWN), yaw_direction)
	else:
		var input_direction_2d: Vector3 = Vector3(player_input_vector_resource.value.x, 0.0, player_input_vector_resource.value.z)
		var motion_velocity_2d: Vector3 = Vector3(player.motion_velocity.x, 0.0, player.motion_velocity.z)
		roll_angle = Lerp.delta_lerp_angle(
			roll_angle, motion_velocity_2d.signed_angle_to(input_direction_2d, Vector3.UP), roll_lerp_weight, delta
		)

		var input_vector_spherical: Vector3 = player_input_vector_resource.value
		input_vector_spherical.y = -sqrt(1.0 - min(input_vector_spherical.length_squared(), 1.0))
		input_vector_spherical = input_vector_spherical.normalized()
		assert(input_vector_spherical.is_normalized(), Errors.CONSISTENCY_ERROR)
		var mesh_direction: Vector3 = Lerp.delta_slerp3(player.motion_velocity.normalized(), input_vector_spherical, turn_lerp_weight, delta)
		mesh_root.look_at(mesh_root.get_global_transform().origin + mesh_direction, Vector3.UP.rotated(mesh_direction, -roll_angle))
