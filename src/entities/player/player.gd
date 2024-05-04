# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name Player
extends CharacterController

@export var _thumbstick_resource_left: Resource
@export var _input_vector_resource: Resource
@export var _state_resource: Resource
@export var _game_state_resource: Resource
@export var _camera_transform_resource: Resource
@export_range(0.0, 1.0, 0.001) var double_jump_shape_cast_length_factor: float = 0.5
@export var double_jump_shape_cast_xz_scale: float = 0.95

var planar_input_vector: Vector2
var can_double_jump: bool

@onready var collision_shape: CollisionShape3D = get_node("CollisionShape3D") as CollisionShape3D
@onready var coyote_timer: Timer = get_node("CoyoteTimer") as Timer
@onready var jump_buffer_timer: Timer = get_node("JumpBufferTimer") as Timer
@onready var water_detector: WaterDetector = get_node("WaterDetector") as WaterDetector
@onready var state_machine: StateMachine = get_node("StateMachine") as StateMachine

@onready var thumbstick_resource_left: Vector2Resource = _thumbstick_resource_left as Vector2Resource
@onready var input_vector_resource: Vector2Resource = _input_vector_resource as Vector2Resource
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

	assert(input_vector_resource.value == Vector2(), Errors.RESOURCE_BUSY)


func _process(_delta: float) -> void:
	# Update input vector according to thumbstick and camera position
	var camera_vector: Vector3 = global_position - camera_transform_resource.value.origin
	camera_vector.y = 0.0
	camera_vector = camera_vector.normalized()
	var camera_yaw_rads: float = camera_vector.signed_angle_to(Vector3.FORWARD, Vector3.UP)
	planar_input_vector = thumbstick_resource_left.value.rotated(camera_yaw_rads).limit_length()
	input_vector_resource.value = planar_input_vector

	# Perform interaction
	if Input.is_action_just_pressed(InputActions.INTERACT) and game_state_resource.current_state == GameStates.GAMEPLAY:
		Signals.emit_request_interaction(self)

	# Pause the game
	if Input.is_action_just_pressed(InputActions.PAUSE) and game_state_resource.current_state == GameStates.GAMEPLAY:
		Signals.emit_request_game_pause(self)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		input_vector_resource.value = Vector2()


func on_bounce(bounce_normal: Vector3, bounce_min_speed: float, bounce_elasticity: float):
	super.on_bounce(bounce_normal, bounce_min_speed, bounce_elasticity)
	Signals.emit_request_screen_shake(self, 0.1, 30.0, 0.15)
	can_double_jump = true
	if state_resource.current_state != PlayerStates.DIVE:
		if Input.is_action_pressed(InputActions.GLIDE):
			state_machine.transition_to_state(PlayerStates.BOUNCE)
		else:
			state_machine.transition_to_state(PlayerStates.FALL)
