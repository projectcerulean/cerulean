# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name Player
extends CharacterController

@export var thumbstick_resource_left: Vector2Resource
@export var input_vector_resource: Vector2Resource
@export var state_resource: StateResource
@export var game_state_resource: StateResource
@export var camera_transform_resource: TransformResource
@export var developer_mode_resource: BoolResource
@export_range(0.0, 1.0, 0.001) var double_jump_shape_cast_length_factor: float = 0.5
@export var double_jump_shape_cast_xz_scale: float = 0.95
@export var roll_min_speed: float = 12.0

var planar_input_vector: Vector2
var can_double_jump: bool

@onready var collision_shape: CollisionShape3D = get_node("CollisionShape3D") as CollisionShape3D
@onready var coyote_timer: Timer = get_node("CoyoteTimer") as Timer
@onready var jump_buffer_timer: Timer = get_node("JumpBufferTimer") as Timer
@onready var water_detector: WaterDetector = get_node("WaterDetector") as WaterDetector
@onready var state_machine: StateMachine = get_node("StateMachine") as StateMachine


func _enter_tree() -> void:
	assert(thumbstick_resource_left != null, Errors.NULL_RESOURCE)
	assert(input_vector_resource != null, Errors.NULL_RESOURCE)
	assert(state_resource != null, Errors.NULL_RESOURCE)
	assert(game_state_resource != null, Errors.NULL_RESOURCE)
	assert(camera_transform_resource != null, Errors.NULL_RESOURCE)
	assert(developer_mode_resource != null, Errors.NULL_RESOURCE)
	input_vector_resource.claim_ownership(self)


func _exit_tree() -> void:
	input_vector_resource.release_ownership(self)


func _ready() -> void:
	super._ready()

	assert(collision_shape != null, Errors.NULL_RESOURCE)
	assert(coyote_timer != null, Errors.NULL_NODE)
	assert(jump_buffer_timer != null, Errors.NULL_NODE)
	assert(water_detector != null, Errors.NULL_NODE)
	assert(state_machine != null, Errors.NULL_NODE)


func _process(_delta: float) -> void:
	if camera_transform_resource.is_owned() and thumbstick_resource_left.is_owned():
		# Update input vector according to thumbstick and camera position
		var camera_vector: Vector3 = global_position - camera_transform_resource.get_value().origin
		camera_vector.y = 0.0
		camera_vector = camera_vector.normalized()
		var camera_yaw_rads: float = camera_vector.signed_angle_to(Vector3.FORWARD, Vector3.UP)
		planar_input_vector = thumbstick_resource_left.get_value().rotated(camera_yaw_rads).limit_length()
		input_vector_resource.set_value(self, planar_input_vector)

		# Ghost mode, for easier development
		if (
			developer_mode_resource.is_owned()
			and developer_mode_resource.get_value()
			and input_vector_resource.get_value().is_zero_approx()
			and Input.is_action_pressed(InputActions.SWIM_UPWARDS)
			and Input.is_action_pressed(InputActions.SWIM_DOWNWARDS)
			and Input.is_action_pressed(InputActions.UI_DOWN)
			and Input.is_action_just_pressed(InputActions.INTERACT)
		):
			state_machine.transition_to_state(PlayerStates.GHOST)


	if game_state_resource.is_owned():
		# Perform interaction
		if Input.is_action_just_pressed(InputActions.INTERACT) and game_state_resource.get_current_state() == GameStates.GAMEPLAY:
			Signals.emit_request_interaction(self)

		# Pause the game
		if Input.is_action_just_pressed(InputActions.PAUSE) and game_state_resource.get_current_state() == GameStates.GAMEPLAY:
			Signals.emit_request_game_pause(self)


func on_bounce(bounce_normal: Vector3, bounce_min_speed: float, bounce_elasticity: float) -> void:
	super.on_bounce(bounce_normal, bounce_min_speed, bounce_elasticity)
	can_double_jump = true
	if state_resource.get_current_state() != PlayerStates.DIVE:
		if Input.is_action_pressed(InputActions.GLIDE):
			Signals.emit_request_camera_shake_impulse(self, 0.16)
			state_machine.transition_to_state(PlayerStates.BOUNCE)
		else:
			Signals.emit_request_camera_shake_impulse(self, 0.14)
			state_machine.transition_to_state(PlayerStates.FALL)
