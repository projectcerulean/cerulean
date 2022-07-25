extends AnimatableBody3D

@export var angular_velocity: float = 0.5

@onready var platform_position1: Position3D = get_node("PlatformPosition") as Position3D
@onready var platform_position2: Position3D = get_node("PlatformPosition2") as Position3D
@onready var platform_position3: Position3D = get_node("PlatformPosition3") as Position3D
@onready var platform1: AnimatableBody3D = get_node("PlatformPosition/Platform") as AnimatableBody3D
@onready var platform2: AnimatableBody3D = get_node("PlatformPosition2/Platform2") as AnimatableBody3D
@onready var platform3: AnimatableBody3D = get_node("PlatformPosition3/Platform3") as AnimatableBody3D


func _ready() -> void:
	assert(platform_position1 != null, Errors.NULL_NODE)
	assert(platform_position2 != null, Errors.NULL_NODE)
	assert(platform_position3 != null, Errors.NULL_NODE)
	assert(platform1 != null, Errors.NULL_NODE)
	assert(platform2 != null, Errors.NULL_NODE)
	assert(platform3 != null, Errors.NULL_NODE)


func _physics_process(delta: float) -> void:
	global_rotate(global_transform.basis.z, angular_velocity * delta)
	platform1.global_position = platform_position1.global_position
	platform2.global_position = platform_position2.global_position
	platform3.global_position = platform_position3.global_position
