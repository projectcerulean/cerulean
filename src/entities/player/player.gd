# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name Player
extends PhysicsEntity

@export var _thumbstick_resource_left: Resource
@export var _input_vector_resource: Resource
@export var _state_resource: Resource
@export var _game_state_resource: Resource
@export var _camera_transform_resource: Resource

var input_vector: Vector3

@onready var collision_shape: CollisionShape3D = get_node("CollisionShape3D") as CollisionShape3D
@onready var coyote_timer: Timer = get_node("CoyoteTimer") as Timer
@onready var jump_buffer_timer: Timer = get_node("JumpBufferTimer") as Timer
@onready var water_detector: WaterDetector = get_node("WaterDetector") as WaterDetector
@onready var state_machine: Node = get_node("StateMachine") as Node

@onready var thumbstick_resource_left: Vector2Resource = _thumbstick_resource_left as Vector2Resource
@onready var input_vector_resource: Vector3Resource = _input_vector_resource as Vector3Resource
@onready var state_resource: StateResource = _state_resource as StateResource
@onready var game_state_resource: StateResource = _game_state_resource as StateResource
@onready var camera_transform_resource: TransformResource = _camera_transform_resource as TransformResource


func _ready() -> void:
	super._ready()

	assert(thumbstick_resource_left != null, Errors.NULL_RESOURCE)
	assert(input_vector_resource != null, Errors.NULL_RESOURCE)
	assert(state_resource != null, Errors.NULL_RESOURCE)
	assert(game_state_resource != null, Errors.NULL_RESOURCE)
	assert(camera_transform_resource != null, Errors.NULL_RESOURCE)
	assert(collision_shape != null, Errors.NULL_RESOURCE)
	assert(coyote_timer != null, Errors.NULL_NODE)
	assert(jump_buffer_timer != null, Errors.NULL_NODE)
	assert(water_detector != null, Errors.NULL_NODE)
	assert(state_machine != null, Errors.NULL_NODE)

	assert(input_vector_resource.value == Vector3(), Errors.RESOURCE_BUSY)


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

	# Perform interaction
	if Input.is_action_just_pressed(InputActions.INTERACT) and game_state_resource.current_state == GameStates.GAMEPLAY:
		Signals.emit_request_interaction(self)

	# Pause the game
	if Input.is_action_just_pressed(InputActions.PAUSE) and game_state_resource.current_state == GameStates.GAMEPLAY:
		Signals.emit_request_game_pause(self)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		input_vector_resource.value = Vector3()


func _on_request_body_bounce(sender: NodePath, body: NodePath, target_velocity: Vector3, elasticy: float) -> void:
	super._on_request_body_bounce(sender, body, target_velocity, elasticy)
	if body == get_path():
		Signals.emit_request_screen_shake(self, 0.1, 30.0, 0.15)
		if Input.is_action_pressed(InputActions.JUMP) and state_resource.current_state != PlayerStates.DIVE:
			Signals.emit_request_state_change(self, state_machine.get_path(), PlayerStates.BOUNCE)
