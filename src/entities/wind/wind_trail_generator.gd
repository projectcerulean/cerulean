extends Node3D

@export var angle: float = 0.0
@export var n_trails: int = 10

var i_trail: int = 0
var wind_trails: Array[Node3D] = []

@onready var collision_shape: CollisionShape3D = get_node("CollisionShape3D") as CollisionShape3D
@onready var shape: BoxShape3D = collision_shape.shape as BoxShape3D
@onready var shape_size: Vector3 = shape.size


func _ready() -> void:
	wind_trails.resize(n_trails)


func _on_spawn_timer_timeout() -> void:
	if is_instance_valid(wind_trails[i_trail]):
		wind_trails[i_trail].queue_free()
	wind_trails[i_trail] = preload("res://src/entities/wind/wind_trail.tscn").instantiate()
	add_child(wind_trails[i_trail])
	wind_trails[i_trail].position = Vector3(randf(), randf(), randf()) * shape_size - shape_size / 2.0
	wind_trails[i_trail].rotate_y(angle)
	i_trail = (i_trail + 1) % n_trails
