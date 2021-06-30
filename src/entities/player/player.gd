class_name Player
extends CharacterBody3D

@export var camera_path := NodePath()
@export var thumbstick_left_path := NodePath()

@export var move_acceleration: float = 150.0
@export var move_friction_coefficient: float = 15.0
@export var turn_weight: float = 0.5
@export var jump_speed: float = 10.0
@export var jump_acceleration: float = 5.0
@export var air_control_modifier: float = 0.08

@onready var camera: Camera3D = get_node(camera_path)
@onready var thumbstick_left: Thumbstick = get_node(thumbstick_left_path)
@onready var raycast: RayCast3D = get_node("RayCast3D")
@onready var coyote_timer: Timer = get_node("CoyoteTimer")
@onready var jump_buffer_timer: Timer = get_node("JumpBufferTimer")
@onready var mesh_instance: MeshInstance3D = get_node("MeshInstance3D")

var direction: Vector3 = Vector3.FORWARD
var move_acceleration_air: float = move_acceleration * air_control_modifier
var move_friction_coefficient_air: float = move_friction_coefficient * air_control_modifier

func _ready() -> void:
	assert(camera != null)
	assert(thumbstick_left != null)
	assert(raycast != null)
	assert(coyote_timer != null)
	assert(jump_buffer_timer != null)
	assert(mesh_instance != null)


func _process(_delta) -> void:
	assert(direction.y == 0)
	mesh_instance.look_at(mesh_instance.get_global_transform().origin + direction)
