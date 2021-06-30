class_name Player
extends CharacterBody3D

@export var camera_path := NodePath()
@export var thumbstick_left_path := NodePath()

@export var move_acceleration: float = 150.0
@export var move_friction_coefficient: float = 15.0
@export var turn_weight: float = 0.5
@export var jump_speed: float = 10.0
@export var jump_acceleration: float = 10.0
@export var air_control_modifier: float = 0.08

@export var camera_anchor_y_smooth_grounded: float = 0.1
@export var camera_anchor_y_smooth_air: float = 0.08

@export var y_min: float = -100.0

@onready var camera: Camera3D = get_node(camera_path)
@onready var thumbstick_left: Thumbstick = get_node(thumbstick_left_path)
@onready var camera_anchor: Position3D = get_node("CameraAnchor")
@onready var state_machine: StateMachine = get_node("StateMachine")
@onready var raycast: RayCast3D = get_node("RayCast3D")
@onready var coyote_timer: Timer = get_node("CoyoteTimer")
@onready var jump_buffer_timer: Timer = get_node("JumpBufferTimer")
@onready var mesh_instance: MeshInstance3D = get_node("MeshInstance3D")

var direction: Vector3 = Vector3.FORWARD
var move_acceleration_air: float = move_acceleration * air_control_modifier
var move_friction_coefficient_air: float = move_friction_coefficient * air_control_modifier


func _ready() -> void:
	assert(camera != null)
	assert(camera_anchor != null)
	assert(thumbstick_left != null)
	assert(raycast != null)
	assert(coyote_timer != null)
	assert(jump_buffer_timer != null)
	assert(mesh_instance != null)


func _process(_delta) -> void:
	assert(direction.y == 0)
	mesh_instance.look_at(mesh_instance.get_global_transform().origin + direction)

	# The camera anchor is a Position3D which follows a bit after the player for a smoother feel.
	# It has a top level transform, i.e. its position is not directly inherited from the player.
	camera_anchor.position.x = position.x
	camera_anchor.position.z = position.z
	if state_machine.state.name == "Run" or state_machine.state.name == "Idle":
		camera_anchor.position.y = lerp(camera_anchor.position.y, position.y, camera_anchor_y_smooth_grounded)
	else:
		camera_anchor.position.y = lerp(camera_anchor.position.y, position.y, camera_anchor_y_smooth_air)

	# Reload scene when falling off the map
	if get_global_transform().origin.y < y_min:
		get_tree().reload_current_scene()
