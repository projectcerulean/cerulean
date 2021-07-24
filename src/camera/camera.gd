# Reference: https://www.youtube.com/watch?v=vEPpS120J7A
extends Camera3D

@export var target_path: NodePath
@export var thumbstick_right: Resource

@export var rotation_speed: Vector2 = Vector2(90, 180)
@export var target_offset: Vector3
@export var camera_rotation: Vector3
@export var pitch_limit: Vector2 = Vector2(-89, 89)
@export var anchor_offset: Vector3
@export var look_target: Vector3
@export var zoom_limit: Vector2 = Vector2(2.5, 25.0)
@export var zoom_speed: float = 2.0

@onready var target: Node3D = get_node(target_path) as Node3D
@onready var area3d: Area3D = get_node("Area3D")

@onready var rotation_speed_rad: Vector2 = Vector2(deg2rad(rotation_speed.x), deg2rad(rotation_speed.y))
@onready var camera_rotation_rad: Vector2 = Vector2(deg2rad(camera_rotation.x), deg2rad(camera_rotation.y))
@onready var pitch_limit_rad: Vector2 = Vector2(deg2rad(pitch_limit.x), deg2rad(pitch_limit.y))

var water_collision_shapes: Array


func _ready() -> void:
	Signals.area_area_entered.connect(self._on_area_area_entered)
	Signals.area_area_exited.connect(self._on_area_area_exited)

	assert(thumbstick_right as ThumbstickResource != null, Errors.NULL_RESOURCE)
	assert(target != null, Errors.NULL_NODE)
	assert(area3d != null, Errors.NULL_NODE)

	if target_offset == Vector3.ZERO:
		target_offset = transform.origin - target.transform.origin - anchor_offset
	assert(clamp(target_offset.length(), zoom_limit.x, zoom_limit.y) == target_offset.length(), Errors.INVALID_ARGUMENT)
	if look_target == Vector3.ZERO:
		look_target = Vector3(0, 0, -100)


func _process(delta: float) -> void:
	if Input.is_action_pressed("camera_move_zoom_toggle"):
		target_offset *= 1.0 + (thumbstick_right.value.y) * zoom_speed * delta
		if target_offset.length() < zoom_limit.x:
			target_offset = target_offset.normalized() * zoom_limit.x
		elif target_offset.length() > zoom_limit.y:
			target_offset = target_offset.normalized() * zoom_limit.y
	else:
		camera_rotation_rad.x = camera_rotation_rad.x - thumbstick_right.value.y * rotation_speed_rad.x * delta
		camera_rotation_rad.x = clamp(camera_rotation_rad.x, pitch_limit_rad.x, pitch_limit_rad.y)
		camera_rotation_rad.y = camera_rotation_rad.y - thumbstick_right.value.x * rotation_speed_rad.y * delta

	var vertical_axis: Vector3 = Vector3.RIGHT.rotated(Vector3.UP, camera_rotation_rad.y)
	var target_offset_rotated: Vector3 = target_offset.rotated(Vector3.UP, camera_rotation_rad.y)
	var look_target_rotated: Vector3 = look_target.rotated(Vector3.UP, camera_rotation_rad.y)
	target_offset_rotated = target_offset_rotated.rotated(vertical_axis, camera_rotation_rad.x)
	look_target_rotated = look_target_rotated.rotated(vertical_axis, camera_rotation_rad.x)

	transform.origin = target.transform.origin + anchor_offset + target_offset_rotated
	look_at(look_target_rotated + target.transform.origin)


func _on_area_area_entered(sender: Area3D, area: Area3D) -> void:
	if area != self.area3d:
		return

	var collision_shape: CollisionShape3D = TreeHelper.get_collision_shape_for_area(sender)
	assert(collision_shape != null, Errors.NULL_NODE)

	if str(sender.owner.name).begins_with("Water"):
		water_collision_shapes.append(collision_shape)

	if water_collision_shapes.size() == 1:
		Signals.emit_camera_water_entered(self)


func _on_area_area_exited(sender: Area3D, area: Area3D) -> void:
	if area != self.area3d:
		return

	var collision_shape: CollisionShape3D = TreeHelper.get_collision_shape_for_area(sender)

	if collision_shape in water_collision_shapes:
		water_collision_shapes.erase(collision_shape)

	if water_collision_shapes.size() == 0:
		Signals.emit_camera_water_exited(self)
