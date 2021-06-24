class_name Player
extends CharacterBody3D

@export var thumbstick_left_path := NodePath()
@onready var thumbstick_left: Thumbstick = get_node(thumbstick_left_path)
@export var thumbstick_right_path := NodePath()
@onready var thumbstick_right: Thumbstick = get_node(thumbstick_right_path)


func _ready() -> void:
	assert(thumbstick_left != null)
	assert(thumbstick_right != null)
