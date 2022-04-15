# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Position3D

const pitch_limit: float = PI / 2.0 - 0.1

@export var _thumbstick_resource_right: Resource
@export var _settings_resource: Resource
@export var _transform_resource: Resource
@export var _target_transform_resource: Resource
@export var _game_state_resource: Resource

@onready var yaw_pivot: Position3D = get_node("YawPivot") as Position3D
@onready var pitch_pivot: Position3D = get_node("YawPivot/PitchPivot") as Position3D
@onready var raycast: RayCast3D = get_node("YawPivot/PitchPivot/RayCast3D") as RayCast3D
@onready var camera_anchor: Position3D = get_node("YawPivot/PitchPivot/CameraAnchor") as Position3D
@onready var camera: Camera3D = get_node("YawPivot/PitchPivot/CameraAnchor/Camera3D") as Camera3D
@onready var area3d: Area3D = get_node("YawPivot/PitchPivot/CameraAnchor/Camera3D/Area3D") as Area3D

@export var camera_distance_min: float = 2.5
@export var camera_distance_max: float = 10.0
@export var camera_distance_speed_max: float = 2.0
@export var camera_distance_lerp_weight: float = 10.0
@export var camera_rotation_speed_max: Vector2 = Vector2(PI, PI/2.0)
@export var camera_rotation_lerp_weight: float = 15.0
@export var camera_push_weight_forwards: float = 10.0
@export var camera_push_weight_backwards: float = 5.0

var camera_rotation_speed: Vector2 = Vector2()
var camera_distance_speed: float = 0.0
var water_collision_shapes: Array

@onready var thumbstick_resource_right: Vector2Resource = _thumbstick_resource_right as Vector2Resource
@onready var settings_resource: SettingsResource = _settings_resource as SettingsResource
@onready var transform_resource: TransformResource = _transform_resource as TransformResource
@onready var target_transform_resource: TransformResource = _target_transform_resource as TransformResource
@onready var game_state_resource: StateResource = _game_state_resource as StateResource

@onready var camera_distance_default: float = camera_anchor.position.z
@onready var yaw_default: float = yaw_pivot.rotation.y
@onready var pitch_default: float = pitch_pivot.rotation.x


func _ready() -> void:
	Signals.scene_changed.connect(self._on_scene_changed)
	Signals.area_area_entered.connect(self._on_area_area_entered)
	Signals.area_area_exited.connect(self._on_area_area_exited)

	assert(thumbstick_resource_right != null, Errors.NULL_RESOURCE)
	assert(settings_resource != null, Errors.NULL_RESOURCE)
	assert(transform_resource != null, Errors.NULL_RESOURCE)
	assert(target_transform_resource != null, Errors.NULL_RESOURCE)
	assert(game_state_resource != null, Errors.NULL_RESOURCE)

	assert(yaw_pivot != null, Errors.NULL_NODE)
	assert(pitch_pivot != null, Errors.NULL_NODE)
	assert(raycast != null, Errors.NULL_NODE)
	assert(camera_anchor != null, Errors.NULL_NODE)
	assert(camera != null, Errors.NULL_NODE)
	assert(area3d != null, Errors.NULL_NODE)


func _process(delta: float) -> void:
	global_transform.origin = target_transform_resource.value.origin

	if game_state_resource.current_state in [GameStates.GAMEPLAY, GameStates.DIALOGUE]:
		var rotation_speed_target: Vector2 = Vector2()
		var distance_speed_target: float = 0.0
		if Input.is_action_pressed(InputActions.CAMERA_ZOOM_TOGGLE):
			distance_speed_target = thumbstick_resource_right.value.y * camera_distance_speed_max
		else:
			rotation_speed_target = thumbstick_resource_right.value * camera_rotation_speed_max
			if settings_resource.settings[Settings.CAMERA_X_INVERTED] == Settings.Boolean.YES:
				rotation_speed_target.x *= -1.0
			if settings_resource.settings[Settings.CAMERA_Y_INVERTED] == Settings.Boolean.YES:
				rotation_speed_target.y *= -1.0

		camera_distance_speed = Lerp.delta_lerp(camera_distance_speed, distance_speed_target, camera_distance_lerp_weight, delta)
		camera_anchor.position.z = camera_anchor.position.z * (1.0 + camera_distance_speed * delta)
		camera_anchor.position.z = clamp(camera_anchor.position.z, camera_distance_min, camera_distance_max)

		camera_rotation_speed = Lerp.delta_lerp2(camera_rotation_speed, rotation_speed_target, camera_rotation_lerp_weight, delta)
		yaw_pivot.rotation.y -= camera_rotation_speed.x * delta
		pitch_pivot.rotation.x -= camera_rotation_speed.y * delta
		pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, -pitch_limit, pitch_limit)

	# Push camera towards the target if there is solid geometry in the way, helps to prevent clipping
	raycast.target_position = camera_anchor.position
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var camera_distance_target: float = -(raycast.get_collision_point() - camera_anchor.global_transform.origin).length()
		camera.position.z = Lerp.delta_lerp(camera.position.z, camera_distance_target, camera_push_weight_forwards, delta)
	else:
		camera.position.z = Lerp.delta_lerp(camera.position.z, 0.0, camera_push_weight_backwards, delta)

	# Look at target
	camera.look_at(target_transform_resource.value.origin)

	# Update tranform resource
	transform_resource.value = camera.global_transform


func _on_scene_changed(_sender: Node) -> void:
	water_collision_shapes.clear()
	camera.position.z = 0.0
	camera_anchor.position.z = camera_distance_default
	yaw_pivot.rotation.y = yaw_default
	pitch_pivot.rotation.x = pitch_default


func _on_area_area_entered(sender: Area3D, area: Area3D) -> void:
	if area != self.area3d:
		return

	var collision_shape: CollisionShape3D = Utils.get_collision_shape_for_area(sender)
	assert(collision_shape != null, Errors.NULL_NODE)

	if str(sender.owner.name).begins_with("Water"):
		water_collision_shapes.append(collision_shape)

	if water_collision_shapes.size() == 1:
		Signals.emit_camera_water_entered(camera)


func _on_area_area_exited(sender: Area3D, area: Area3D) -> void:
	if area != self.area3d:
		return

	var collision_shape: CollisionShape3D = Utils.get_collision_shape_for_area(sender)

	if collision_shape in water_collision_shapes:
		water_collision_shapes.erase(collision_shape)

	if water_collision_shapes.size() == 0:
		Signals.emit_camera_water_exited(camera)
