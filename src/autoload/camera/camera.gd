# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Marker3D

const pitch_limit: float = PI / 2.0 - 0.1

@export var _thumbstick_resource_right: Resource
@export var _settings_resource: Resource
@export var _target_transform_resource: Resource
@export var _game_state_resource: Resource

@onready var yaw_pivot: Marker3D = get_node("YawPivot") as Marker3D
@onready var pitch_pivot: Marker3D = get_node("YawPivot/PitchPivot") as Marker3D
@onready var raycast: RayCast3D = get_node("YawPivot/PitchPivot/RayCast3D") as RayCast3D
@onready var camera_anchor: Marker3D = get_node("YawPivot/PitchPivot/CameraAnchor") as Marker3D
@onready var camera: Camera3D = get_node("YawPivot/PitchPivot/CameraAnchor/Camera3D") as Camera3D
@onready var water_detector: Area3D = get_node("YawPivot/PitchPivot/CameraAnchor/Camera3D/WaterDetector") as Area3D

@export var camera_distance_min: float = 2.5
@export var camera_distance_max: float = 10.0
@export var camera_distance_speed_max: float = 2.0
@export var camera_distance_lerp_weight: float = 10.0
@export var camera_rotation_speed_max: Vector2 = Vector2(PI, PI/2.0)
@export var camera_rotation_lerp_weight: float = 15.0
@export var camera_push_weight_forwards: float = 25.0
@export var camera_push_weight_backwards: float = 5.0
@export var camera_push_frustum_scale: float = 2.5
@export var fov_change_tween_time: float = 0.5

var camera_rotation_speed: Vector2 = Vector2()
var camera_distance_speed: float = 0.0

@onready var thumbstick_resource_right: Vector2Resource = _thumbstick_resource_right as Vector2Resource
@onready var settings_resource: SettingsResource = _settings_resource as SettingsResource
@onready var target_transform_resource: TransformResource = _target_transform_resource as TransformResource
@onready var game_state_resource: StateResource = _game_state_resource as StateResource

@onready var camera_distance_default: float = camera_anchor.position.z
@onready var pitch_default: float = pitch_pivot.rotation.x
@onready var fov_tween: Tween


func _ready() -> void:
	Signals.scene_changed.connect(self._on_scene_changed)
	Signals.setting_updated.connect(_on_setting_updated)

	assert(thumbstick_resource_right != null, Errors.NULL_RESOURCE)
	assert(settings_resource != null, Errors.NULL_RESOURCE)
	assert(target_transform_resource != null, Errors.NULL_RESOURCE)
	assert(game_state_resource != null, Errors.NULL_RESOURCE)

	assert(yaw_pivot != null, Errors.NULL_NODE)
	assert(pitch_pivot != null, Errors.NULL_NODE)
	assert(raycast != null, Errors.NULL_NODE)
	assert(camera_anchor != null, Errors.NULL_NODE)
	assert(camera != null, Errors.NULL_NODE)
	assert(water_detector != null, Errors.NULL_NODE)

	camera.fov = float(Settings.SETTINGS.FIELD_OF_VIEW.VALUES[settings_resource.settings[Settings.FIELD_OF_VIEW]])


