class_name Player
extends CharacterBody3D

@export var thumbstickLeftPath := NodePath()
@onready var thumbstickLeft: Thumbstick = get_node(thumbstickLeftPath)
@export var thumbstickRightPath := NodePath()
@onready var thumbstickRight: Thumbstick = get_node(thumbstickRightPath)


func _ready() -> void:
	assert(thumbstickLeft != null)
	assert(thumbstickRight != null)
