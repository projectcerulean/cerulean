extends AnimatableBody3D

@export var _environment_resource: Resource

var angle: float = TAU*randf()
var water_bodies: Array[Area3D]
var look_direction: Vector3 = Vector3.UP
var look_direction_lerp_weight: float = 1.0
var transform_lerp_weight: float = 10.0

@onready var environment_resource: EnvironmentResource = _environment_resource as EnvironmentResource


func _ready() -> void:
	Signals.area_body_entered.connect(self._on_area_body_entered)
	Signals.area_body_exited.connect(self._on_area_body_exited)

	assert(environment_resource != null, Errors.NULL_RESOURCE)


func _process(delta: float) -> void:
	global_transform.origin.y = Lerp.delta_lerp(global_transform.origin.y, get_water_surface_height(), transform_lerp_weight, delta)
	var normal: Vector3 = get_water_surface_normal()
	look_direction = Lerp.delta_slerp3(look_direction, normal, look_direction_lerp_weight, delta)
	look_at(global_transform.origin + look_direction, Vector3.RIGHT.rotated(Vector3.UP, angle))


func _on_area_body_entered(sender: Area3D, body: PhysicsBody3D) -> void:
	if body != self:
		return

	assert(str(sender.owner.name).begins_with("Water"), Errors.CONSISTENCY_ERROR)
	water_bodies.append(sender)


func _on_area_body_exited(sender: Area3D, body: PhysicsBody3D) -> void:
	if body != self:
		return

	if sender in water_bodies:
		water_bodies.erase(sender)


func get_water_surface_height() -> float:
	var height: float = -INF
	for area in water_bodies:
		height = max(
			height,
			area.global_transform.origin.y + Utils.get_water_surface_height(
				environment_resource.value, Vector2(global_transform.origin.x, global_transform.origin.z)
			)
	)
	return height


func get_water_surface_normal() -> Vector3:
	var normal: Vector3 = Utils.get_water_surface_normal(
		environment_resource.value,
		Vector2(global_transform.origin.x, global_transform.origin.z)
	)
	return normal
