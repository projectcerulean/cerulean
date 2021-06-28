class_name Player
extends CharacterBody3D

@export var camera_path := NodePath()
@export var thumbstick_left_path := NodePath()

@export var move_acceleration: float = 150.0
@export var move_friction_coefficient: float = 15.0
@export var move_acceleration_air: float = move_acceleration / 7.0
@export var move_friction_coefficient_air: float = move_friction_coefficient / 7.0
@export var jump_speed: float = 10.0
@export var jump_acceleration: float = 5.0

@onready var camera: Camera3D = get_node(camera_path)
@onready var thumbstick_left: Thumbstick = get_node(thumbstick_left_path)
@onready var raycast: RayCast3D = get_node("RayCast3D")
@onready var coyote_timer: Timer = get_node("CoyoteTimer")


func _ready() -> void:
	assert(camera != null)
	assert(thumbstick_left != null)
	assert(raycast != null)
	assert(coyote_timer != null)
