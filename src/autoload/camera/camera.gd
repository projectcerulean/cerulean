extends Position3D

const pitch_limit: float = PI / 2.0 - 0.1

@export var thumbstick_right: Resource
@export var settings: Resource
@export var transform_resource: Resource
@export var target_transform_resource: Resource

@onready var yaw_pivot: Node3D = get_node("YawPivot")
@onready var pitch_pivot: Node3D = get_node("YawPivot/PitchPivot")
@onready var camera: Camera3D = get_node("YawPivot/PitchPivot/Camera3D")
@onready var area3d: Area3D = get_node("YawPivot/PitchPivot/Camera3D/Area3D")

@export var camera_distance_min: float = 2.5
@export var camera_distance_max: float = 25.0
@export var camera_distance_speed: float = 2.0
@export var yaw_speed = PI
@export var pitch_speed = PI / 2.0

var water_collision_shapes: Array

@onready var camera_distance_default: float = camera.position.z
@onready var yaw_default: float = yaw_pivot.rotation.y
@onready var pitch_default: float = pitch_pivot.rotation.x


func _ready() -> void:
	Signals.scene_changed.connect(self._on_scene_changed)
	Signals.area_area_entered.connect(self._on_area_area_entered)
	Signals.area_area_exited.connect(self._on_area_area_exited)

	assert(thumbstick_right as ThumbstickResource != null, Errors.NULL_RESOURCE)
	assert(settings as SettingsResource != null, Errors.NULL_RESOURCE)
	assert(transform_resource as TransformResource != null, Errors.NULL_RESOURCE)
	assert(yaw_pivot != null, Errors.NULL_NODE)
	assert(pitch_pivot != null, Errors.NULL_NODE)
	assert(camera != null, Errors.NULL_NODE)
	assert(area3d != null, Errors.NULL_NODE)


func _process(delta: float) -> void:
	global_transform.origin = target_transform_resource.global_transform.origin

	if Input.is_action_pressed("camera_move_zoom_toggle"):
		camera.position.z = camera.position.z * (1.0 + thumbstick_right.value.y * camera_distance_speed * delta)
		camera.position.z = clamp(camera.position.z, camera_distance_min, camera_distance_max)
	else:
		var thumbstick_value: Vector2 = thumbstick_right.value
		if settings.settings[Settings.CAMERA_X_INVERTED] == Settings.Boolean.YES:
			thumbstick_value.x = -thumbstick_value.x
		if settings.settings[Settings.CAMERA_Y_INVERTED] == Settings.Boolean.YES:
			thumbstick_value.y = -thumbstick_value.y

		yaw_pivot.rotation.y = yaw_pivot.rotation.y - thumbstick_value.x * yaw_speed * delta
		pitch_pivot.rotation.x = pitch_pivot.rotation.x - thumbstick_value.y * pitch_speed * delta
		pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, -pitch_limit, pitch_limit)

	camera.look_at(target_transform_resource.global_transform.origin)

	# Update tranform resource
	transform_resource.global_transform = camera.global_transform
	transform_resource.transform = camera.transform


func _on_scene_changed(sender: Node) -> void:
	camera.position.z = camera_distance_default
	yaw_pivot.rotation.y = yaw_default
	pitch_pivot.rotation.x = pitch_default


func _on_area_area_entered(sender: Area3D, area: Area3D) -> void:
	if area != self.area3d:
		return

	var collision_shape: CollisionShape3D = TreeHelper.get_collision_shape_for_area(sender)
	assert(collision_shape != null, Errors.NULL_NODE)

	if str(sender.owner.name).begins_with("Water"):
		water_collision_shapes.append(collision_shape)

	if water_collision_shapes.size() == 1:
		Signals.emit_camera_water_entered(camera)


func _on_area_area_exited(sender: Area3D, area: Area3D) -> void:
	if area != self.area3d:
		return

	var collision_shape: CollisionShape3D = TreeHelper.get_collision_shape_for_area(sender)

	if collision_shape in water_collision_shapes:
		water_collision_shapes.erase(collision_shape)

	if water_collision_shapes.size() == 0:
		Signals.emit_camera_water_exited(camera)
