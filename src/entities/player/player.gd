class_name Player
extends CharacterBody3D

@export var thumbstick_left_path := NodePath()
@export var thumbstick_right_path := NodePath()
@export var move_acceleration: float = 150.0
@export var move_friction_coefficient: float = 15.0
@export var move_acceleration_air: float = move_acceleration / 7.0
@export var move_friction_coefficient_air: float = move_friction_coefficient / 7.0
@export var jump_speed: float = 10.0
@export var jump_acceleration: float = 5.0
@export var gravity: float = 20.0

@onready var thumbstick_left: Thumbstick = get_node(thumbstick_left_path)
@onready var thumbstick_right: Thumbstick = get_node(thumbstick_right_path)
@onready var raycast: RayCast3D = get_node("RayCast3D")


func _ready() -> void:
	assert(thumbstick_left != null)
	assert(thumbstick_right != null)
