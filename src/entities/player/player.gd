# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name Player
extends CharacterBody3D

@export var _thumbstick_resource_left: Resource
@export var _input_vector_resource: Resource
@export var _game_state_resource: Resource
@export var _transform_resource: Resource
@export var _camera_transform_resource: Resource

var input_vector: Vector3
var water_collision_shapes: Array

@onready var raycast_container: Node3D = get_node("RaycastContainer") as Node3D
@onready var coyote_timer: Timer = get_node("CoyoteTimer") as Timer
@onready var jump_buffer_timer: Timer = get_node("JumpBufferTimer") as Timer

@onready var thumbstick_resource_left: Vector2Resource = _thumbstick_resource_left as Vector2Resource
@onready var input_vector_resource: Vector3Resource = _input_vector_resource as Vector3Resource
@onready var game_state_resource: StateResource = _game_state_resource as StateResource
@onready var transform_resource: TransformResource = _transform_resource as TransformResource
@onready var camera_transform_resource: TransformResource = _camera_transform_resource as TransformResource


func _ready() -> void:
	Signals.area_body_entered.connect(self._on_area_body_entered)
	Signals.area_body_exited.connect(self._on_area_body_exited)

	assert(thumbstick_resource_left != null, Errors.NULL_RESOURCE)
	assert(input_vector_resource != null, Errors.NULL_RESOURCE)
	assert(game_state_resource != null, Errors.NULL_RESOURCE)
	assert(transform_resource != null, Errors.NULL_RESOURCE)
	assert(camera_transform_resource != null, Errors.NULL_RESOURCE)
	assert(raycast_container != null, Errors.NULL_NODE)
	assert(coyote_timer != null, Errors.NULL_NODE)
	assert(jump_buffer_timer != null, Errors.NULL_NODE)

	assert(input_vector_resource.value == Vector3(), Errors.RESOURCE_BUSY)
	assert(transform_resource.value == Transform3D(), Errors.RESOURCE_BUSY)

	# Update tranform resource
	transform_resource.value = global_transform


func _process(_delta: float) -> void:
	# Update input vector according to thumbstick and camera position
	var camera_vector: Vector3 = camera_transform_resource.value.origin - global_transform.origin
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


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		input_vector_resource.value = Vector3()
		transform_resource.value = Transform3D()


func _on_area_body_entered(sender: Area3D, body: PhysicsBody3D) -> void:
	if body != self:
		return

	var collision_shape: CollisionShape3D = Utils.get_collision_shape_for_area(sender)
	assert(collision_shape != null, Errors.NULL_NODE)

	if str(sender.owner.name).begins_with("Water"):
		water_collision_shapes.append(collision_shape)


func _on_area_body_exited(sender: Area3D, body: PhysicsBody3D) -> void:
	if body != self:
		return

	var collision_shape: CollisionShape3D = Utils.get_collision_shape_for_area(sender)

	if collision_shape in water_collision_shapes:
		water_collision_shapes.erase(collision_shape)


func are_raycasts_colliding() -> bool:
	for _raycast in raycast_container.get_children():
		var raycast: RayCast3D = _raycast as RayCast3D
		if raycast.is_colliding():
			return true
	return false


func is_in_water() -> bool:
	return water_collision_shapes.size() > 0


func get_water_surface_height() -> float:
	if not is_in_water():
		return NAN

	var height: float = -INF
	for shape in water_collision_shapes:
		height = max(height, shape.global_transform.origin.y + shape.shape.size.y / 2.0)
	return height
