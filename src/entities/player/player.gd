# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name Player
extends RigidDynamicBody3D

@export var floor_max_angle: float = PI / 4.0
@export var floor_snap_length_max: float = 0.1
@export var floor_snap_length_min: float = 0.001
@export var _thumbstick_resource_left: Resource
@export var _input_vector_resource: Resource
@export var _game_state_resource: Resource
@export var _transform_resource: Resource
@export var _camera_transform_resource: Resource

var input_vector: Vector3
var force_vector: Vector3
var floor_snapping_enabled: bool
var _is_on_floor: bool
var bottom_point_height: float
var top_point_height: float
var floor_collisions: Array[KinematicCollision3D]

@onready var collision_shape: CollisionShape3D = get_node("CollisionShape3D") as CollisionShape3D
@onready var coyote_timer: Timer = get_node("CoyoteTimer") as Timer
@onready var jump_buffer_timer: Timer = get_node("JumpBufferTimer") as Timer
@onready var water_detector: WaterDetector = get_node("WaterDetector") as WaterDetector

@onready var thumbstick_resource_left: Vector2Resource = _thumbstick_resource_left as Vector2Resource
@onready var input_vector_resource: Vector3Resource = _input_vector_resource as Vector3Resource
@onready var game_state_resource: StateResource = _game_state_resource as StateResource
@onready var transform_resource: TransformResource = _transform_resource as TransformResource
@onready var camera_transform_resource: TransformResource = _camera_transform_resource as TransformResource


func _ready() -> void:
	assert(thumbstick_resource_left != null, Errors.NULL_RESOURCE)
	assert(input_vector_resource != null, Errors.NULL_RESOURCE)
	assert(game_state_resource != null, Errors.NULL_RESOURCE)
	assert(transform_resource != null, Errors.NULL_RESOURCE)
	assert(camera_transform_resource != null, Errors.NULL_RESOURCE)
	assert(collision_shape != null, Errors.NULL_RESOURCE)
	assert(coyote_timer != null, Errors.NULL_NODE)
	assert(jump_buffer_timer != null, Errors.NULL_NODE)
	assert(water_detector != null, Errors.NULL_NODE)

	assert(input_vector_resource.value == Vector3(), Errors.RESOURCE_BUSY)
	assert(transform_resource.value == Transform3D(), Errors.RESOURCE_BUSY)

	# Update tranform resource
	transform_resource.value = global_transform


func _process(_delta: float) -> void:
	# Update input vector according to thumbstick and camera position
	var camera_vector: Vector3 = camera_transform_resource.value.origin - global_position
	camera_vector.y = 0.0
	camera_vector = camera_vector.normalized()
	var forward_vector: Vector3 = camera_vector
	var right_vector: Vector3 = -camera_vector.cross(Vector3.UP)
	input_vector = right_vector * thumbstick_resource_left.value.x + forward_vector * thumbstick_resource_left.value.y

	if input_vector.length_squared() > 1.0:
		input_vector = input_vector.normalized()
	elif input_vector.is_equal_approx(Vector3.ZERO):
		input_vector = Vector3.ZERO

	input_vector_resource.value = input_vector

	# Update tranform resource
	transform_resource.value = global_transform

	# Perform interaction
	if Input.is_action_just_pressed(InputActions.INTERACT) and game_state_resource.current_state == GameStates.GAMEPLAY:
		Signals.emit_request_interaction(self)

	# Pause the game
	if Input.is_action_just_pressed(InputActions.PAUSE) and game_state_resource.current_state == GameStates.GAMEPLAY:
		Signals.emit_request_game_pause(self)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	state.apply_central_force(force_vector)

	# Floor snapping
	var shape: CapsuleShape3D = collision_shape.shape as CapsuleShape3D
	assert(shape != null, Errors.NULL_RESOURCE)
	bottom_point_height = collision_shape.global_position.y - shape.height / 2.0
	top_point_height = collision_shape.global_position.y + shape.height / 2.0

	_is_on_floor = false
	floor_collisions.clear()
	var floor_height: float = -INF
	var collision: KinematicCollision3D = KinematicCollision3D.new()
	test_move(global_transform, floor_snap_length_max * Vector3.DOWN, collision)
	for i in range(collision.get_collision_count()):
		if collision.get_position(i).y < global_position.y and collision.get_angle(i) <= floor_max_angle:
			floor_collisions.append(collision)
			floor_height = maxf(floor_height, collision.get_position(i).y)
	if not is_inf(floor_height):
		_is_on_floor = true
		if floor_snapping_enabled:
			var floor_distance: float = bottom_point_height - floor_height
			if floor_distance > floor_snap_length_min:
				state.set_transform(state.get_transform().translated(floor_distance * Vector3.DOWN))
				state.linear_velocity.y = 0.0


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		input_vector_resource.value = Vector3()
		transform_resource.value = Transform3D()


func is_on_floor() -> bool:
	return _is_on_floor