func _process(delta: float) -> void:
	global_position = target_transform_resource.value.origin

	if game_state_resource.current_state in [GameStates.GAMEPLAY, GameStates.DIALOGUE]:
		var rotation_speed_target: Vector2 = Vector2()
		var distance_speed_target: float = 0.0
		if Input.is_action_pressed(InputActions.CAMERA_ZOOM_TOGGLE):
			distance_speed_target = thumbstick_resource_right.value.y * camera_distance_speed_max
		else:
			rotation_speed_target = thumbstick_resource_right.value * camera_rotation_speed_max
			if Settings.SETTINGS.CAMERA_X_INVERTED.VALUES[settings_resource.settings[Settings.CAMERA_X_INVERTED]]:
				rotation_speed_target.x *= -1.0
			if Settings.SETTINGS.CAMERA_Y_INVERTED.VALUES[settings_resource.settings[Settings.CAMERA_Y_INVERTED]]:
				rotation_speed_target.y *= -1.0

		# Mouse wheel only generates 'released' events, not 'pressed' events.
		# https://github.com/godotengine/godot/issues/36322
		if Input.is_action_just_released(InputActions.CAMERA_ZOOM_IN):
			distance_speed_target = -camera_distance_speed_max
		elif Input.is_action_just_released(InputActions.CAMERA_ZOOM_OUT):
			distance_speed_target = camera_distance_speed_max

		camera_distance_speed = Lerp.delta_lerp(camera_distance_speed, distance_speed_target, camera_distance_lerp_weight, delta)
		camera_anchor.position.z = camera_anchor.position.z * (1.0 + camera_distance_speed * delta)
		camera_anchor.position.z = clamp(camera_anchor.position.z, camera_distance_min, camera_distance_max)

		camera_rotation_speed = Lerp.delta_lerp2(camera_rotation_speed, rotation_speed_target, camera_rotation_lerp_weight, delta)
		yaw_pivot.rotation.y -= camera_rotation_speed.x * delta
		pitch_pivot.rotation.x -= camera_rotation_speed.y * delta
		pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, -pitch_limit, pitch_limit)

	# Push camera towards the target if there is solid geometry in the way, helps to prevent clipping
	var camera_vector: Vector3 = (camera_anchor.global_position - global_position).normalized()
	var frustum: Array[Plane] = camera.get_frustum()
	var frustum_near: Plane = frustum[0]
	var frustum_sides: Array[Plane] = frustum.slice(2)

	var camera_distance_target: float = 0.0

	for i in range(len(frustum_sides)):
		# Need to calculate some points
		var frustum_near_vertex: Vector3 = frustum_sides[i].intersect_3(frustum_sides[(i + 1) % frustum_sides.size()], frustum_near)
		var frustum_vector: Vector3 = (global_position - frustum_near_vertex).project(camera_vector)
		var frustum_near_vertex_scaled: Vector3 = camera_push_frustum_scale * (frustum_near_vertex - camera.global_position) + camera.global_position
		var frustum_near_vertex_anchor: Vector3 = camera_anchor.global_position + (frustum_near_vertex_scaled - camera.global_position)

		# Raycast forwards
		raycast.look_at_from_position(frustum_near_vertex_scaled, frustum_near_vertex_scaled + frustum_vector)
		raycast.target_position = Vector3.FORWARD * frustum_vector.length()
		raycast.force_raycast_update()
		var collision_point_forward: Vector3 = raycast.get_collision_point() if raycast.is_colliding() else frustum_near_vertex_scaled + frustum_vector
		var collider: CollisionObject3D = raycast.get_collider() as CollisionObject3D
		if collider != null:
			raycast.add_exception(collider)

		# Raycast backwards
		raycast.look_at_from_position(collision_point_forward, frustum_near_vertex_anchor)
		raycast.target_position = Vector3.FORWARD * (frustum_near_vertex_anchor - collision_point_forward).length()
		raycast.force_raycast_update()
		var collision_point_backward: Vector3 = raycast.get_collision_point() if raycast.is_colliding() else frustum_near_vertex_anchor
		raycast.clear_exceptions()

		# Calculate camera position
		camera_distance_target = max(camera_distance_target, (collision_point_backward - frustum_near_vertex_anchor).length())

	# Actually set the camera push position
	var camera_push_weight = camera_push_weight_forwards if camera.position.z > -camera_distance_target else camera_push_weight_backwards
	camera.position.z = Lerp.delta_lerp(camera.position.z, -camera_distance_target, camera_push_weight, delta)

	# Look at target
	camera.look_at(target_transform_resource.value.origin)


func _on_scene_changed(_sender: Node) -> void:
	camera.position.z = 0.0
	camera_anchor.position.z = camera_distance_default
	pitch_pivot.rotation.x = pitch_default

	# Center camera behind player
	var yaw: float = target_transform_resource.value.basis.get_euler().y
	yaw_pivot.rotation.y = yaw


func _on_setting_updated(_sender: Node, key: StringName) -> void:
	if key == Settings.FIELD_OF_VIEW:
		if fov_tween != null:
			fov_tween.kill()
		fov_tween = create_tween()
		fov_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		fov_tween.set_trans(Tween.TRANS_QUINT)
		fov_tween.set_ease(Tween.EASE_OUT)
		fov_tween.tween_property(camera, "fov", float(Settings.SETTINGS.FIELD_OF_VIEW.VALUES[settings_resource.settings[Settings.FIELD_OF_VIEW]]), fov_change_tween_time)
